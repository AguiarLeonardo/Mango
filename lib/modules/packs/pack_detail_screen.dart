import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'packs_controller.dart'; // Asegúrate de importar tu controlador

class PackDetailScreen extends StatelessWidget {
  const PackDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. RECIBIMOS EL MAPA (No el PackModel)
    final pack = Get.arguments as Map<String, dynamic>;
    
    // Recuperamos el controlador para la función de reservar
    final PacksController controller = Get.find<PacksController>();
    
    // Obtenemos los datos del negocio (si vienen dentro del pack)
    final business = pack['businesses'] ?? {};

    // 2. PARSEO DE FECHAS (Porque en el Mapa vienen como String)
    final start = DateTime.parse(pack['pickup_start']).toLocal();
    final end = DateTime.parse(pack['pickup_end']).toLocal();
    final timeFormat = DateFormat('hh:mm a');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- IMAGEN Y TÍTULO ---
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                pack['title'] ?? 'Sin título',
                style: const TextStyle(
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: pack['image_url'] != null
                  ? Image.network(pack['image_url'], fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey,
                      child: const Icon(Icons.fastfood, size: 80, color: Colors.white),
                    ),
            ),
          ),
          
          // --- INFORMACIÓN DEL PACK ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PRECIO Y DISPONIBILIDAD
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${pack['price']}", 
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          "${pack['quantity_available']} Disponibles", 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                        ),
                      )
                    ],
                  ),
                  
                  const SizedBox(height: 20),

                  // NOMBRE DEL NEGOCIO
                  Row(
                    children: [
                      const CircleAvatar(child: Icon(Icons.store)),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(business['commercial_name'] ?? 'Comercio', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(business['address'] ?? 'Ver en mapa', style: const TextStyle(color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                  
                  const Divider(height: 30),

                  // HORARIO
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_filled, color: Colors.blue),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Horario de Retiro:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                            Text("${timeFormat.format(start)} - ${timeFormat.format(end)}", style: const TextStyle(fontSize: 16)),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- BOTÓN DE RESERVAR ---
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() {
                      // Verificamos stock usando el mapa
                      final stock = pack['quantity_available'] ?? 0;
                      final bool isAvailable = stock > 0;

                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return ElevatedButton(
                        onPressed: isAvailable
                            ? () {
                                // Llamamos a reservar pasando los IDs del mapa
                                controller.reservePack(pack['id'], pack['business_id']);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAvailable ? Colors.green : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          isAvailable ? "RESERVAR AHORA" : "AGOTADO",
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}