import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'orders_controller.dart';

class OrdersScreen extends StatelessWidget {
  // Inyectamos el controlador
  final OrdersController controller = Get.put(OrdersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Reservas")),
      
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.myOrders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey),
                SizedBox(height: 10),
                Text("Aún no tienes reservas activa.", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.myOrders.length,
          itemBuilder: (context, index) {
            final order = controller.myOrders[index];
            final pack = order['packs'] ?? {};
            final business = order['businesses'] ?? {};
            
            // Formato de fecha
            final created = DateTime.parse(order['created_at']).toLocal();
            final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(created);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // FOTO DEL PACK
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: pack['image_url'] != null
                        ? Image.network(pack['image_url'], width: 80, height: 80, fit: BoxFit.cover)
                        : Container(width: 80, height: 80, color: Colors.grey[300], child: const Icon(Icons.fastfood, color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    
                    // INFORMACIÓN
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pack['title'] ?? 'Pack Sorpresa', 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          
                          Text(business['commercial_name'] ?? 'Tienda',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          
                          const SizedBox(height: 8),
                          
                          // CÓDIGO Y ESTADO
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)),
                                child: Text("CÓDIGO: ${order['code']}", 
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 12)),
                              ),
                              const Spacer(),
                              Text(order['status'] == 'reserved' ? 'RESERVADO' : order['status'],
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12))
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}