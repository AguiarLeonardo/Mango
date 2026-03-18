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

      print('🔍 [BusinessDetail] Buscando packs para businessId: $businessId');

      // Traemos todos los packs del negocio.
      // El filtrado de activos/vigentes se hace en la vista (BusinessDetailScreen).
      final data = await _supabase
          .from('packs')
          .select()
          .eq('business_id', businessId);

      availablePacks.value = List<Map<String, dynamic>>.from(data);
      print('✅ [BusinessDetail] Packs recibidos: ${availablePacks.length}');
    } catch (e) {
      errorMessage.value = "Error al cargar ofertas.";
      print('❌ Error fetching packs: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

