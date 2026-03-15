import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class ShellController extends GetxController {
  // 🔹 ÍNDICE DE NAVEGACIÓN
  var currentIndex = 0.obs;

  // 🔹 NOMBRE DE USUARIO / EMPRESA
  var userName = 'Cargando...'.obs;

  // 🟢 NUEVA VARIABLE: Nos dirá si es negocio o usuario
  var isBusiness = false.obs;

  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    _fetchUserName();
  }

  // 🔹 FUNCIÓN: Cambiar pestaña
  void changeIndex(int index) {
    currentIndex.value = index;
  }

  // 🔹 FUNCIÓN: Busca el nombre en users o businesses
  Future<void> _fetchUserName() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      userName.value = 'Usuario';
      return;
    }

    try {
      // 1. Intentamos buscar si es un USUARIO
      final userData = await _supabase
          .from('users')
          .select('first_name')
          .eq('id', userId)
          .maybeSingle();

      if (userData != null) {
        isBusiness.value = false; // 🟢 Es un usuario
        String fetchedName = userData['first_name'] ?? 'Usuario';
        userName.value = fetchedName.trim().isEmpty ? 'Usuario' : fetchedName;
        return;
      }

      // 2. Si no, buscamos si es una EMPRESA
      final businessData = await _supabase
          .from('businesses')
          .select('commercial_name')
          .eq('id', userId)
          .maybeSingle();

      if (businessData != null && businessData['commercial_name'] != null) {
        isBusiness.value = true; // 🟢 Es una empresa
        userName.value = businessData['commercial_name'];
      } else {
        userName.value = 'Usuario';
      }
    } catch (e) {
      debugPrint("Error obteniendo nombre: $e");
      userName.value = 'Usuario';
    }
  }

  // 🔹 FUNCIÓN: Cerrar sesión
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      Get.offAllNamed(
        '/start',
      ); // ✅ Asegúrate de que esta ruta lleve a tu pantalla de inicio/login
    } catch (e) {
      Get.snackbar(
        "Error",
        "No se pudo cerrar sesión: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
