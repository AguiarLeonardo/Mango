import 'package:get/get.dart';
import 'package:mango/data/models/pack_model.dart';
import 'package:mango/data/services/supabase_service.dart';

class BrowseController extends GetxController {
  var isLoading = true.obs;
  var packs = <PackModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAllPacks();
  }

  Future<void> loadAllPacks() async {
    try {
      isLoading.value = true;
      final all = await SupabaseService().getAllAvailablePacks();
      packs.assignAll(all);
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar el contenido');
    } finally {
      isLoading.value = false;
    }
  }
}
