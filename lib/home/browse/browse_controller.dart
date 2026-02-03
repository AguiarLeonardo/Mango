import 'package:get/get.dart';
import 'package:mango/data/models/pack_model.dart';
import 'package:mango/data/services/supabase_service.dart';

class BrowseController extends GetxController {
  var allPacks = <PackModel>[].obs;
  var filteredPacks = <PackModel>[].obs;
  var isLoading = true.obs;

  var searchQuery = ''.obs;
  var selectedCategory = ''.obs;
  var categories = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPacks();
  }

  Future<void> loadPacks() async {
    try {
      isLoading.value = true;
      final packs = await SupabaseService().getAllAvailablePacks();
      allPacks.assignAll(packs);
      filteredPacks.assignAll(packs);

      // Extraer categorías únicas
      final uniqueCategories = packs
          .map((pack) => pack.category ?? '')
          .toSet()
          .where((c) => c.isNotEmpty)
          .toList();
      categories.assignAll(uniqueCategories);
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los packs');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    final query = searchQuery.value.toLowerCase();
    final category = selectedCategory.value;

    final results = allPacks.where((pack) {
      final matchesSearch = pack.title.toLowerCase().contains(query);
      final matchesCategory = category.isEmpty || pack.category == category;
      return matchesSearch && matchesCategory;
    }).toList();

    filteredPacks.assignAll(results);
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void onCategorySelected(String category) {
    if (selectedCategory.value == category) {
      selectedCategory.value = '';
    } else {
      selectedCategory.value = category;
    }
    applyFilters();
  }
}
