import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import '../packs/packs_controller.dart';
import '../shell/shell_controller.dart';
import '../../routes/app_routes.dart';

class PaymentController extends GetxController {
  final isLoading = false.obs;

  late String packId;
  late String businessId;
  late String title;
  late double price;

  // Solo nos quedamos con tarjeta y pagomovil
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
    final args = Get.arguments as Map<String, dynamic>;
    packId = args['packId'];
    businessId = args['businessId'];
    title = args['title'];
    price = args['price'];
  }

  // --- VALIDACIÓN Y PAGO ---
  Future<void> processPayment() async {
    // 1. VALIDACIÓN TARJETA
    if (selectedMethod.value == 'tarjeta') {
      if (cardNumberController.text.length < 19) {
        Get.snackbar(
          "Error",
          "Número de tarjeta inválido",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      if (cardExpiryController.text.length < 5) {
        Get.snackbar(
          "Error",
          "Fecha de vencimiento inválida",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      if (cardCvvController.text.length < 3) {
        Get.snackbar(
          "Error",
          "CVV inválido",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    // 2. VALIDACIÓN PAGO MÓVIL
    if (selectedMethod.value == 'pagomovil') {
      if (selectedBank.value.isEmpty) {
        Get.snackbar(
          "Error",
          "Selecciona el banco desde el que pagaste",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      if (referenceController.text.length < 4) {
        Get.snackbar(
          "Error",
          "Número de referencia muy corto",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    // Si todo está correcto, procesamos el pago
    await _executePayment();
  }

  Future<void> _executePayment() async {
    try {
      isLoading.value = true;

      // Simulamos conexión con el banco
      await Future.delayed(const Duration(seconds: 2));
      bool paymentSuccess = Random().nextDouble() > 0.2; // 80% éxito

      if (paymentSuccess) {
        final packsController = Get.find<PacksController>();
        await packsController.reservePack(packId, businessId);

        Get.offAllNamed(Routes.shell);

        if (Get.isRegistered<ShellController>()) {
          Get.find<ShellController>().changeIndex(1);
        }

        Future.delayed(const Duration(milliseconds: 500), () {
          Get.snackbar(
            "¡Reserva Exitosa! 🎉",
            "Tu pack ha sido reservado. Revísalo en la pestaña Reservas.",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
            snackPosition: SnackPosition.TOP,
          );
        });
      } else {
        Get.snackbar(
          "Pago Rechazado",
          "El banco ha declinado la transacción. Verifica tus datos o fondos.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error de sistema",
        "No se pudo procesar el pago.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
