import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/pack_model.dart';

class BusinessHistoryController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  var isLoading = true.obs;

  // Lista 1: Resumen de packs que ya terminaron o se agotaron
  var finishedPacks = <PackModel>[].obs;

  // Lista 2: Tickets individuales (quién compró qué)
  var salesTickets = <Map<String, dynamic>>[].obs; 

  @override
  void onInit() {
    super.onInit();
    fetchBusinessHistory();
  }

  Future<void> fetchBusinessHistory() async {
    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;
      
      if (userId == null) {
        print("❌ Error: No hay usuario autenticado.");
        return;
      }

      final String nowIso = DateTime.now().toUtc().toIso8601String();

      // ---------------------------------------------------------
      // 1. OBTENER PACKS FINALIZADOS (Funciona perfecto)
      // ---------------------------------------------------------
      final packsResponse = await _supabase
          .from('packs')
          .select('*')
          .eq('business_id', userId)
          .or('quantity_available.lte.0, pickup_end.lt.$nowIso, is_active.eq.false')
          .order('pickup_end', ascending: false);

      finishedPacks.assignAll(
        (packsResponse as List).map((json) => PackModel.fromJson(json)).toList()
      );
      print("✅ Packs finalizados cargados: ${finishedPacks.length}");

      // ---------------------------------------------------------
      // 2. OBTENER TICKETS DE VENTAS (Historial Completo)
      // ---------------------------------------------------------
      try {
        // Intentamos traer todo, incluyendo los datos del usuario.
        // NOTA: Si tu tabla de usuarios se llama 'profiles', cambia 'users' por 'profiles'.
        final ordersResponse = await _supabase
            .from('orders')
            .select('''
              *,
              packs(id, title, price, pickup_start, pickup_end, quantity_total),
              users(id, first_name, last_name, avatar_url)
            ''')
            .eq('business_id', userId)
            .order('created_at', ascending: false);

        print("✅ TICKETS ENCONTRADOS: ${(ordersResponse as List).length}");
        salesTickets.assignAll(List<Map<String, dynamic>>.from(ordersResponse));
        
      } catch (orderError) {
        print("⚠️ Advertencia: Falló la consulta con 'users'. Error: $orderError");
        
        // PLAN B: Si la unión con 'users' falla, traemos los tickets igual pero sin los datos del cliente
        // para que por lo menos veas las ventas en pantalla.
        print("🔄 Intentando cargar tickets sin datos de usuario (Plan B)...");
        final fallbackResponse = await _supabase
            .from('orders')
            .select('*, packs(id, title, price)')
            .eq('business_id', userId)
            .order('created_at', ascending: false);
            
        print("✅ TICKETS ENCONTRADOS (PLAN B): ${(fallbackResponse as List).length}");
        salesTickets.assignAll(List<Map<String, dynamic>>.from(fallbackResponse));
      }

    } catch (e) {
      print("❌ Error general obteniendo historial de empresa: $e");
      Get.snackbar(
        "Error", 
        "No se pudo cargar el historial.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}