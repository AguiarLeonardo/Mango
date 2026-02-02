import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Importamos el controlador para poder usar la función de reservar
import 'packs_controller.dart';

class PackDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Recibimos los datos pasados desde la pantalla anterior
    final pack = Get.arguments as Map<String, dynamic>;
    final business = pack['businesses'] ?? {};

    // Buscamos el controlador que ya está activo en memoria
    final PacksController controller = Get.find<PacksController>();

    // Formateo seguro de fechas
    final start = DateTime.parse(pack['pickup_start']).toLocal();
    final end = DateTime.parse(pack['pickup_end']).toLocal();
    final timeFormat = DateFormat('hh:mm a');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header con Imagen grande
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(pack['title'], style: const TextStyle(shadows: [Shadow(color: Colors.black, blurRadius: 10)])),
              background: pack['image_url'] != null
                ? Image.network(pack['image_url'], fit: BoxFit.cover)
                : Container(color: Colors.grey, child: const Icon(Icons.fastfood, size: 80, color: Colors.white)),
            ),
          ),
          
          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Precios y Stock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (pack['original_price'] != null)
                            Text("\$${pack['original_price']}", 
                              style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)),
                          Text("\$${pack['price']}", 
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
                        child: Text("${pack['quantity_available']} Disponibles", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Info del Negocio
                  Row(
                    children: [
                      const CircleAvatar(child: Icon(Icons.store)),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(business['commercial_name'] ?? 'Empresa', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(business['address'] ?? 'Sin dirección', style: const TextStyle(color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                  const Divider(height: 30),

                  // Descripción
                  const Text("Lo que incluye:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(pack['description'] ?? "Sin descripción", style: const TextStyle(fontSize: 16, height: 1.5)),
                  
                  const SizedBox(height: 20),
                  
                  // Horario de Retiro
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
                  
                  // --- BOTÓN DE RESERVA ACTUALIZADO ---
                  SizedBox(
                    width: double.infinity,
                    // Usamos Obx para escuchar cambios en isLoading
                    child: Obx(() {
                        // Si está cargando, mostramos la ruedita
                        if (controller.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        // Verificamos si hay stock
                        final int stock = pack['quantity_available'];
                        final bool isAvailable = stock > 0;

                        return ElevatedButton(
                          onPressed: isAvailable 
                            ? () {
                                // Aquí llamamos a la función real de reservar
                                // Asegúrate de que los nombres de los campos coincidan con tu base de datos
                                controller.reservePack(pack['id'], pack['business_id']);
                              }
                            : null, // Si no hay stock, el botón se deshabilita
                          
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAvailable ? Colors.green : Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                          ),
                          child: Text(
                            isAvailable ? "RESERVAR AHORA" : "AGOTADO",
                            style: const TextStyle(fontSize: 18, color: Colors.white)
                          ),
                        );
                      }
                    ),
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