import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'cart_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Si el controlador ya existe, lo usa; si no, lo crea.
    final controller = Get.put(CartController());

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream, // Usando tu color de fondo
      appBar: AppBar(
        title: const Text("Mi Carrito", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textBlack)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textBlack),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(), // Solo regresa, NO cancela el carrito
        ),
      ),
      body: Obx(() {
        final pack = controller.cartItem.value;

        // Si el carrito está vacío
        if (pack == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 20),
                Text("Tu carrito está vacío", style: TextStyle(color: Colors.grey[600], fontSize: 18)),
              ],
            ),
          );
        }

        // Si hay un pack en el carrito
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ALERTA DE TIEMPO ---
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppTheme.accentOrange.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: AppTheme.accentOrange),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Reserva temporal. Completa tu pago antes de que termine el tiempo.",
                        style: TextStyle(color: AppTheme.accentOrange.withOpacity(0.9), fontSize: 13),
                      ),
                    ),
                    Text(
                      controller.formattedTime, // Aquí se ve el reloj: 14:59, 14:58...
                      style: const TextStyle(color: AppTheme.accentOrange, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- TARJETA DEL PACK ---
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: pack.imageUrl != null
                          ? Image.network(pack.imageUrl!, width: 70, height: 70, fit: BoxFit.cover)
                          : Container(width: 70, height: 70, color: Colors.grey[300], child: const Icon(Icons.fastfood, color: Colors.white)),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pack.businessName ?? "Tienda", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          Text(pack.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 5),
                          Text("${pack.price} Bs", style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    // Botón para eliminar del carrito
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => controller.releaseCartItem(), // Cancela y devuelve el stock
                    )
                  ],
                ),
              ),

              const Spacer(),

              // --- BOTÓN IR A PAGAR ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Enviamos el pack a la pasarela de pago que ya tienes
                    Get.toNamed(Routes.payment, arguments: pack);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("PROCEDER AL PAGO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}