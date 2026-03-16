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

      // Buscamos todas sus ventas completadas
      final response = await _supabase
          .from('orders')
          .select('id, packs(price, original_price)')
          .eq('business_id', myBusinessId)
          .neq('status', 'pending');

      if (response != null) {
        final List orders = response as List;
        packsRescued.value = orders.length;
        co2Avoided.value = packsRescued.value * 2.5;

        double totalSaved = 0.0;
        for (var order in orders) {
          final pack = order['packs'];
          if (pack != null) {
            double original = double.tryParse(pack['original_price'].toString()) ?? 0.0;
            double price = double.tryParse(pack['price'].toString()) ?? 0.0;
            if (original > price) totalSaved += (original - price); 
          }
        }
        moneySaved.value = totalSaved > 0 ? totalSaved : (packsRescued.value * 4.50);
      }
    } catch (e) {
      print("Error cargando impacto del dashboard: $e");
    }
  }
}