import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import 'package:supabase_flutter/supabase_flutter.dart'; // <--- AGREGA ESTO

// --- IMPORTACIONES DE TUS PANTALLAS ---
// Asegúrate de que estas rutas sean correctas en tu proyecto
import '../modules/packs/packs_screen.dart';      
import '../modules/packs/packs_controller.dart';  
import '../orders/orders_screen.dart'; // Asegúrate de que esta ruta exista

// Controlador simple para la navegación del Home
class HomeController extends GetxController {
  var currentIndex = 0.obs;
  void changeTab(int index) => currentIndex.value = index;
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController homeController = Get.put(HomeController());
  // Inyectamos el PacksController para saber si es negocio y mostrar el botón "+"
  final PacksController packsController = Get.put(PacksController());

  // LISTA DE PÁGINAS
  final List<Widget> pages = [
    PacksScreen(), 
    OrdersScreen(), // Asegúrate de que esta clase exista y esté importada
    const FavoritesView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      // Usamos IndexedStack para mantener el estado de las páginas
      body: IndexedStack(
        index: homeController.currentIndex.value,
        children: pages,
      ),
      
      // BOTÓN FLOTANTE (Solo si es pestaña 0 'Descubre' y es Negocio)
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
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Reservas'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    ));
  }

  // --- MODAL PARA CREAR PACK ---
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
              
              // Campos del formulario
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
              
              // Selector de hora CORREGIDO
              Row(
                children: [
                   Obx(() => TextButton.icon(
                    icon: const Icon(Icons.access_time),
                    // AQUÍ ESTABA EL ERROR: Agregamos .value antes del signo de exclamación y en la condición
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
                    // AQUÍ TAMBIÉN: Agregamos .value
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
              
              // Botón guardar
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
              // Espacio extra para el teclado
              Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom))
            ],
          ),
        ),
      ),
    );
  }
}

// --- CLASES PLACEHOLDER ---
class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Favoritos")), body: const Center(child: Text("Próximamente")));
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el usuario actual (si existe) para mostrar su email, opcional
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        centerTitle: true,
      ), 
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_pin, size: 100, color: Colors.grey),
              const SizedBox(height: 20),
              
              Text(
                user?.email ?? "Usuario", 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      // 1. Cerramos sesión en Supabase
                      await Supabase.instance.client.auth.signOut();
                      
                      // 2. Borramos el historial de navegación y vamos al inicio
                      // Asegúrate de que '/start' o '/login' sea la ruta correcta en tu app_pages.dart
                      Get.offAllNamed('/start'); 
                      
                    } catch(e) {
                      Get.snackbar("Error", "No se pudo cerrar sesión: $e", 
                        backgroundColor: Colors.red, colorText: Colors.white);
                    }
                  }, 
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text("Cerrar Sesión", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}