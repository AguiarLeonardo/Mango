import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdersController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Lista reactiva de órdenes
  final myOrders = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) return;

      // Hacemos una consulta RELACIONAL:
      // Traemos la orden + datos del Pack + datos del Business
      final response = await _supabase
          .from('orders')
          .select('*, packs(title, price, image_url, pickup_start, pickup_end), businesses(commercial_name)')
          .eq('user_id', userId) // Solo mis órdenes
          .order('created_at', ascending: false);

      myOrders.value = List<Map<String, dynamic>>.from(response);

    } catch (e) {
      Get.snackbar("Error", "No se pudieron cargar las órdenes: $e");
    } finally {
      isLoading.value = false;
    }
  }
}