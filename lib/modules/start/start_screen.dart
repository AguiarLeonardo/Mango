// Archivo: lib/app/modules/start/start_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart'; // O donde tengas tus colores
import 'start_controller.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializamos el controlador aquí mismo
    Get.put(StartController());

    return Scaffold(
      backgroundColor: AppColors.darkOlive, // Tu color de fondo
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tu Logo o Icono
            const Icon(Icons.eco, size: 100, color: AppColors.brightYellow),
            const SizedBox(height: 30),
            
            // Indicador de carga
            const CircularProgressIndicator(
              color: AppColors.orange,
            ),
            const SizedBox(height: 20),
            Text(
              "Cargando...", 
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            )
          ],
        ),
      ),
    );
  }
}