import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../routes/app_routes.dart'; 
import 'package:flutter/foundation.dart'; 

class LoginController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- CAMBIO: Ahora este controlador maneja ambos casos ---
  final emailOrUserController = TextEditingController();
  final passwordController = TextEditingController();

  // Variables reactivas
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;
  final rememberMe = false.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login() async {
    // 1. Validar campos vacíos
    if (emailOrUserController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        "Datos incompletos", 
        "Por favor ingresa tu usuario/correo y contraseña",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      
      String inputLogin = emailOrUserController.text.trim();
      String finalEmail = inputLogin;

      // 2. LÓGICA DE USUARIO vs EMAIL
      // Si NO parece un correo, asumimos que es un nombre de usuario
      if (!GetUtils.isEmail(inputLogin)) {
        
        // Buscamos el correo asociado a ese username en la tabla 'users'
        final userData = await _supabase
            .from('users')
            .select('email')
            .eq('username', inputLogin)
            .maybeSingle(); 
        
        if (userData == null) {
          throw "El usuario '$inputLogin' no existe.";
        }
        
        // Si encontramos el usuario, usamos su email para el login
        finalEmail = userData['email'];
      }

      // 3. Intentar iniciar sesión en Supabase (Siempre requiere Email)
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: finalEmail,
        password: passwordController.text,
      );

      // 4. Si el usuario no es nulo, el login fue EXITOSO
      if (res.user != null) {
        Get.snackbar(
          "¡Bienvenido!", 
          "Inicio de sesión exitoso",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        await Future.delayed(const Duration(seconds: 1));
        
        Get.offAllNamed(Routes.home); 
      }

    } catch (e) {
      String msg = "Error al iniciar sesión.";
      String errorStr = e.toString();

      // Mensajes de error amigables
      if (errorStr.contains("Invalid login") || errorStr.contains("400")) {
        msg = "Credenciales incorrectas.";
      } else if (errorStr.contains("El usuario")) {
        // Mantiene el error personalizado que lanzamos arriba
        msg = errorStr; 
      } else {
        msg = errorStr;
      }

      Get.snackbar(
        "Error", 
        msg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Navegar al registro si no tiene cuenta
  void goToRegister() {
    Get.toNamed(Routes.registerUser);
  }

  // Función para recuperar contraseña
  Future<void> sendResetPassword(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      Get.snackbar("Error", "Escribe un correo válido para recuperar.", 
        backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: kIsWeb ? null : 'io.mango.app://login-callback', 
      );

      Get.back(); // Cierra carga
      Get.back(); // Cierra diálogo

      Get.snackbar("¡Listo!", "Revisa tu correo. Si no aparece, busca en Spam.",
          backgroundColor: Colors.green, colorText: Colors.white, duration: const Duration(seconds: 5));

    } catch (e) {
      Get.back(); 
      Get.snackbar("Error", "No se pudo enviar: ${e.toString()}",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}