import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// --- CONTROLADORES ---
import 'home_controller.dart';
import '../modules/packs/packs_controller.dart';

// --- PANTALLAS ---
import '../modules/packs/packs_screen.dart';
import '../orders/orders_screen.dart';
import '../modules/profile/profile_tab.dart'; 
// IMPORTANTE: Importamos la nueva pantalla de Buscador
import '../modules/search/search_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  // Inyectamos nuestro nuevo HomeController
  final HomeController homeController = Get.put(HomeController());
  
  // Inyectamos el PacksController para el botón flotante y el modal
  final PacksController packsController = Get.put(PacksController());

  // LISTA DE PÁGINAS (Ahora son 5 incluyendo el Buscador)
  final List<Widget> pages = [
    PacksScreen(),         // Index 0: Inicio
    const SearchScreen(),  // Index 1: BUSCADOR (NUEVO)
    OrdersScreen(),        // Index 2: Reservas
    const FavoritesView(), // Index 3: Favoritos
    const ProfileTab(),    // Index 4: Perfil
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      // Mantiene el estado de las páginas al cambiar de tab
      body: IndexedStack(
        index: homeController.currentIndex.value,
        children: pages,
      ),
      
      // BOTÓN FLOTANTE (Solo visible en tab 0 'Descubre' y si es Negocio)
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
        type: BottomNavigationBarType.fixed, // Esto es vital para que se vean bien 5 iconos
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Descubre'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscador'), // <--- ÍCONO NUEVO
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Reservas'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    ));
  }

  // --- MODAL PARA CREAR PACK (UI) ---
  void _showCreatePackModal(BuildContext context, PacksController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Crear Nuevo Pack", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                ],
              ),
              const Divider(),
              
              TextField(controller: controller.titleController, decoration: const InputDecoration(labelText: "Título del Pack", prefixIcon: Icon(Icons.fastfood))),
              const SizedBox(height: 10),
              TextField(controller: controller.descController, decoration: const InputDecoration(labelText: "Descripción", prefixIcon: Icon(Icons.description)), maxLines: 2),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: controller.priceController, decoration: const InputDecoration(labelText: "Precio (Bs)", prefixIcon: Icon(Icons.attach_money)), keyboardType: TextInputType.number)),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: controller.originalPriceController, decoration: const InputDecoration(labelText: "Precio Original", prefixIcon: Icon(Icons.money_off)), keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 10),
              TextField(controller: controller.quantityController, decoration: const InputDecoration(labelText: "Cantidad Disponible", prefixIcon: Icon(Icons.inventory)), keyboardType: TextInputType.number),
              
              const SizedBox(height: 15),
              const Text("Horario de Retiro", style: TextStyle(fontWeight: FontWeight.bold)),
              
              Row(
                children: [
                    Obx(() => TextButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Text(controller.pickupStart.value == null 
                        ? "Inicio" 
                        : DateFormat('HH:mm').format(controller.pickupStart.value!)),
                    onPressed: () async {
                      final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (time != null) {
                          final now = DateTime.now();
                          controller.setPickupStart(DateTime(now.year, now.month, now.day, time.hour, time.minute));
                      }
                    },
                  )),
                  const Text(" - "),
                  Obx(() => TextButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Text(controller.pickupEnd.value == null 
                        ? "Fin" 
                        : DateFormat('HH:mm').format(controller.pickupEnd.value!)),
                    onPressed: () async {
                        final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (time != null) {
                          final now = DateTime.now();
                          controller.setPickupEnd(DateTime(now.year, now.month, now.day, time.hour, time.minute));
                      }
                    },
                  )),
                ],
              ),

              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.createPack,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, 
                    padding: const EdgeInsets.symmetric(vertical: 15)
                  ),
                  child: const Text("PUBLICAR PACK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom))
            ],
          ),
        ),
      ),
    );
  }
}

// --- SUB-VISTAS ---

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Favoritos"), centerTitle: true), 
    body: const Center(child: Text("Próximamente", style: TextStyle(color: Colors.grey)))
  );
}