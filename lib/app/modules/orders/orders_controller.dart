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
            .select(
                '*, packs(id, title, image_url, price, businesses(id, commercial_name))')
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

  // ✅ VALIDAR ENTREGA DEL PACK (US 1)
  /// Valida y completa la entrega de un pedido mediante código o QR.
  Future<void> validateOrderCode(String code) async {
    try {
      isLoading.value = true;
      final myBusinessId = _supabase.auth.currentUser?.id;

      if (myBusinessId == null) {
        Get.snackbar("Error", "Sesión no válida");
        return;
      }

      final response = await _supabase.rpc('fulfill_order', params: {
        'p_business_id': myBusinessId,
        'p_code': code,
      });

      if (response['success'] == true) {
        Get.snackbar(
          "¡Éxito! ✅",
          "Pack entregado correctamente",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchOrders();
      } else {
        Get.snackbar(
          "Error",
          "Código inválido o ya usado",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Ocurrió un problema al validar: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ CANCELAR RESERVA (US 2)
  /// Cancela una orden si no ha pasado el límite de recogida.
  Future<void> cancelMyOrder(String orderId, DateTime pickupEnd) async {
    // Validación local: verificar si el horario límite ya pasó
    if (DateTime.now().isAfter(pickupEnd)) {
      Get.snackbar(
        "No puedes cancelar",
        "El horario límite de recogida ha pasado",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      isLoading.value = true;
      final myUserId = _supabase.auth.currentUser?.id;

      if (myUserId == null) {
        Get.snackbar("Error", "Sesión no válida");
        return;
      }

      await _supabase.rpc('cancel_order', params: {
        'p_order_id': orderId,
        'p_user_id': myUserId,
      });

      Get.snackbar(
        "Reserva cancelada",
        "Se ha cancelado tu reserva y el stock ha sido devuelto",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      await fetchOrders();
    } catch (e) {
      Get.snackbar("Error", "No se pudo cancelar la reserva: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
