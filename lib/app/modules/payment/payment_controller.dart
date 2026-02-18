import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/payment_service.dart';
import '../../routes/app_routes.dart';

class PaymentController extends GetxController {
  final PaymentService _paymentService = PaymentService();
  final SupabaseClient _supabase = Supabase.instance.client;

  var isLoading = false.obs;
  
  // Datos recibidos de la pantalla anterior
  late String packId;
  late String businessId;
  late double amount;
  late String packTitle;

  @override
  void onInit() {
    super.onInit();
    // Recibimos los argumentos al navegar a esta pantalla
    final args = Get.arguments as Map<String, dynamic>;
    packId = args['packId'];
    businessId = args['businessId'];
    amount = (args['price'] as num).toDouble();
    packTitle = args['title'];
  }

  Future<void> payAndReserve() async {
    isLoading.value = true;
    try {
      // --- PASO 1: PROCESAR PAGO (Criterio 1 y 3 y 4) ---
      await _paymentService.processPayment(amount: amount, currency: 'Bs');

      // --- PASO 2: SI EL PAGO PASÓ, REGISTRAR RESERVA (Criterio 2) ---
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception("Usuario no autenticado");

      final response = await _supabase.rpc('reserve_pack', params: {
        'p_pack_id': packId,
        'p_business_id': businessId,
      });

      if (response['success'] == true) {
        // ÉXITO TOTAL
        Get.offNamed(Routes.orders); // O una pantalla de "Pago Exitoso"
        Get.snackbar(
          "¡Pago Exitoso!", 
          "Tu reserva ha sido confirmada. Código: ${response['reservation_code']}",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 5)
        );
      } else {
        // Caso raro: Pagó pero la base de datos falló (ej. se agotó justo en ese milisegundo)
        // Aquí deberías implementar una lógica de reembolso automática en un caso real
        throw Exception(response['message'] ?? "Error registrando la reserva");
      }

    } catch (e) {
      // MANEJO DE ERRORES (Criterio 3 y 4)
      String errorMessage = e.toString().replaceAll("Exception: ", "");
      
      Get.dialog(
        AlertDialog(
          title: const Text("Error en el pago"),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Get.back(), 
              child: const Text("Reintentar") // Permite reintentar (Criterio 3)
            )
          ],
        )
      );
    } finally {
      isLoading.value = false;
    }
  }
}