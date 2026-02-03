import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mango/data/models/pack_model.dart';
import 'packs_controller.dart';

class PackDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PackModel pack = Get.arguments as PackModel;
    final PacksController controller = Get.find<PacksController>();

    final start = pack.pickupStart.toLocal();
    final end = pack.pickupEnd.toLocal();
    final timeFormat = DateFormat('hh:mm a');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                pack.title,
                style: const TextStyle(
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: pack.imageUrl != null
                  ? Image.network(pack.imageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey,
                      child: const Icon(Icons.fastfood, size: 80, color: Colors.white),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Precios y stock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (pack.originalPrice != null)
                            Text(
                              "\$${pack.originalPrice}",
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                          Text(
                            "\$${pack.price}",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${pack.quantityAvailable} Disponibles",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Info del negocio
                  Row(
                    children: [
                      const CircleAvatar(child: Icon(Icons.store)),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pack.businessId,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Text("ID del negocio", style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                  const Divider(height: 30),

                  const Text("Lo que incluye:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(
                    pack.description ?? "Sin descripción",
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  // Horario de Retiro
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_filled, color: Colors.blue),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Horario de Retiro:",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            Text(
                              "${timeFormat.format(start)} - ${timeFormat.format(end)}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Botón de reservar
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() {
                      final bool isAvailable = pack.quantityAvailable > 0;

                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return ElevatedButton(
                        onPressed: isAvailable
                            ? () {
                                controller.reservePack(pack.id, pack.businessId);
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
