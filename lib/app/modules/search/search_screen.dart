import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';

import '../../data/models/pack_model.dart';
import 'search_controller.dart';
import '../packs/pack_detail_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchMyController());
    final List<String> categories = ['Restaurante', 'Panadería', 'Frutería', 'Market', 'Postres'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Explorar Packs", style: TextStyle(color: AppColors.darkOlive, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // BARRA DE BÚSQUEDA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: controller.searchInput,
              onChanged: (val) => controller.searchText.value = val,
              decoration: InputDecoration(
                hintText: "Busca comida o locales...",
                prefixIcon: const Icon(Icons.search, color: AppColors.orange),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),

          // FILTRO DE PRECIO
          Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Row(
              children: [
                const Text("Precio máx:", style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Slider(
                    value: controller.maxPrice.value,
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    activeColor: AppColors.orange,
                    label: "${controller.maxPrice.value.round()} Bs",
                    onChanged: (val) => controller.maxPrice.value = val,
                  ),
                ),
                Text("${controller.maxPrice.value.round()} Bs"),
              ],
            ),
          )),

          // FILTRO DE CATEGORÍAS
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Obx(() {
                    bool isSelected = controller.selectedCategory.value == categories[index];
                    return FilterChip(
                      label: Text(categories[index]),
                      selected: isSelected,
                      onSelected: (val) => controller.setCategory(categories[index]),
                      selectedColor: AppColors.sageGreen.withOpacity(0.3),
                      checkmarkColor: AppColors.darkOlive,
                    );
                  }),
                );
              },
            ),
          ),

          // LISTADO DE RESULTADOS
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator(color: AppColors.orange));
              if (controller.searchResults.isEmpty) return _buildEmptyState();

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: controller.searchResults.length,
                itemBuilder: (context, index) {
                  // "pack" aquí es un MAP (JSON) que viene de Supabase
                  final packMap = controller.searchResults[index];
                  final business = packMap['businesses'];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: packMap['image_url'] != null 
                          ? Image.network(packMap['image_url'], width: 60, height: 60, fit: BoxFit.cover)
                          : Container(width: 60, height: 60, color: AppColors.sageGreen, child: const Icon(Icons.fastfood, color: Colors.white)),
                      ),
                      title: Text(packMap['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(business != null ? business['commercial_name'] : 'Negocio', style: const TextStyle(color: AppColors.orange)),
                          Text("${packMap['price']} Bs", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      // --- CORRECCIÓN CRÍTICA AQUÍ ---
                      // Convertimos el mapa a PackModel antes de enviarlo
                      onTap: () {
                         final packModel = PackModel.fromJson(packMap);
                         Get.to(() => const PackDetailScreen(), arguments: packModel);
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const Text("No hay packs con esos filtros", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}