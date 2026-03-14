import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
import { JWT } from "npm:google-auth-library@9.6.3";

// Definir headers CORS para permitir peticiones desde cualquier origen (si es llamado vía API)
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface NotificationRequest {
  user_id: string;
  title: string;
  body: string;
  route?: string; // Opcional, por defecto "/orders"
}

// Inicializar el cliente JWT fuera del handler para cachear el auth token si es posible
let jwtClient: JWT | null = null;
let cachedAccessToken: string | null = null;
let tokenExpiryTime: number = 0;

async function getAccessToken(): Promise<string> {
  // Retornar token cacheado si aún es válido (margen de 5 minutos)
  if (cachedAccessToken && Date.now() < tokenExpiryTime - 5 * 60 * 1000) {
    return cachedAccessToken;
  }

  const serviceAccountRaw = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
  if (!serviceAccountRaw) {
    throw new Error("Missing FIREBASE_SERVICE_ACCOUNT environment variable");
  }

  const serviceAccount = JSON.parse(serviceAccountRaw);

  if (!jwtClient) {
    jwtClient = new JWT({
      email: serviceAccount.client_email,
      key: serviceAccount.private_key,
      scopes: ["https://www.googleapis.com/auth/cloud-platform"],
    });
  }

  const tokens = await jwtClient.getAccessToken();
  if (!tokens.token) {
    throw new Error("Failed to generate access token");
  }

  cachedAccessToken = tokens.token;
  // Google tokens usually expire in 1 hour
  tokenExpiryTime = Date.now() + 60 * 60 * 1000; 

  return cachedAccessToken;
}

serve(async (req) => {
  // Manejo de preflight request (CORS)
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. Extraer el payload del Webhook/Client
    const bodyText = await req.text();
    if (!bodyText) {
      throw new Error("Empty request body");
    }
    
    const payload: NotificationRequest = JSON.parse(bodyText);
    const { user_id, title, body, route = "/orders" } = payload;

    if (!user_id || !title || !body) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: user_id, title, or body" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 2. Instanciar cliente Supabase Service Role para saltar RLS y buscar el token
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error("Missing Supabase environment variables");
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // 3. Obtener el fcm_token del usuario
    const { data: userData, error: userError } = await supabase
      .from("users")
      .select("fcm_token")
      .eq("id", user_id)
      .single();

    if (userError || !userData?.fcm_token) {
      console.warn(`No FCM token found for user ${user_id}`);
      return new Response(
        JSON.stringify({ message: "User has no FCM token. Notification skipped." }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const fcmToken = userData.fcm_token;

    // 4. Obtener OAuth2 Token via Google Auth Library 
    const accessToken = await getAccessToken();

    // 5. Extraer el Project ID del Service Account para armar la URL v1
    const serviceAccountRaw = Deno.env.get("FIREBASE_SERVICE_ACCOUNT")!;
    const projectId = JSON.parse(serviceAccountRaw).project_id;
    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

    // 6. Configurar el payload FCM v1
    const fcmPayload = {
      message: {
        token: fcmToken,
        notification: {
          title: title,
          body: body,
        },
        data: {
          route: route,
        },
      },
    };

    // 7. Enviar petición a FCM v1
    const fcmResponse = await fetch(fcmUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${accessToken}`,
      },
      body: JSON.stringify(fcmPayload),
    });

    const fcmResult = await fcmResponse.json();

    if (!fcmResponse.ok) {
      console.error("FCM API Error:", fcmResult);
      return new Response(
        JSON.stringify({ error: "FCM API Error", details: fcmResult }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Éxito
    return new Response(
      JSON.stringify({ success: true, messageId: fcmResult.name }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (error) {
    console.error("Unhandled error:", error);
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : "Internal Server Error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
