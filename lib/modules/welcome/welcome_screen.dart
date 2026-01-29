import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkOlive,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.eco, size: 80, color: AppColors.brightYellow),
              const SizedBox(height: 20),
              const Text("MANGO", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.white, letterSpacing: 2)),
              const SizedBox(height: 50),
              
              // Botón 1: Login
              _buildMenuButton(context, "Iniciar Sesión", () {
                 Get.toNamed(Routes.login);
              }),
              const SizedBox(height: 20),
              
              // Botón 2: Registro Usuario (Ahora es el principal)
              _buildMenuButton(context, "Crear Cuenta", () { // Le cambié el texto a algo más corto y directo
                 Get.toNamed(Routes.registerUser);
              }),
              
              // --- AQUÍ ELIMINAMOS EL BOTÓN DE EMPRESA ---
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
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}