import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchMyController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final TextEditingController searchInput = TextEditingController();
  var isLoading = false.obs;
  
  // Lista de resultados (ahora de Packs con datos de Negocio incluidos)
  var searchResults = <Map<String, dynamic>>[].obs;
  
  // Observables para filtros
  var searchText = ''.obs; 
  var selectedCategory = ''.obs; 
  var maxPrice = 500.0.obs; // Ejemplo: Rango hasta 500 Bs.

  @override
  void onInit() {
    super.onInit();
    // Escucha cambios en texto, categoría o precio para disparar la búsqueda
    debounce(searchText, (_) => performSearch(), time: const Duration(milliseconds: 500));
    ever(selectedCategory, (_) => performSearch());
    ever(maxPrice, (_) => performSearch());
  }

  void setCategory(String category) {
    selectedCategory.value = (selectedCategory.value == category) ? '' : category;
  }

  Future<void> performSearch() async {
    try {
      isLoading.value = true;

      // 1. Construimos la query base sobre PACKS y traemos los datos del NEGOCIO
      // Usamos inner join (businesses!inner) para que si filtramos por negocio, funcione.
      var query = _supabase.from('packs').select('''
        *,
        businesses!inner (
          commercial_name,
          address,
          category,
          state,
          city
        )
      ''');

      // 2. Filtro de Texto (Busca en el título del pack o nombre del negocio)
      if (searchText.value.isNotEmpty) {
        // Filtramos donde el título del pack O el nombre del negocio coincidan
        query = query.or('title.ilike.%${searchText.value}%, businesses.commercial_name.ilike.%${searchText.value}%');
      }

      // 3. Filtro de Categoría (del negocio o del pack)
      if (selectedCategory.value.isNotEmpty) {
        query = query.eq('category', selectedCategory.value);
      }

      // 4. Filtro de Precio
      query = query.lte('price', maxPrice.value);

      // 5. Solo mostrar packs disponibles
      query = query.eq('status', 'available').gt('quantity_available', 0);

      final data = await query.order('created_at', ascending: false);
      searchResults.value = List<Map<String, dynamic>>.from(data);

    } catch (e) {
      print("❌ Error en búsqueda avanzada: $e");
    } finally {
      isLoading.value = false;
    }
  }
}