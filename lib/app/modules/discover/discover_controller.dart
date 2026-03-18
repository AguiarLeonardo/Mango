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

  // 🌱 VARIABLES DE IMPACTO
  final RxInt packsRescued = 0.obs;
  final RxDouble co2Avoided = 0.0.obs;

  // ✅ SERVICIOS Y REPOSITORIOS (Locales por Estado)
  final LocationService locationService = Get.find<LocationService>();
  final StoreRepository _storeRepository = StoreRepository();

  final RxList<Map<String, dynamic>> stateStores = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingStores = true.obs;

  // Estado del usuario (se obtiene del perfil o GPS)
  final RxString userState = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDiscoverData();
    
    // Escuchar cuando se detecte el estado por GPS para cargar locales
    ever(locationService.currentStateName, (_) {
      if (locationService.currentStateName.value.isNotEmpty && userState.value.isEmpty) {
        userState.value = locationService.currentStateName.value;
        fetchStoresByState();
      }
    });

    _loadUserState();
  }

  /// Carga el estado del usuario desde su perfil en Supabase.
  /// Si no tiene estado guardado, usa el del GPS (LocationService).
  Future<void> _loadUserState() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Intentar obtener estado del perfil del usuario
      final userData = await _supabase
          .from('users')
          .select('state')
          .eq('id', userId)
          .maybeSingle();

      if (userData != null && userData['state'] != null && (userData['state'] as String).trim().isNotEmpty) {
        userState.value = userData['state'];
        fetchStoresByState();
        return;
      }

      // Intentar obtener estado del perfil de empresa
      final bizData = await _supabase
          .from('businesses')
          .select('state')
          .eq('id', userId)
          .maybeSingle();

      if (bizData != null && bizData['state'] != null && (bizData['state'] as String).trim().isNotEmpty) {
        userState.value = bizData['state'];
        fetchStoresByState();
        return;
      }

      // Fallback: usar el estado del GPS si ya está disponible
      if (locationService.currentStateName.value.isNotEmpty) {
        userState.value = locationService.currentStateName.value;
        fetchStoresByState();
      }
    } catch (e) {
      print("Error cargando estado del usuario: $e");
      // Fallback al GPS
      if (locationService.currentStateName.value.isNotEmpty) {
        userState.value = locationService.currentStateName.value;
        fetchStoresByState();
      }
    }
  }

  /// Busca locales filtrados por el estado del usuario.
  Future<void> fetchStoresByState() async {
    try {
      isLoadingStores.value = true;
      final state = userState.value;

      if (state.isNotEmpty) {
        final result = await _storeRepository.getStoresByState(
          userState: state,
        );
        stateStores.assignAll(result);
      } else {
        stateStores.clear();
      }
    } catch (e) {
      print("Error obteniendo locales por estado: $e");
      stateStores.clear();
    } finally {
      isLoadingStores.value = false;
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

      // ✅ OBTENEMOS LA HORA ACTUAL EN UTC PARA COMPARARLA CON SUPABASE
      final String nowIso = DateTime.now().toUtc().toIso8601String();

      // --- 2. OBTENER PACKS REALES DE SUPABASE ---
      final packsResponse = await _supabase
          .from('packs')
          .select('*, businesses(commercial_name)')
          .eq('is_active', true) // Solo los activos
          .gt('quantity_available', 0) // 👈 Solo si queda al menos 1
          .gte('pickup_end', nowIso) // 👈 Solo si la hora final NO ha pasado
          .limit(10);

      // 🔍 DEBUG: Packs que llegaron de Supabase (ya filtrados por la query)
      print('📦 [Discover] Packs recibidos de Supabase: ${packsResponse.length}');

      featuredPacks.assignAll(
          packsResponse.map((json) => PackModel.fromJson(json)).toList());

      print('✅ [Discover] Packs asignados a featuredPacks: ${featuredPacks.length}');

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

  // 🌿 FUNCIÓN QUE CALCULA EL IMPACTO PARA EL HOMESCREEN
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
    await fetchStoresByState();
  }
}