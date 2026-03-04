import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'cart_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CartController());

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text("Mi Carrito", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textBlack)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textBlack),
      ),
      body: Obx(() {
        // ✅ SI EL CARRITO ESTÁ VACÍO
        if (controller.cartItems.isEmpty) {
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

        // ✅ SI HAY PACKS EN EL CARRITO
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Packs seleccionados", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // --- LISTA DE PACKS ---
              Expanded(
                child: ListView.builder(
                  itemCount: controller.cartItems.length,
                  itemBuilder: (context, index) {
                    final pack = controller.cartItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
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
                                Text(pack.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 5),
                                Text("${pack.price} Bs", style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => controller.removeFromCart(pack),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),

              // --- TOTAL Y BOTÓN DE PAGO ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                    Text("${controller.totalCartPrice.toStringAsFixed(2)} Bs", 
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textBlack)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Get.toNamed(Routes.payment), // Ya no pasamos argumentos, el pago leerá el carrito
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