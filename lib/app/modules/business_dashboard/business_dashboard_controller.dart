import 'package:flutter/foundation.dart';
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
  final businessImageUrl = Rxn<String>(); // 👈 Aquí guardaremos el logo_url

  // ✅ ─── ESTADO DE IMPACTO ───
  var packsRescued = 0.obs;
  var co2Avoided = 0.0.obs;
  var moneySaved = 0.0.obs;
  var savedMeals = 0.obs; // ✅ NUEVO: Contador directo de comidas salvadas

  /// ID del negocio autenticado.
  String get myBusinessId => _supabase.auth.currentUser?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchBusinessProfile();
    loadBusinessImpact(); // 👈 Cargamos el impacto en cuanto abre la pantalla
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
        
        // ✅ AHORA DESCARGAMOS EL LOGO EN VEZ DEL RIF
        businessImageUrl.value = data['logo_url']?.toString(); 
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

// ✅ ─── CARGAR IMPACTO DEL NEGOCIO ───
  Future<void> loadBusinessImpact() async {
    try {
      if (myBusinessId.isEmpty) return;

      // ✅ NUEVA LÓGICA: Consultamos solo el COUNT de comidas salvadas (optimizada)
      final countResponse = await _supabase
          .from('orders')
          .select('id')
          .eq('business_id', myBusinessId)
          .eq('status', 'completed')
          .count(CountOption.exact); // 👈 Pide a Supabase el número exacto, sin traer filas

      final int completedOrdersCount = countResponse.count;
      
      packsRescued.value = completedOrdersCount;
      savedMeals.value = completedOrdersCount; // Variable específica de comidas salvadas

      co2Avoided.value = packsRescued.value * 2.5;
      moneySaved.value = packsRescued.value * 4.50; // Promedio estadístico en impacto
      
    } catch (e) {
      debugPrint("Error cargando impacto del dashboard: $e");
    }
  }
}