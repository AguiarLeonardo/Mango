import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'orders_controller.dart';

class OrdersScreen extends StatelessWidget {
  final OrdersController controller = Get.put(OrdersController());

  OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.isBusinessMode.value ? "Mis Ventas" : "Mis Reservas")),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.ordersList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 70, color: Colors.grey[300]),
                const SizedBox(height: 15),
                Text(
                  controller.isBusinessMode.value 
                    ? "Aún no tienes ventas." 
                    : "No tienes reservas activas.",
                  style: TextStyle(color: Colors.grey[600], fontSize: 16)
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.ordersList.length,
          itemBuilder: (context, index) {
            final order = controller.ordersList[index];
            
            // --- VALIDACIÓN DE SEGURIDAD ---
            // Si 'packs' viene nulo, ponemos un mapa vacío para que no explote
            final pack = order['packs'] ?? {}; 
            final business = pack['businesses'] ?? {}; // El negocio suele venir dentro del pack
            
            // --- MANEJO SEGURO DE FECHA ---
            // Si created_at es nulo, usamos la fecha de ahora para que no de error
            DateTime date;
            if (order['created_at'] != null) {
              date = DateTime.parse(order['created_at']).toLocal();
            } else {
              date = DateTime.now(); // Fallback si falla la base de datos
            }
            
            // --- MANEJO SEGURO DEL CÓDIGO ---
            // Probamos leer 'code', si no existe probamos 'pickup_code', si no '---'
            final String code = order['code'] ?? order['pickup_code'] ?? '---';
            final String status = order['status'] ?? 'pending';

            // Tarjeta Usuario
            if (!controller.isBusinessMode.value) {
               return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // CÓDIGO
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange[200]!)
                        ),
                        child: Column(
                          children: [
                            Text("CÓDIGO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                            const SizedBox(height: 5),
                            Text(code, // Usamos la variable segura
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange[800])),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      // DETALLES
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pack['title'] ?? 'Pack Reservado', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(business['commercial_name'] ?? 'Tienda', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text(DateFormat('dd MMM, HH:mm').format(date), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                                const Spacer(),
                                Text(status, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } 
            
            // Tarjeta Empresa
            else {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person, color: Colors.white), backgroundColor: Colors.blue),
                  title: Text("Reserva: $code"),
                  subtitle: Text(pack['title'] ?? 'Pack'),
                  trailing: Text(DateFormat('HH:mm').format(date)),
                ),
              );
            }
          },
        );
      }),
    );
  }
}