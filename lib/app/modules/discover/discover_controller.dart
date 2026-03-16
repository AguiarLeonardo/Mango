import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/pack_model.dart';
import '../../data/models/business_model.dart';
import '../../core/services/location_service.dart';
import '../../data/repositories/store_repository.dart';

class DiscoverController extends GetxController {
  final RxBool isLoading = true.obs;
  final SupabaseClient _supabase = Supabase.instance.client;

  final RxList<PackModel> featuredPacks = <PackModel>[].obs;
  final RxList<BusinessModel> recommendedBusinesses = <BusinessModel>[].obs;

  // ✅ VARIABLES PARA EL USUARIO / EMPRESA
  final RxString userName = ''.obs;
  final RxString avatarUrl = ''.obs; 
  final RxBool isBusiness = false.obs;

  // 🌱 VARIABLES DE IMPACTO (NUEVO)
  final RxInt packsRescued = 0.obs;
  final RxDouble co2Avoided = 0.0.obs;

  // ✅ SERVICIOS Y REPOSITORIOS (Locales Cercanos)
  final LocationService locationService = Get.find<LocationService>();
  final StoreRepository _storeRepository = StoreRepository();

  final RxList<Map<String, dynamic>> nearbyStores = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingNearby = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDiscoverData();
    
    // Escuchar si la latitud cambia para volver a buscar locales
    ever(locationService.latitude, (_) {
      if (locationService.latitude.value != 0.0) {
        fetchNearbyStores();
      }
    });

    fetchNearbyStores();
  }

  Future<void> fetchNearbyStores() async {
    try {
      isLoadingNearby.value = true;
      final lat = locationService.latitude.value;
      final lon = locationService.longitude.value;
      final state = locationService.currentStateName.value;

      if (lat != 0.0 && lon != 0.0) {
        final result = await _storeRepository.getNearbyStores(
          lat: lat,
          lon: lon,
          state: state,
          radiusKm: 5.0,
        );
        nearbyStores.assignAll(result);
      } else {
        nearbyStores.clear();
      }
    } catch (e) {
      print("Error obteniendo locales cercanos: $e");
      nearbyStores.clear();
    } finally {
      isLoadingNearby.value = false;
    }
  }

  Future<void> fetchDiscoverData() async {
    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;

      // --- 1. OBTENER DATOS DEL USUARIO O EMPRESA ---
      if (userId != null) {
        final businessResponse = await _supabase
            .from('businesses')
            .select('commercial_name, logo_url')
            .eq('id', userId)
            .maybeSingle();

        if (businessResponse != null) {
          isBusiness.value = true; 
          userName.value = businessResponse['commercial_name'] ?? 'Negocio';
          avatarUrl.value = businessResponse['logo_url'] ?? ''; 
        } else {
          final userResponse = await _supabase
              .from('users')
              .select('first_name, avatar_url')
              .eq('id', userId)
              .maybeSingle();

          if (userResponse != null) {
            isBusiness.value = false; 
            userName.value = userResponse['first_name'] ?? 'Usuario';
            avatarUrl.value = userResponse['avatar_url'] ?? '';
          }
        }
        
        // 🌿 CARGAMOS EL IMPACTO DEL USUARIO O NEGOCIO
        await loadImpactData(userId);
      }

      // --- 2. OBTENER PACKS REALES DE SUPABASE ---
      final packsResponse = await _supabase
          .from('packs')
          .select('*, businesses(commercial_name)')
          .eq('is_active', true) 
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
      Get.snackbar('Aviso', 'Hubo un problema de conexión o estás en modo de prueba.');
      print("Error en DiscoverController: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 🌿 NUEVA FUNCIÓN QUE CALCULA EL IMPACTO PARA EL HOMESCREEN
  Future<void> loadImpactData(String userId) async {
    try {
      final String searchColumn = isBusiness.value ? 'business_id' : 'user_id';
      
      final response = await _supabase
          .from('orders')
          .select('id')
          .eq(searchColumn, userId)
          .eq('status', 'completed'); // Solo cuenta las completadas

      if (response != null) {
        final List orders = response as List;
        packsRescued.value = orders.length;
        co2Avoided.value = packsRescued.value * 2.5;
      }
    } catch (e) {
      print("Error cargando impacto en Discover: $e");
    }
  }

  Future<void> refreshData() async {
    await fetchDiscoverData();
    await fetchNearbyStores();
  }
}