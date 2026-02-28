import 'package:flutter/material.dart'; // <-- Agregamos Material para los colores del SnackBar
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdersController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  var isLoading = true.obs;
  var ordersList = <Map<String, dynamic>>[].obs;
  var isBusinessMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkUserRole();
  }

  Future<void> checkUserRole() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      final data = await _supabase
          .from('businesses')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      isBusinessMode.value = (data != null);
      fetchOrders();
    }
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      dynamic response;

      if (isBusinessMode.value) {
        response = await _supabase
            .from('orders')
            .select('*, packs(title, image_url, price)')
            .eq('business_id', userId)
            .order('created_at', ascending: false);
      } else {
        // ✅ Aseguramos traer también los IDs de negocio y pack por si acaso
        response = await _supabase
            .from('orders')
            .select('*, packs(id, title, image_url, price, businesses(id, commercial_name))')
            .eq('user_id', userId)
            .order('created_at', ascending: false);
      }

      if (response != null) {
        ordersList.value = List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      print("Error cargando órdenes: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ NUEVA FUNCIÓN: ENVIAR RESEÑA A SUPABASE
  Future<void> submitReview({
    required String businessId,
    required String packId,
    required int rating,
    required String comment,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Insertamos los datos en la tabla 'ratings' que hizo tu compañera
      await _supabase.from('ratings').insert({
        'user_id': userId,
        'business_id': businessId,
        'pack_id': packId,
        'rating': rating,
        'comment': comment,
      });

      Get.back(); // Cierra la ventanita emergente (BottomSheet)
      
      Get.snackbar(
        "¡Gracias por tu reseña! ⭐",
        "Tu opinión ayuda a otros a salvar comida.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print("Error al enviar reseña: $e");
      Get.snackbar(
        "Error", 
        "No se pudo enviar la reseña. Intenta de nuevo.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}