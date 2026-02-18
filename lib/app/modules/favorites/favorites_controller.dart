import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  var isLoading = false.obs;

  // Listas separadas
  var favoriteBusinesses = <Map<String, dynamic>>[].obs;
  var favoritePacks = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  // 🔥 Cargar favoritos (negocios + packs)
  Future<void> loadFavorites() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      isLoading.value = true;

      final response = await _supabase
          .from('favorites')
          .select('business_id, pack_id, businesses(*), packs(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final data = List<Map<String, dynamic>>.from(response);

      favoriteBusinesses.assignAll(
        data.where((fav) => fav['business_id'] != null).toList(),
      );

      favoritePacks.assignAll(
        data.where((fav) => fav['pack_id'] != null).toList(),
      );

    } catch (e) {
      print("Error cargando favoritos: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // =============================
  // ❤️ BUSINESS
  // =============================

  bool isBusinessFavorite(String businessId) {
    return favoriteBusinesses
        .any((fav) => fav['business_id'] == businessId);
  }

  Future<void> toggleBusinessFavorite(String businessId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      Get.snackbar("Aviso", "Inicia sesión para guardar favoritos");
      return;
    }

    try {
      if (isBusinessFavorite(businessId)) {
        await _supabase.from('favorites').delete().match({
          'user_id': userId,
          'business_id': businessId
        });

        favoriteBusinesses.removeWhere(
            (fav) => fav['business_id'] == businessId);
      } else {
        await _supabase.from('favorites').insert({
          'user_id': userId,
          'business_id': businessId,
        });

        await loadFavorites();
      }
    } catch (e) {
      Get.snackbar("Error", "No se pudo actualizar favoritos");
    }
  }

  // =============================
  // ❤️ PACKS
  // =============================

  bool isPackFavorite(String packId) {
    return favoritePacks.any((fav) => fav['pack_id'] == packId);
  }

  Future<void> togglePackFavorite(String packId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      Get.snackbar("Aviso", "Inicia sesión para guardar favoritos");
      return;
    }

    try {
      if (isPackFavorite(packId)) {
        await _supabase.from('favorites').delete().match({
          'user_id': userId,
          'pack_id': packId
        });

        favoritePacks
            .removeWhere((fav) => fav['pack_id'] == packId);
      } else {
        await _supabase.from('favorites').insert({
          'user_id': userId,
          'pack_id': packId,
        });

        await loadFavorites();
      }
    } catch (e) {
      Get.snackbar("Error", "No se pudo actualizar favoritos");
    }
  }
}
