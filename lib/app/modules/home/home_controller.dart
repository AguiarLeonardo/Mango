import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

// Si tienes un archivo de rutas, impórtalo. Si no, usa strings directos.
// import '../../../routes/app_routes.dart'; 

class HomeController extends GetxController {
  // --- VARIABLES REACTIVAS ---
  var currentIndex = 0.obs;
  
  // Cliente de Supabase
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- GETTERS ---
  // Obtener el email del usuario actual de forma segura
  String get userEmail => _supabase.auth.currentUser?.email ?? "Usuario Invitado";

  // --- MÉTODOS ---

  // Cambiar de pestaña en el BottomNavigationBar
  void changeTab(int index) {
    currentIndex.value = index;
  }

  // Lógica para Cerrar Sesión
  Future<void> signOut() async {
    try {
      // 1. Cerrar sesión en Supabase
      await _supabase.auth.signOut();
      
      // 2. Redirigir al inicio (Login/Start)
      // Ajusta '/start' si tu ruta se llama diferente en app_pages.dart
      Get.offAllNamed('/start'); 
      
    } catch (e) {
      Get.snackbar(
        "Error", 
        "No se pudo cerrar sesión: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}