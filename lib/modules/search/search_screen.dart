import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'search_controller.dart';
import 'business_detail_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyectamos el controlador
    final controller = Get.put(SearchMyController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Explorar Negocios", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, 
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // --- 1. BARRA DE BÚSQUEDA ---
            TextField(
              controller: controller.searchInput,
              onChanged: (val) {
                // [IMPORTANTE] Actualizamos la variable observable para activar la búsqueda
                controller.searchText.value = val; 
                
                // Si borran todo, limpiamos la lista visualmente
                if (val.isEmpty) controller.searchResults.clear();
              }, 
              decoration: InputDecoration(
                hintText: "Busca 'PAWER', 'KFC'...",
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
            
            const SizedBox(height: 15),

            // --- 2. FILTROS VISUALES (Chips) ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row( 
                children: [
                  _buildFilterChip("Comida", controller),
                  const SizedBox(width: 10),
                  _buildFilterChip("Precio", controller),
                  const SizedBox(width: 10),
                  _buildFilterChip("Valoración", controller),
                  const SizedBox(width: 10),
                  _buildFilterChip("Cercanía", controller),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- 3. LISTA DE RESULTADOS ---
            Expanded(
              child: Obx(() {
                // ESTADO: Cargando
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: Colors.green));
                }

                // ESTADO: Buscador vacío (Inicio)
                if (controller.searchText.value.isEmpty && controller.searchResults.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.storefront, size: 80, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("Escribe el nombre de un comercio", style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  );
                }

                // ESTADO: Sin resultados (Solo si ya escribieron algo y no hubo coincidencias)
                if (controller.searchResults.isEmpty && controller.searchText.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        const Text("No encontramos negocios con ese nombre", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                // ESTADO: Resultados encontrados (Lista de Negocios)
                return ListView.builder(
                  itemCount: controller.searchResults.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final business = controller.searchResults[index];
                    
                    final name = business['commercial_name'] ?? business['legal_name'] ?? "Negocio sin nombre";
                    final address = business['address'] ?? "Dirección no disponible";
                    final category = business['category'] ?? "Comercio";

                    return Card(
                      elevation: 3,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: const EdgeInsets.only(bottom: 15),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          Get.to(() => BusinessDetailScreen(businessData: business));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.green[50],
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                                  style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 24),
                                ),
                              ),
                              const SizedBox(width: 15),
                              
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[50],
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        category.toUpperCase(),
                                        style: TextStyle(fontSize: 10, color: Colors.orange[800], fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      address,
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
      ),
    );
  }

  // Widget auxiliar para los chips de filtro
  Widget _buildFilterChip(String label, SearchMyController controller) {
    return Obx(() {
      bool isSelected = controller.selectedFilter.value == label;
      return FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          controller.setFilter(selected ? label : '');
        },
        selectedColor: Colors.green[100],
        checkmarkColor: Colors.green[800],
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), 
          side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300)
        ),
        labelStyle: TextStyle(
          color: isSelected ? Colors.green[900] : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      );
    });
  }
}