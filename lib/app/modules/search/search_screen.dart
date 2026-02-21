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
      backgroundColor: AppTheme.backgroundCream, // Fondo suave crema
      appBar: AppBar(
        title: const Text("Explorar Packs", style: TextStyle(color: AppTheme.textBlack, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.backgroundCream, // Fundido con el fondo
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- BARRA DE BÚSQUEDA ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: controller.searchInput,
              onChanged: (val) => controller.searchText.value = val,
              decoration: InputDecoration(
                hintText: "Busca comida o locales...",
                hintStyle: TextStyle(color: AppTheme.disabledIcon.withOpacity(0.8)),
                prefixIcon: const Icon(Icons.search, color: AppTheme.accentOrange), // Llama la atención hacia la búsqueda
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15), 
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5)
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15), 
                  borderSide: const BorderSide(color: AppTheme.accentOrange, width: 2) // Borde Naranja al tocar
                ),
              ),
            ),
          ),

          // --- FILTRO DE PRECIO ---
          Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Row(
              children: [
                const Text("Precio máx:", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textBlack)),
                Expanded(
                  child: Slider(
                    value: controller.maxPrice.value,
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    activeColor: AppTheme.accentOrange, // Mantiene la urgencia/promoción
                    inactiveColor: AppTheme.disabledBackground,
                    label: "${controller.maxPrice.value.round()} Bs",
                    onChanged: (val) => controller.maxPrice.value = val,
                  ),
                ),
                Text("${controller.maxPrice.value.round()} Bs", style: const TextStyle(color: AppTheme.textBlack, fontWeight: FontWeight.bold)),
              ],
            ),
          )),

          // --- FILTRO DE CATEGORÍAS (CHIPS) ---
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
                      label: Text(
                        categories[index], 
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textBlack.withOpacity(0.7),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                        )
                      ),
                      selected: isSelected,
                      onSelected: (val) => controller.setCategory(categories[index]),
                      selectedColor: AppTheme.primaryGreen, // Verde si está seleccionado
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300
                        )
                      ),
                      showCheckmark: false, // Ocultamos el check para un diseño más limpio tipo "Píldora"
                    );
                  }),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // --- LISTADO DE RESULTADOS ---
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
              if (controller.searchResults.isEmpty) return _buildEmptyState();

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: controller.searchResults.length,
                itemBuilder: (context, index) {
                  // "pack" aquí es un MAP (JSON) que viene de Supabase
                  final packMap = controller.searchResults[index];
                  final business = packMap['businesses'];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.1),
                    color: Colors.white, // Tarjeta blanca sobre fondo crema
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: InkWell( // InkWell le da el efecto "ripple" (onda) al tocar, mejorando UX
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                         final packModel = PackModel.fromJson(packMap);
                         Get.to(() => const PackDetailScreen(), arguments: packModel);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Imagen
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: packMap['image_url'] != null 
                                ? Image.network(packMap['image_url'], width: 70, height: 70, fit: BoxFit.cover)
                                : Container(width: 70, height: 70, color: AppTheme.primaryGreen.withOpacity(0.2), child: const Icon(Icons.fastfood, color: AppTheme.primaryGreen)),
                            ),
                            const SizedBox(width: 15),
                            // Detalles
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    packMap['title'], 
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textBlack),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    business != null ? business['commercial_name'] : 'Negocio Local', 
                                    style: TextStyle(color: AppTheme.textBlack.withOpacity(0.6), fontSize: 13)
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "${packMap['price']} Bs", 
                                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryGreen, fontSize: 15) // Precio en Verde
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppTheme.disabledIcon),
                          ],
                        ),
                      ),
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
          Icon(Icons.search_off, size: 80, color: AppTheme.disabledIcon.withOpacity(0.5)),
          const SizedBox(height: 15),
          Text("No encontramos packs", style: TextStyle(color: AppTheme.textBlack.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 5),
          Text("Prueba con otra palabra o ajusta el precio", style: TextStyle(color: AppTheme.textBlack.withOpacity(0.4), fontSize: 13)),
        ],
      ),
    );
  }
}