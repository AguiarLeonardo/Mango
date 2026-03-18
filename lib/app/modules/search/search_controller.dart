import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/location_service.dart';

class SearchMyController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final TextEditingController searchInput = TextEditingController();
  var isLoading = false.obs;

  // ✅ Lista de resultados de Negocios
  var searchResults = <Map<String, dynamic>>[].obs;

  // ✅ Servicios
  final LocationService locationService = Get.find<LocationService>();

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
  }

  void setCategory(String category) {
    selectedCategory.value =
        (selectedCategory.value == category) ? '' : category;
  }

  Future<void> performSearch() async {
    // ✅ ESTADO INICIAL: Si no hay texto ni categoría seleccionada, vaciamos la lista
    if (searchText.value.trim().isEmpty && selectedCategory.value.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isLoading.value = true;

      // Obtener el estado del usuario desde LocationService o perfil
      final userState = locationService.currentStateName.value;

      // Construir query base con filtro de estado
      var query = _supabase.from('businesses').select('*');

      // Aplicar regla de negocio: Miranda + Distrito Capital juntos
      if (userState.isNotEmpty) {
        final normalizedState = userState.trim().toLowerCase();
        if (normalizedState == 'miranda' || normalizedState == 'distrito capital') {
          query = query.inFilter('state', ['Miranda', 'Distrito Capital']);
        } else {
          query = query.eq('state', userState);
        }
      }

      // Filtrar por texto (nombre del negocio)
      if (searchText.value.isNotEmpty) {
        query = query.ilike('commercial_name', '%${searchText.value}%');
      }

      // Filtrar por categoría
      if (selectedCategory.value.isNotEmpty) {
        query = query.eq('category', selectedCategory.value);
      }

      final response = await query.order('commercial_name', ascending: true);
      searchResults.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("❌ Error en búsqueda de negocios: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
