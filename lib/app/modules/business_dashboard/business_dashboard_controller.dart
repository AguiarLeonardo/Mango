import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BusinessDashboardController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ─── Estado de Navegación ───
  // 0: Mis Packs, 1: Pedidos / Entregas
  final currentIndex = 0.obs;

  // ─── Estado de carga y Perfil ───
  final isLoading = false.obs;
  final businessName = ''.obs;
  final businessCategory = ''.obs;
  final businessImageUrl = Rxn<String>();

  /// ID del negocio autenticado.
  String get myBusinessId => _supabase.auth.currentUser?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchBusinessProfile();
  }

  /// Cambia la pestaña activa del BottomNavigationBar.
  void changeTab(int index) {
    currentIndex.value = index;
  }

  /// Carga el perfil del negocio autenticado desde Supabase.
  Future<void> fetchBusinessProfile() async {
    try {
      isLoading.value = true;
      if (myBusinessId.isEmpty) return;

      final data = await _supabase
          .from('businesses')
          .select()
          .eq('id', myBusinessId)
          .maybeSingle();

      if (data != null) {
        businessName.value =
            data['commercial_name']?.toString() ?? 'Mi Negocio';
        businessCategory.value = data['category']?.toString() ?? '';
        businessImageUrl.value = data['rif_image_url']?.toString();
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "No se pudo cargar el perfil del negocio",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
