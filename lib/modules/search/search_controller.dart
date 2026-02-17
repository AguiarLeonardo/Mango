import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchMyController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Variables
  final TextEditingController searchInput = TextEditingController();
  var isLoading = false.obs;
  var searchResults = <Map<String, dynamic>>[].obs;
  
  // NUEVO: Variable observable para detectar lo que escribes
  var searchText = ''.obs; 

  // Filtros
  var selectedFilter = ''.obs; 

  @override
  void onInit() {
    super.onInit();
    
    // CORRECCIÓN: Ahora vigilamos 'searchText', no el controller
    debounce(
      searchText, 
      (_) => searchBusinesses(), 
      time: const Duration(milliseconds: 500),
    );
  }

  Future<void> searchBusinesses() async {
    // Usamos el valor de la variable observable
    String query = searchText.value.trim();

    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isLoading.value = true;
      print("🔍 Buscando: $query"); // Para ver en la consola

      final data = await _supabase
          .from('businesses')
          .select()
          .ilike('commercial_name', '%$query%'); 

      print("✅ Resultados: ${data.length}"); 
      searchResults.value = List<Map<String, dynamic>>.from(data);

    } catch (e) {
      print("❌ Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    if (selectedFilter.value == filter) {
      selectedFilter.value = '';
    } else {
      selectedFilter.value = filter;
    }
  }
  
  @override
  void onClose() {
    searchInput.dispose();
    super.onClose();
  }
}