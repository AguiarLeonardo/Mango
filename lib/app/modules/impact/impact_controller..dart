import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImpactController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  var packsRescued = 0.obs;
  var co2Avoided = 0.0.obs;
  var moneySaved = 0.0.obs;
  var savedMeals = 0.obs; // ✅ NUEVO: Contador directo de comidas salvadas

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

      // ✅ 1. NUEVA LÓGICA: Consultamos solo el COUNT de comidas salvadas (optimizada)
      final countResponse = await _supabase
          .from('orders')
          .select('id')
          .eq('user_id', user.id)
          .eq('status', 'completed')
          .count(CountOption.exact); // 👈 Pide a Supabase el número exacto, sin traer filas

      final int completedOrdersCount = countResponse.count;
      
      packsRescued.value = completedOrdersCount;
      savedMeals.value = completedOrdersCount; // Variable específica de comidas salvadas

      // 🌿 FÓRMULA CO2: Cada pack salva en promedio 2.5 kg de CO2
      co2Avoided.value = packsRescued.value * 2.5;

      // 💰 FÓRMULA DINERO (simplificada y rápida usando el promedio)
      // Si a futuro se requiere la precisión del centavo, se justificaría descargar todas las filas, 
      // pero para fines de impacto, el promedio estadístico es estándar en la industria.
      moneySaved.value = packsRescued.value * 4.50;

    } catch (e) {
      debugPrint("Error cargando impacto de usuario: $e");
      packsRescued.value = 0;
      savedMeals.value = 0;
      co2Avoided.value = 0.0;
      moneySaved.value = 0.0;
    } finally {
      isLoading.value = false;
    }
  }
}