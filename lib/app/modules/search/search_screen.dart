import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import 'search_controller.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchMyController());

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text("Explorar Negocios",
            style: TextStyle(
                color: AppTheme.textBlack, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.backgroundCream,
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
                hintText: "Busca locales, restaurantes...",
                hintStyle:
                    TextStyle(color: AppTheme.disabledIcon.withOpacity(0.8)),
                prefixIcon:
                    const Icon(Icons.search, color: AppTheme.accentOrange),
                // ✅ EMBUDO DE FILTRO A LA DERECHA
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list,
                      color: AppTheme.primaryGreen),
                  onPressed: () => _showFilterBottomSheet(context, controller),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.5)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                        color: AppTheme.accentOrange, width: 2)),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // --- LISTADO DE RESULTADOS (NEGOCIOS) ---
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primaryGreen));
              }

              // ✅ MOSTRAR ESTADO INICIAL SI NO HAY BÚSQUEDA
              if (controller.searchText.value.trim().isEmpty &&
                  controller.selectedCategory.value.isEmpty) {
                return _buildInitialState();
              }

              // ✅ MOSTRAR ESTADO VACÍO SI NO HUBO RESULTADOS
              if (controller.searchResults.isEmpty) return _buildEmptyState();

              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: controller.searchResults.length,
                itemBuilder: (context, index) {
                  final businessMap = controller.searchResults[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.1),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        // ✅ NAVEGACIÓN AL DETALLE DEL NEGOCIO
                        // Pasamos la ruta '/business-detail' y enviamos el map como argumento
                        Get.toNamed('/business-detail', arguments: businessMap);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // ✅ ICONO/LOGOTIPO DEL NEGOCIO
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.storefront,
                                  color: AppTheme.primaryGreen, size: 30),
                            ),
                            const SizedBox(width: 15),
                            // ✅ DETALLES DEL NEGOCIO
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    businessMap['commercial_name'] ?? 'Negocio',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppTheme.textBlack),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    businessMap['category'] ??
                                        'Categoría General',
                                    style: TextStyle(
                                        color:
                                            AppTheme.textBlack.withOpacity(0.6),
                                        fontSize: 13),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          size: 14,
                                          color: AppTheme.accentOrange),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          businessMap['city'] ??
                                              businessMap['address'] ??
                                              'Ubicación desconocida',
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                color: AppTheme.disabledIcon),
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

  // ✅ WIDGET DEL ESTADO INICIAL AL ABRIR EL BUSCADOR
  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search,
              size: 80, color: AppTheme.disabledIcon.withOpacity(0.3)),
          const SizedBox(height: 15),
          const Text("Explora nuestros locales",
              style: TextStyle(
                  color: AppTheme.textBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 5),
          Text("Escribe un nombre o usa el filtro de categorías",
              style: TextStyle(
                  color: AppTheme.textBlack.withOpacity(0.5), fontSize: 13)),
        ],
      ),
    );
  }

  // ✅ WIDGET DEL BOTTOM SHEET PARA EL FILTRO DE CATEGORÍAS
  void _showFilterBottomSheet(
      BuildContext context, SearchMyController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ajusta altura al contenido
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Filtrar por Categoría",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: controller.categories.map((category) {
                  return Obx(() {
                    bool isSelected =
                        controller.selectedCategory.value == category;
                    return FilterChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textBlack.withOpacity(0.7),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (val) {
                        controller.setCategory(category);
                        Get.back(); // Se cierra tras seleccionar para ver resultados rápido
                      },
                      selectedColor: AppTheme.primaryGreen,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.primaryGreen
                              : Colors.grey.shade300,
                        ),
                      ),
                      showCheckmark: false,
                    );
                  });
                }).toList(),
              ),
              const SizedBox(height: 10),

              // Botón para limpiar filtro (solo aparece si hay uno seleccionado)
              Obx(() => controller.selectedCategory.value.isNotEmpty
                  ? Center(
                      child: TextButton(
                        onPressed: () {
                          controller.selectedCategory.value = '';
                          Get.back();
                        },
                        child: const Text("Limpiar filtro",
                            style: TextStyle(color: Colors.redAccent)),
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront,
              size: 80, color: AppTheme.disabledIcon.withOpacity(0.5)),
          const SizedBox(height: 15),
          const Text("No encontramos negocios",
              style: TextStyle(
                  color: AppTheme.textBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 5),
          Text("Prueba con otra palabra o elimina el filtro",
              style: TextStyle(
                  color: AppTheme.textBlack.withOpacity(0.5), fontSize: 13)),
        ],
      ),
    );
  }
}
