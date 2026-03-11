import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImpactController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  var packsRescued = 0.obs;
  var co2Avoided = 0.0.obs; // ✅ NUEVO: Contador de CO2
  var moneySaved = 0.0.obs; // ✅ NUEVO: Contador de dinero ahorrado

  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserImpact();
  }

  Future<void> loadUserImpact() async {
    try {
      isLoading.value = true;
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // 1. Buscamos las reservas completadas (Contador principal)
      final response = await _supabase
          .from('orders')
          .select('id')
          .eq('user_id', user.id)
          .neq('status', 'pending');

      if (response != null) {
        final List orders = response as List;
        packsRescued.value = orders.length;
        
        // 🌿 FÓRMULA CO2: Cada pack salva en promedio 2.5 kg de CO2
        co2Avoided.value = packsRescued.value * 2.5;

        // 💰 FÓRMULA DINERO: Intentamos buscar el precio exacto en la base de datos
        try {
          final detailedResponse = await _supabase
              .from('orders')
              .select('id, packs(price, original_price)')
              .eq('user_id', user.id)
              .neq('status', 'pending');
              
          double totalSaved = 0.0;
          for (var order in detailedResponse) {
            final pack = order['packs'];
            if (pack != null) {
              double original = double.tryParse(pack['original_price'].toString()) ?? 0.0;
              double price = double.tryParse(pack['price'].toString()) ?? 0.0;
              if (original > price) {
                totalSaved += (original - price); // Suma la diferencia
              }
            }
          }
          
          // Si totalSaved es 0 (porque no encontró datos), usamos un promedio estimado de $4.50 de ahorro por pack
          moneySaved.value = totalSaved > 0 ? totalSaved : (packsRescued.value * 4.50);

        } catch (e) {
          // PLAN B: Si no hay conexión directa entre tablas, usa el promedio de $4.50
          moneySaved.value = packsRescued.value * 4.50; 
        }
      }
    } catch (e) {
      print("Error cargando impacto: $e");
      packsRescued.value = 0;
      co2Avoided.value = 0.0;
      moneySaved.value = 0.0;
    } finally {
      isLoading.value = false;
    }
  }
}