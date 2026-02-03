import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'browse_controller.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BrowseController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explora Packs'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // --- Campo de búsqueda ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                onChanged: controller.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

            // --- Chips de categorías ---
            SizedBox(
              height: 40,
              child: Obx(() => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.categories.length,
                    itemBuilder: (context, index) {
                      final category = controller.categories[index];
                      final isSelected = controller.selectedCategory.value == category;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) => controller.onCategorySelected(category),
                        ),
                      );
                    },
                  )),
            ),

            const SizedBox(height: 10),

            // --- Lista de packs ---
            Expanded(
              child: Obx(() {
                final packs = controller.filteredPacks;

                if (packs.isEmpty) {
                  return const Center(child: Text('No hay resultados'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: packs.length,
                  itemBuilder: (context, index) {
                    final pack = packs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
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
                        onTap: () {
                          Get.toNamed('/pack_detail', arguments: pack);
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        );
      }),
    );
  }
}
