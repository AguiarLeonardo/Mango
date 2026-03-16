import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/location_service.dart';
import '../../data/repositories/store_repository.dart';

class SearchMyController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final TextEditingController searchInput = TextEditingController();
  var isLoading = false.obs;

  // ✅ Lista de resultados de Negocios
  var searchResults = <Map<String, dynamic>>[].obs;

  // ✅ Servicios y Repositorios
  final LocationService locationService = Get.find<LocationService>();
  final StoreRepository _storeRepository = StoreRepository();

  // ✅ Radio de búsqueda dinámico
  RxDouble searchRadius = 5.0.obs;

  // Observables para filtros
  var searchText = ''.obs;
  var selectedCategory = ''.obs;

  // ✅ Categorías para usarlas en el Bottom Sheet
  final List<String> categories = [
    'Restaurante',
    'Panadería',
    'Frutería',
    'Market',
    'Postres'
  ];

  @override
  void onInit() {
    super.onInit();
    // Escucha cambios en texto o categoría
    debounce(searchText, (_) => performSearch(),
        time: const Duration(milliseconds: 500));
    ever(selectedCategory, (_) => performSearch());

    // ❌ Eliminamos performSearch() inicial para no cargar nada al abrir la pantalla
  }

  void setCategory(String category) {
    selectedCategory.value =
        (selectedCategory.value == category) ? '' : category;
  }

  Future<void> performSearch() async {
    // ✅ ESTADO INICIAL: Si no hay texto ni categoría seleccionada, vaciamos la lista y detenemos la ejecución
    if (searchText.value.trim().isEmpty && selectedCategory.value.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isLoading.value = true;

      // 1. Obtener coordenadas actuales
      final lat = locationService.latitude.value;
      final lon = locationService.longitude.value;
      final state = locationService.currentStateName.value;

      List<Map<String, dynamic>> data = [];

      // 2. Si tenemos ubicación, buscar por cercanía con el radio actual
      if (lat != 0.0 && lon != 0.0) {
        data = await _storeRepository.getNearbyStores(
          lat: lat,
          lon: lon,
          state: state,
          radiusKm: searchRadius.value,
        );

        // 3. Filtrar localmente por texto y categoría
        if (searchText.value.isNotEmpty) {
          final queryStr = searchText.value.toLowerCase();
          data = data.where((store) {
            final name = (store['commercial_name'] ?? store['name'] ?? '').toString().toLowerCase();
            return name.contains(queryStr);
          }).toList();
        }

        if (selectedCategory.value.isNotEmpty) {
          data = data.where((store) => store['category'] == selectedCategory.value).toList();
        }
      } else {
        // Fallback: Si no hay permisos o GPS, usar búsqueda tradicional (sin filtro de distancia)
        var query = _supabase.from('businesses').select('*');

        if (searchText.value.isNotEmpty) {
          query = query.ilike('commercial_name', '%${searchText.value}%');
        }

        if (selectedCategory.value.isNotEmpty) {
          query = query.eq('category', selectedCategory.value);
        }

        final response = await query.order('commercial_name', ascending: true);
        data = List<Map<String, dynamic>>.from(response);
      }

      searchResults.value = data;
    } catch (e) {
      print("❌ Error en búsqueda de negocios: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void updateRadius(double newRadius) {
    searchRadius.value = newRadius;
    performSearch();
  }
}
