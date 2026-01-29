import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'modules/auth/register_user/register_user_screen.dart';
import 'modules/auth/register_business/register_business_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mango App',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.darkOlive,
        scaffoldBackgroundColor: AppColors.darkOlive,
        // Tema global de Inputs para asegurar consistencia
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.sageGreen.withOpacity(0.25),
          labelStyle: TextStyle(color: AppColors.darkOlive.withOpacity(0.6)),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.orange, width: 2)),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

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
              
              _buildMenuButton(context, "Iniciar Sesión", () => print("Ir a Login")),
              const SizedBox(height: 20),
              _buildMenuButton(context, "Registrarse como Usuario", () => Get.to(() => const RegisterUserScreen())),
              const SizedBox(height: 20),
              _buildMenuButton(context, "Registrarse como Empresa", () => Get.to(() => const RegisterBusinessScreen())),
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