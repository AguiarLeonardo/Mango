import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'discover_controller.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DiscoverController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Descubre Packs Cercanos'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.packs.isEmpty) {
          return const Center(child: Text('No hay packs disponibles.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.packs.length,
          itemBuilder: (context, index) {
            final pack = controller.packs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: pack.imageUrl != null
                    ? Image.network(
                        pack.imageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image_not_supported),
                title: Text(pack.title),
                subtitle: Text('${pack.price.toStringAsFixed(2)} Bs'),
                trailing: Text(
                  pack.status,
                  style: TextStyle(
                    color: pack.status == 'available' ? Colors.green : Colors.grey,
                  ),
                ),
                onTap: () {
                  Get.toNamed('/pack_detail', arguments: pack);
                },
              ),
            );
          },
        );
      }),
    );
  }
}
