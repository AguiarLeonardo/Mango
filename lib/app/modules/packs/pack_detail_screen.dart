import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/pack_model.dart'; 
import 'packs_controller.dart';

class PackDetailScreen extends StatelessWidget {
  const PackDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Verificación y Conversión segura de Datos
    // Si viene el objeto directo, lo usa. Si viene un Mapa (JSON), lo convierte.
    final PackModel pack = (Get.arguments is PackModel)
        ? Get.arguments as PackModel
        : PackModel.fromJson(Get.arguments); 

    // 2. Inyección segura del Controlador
    // Busca si ya existe, si no, lo crea.
    final PacksController controller = Get.isRegistered<PacksController>() 
        ? Get.find<PacksController>() 
        : Get.put(PacksController());

    final timeFormat = DateFormat('hh:mm a');

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // --- SECCIÓN 1: IMAGEN Y TÍTULO ---
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                pack.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: pack.imageUrl != null && pack.imageUrl!.isNotEmpty
                  ? Image.network(pack.imageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey,
                      child: const Icon(Icons.fastfood, size: 80, color: Colors.white),
                    ),
            ),
          ),
          
          // --- SECCIÓN 2: DETALLES DEL PAQUETE ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PRECIO Y CANTIDAD DISPONIBLE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${pack.price.toStringAsFixed(2)} Bs", 
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          "${pack.quantityAvailable} Disponibles", 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                        ),
                      )
                    ],
                  ),
                  
                  const SizedBox(height: 20),

                  // INFORMACIÓN DEL NEGOCIO
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.green, 
                        child: Icon(Icons.store, color: Colors.white)
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pack.businessName ?? 'Negocio Desconocido', 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                          ),
                          const Text(
                            'Ver ubicación en el mapa', 
                            style: TextStyle(color: Colors.grey)
                          ),
                        ],
                      )
                    ],
                  ),
                  
                  const Divider(height: 40),

                  // HORARIO DE RETIRO
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1), 
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.green.withOpacity(0.3))
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_filled, color: Colors.green),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Horario de Retiro:", 
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)
                            ),
                            Text(
                              "${timeFormat.format(pack.pickupStart)} - ${timeFormat.format(pack.pickupEnd)}", 
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- BOTÓN DE RESERVA ---
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() {
                      final bool isAvailable = pack.quantityAvailable > 0;

                      // Si está cargando, mostramos spinner
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return ElevatedButton(
                      
                        onPressed: isAvailable
                            ? () => controller.reservePack(
                                  pack.id, 
                                  pack.businessId.toString()
                                )
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAvailable ? Colors.orange : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: Text(
                          isAvailable ? "RESERVAR AHORA" : "AGOTADO",
                          style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}