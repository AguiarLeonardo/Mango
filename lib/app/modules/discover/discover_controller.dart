import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Importante para la BD

import '../../data/models/pack_model.dart';
import '../../data/models/business_model.dart';

class DiscoverController extends GetxController {
  final RxBool isLoading = true.obs;
  final SupabaseClient _supabase = Supabase.instance.client;

  final RxList<PackModel> featuredPacks = <PackModel>[].obs;
  final RxList<BusinessModel> recommendedBusinesses = <BusinessModel>[].obs;

  // ✅ VARIABLE PARA GUARDAR EL NOMBRE DEL USUARIO
  final RxString userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDiscoverData();
  }

  Future<void> fetchDiscoverData() async {
    try {
      isLoading.value = true;

      // --- 1. OBTENER EL NOMBRE DEL USUARIO (first_name) ---
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        final userResponse = await _supabase
            .from('users')
            .select('first_name')
            .eq('id', userId)
            .maybeSingle();

        if (userResponse != null && userResponse['first_name'] != null) {
          userName.value = userResponse['first_name'];
        }
      }

      // --- 2. OBTENER PACKS REALES DE SUPABASE ---
      final packsResponse = await _supabase
          .from('packs')
          .select('*, businesses(commercial_name)')
          .limit(10); // Límite para no saturar la pantalla

      featuredPacks.assignAll(
          packsResponse.map((json) => PackModel.fromJson(json)).toList());

      // --- 3. OBTENER NEGOCIOS REALES DE SUPABASE ---
      final businessesResponse =
          await _supabase.from('businesses').select('*').limit(5);

      recommendedBusinesses.assignAll(businessesResponse
          .map((json) => BusinessModel(
                commercialName: json['commercial_name'] ?? 'Negocio',
                category: json['category'],
                city: json['city'],
                address: json['address'] ?? '',
                // Puedes mapear los demás campos si los necesitas
              ))
          .toList());
    } catch (e) {
      Get.snackbar(
          'Aviso', 'Hubo un problema de conexión o estás en modo de prueba.');
      print("Error en DiscoverController: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await fetchDiscoverData();
  }
}
