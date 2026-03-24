import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../packs/packs_controller.dart';
import '../shell/shell_controller.dart';
import '../../routes/app_routes.dart';
import '../orders/orders_controller.dart';
import '../cart/cart_controller.dart';
import '../../core/services/network_service.dart';

class PaymentController extends GetxController {
  final isLoading = false.obs;

  // ✅ Inyectamos el carrito directamente para leer todo desde allí
  final CartController cartController = Get.find<CartController>();

  late String title;
  late double totalPrice;

  var selectedMethod = 'tarjeta'.obs;
  var selectedBank = ''.obs;
  final List<String> bankList = [
    'Banesco (0134)',
    'Banco de Venezuela (0102)',
    'Mercantil (0105)',
    'Provincial (0108)',
    'BNC (0191)',
    'Bancaribe (0114)',
    'Otro',
  ];

  final cardNumberController = TextEditingController();
  final cardExpiryController = TextEditingController();
  final cardCvvController = TextEditingController();
  final referenceController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Leemos el total a cobrar y preparamos el título del recibo
    totalPrice = cartController.totalCartPrice;
    int amountPacks = cartController.cartItems.length;
    title = amountPacks == 1
        ? "1 Pack seleccionado"
        : "$amountPacks Packs seleccionados";
  }

  // --- VALIDACIÓN Y PAGO ---
  Future<void> processPayment() async {
    if (selectedMethod.value == 'tarjeta') {
      if (cardNumberController.text.length < 19) {
        Get.snackbar("Error", "Número de tarjeta inválido",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      if (cardExpiryController.text.length < 5) {
        Get.snackbar("Error", "Fecha de vencimiento inválida",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      if (cardCvvController.text.length < 3) {
        Get.snackbar("Error", "CVV inválido",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
    }

    if (selectedMethod.value == 'pagomovil') {
      if (selectedBank.value.isEmpty) {
        Get.snackbar("Error", "Selecciona el banco desde el que pagaste",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      if (referenceController.text.length < 4) {
        Get.snackbar("Error", "Número de referencia muy corto",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
    }

    await _executePayment();
  }

  Future<void> _executePayment() async {
    try {
      isLoading.value = true;

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception("Usuario no autenticado");

      // ─── GUARD OFFLINE ───────────────────────────────────────
      final networkService = Get.find<NetworkService>();
      if (!networkService.isOnline.value) {
        // Preparar datos para resguardo local
        String? last4;
        if (selectedMethod.value == 'tarjeta') {
          String rawCard = cardNumberController.text.replaceAll(' ', '');
          if (rawCard.length >= 4) {
            last4 = rawCard.substring(rawCard.length - 4);
          }
        }

        final paymentData = {
          'userId': userId,
          'packs': cartController.cartItems.map((p) => p.toJson()).toList(),
          'paymentMethod': selectedMethod.value,
          'bankName': selectedMethod.value == 'pagomovil'
              ? selectedBank.value
              : null,
          'referenceNumber': selectedMethod.value == 'pagomovil'
              ? referenceController.text
              : null,
          'cardLast4': last4,
          'totalPrice': totalPrice,
        };

        networkService.savePendingPayment(paymentData);

        Get.snackbar(
          'Falla de conectividad',
          'tu pago será resguardado',
          backgroundColor: Colors.orange.shade800,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
          icon: const Icon(Icons.cloud_off, color: Colors.white, size: 28),
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );

        isLoading.value = false;
        return;
      }
      // ─── FIN GUARD OFFLINE ───────────────────────────────────

      // Simulamos conexión con el banco
      await Future.delayed(const Duration(seconds: 2));
      bool paymentSuccess = true;

      String? last4;
      if (selectedMethod.value == 'tarjeta') {
        String rawCard = cardNumberController.text.replaceAll(' ', '');
        if (rawCard.length >= 4) {
          last4 = rawCard.substring(rawCard.length - 4);
        }
      }

      if (paymentSuccess) {
        final packsController = Get.put(PacksController());

        // ✅ MAGIA: RECORREMOS TODOS LOS PACKS DEL CARRITO
        for (var pack in cartController.cartItems) {
          // 1. Guardamos cada pago en Supabase vinculado a su negocio respectivo
          await Supabase.instance.client.from('payments').insert({
            'user_id': userId,
            'pack_id': pack.id,
            'business_id': pack.businessId,
            'amount':
                pack.price, // Registramos el precio individual de este pack
            'payment_method': selectedMethod.value,
            'status': 'success',
            'bank_name':
                selectedMethod.value == 'pagomovil' ? selectedBank.value : null,
            'reference_number': selectedMethod.value == 'pagomovil'
                ? referenceController.text
                : null,
            'card_last4': last4,
          });

          // 2. Ejecutamos la reserva (resta de cantidad, creación de orden, etc.)
          await packsController.reservePack(pack.id, pack.businessId ?? '');
        }

        // 3. Vaciamos el carrito (ya no maneja lógica de base de datos)
        cartController.clearCartAfterPayment();

        // 4. Actualizamos vistas y navegamos
        if (Get.isRegistered<OrdersController>()) {
          Get.find<OrdersController>().fetchOrders();
        }

        Get.offAllNamed(Routes.shell);

        if (Get.isRegistered<ShellController>()) {
          Get.find<ShellController>().changeIndex(2);
        }

        Future.delayed(const Duration(milliseconds: 500), () {
          Get.snackbar(
            "¡Reserva Confirmada! 🎉",
            "Tu pago fue exitoso y el pack te está esperando.",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.TOP,
          );
        });
      } else {
        Get.snackbar("Pago Rechazado", "El banco declinó la transacción.",
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      print("Error procesando carrito múltiple: $e");
      Get.snackbar("Error de sistema", "Hubo un problema. Intenta de nuevo.",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
