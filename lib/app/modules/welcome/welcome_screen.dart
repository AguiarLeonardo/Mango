import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import 'welcome_controller.dart'; 

class WelcomeScreen extends GetView<WelcomeController> {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Esto asegura que el controlador se inicialice si no se hizo en el binding
    Get.put(WelcomeController()); 

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream, // Cambiado al fondo fresco y limpio
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo con el verde principal y un fondo sutil
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.eco, size: 80, color: AppTheme.primaryGreen), 
              ),
              const SizedBox(height: 20),
              
              // Título actualizado al color de la marca
              const Text(
                "MANGO", 
                style: TextStyle(
                  fontSize: 40, 
                  fontWeight: FontWeight.bold, 
                  color: AppTheme.primaryGreen, // Texto verde en lugar de blanco
                  letterSpacing: 2
                )
              ),
              const SizedBox(height: 50),
              
              _buildMenuButton(context, "Iniciar Sesión", () {
                 Get.toNamed(Routes.login);
              }),
              const SizedBox(height: 20),
              
              _buildMenuButton(context, "Crear Cuenta", () {
                 Get.toNamed(Routes.registerUser);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentOrange,
          foregroundColor: Colors.white,
          elevation: 2, // Bajé un poquito la sombra para un diseño más plano y moderno
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}