import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/order_model.dart';

class BusinessOrdersController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final isLoading = false.obs;
  // Validating the code explicitly
  final isValidating = false.obs;

  // Solamente órdenes pendientes
  final pendingOrdersList = <OrderModel>[].obs;

  String get myBusinessId => _supabase.auth.currentUser?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchPendingOrders();
  }

  /// Carga las órdenes pendientes asociadas al negocio autenticado.
  Future<void> fetchPendingOrders() async {
    try {
      isLoading.value = true;
      if (myBusinessId.isEmpty) return;

      final response = await _supabase
          .from('orders')
          .select('*, packs(title, image_url, price, pickup_start, pickup_end)')
          .eq('business_id', myBusinessId)
          .eq('status', OrderStatus.pending.name) // Filtramos por pending
          .order('created_at', ascending: false);

      pendingOrdersList.value = (response as List)
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Get.snackbar(
        "Error",
        "No se pudieron cargar los pedidos pendientes.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Valida y completa la entrega de un pedido mediante código.
  Future<void> confirmPickup(String code) async {
    if (code.trim().isEmpty) return;

    try {
      isValidating.value = true;

      // Usando el RPC fulfill_order de Supabase
      final response = await _supabase.rpc('fulfill_order', params: {
        'p_business_id': myBusinessId,
        'p_code': code.trim().toUpperCase(),
      });

      if (response['success'] == true) {
        // En lugar de volver a cargar todo, eliminamos localmente la orden validada
        pendingOrdersList.removeWhere(
            (order) => order.code.toUpperCase() == code.trim().toUpperCase());

        Get.snackbar(
          "¡Entrega Exitosa! 🎉",
          "El pack se marcó como entregado.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      } else {
        Get.snackbar(
          "Código Inválido",
          "El código no existe, pertenece a otro local, o ya fue entregado.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Ocurrió un problema al validar la entrega.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isValidating.value = false;
    }
  }

  // Mantenemos esto por retrocompatibilidad con la validación de BusinessDashboard
  Future<void> validateOrderCode(String code) => confirmPickup(code);
}
