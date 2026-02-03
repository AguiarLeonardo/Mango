import 'package:get/get.dart';
import 'package:mango/data/services/supabase_service.dart';
import 'package:mango/data/models/pack_model.dart';

class DiscoverController extends GetxController {
  var isLoading = true.obs;
  var packs = <PackModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPacks();
  }

  Future<void> loadPacks() async {
    try {
      isLoading.value = true;
      final data = await SupabaseService().getAvailablePacks();
      packs.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los packs');
    } finally {
      isLoading.value = false;
    }
  }
}
