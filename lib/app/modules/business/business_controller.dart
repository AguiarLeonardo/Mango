import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BusinessDetailController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Recibimos el ID del negocio al inicializar el controlador
  final String businessId;

  var isLoading = true.obs;
  var availablePacks = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  BusinessDetailController({required this.businessId});

  @override
  void onInit() {
    super.onInit();
    fetchBusinessPacks();
  }

  Future<void> fetchBusinessPacks() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await _supabase
          .from('packs')
          .select()
          .eq('business_id', businessId)
          .eq('status', 'available');

      availablePacks.value = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      errorMessage.value = "Error al cargar ofertas: $e";
      print("❌ Error en BusinessDetailController: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
