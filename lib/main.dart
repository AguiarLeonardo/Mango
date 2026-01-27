import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'register.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Registro Venezuela',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.darkOlive,
        // Configuración global para Inputs y Dropdowns para asegurar consistencia
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.sageGreen.withOpacity(0.25),
          labelStyle: TextStyle(color: AppColors.darkOlive.withOpacity(0.6)),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(12),
             borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.orange, width: 2),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

// Bloque lógico para verificar registro
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Lógica simulada: false = no registrado
    bool isRegistered = false;

    if (isRegistered) {
      // Placeholder para cuando esté registrado (ej: HomeScreen)
      return const Scaffold(body: Center(child: Text("Bienvenido Usuario Registrado")));
    } else {
      return const WelcomeScreen();
    }
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkOlive,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "MANGO",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 50),
              _buildMenuButton(context, "Iniciar Sesión", () {
                // Acción Iniciar Sesión
              }),
              const SizedBox(height: 20),
              _buildMenuButton(context, "Registrarse como Usuario", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              }),
              const SizedBox(height: 20),
              _buildMenuButton(context, "Registrarse como Empresa", () {
                // Acción Registrar Empresa
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
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}