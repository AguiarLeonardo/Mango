import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import 'payment_controller.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentController());

    return Scaffold(
      appBar: AppBar(title: const Text("Pasarela de Pago")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Resumen de Compra", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // Tarjeta de resumen
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)]
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Producto:"),
                      Text(controller.packTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total a Pagar:", style: TextStyle(fontSize: 18)),
                      Text("${controller.amount.toStringAsFixed(2)} Bs", 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkOlive)),
                    ],
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Botón de Pagar
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.payAndReserve,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: controller.isLoading.value 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("CONFIRMAR Y PAGAR", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              )),
            ),
            const SizedBox(height: 20),
            const Center(child: Text("🔒 Pago seguro simulado", style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }
}