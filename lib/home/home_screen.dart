import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Importamos nuestros controladores y pantallas de detalle
import '../modules/packs/packs_controller.dart';
import '../routes/app_routes.dart';

class HomeController extends GetxController {
  var currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  // Inicializamos AMBOS controladores
  final HomeController homeController = Get.put(HomeController());
  final PacksController packsController = Get.put(PacksController());

  // Definimos las vistas aquí para que el código quede limpio
  final List<Widget> pages = [
    DiscoverView(),   // Aquí estará nuestra lógica de packs
    const BrowseView(),
    const FavoritesView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      body: IndexedStack(
        index: homeController.currentIndex.value,
        children: pages,
      ),
      
      // --- LOGICA DEL BOTÓN FLOTANTE (FAB) ---
      // Solo mostramos el botón si:
      // 1. Estamos en la pestaña 0 (Descubre)
      // 2. El usuario es una Empresa (isBusiness es true)
      floatingActionButton: (homeController.currentIndex.value == 0 && packsController.isBusiness.value)
          ? FloatingActionButton.extended(
              onPressed: () => _showCreatePackModal(context, packsController),
              label: const Text("Nuevo Pack"),
              icon: const Icon(Icons.add_business),
              backgroundColor: Colors.orange,
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: homeController.currentIndex.value,
        onTap: homeController.changeTab,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Descubre'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explora'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    ));
  }

  // --- MODAL PARA CREAR PACK (VERSIÓN COMPLETA Y CORREGIDA) ---
  void _showCreatePackModal(BuildContext context, PacksController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        height: Get.height * 0.85, // Ocupa el 85% de la pantalla
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: GetBuilder<PacksController>(
            builder: (_) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Crear Nuevo Pack", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                  ],
                ),
                const SizedBox(height: 20),

                // 1. FOTO
                GestureDetector(
                  onTap: controller.pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!)
                    ),
                    child: controller.pickedImage != null 
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(File(controller.pickedImage!.path), fit: BoxFit.cover)
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40, color: Colors.grey[400]),
                            const SizedBox(height: 5),
                            Text("Toca para agregar foto", style: TextStyle(color: Colors.grey[600]))
                          ],
                        ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. TÍTULO Y DESCRIPCIÓN
                TextField(
                  controller: controller.titleController,
                  decoration: const InputDecoration(
                    labelText: "Título del Pack",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.fastfood),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: controller.descController,
                  maxLines: 3, 
                  decoration: const InputDecoration(
                    labelText: "Descripción (¿Qué incluye?)",
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 15),

                // 3. PRECIOS Y STOCK
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.originalPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Precio Original",
                          suffixText: "\$",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: controller.priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Precio Oferta",
                          suffixText: "\$",
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(color: Colors.green)
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: controller.quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Cantidad Disponible",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.inventory),
                  ),
                ),
                const SizedBox(height: 15),

                // 4. HORARIOS DE RETIRO
                const Text("Horario de Retiro:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: Text(controller.pickupStart == null 
                          ? "Inicio" 
                          : "${controller.pickupStart!.hour}:${controller.pickupStart!.minute.toString().padLeft(2, '0')}"),
                        onPressed: () async {
                          final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                          if (time != null) {
                            final now = DateTime.now();
                            controller.setPickupStart(DateTime(now.year, now.month, now.day, time.hour, time.minute));
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text("-"),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time_filled),
                        label: Text(controller.pickupEnd == null 
                          ? "Fin" 
                          : "${controller.pickupEnd!.hour}:${controller.pickupEnd!.minute.toString().padLeft(2, '0')}"),
                        onPressed: () async {
                          final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                          if (time != null) {
                            final now = DateTime.now();
                            controller.setPickupEnd(DateTime(now.year, now.month, now.day, time.hour, time.minute));
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 5. BOTÓN FINAL
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(); // Cerramos el modal
                      controller.createPack(); // Creamos el pack
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    child: const Text("PUBLICAR PACK AHORA", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true, // Importante para que el teclado no tape el formulario
    );
  }
}

// --- VISTA DESCUBRE (INTEGRADA CON PACKS CONTROLLER) ---
class DiscoverView extends StatelessWidget {
  // Buscamos el controlador que ya inyectamos en el HomeScreen
  final PacksController controller = Get.find<PacksController>();

  DiscoverView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Descubre Packs'),
        automaticallyImplyLeading: false, // Quitamos flecha de atrás
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

        // Usamos el GridView que ya tenías
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

  Widget _buildPackCard(Map<String, dynamic> pack) {
    final business = pack['businesses'] ?? {};
    final String title = pack['title'] ?? 'Pack Sorpresa';
    final String price = pack['price'].toString();
    final String? imageUrl = pack['image_url'];

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.packDetail, arguments: pack),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: imageUrl != null 
                ? Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity)
                : Container(color: Colors.grey[300], child: const Icon(Icons.fastfood, size: 50, color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
                  Text(business['commercial_name'] ?? 'Comercio', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("\$$price", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      if (pack['quantity_available'] != null)
                        Text("${pack['quantity_available']} disp.", style: TextStyle(fontSize: 10, color: Colors.orange[900])),
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
}

// --- OTRAS VISTAS (PLACEHOLDERS) ---
class BrowseView extends StatelessWidget {
  const BrowseView({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Explora por categoría (Próximamente)'));
}

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Tus favoritos (Próximamente)'));
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => Get.offAllNamed(Routes.login),
        child: const Text("Cerrar Sesión"),
      ),
    );
  }
}