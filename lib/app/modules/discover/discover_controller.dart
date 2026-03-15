import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/pack_model.dart';
import '../../data/models/business_model.dart';

class DiscoverController extends GetxController {
  final RxBool isLoading = true.obs;
  final SupabaseClient _supabase = Supabase.instance.client;

  final RxList<PackModel> featuredPacks = <PackModel>[].obs;
  final RxList<BusinessModel> recommendedBusinesses = <BusinessModel>[].obs;

  // ✅ VARIABLES PARA EL USUARIO / EMPRESA
  final RxString userName = ''.obs;
  final RxString avatarUrl = ''.obs; // 👈 Guarda la foto de perfil o el logo de la empresa

  @override
  void onInit() {
    super.onInit();
    fetchDiscoverData();
  }

  Future<void> fetchDiscoverData() async {
    try {
      isLoading.value = true;

      // --- 1. OBTENER DATOS DEL USUARIO O EMPRESA (Nombre y Foto/Logo) ---
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        
        // A) Intentamos buscar si es un USUARIO NORMAL
        final userResponse = await _supabase
            .from('users')
            .select('first_name, avatar_url')
            .eq('id', userId)
            .maybeSingle();

        if (userResponse != null) {
          // Es un usuario: asignamos nombre y avatar
          userName.value = userResponse['first_name'] ?? 'Usuario';
          avatarUrl.value = userResponse['avatar_url'] ?? ''; 
        } else {
          // B) Si no es usuario, buscamos si es una EMPRESA
          final businessResponse = await _supabase
              .from('businesses')
              .select('commercial_name, logo_url') // ✅ PEDIMOS EL LOGO AQUÍ
              .eq('id', userId)
              .maybeSingle();

          if (businessResponse != null) {
            // Es una empresa: asignamos nombre comercial y logo
            userName.value = businessResponse['commercial_name'] ?? 'Negocio';
            avatarUrl.value = businessResponse['logo_url'] ?? ''; // Reutilizamos la variable de la UI
          }
        }
      }

      // --- 2. OBTENER PACKS REALES DE SUPABASE ---
      final packsResponse = await _supabase
          .from('packs')
          .select('*, businesses(commercial_name)')
          .limit(10);

      featuredPacks.assignAll(
          packsResponse.map((json) => PackModel.fromJson(json)).toList());

      // --- 3. OBTENER NEGOCIOS REALES DE SUPABASE ---
      final businessesResponse =
          await _supabase.from('businesses').select('*').limit(5);

      recommendedBusinesses.assignAll(businessesResponse
          .map((json) => BusinessModel(
                id: json['id'],
                commercialName: json['commercial_name'] ?? 'Negocio',
                category: json['category'],
                city: json['city'],
                address: json['address'] ?? '',
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