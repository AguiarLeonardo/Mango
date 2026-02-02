import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inicio"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Aquí pondremos la lógica para cerrar sesión
              Get.offAllNamed(Routes.login);
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "¡Bienvenido a Mango!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 30), // Un poco más de espacio
            
            // --- BOTÓN 1: VER PACKS ---
            SizedBox(
              width: 250, // Hacemos los botones del mismo ancho
              child: ElevatedButton.icon(
                icon: const Icon(Icons.inventory_2),
                label: const Text("Ver Packs Disponibles"),
                onPressed: () {
                  Get.toNamed(Routes.packs);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),

            const SizedBox(height: 15), // Espacio entre botones

            // --- BOTÓN 2: MIS RESERVAS (NUEVO) ---
            SizedBox(
              width: 250,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.receipt_long), // Ícono de recibo/lista
                label: const Text("Mis Reservas"),
                onPressed: () {
                  Get.toNamed(Routes.orders); // <--- Navega a la pantalla de órdenes
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Color diferente para destacar
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}