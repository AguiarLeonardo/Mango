import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart'; 
import '../../../routes/app_routes.dart'; 
import '../../../core/theme/app_theme.dart'; // Asegúrate de que la ruta sea correcta

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Definimos el borde consistente que usamos en toda la app
    final OutlineInputBorder roundedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12), 
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
    );

    return Scaffold(
      backgroundColor: AppTheme.primaryGreen, // Fondo crema unificado
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textBlack, size: 28),
          onPressed: () => Get.offAllNamed(Routes.welcome), 
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // --- TARJETA BLANCA DE LOGIN ---
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Icono / Avatar
                      const Center(
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: AppTheme.backgroundCream,
                          child: Icon(Icons.person, size: 50, color: AppTheme.primaryGreen),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- CAMPO CORREO O USUARIO ---
                      _buildLoginTextField(
                        label: "Correo o Usuario",
                        ctrl: controller.emailOrUserController,
                        icon: Icons.person_outline,
                        border: roundedBorder,
                      ),
                      const SizedBox(height: 15),

                      // --- CAMPO CONTRASEÑA ---
                      Obx(() => _buildLoginTextField(
                        label: "Contraseña",
                        ctrl: controller.passwordController,
                        icon: Icons.lock_outline,
                        border: roundedBorder,
                        isPassword: true,
                        obscureText: controller.isPasswordHidden.value,
                        toggleVisibility: controller.togglePasswordVisibility,
                      )),
                      
                      const SizedBox(height: 10),

                      // Checkbox y Olvidaste contraseña
                      Row(
                        children: [
                          Obx(() => SizedBox(
                            width: 24,
                            child: Checkbox(
                              value: controller.rememberMe.value,
                              activeColor: AppTheme.primaryGreen,
                              onChanged: (val) => controller.rememberMe.value = val!,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          )),
                          const SizedBox(width: 8),
                          const Text("Recordarme", style: TextStyle(color: AppTheme.textBlack, fontSize: 14)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _showForgotPasswordDialog(context, controller),
                            child: const Text(
                              "¿Olvidaste la contraseña?",
                              style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Botón Login
                      Obx(() => controller.isLoading.value
                          ? const Center(child: CircularProgressIndicator(color: AppTheme.accentOrange))
                          : ElevatedButton(
                              onPressed: controller.login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Text("INICIAR SESIÓN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Link a Registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿No tienes cuenta? ", style: TextStyle(color: AppTheme.textBlack)),
                  GestureDetector(
                    onTap: controller.goToRegister,
                    child: const Text(
                      "Regístrate aquí", 
                      style: TextStyle(color: AppTheme.accentOrange, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET DE CAMPO DE TEXTO REUTILIZABLE ---
  Widget _buildLoginTextField({
    required String label,
    required TextEditingController ctrl,
    required IconData icon,
    required OutlineInputBorder border,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleVisibility,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscureText,
      style: const TextStyle(color: AppTheme.textBlack, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.textBlack.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: AppTheme.primaryGreen),
        suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: AppTheme.primaryGreen),
                onPressed: toggleVisibility,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        filled: true,
        fillColor: Colors.white,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(borderSide: const BorderSide(color: AppTheme.accentOrange, width: 2)),
      ),
    );
  }

  // --- DIÁLOGO DE RECUPERACIÓN ESTILIZADO ---
  void _showForgotPasswordDialog(BuildContext context, LoginController controller) {
    final TextEditingController resetEmailCtrl = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_reset_rounded, size: 60, color: AppTheme.primaryGreen),
              const SizedBox(height: 16),
              const Text("Recuperar Contraseña", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textBlack)),
              const SizedBox(height: 8),
              const Text("Enviaremos un enlace a tu correo.", 
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              TextField(
                controller: resetEmailCtrl,
                decoration: InputDecoration(
                  labelText: "Correo Electrónico",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.sendResetPassword(resetEmailCtrl.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("ENVIAR CORREO", style: TextStyle(color: Colors.white)),
                ),
              ),
              TextButton(onPressed: () => Get.back(), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
            ],
          ),
        ),
      ),
    );
  }
}