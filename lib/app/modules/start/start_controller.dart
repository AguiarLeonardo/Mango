import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes/app_routes.dart';

class StartController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _handleStart();
  }

  Future<void> _handleStart() async {
    // 1. Esperamos un poco para dar tiempo a:
    //    a) Que se vea el logo (UX).
    //    b) Que Supabase lea el disco/navegador.
    await Future.delayed(const Duration(milliseconds: 1500));

    final currentUri = Uri.base; // URL del navegador
    final fragment = currentUri.fragment; // Lo que va después del #

    print("🔎 Start Check - URL: $currentUri");

    // --- ESCENARIO A: RECUPERACIÓN WEB (Futuro Implicit Flow) ---
    // Detecta: localhost:3000/#access_token=...&type=recovery
    if (fragment.contains("type=recovery") &&
        fragment.contains("access_token")) {
      print("✅ DETECTADO: Link de recuperación (Implicit).");
      // Damos un respiro extra para que el SDK procese el token del hash
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateBasedOnSession(isRecovery: true);
      return;
    }

    // --- ESCENARIO B: LINK PKCE (El que da error ahora, pero por si acaso) ---
    // Detecta: localhost:3000/?code=...
    if (currentUri.queryParameters.containsKey('code')) {
      print("⚠️ DETECTADO: Código PKCE. Intentando procesar...");
      // Aquí Supabase intenta canjear el código automáticamente.
      // Si falla (como ahora), simplemente no habrá sesión y pasaremos al else.
    }

    // --- ESCENARIO C: FLUJO NORMAL (Desarrollo actual) ---
    // Si no hay links raros, o si fallaron, verificamos si ya estás logueado.
    _navigateBasedOnSession(isRecovery: false);
  }

  void _navigateBasedOnSession({required bool isRecovery}) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      if (isRecovery) {
        print("🚀 Sesión válida + Recuperación -> UpdatePassword");
        Get.offAllNamed(Routes.updatePassword);
      } else {
        print("🚀 Sesión válida -> shell");
        Get.offAllNamed(Routes.shell);
      }
    } else {
      print("👋 Sin sesión -> Welcome");
      Get.offAllNamed(Routes.welcome);
    }
  }
}
