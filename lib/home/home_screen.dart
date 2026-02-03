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

  // --- MODAL PARA CREAR PACK (Reutilizado de tu código anterior) ---
  void _showCreatePackModal(BuildContext context, PacksController controller) {
    // Usamos la misma lógica que tenías en packs_screen.dart
    // NOTA: Asegúrate de tener los imports de dart:io e image_picker en packs_controller
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                GestureDetector(
                  onTap: controller.pickImage,
                  child: Container(
                    height: 150, width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                    child: controller.pickedImage != null 
                      ? Image.file(File(controller.pickedImage!.path), fit: BoxFit.cover)
                      : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt), Text("Foto")]),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(controller: controller.titleController, decoration: const InputDecoration(labelText: "Título", border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: controller.priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Precio", border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: controller.quantityController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Cantidad", border: OutlineInputBorder())),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: controller.createPack, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: const Text("PUBLICAR", style: TextStyle(color: Colors.white)))),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
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