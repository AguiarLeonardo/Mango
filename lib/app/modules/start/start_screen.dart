// Archivo: lib/app/modules/start/start_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart'; // Importamos tu nuevo Tema Global
import 'start_controller.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializamos el controlador aquí mismo
    Get.put(StartController());

    return Scaffold(
      // Usamos el color Crema para un inicio suave y luminoso
      backgroundColor: AppTheme.backgroundCream, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tu Logo o Icono en el Verde Principal de Mango
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.eco, size: 100, color: AppTheme.primaryGreen),
            ),
            const SizedBox(height: 40),
            
            // Indicador de carga en Naranja (Visibilidad del Estado del Sistema)
            const CircularProgressIndicator(
              color: AppTheme.accentOrange,
              strokeWidth: 4, // Un poco más grueso para que se vea moderno
            ),
            const SizedBox(height: 20),
            
            // Texto con la tipografía global
            Text(
              "Cargando...", 
              style: TextStyle(
                color: AppTheme.textBlack.withOpacity(0.6),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            )
          ],
        ),
      ),
    );
  }
}