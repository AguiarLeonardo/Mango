import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchMyController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final TextEditingController searchInput = TextEditingController();
  var isLoading = false.obs;

  // ✅ Lista de resultados de Negocios
  var searchResults = <Map<String, dynamic>>[].obs;

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

      // 1. Consulta directa a la tabla BUSINESSES
      var query = _supabase.from('businesses').select('*');

      // 2. Filtro de Texto (Busca por el nombre comercial del negocio)
      if (searchText.value.isNotEmpty) {
        query = query.ilike('commercial_name', '%${searchText.value}%');
      }

      // 3. Filtro de Categoría
      if (selectedCategory.value.isNotEmpty) {
        query = query.eq('category', selectedCategory.value);
      }

      // Ordenamos alfabéticamente
      final data = await query.order('commercial_name', ascending: true);
      searchResults.value = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print("❌ Error en búsqueda de negocios: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
