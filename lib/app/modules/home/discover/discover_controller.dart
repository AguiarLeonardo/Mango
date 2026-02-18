import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Usamos la librería directa
import '../../data/models/pack_model.dart'; // Asegúrate que la ruta al modelo sea correcta

class DiscoverController extends GetxController {
  // Cliente directo, igual que en PacksController
  final SupabaseClient _supabase = Supabase.instance.client;

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

      // Lógica trasladada desde SupabaseService directamente aquí
      final List<dynamic> response = await _supabase
          .from('packs')
          .select('*, businesses(*)') // Traemos el pack y los datos del negocio
          .eq('status', 'available')
          .gt('quantity_available', 0);

      // Mapeo de datos (igual que hacías en el servicio)
      final List<PackModel> parsedPacks = response.map((packData) {
        // Manejo seguro del negocio anidado
        final businessData = packData['businesses'];
        final business = (businessData is Map) ? businessData : {};

        // Creamos un mapa combinado para el modelo
        final Map<String, dynamic> combinedMap = {
          ...packData,
          'business_name': business['name'] ?? 'Negocio',
          'business_address': business['address'] ?? '',
          // Añade otros campos si tu PackModel los requiere
        };

        return PackModel.fromMap(combinedMap);
      }).toList();

      packs.assignAll(parsedPacks);

    } catch (e) {
      print("Error cargando packs: $e");
      Get.snackbar('Error', 'No se pudieron cargar los packs');
    } finally {
      isLoading.value = false;
    }
  }
}