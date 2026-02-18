import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; 

import 'packs_controller.dart';
import 'pack_detail_screen.dart';

class PacksScreen extends StatelessWidget {
  // Asegúrate de instanciar el controlador
  final PacksController controller = Get.put(PacksController());

  PacksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Packs Disponibles")),
      
      // Botón flotante SOLO para Negocios
      floatingActionButton: Obx(() => controller.isBusiness.value 
        ? FloatingActionButton.extended(
            onPressed: () => _showCreatePackModal(context),
            label: const Text("Nuevo Pack"),
            icon: const Icon(Icons.add_business),
            backgroundColor: Colors.orange,
          )
        : const SizedBox.shrink()
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.packsList.isEmpty) {
          return Center(child: Text(controller.isBusiness.value 
            ? "No has creado packs aún." 
            : "No hay packs disponibles por ahora."));
        }

        // Grid de Packs
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75, 
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: controller.packsList.length,
          itemBuilder: (context, index) {
            final pack = controller.packsList[index];
            return _buildPackCard(pack);
          },
        );
      }),
    );
  }

  // Tarjeta de cada Pack
  Widget _buildPackCard(Map<String, dynamic> pack) {
    final business = pack['businesses'] ?? {};
    final String title = pack['title'] ?? 'Pack Sorpresa';
    final String price = pack['price'].toString();
    final String? imageUrl = pack['image_url'];

    return GestureDetector(
      onTap: () => Get.to(() => PackDetailScreen(), arguments: pack),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Expanded(
              child: imageUrl != null 
                ? Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity)
                : Container(color: Colors.grey[300], child: const Icon(Icons.fastfood, size: 50, color: Colors.grey)),
            ),
            // Datos
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(business['commercial_name'] ?? 'Comercio', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("\$$price", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(4)),
                        child: Text("${pack['quantity_available']} disp.", style: TextStyle(fontSize: 10, color: Colors.orange[900])),
                      )
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

  // Modal para Crear Pack
  void _showCreatePackModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      // Usamos GetBuilder para la IMAGEN (que usa update()) y Obx dentro para las HORAS (que usan .value)
      builder: (_) => GetBuilder<PacksController>( 
        builder: (_) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, 
            left: 20, right: 20, top: 20
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Crear Nuevo Pack", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                // Selector de Imagen
                GestureDetector(
                  onTap: controller.pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey)),
                    child: controller.pickedImage != null 
                      ? Image.file(File(controller.pickedImage!.path), fit: BoxFit.cover)
                      : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt, size: 40), Text("Toca para agregar foto")]),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(controller: controller.titleController, decoration: const InputDecoration(labelText: "Título del Pack", border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: controller.descController, decoration: const InputDecoration(labelText: "Descripción (Opcional)", border: OutlineInputBorder()), maxLines: 2),
                const SizedBox(height: 10),
                
                Row(
                  children: [
                    Expanded(child: TextField(controller: controller.priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Precio \$", border: OutlineInputBorder()))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: controller.originalPriceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Precio Original (Opcional)", border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(controller: controller.quantityController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Cantidad Total", border: OutlineInputBorder())),
                
                const SizedBox(height: 15),
                const Text("Horario de Retiro", style: TextStyle(fontWeight: FontWeight.bold)),
                
                // --- AQUÍ ESTÁ EL CAMBIO IMPORTANTE ---
                // Envolvemos los botones de hora en un Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Centramos los botones
                  children: [
                    // Botón Inicio (Envuelto en Obx porque pickupStart es reactivo)
                    Obx(() => TextButton.icon(
                      icon: const Icon(Icons.access_time),
                      // AGREGAMOS .value AQUÍ ABAJO
                      label: Text(controller.pickupStart.value == null 
                          ? "Inicio" 
                          : DateFormat('HH:mm').format(controller.pickupStart.value!)),
                      onPressed: () async {
                        final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (time != null) {
                          final now = DateTime.now();
                          controller.setPickupStart(DateTime(now.year, now.month, now.day, time.hour, time.minute));
                        }
                      },
                    )),
                    
                    const Text("-"),
                    
                    // Botón Fin (Envuelto en Obx porque pickupEnd es reactivo)
                    Obx(() => TextButton.icon(
                      icon: const Icon(Icons.access_time),
                      // AGREGAMOS .value AQUÍ ABAJO
                      label: Text(controller.pickupEnd.value == null 
                          ? "Fin" 
                          : DateFormat('HH:mm').format(controller.pickupEnd.value!)),
                      onPressed: () async {
                        final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (time != null) {
                          final now = DateTime.now();
                          controller.setPickupEnd(DateTime(now.year, now.month, now.day, time.hour, time.minute));
                        }
                      },
                    )),
                  ],
                ),
                // -------------------------------------

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.createPack,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 15)),
                    child: const Text("PUBLICAR PACK", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}