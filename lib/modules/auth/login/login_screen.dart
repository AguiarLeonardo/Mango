import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart'; 
import '../../../routes/app_routes.dart'; 

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Paleta de Colores
    final Color primaryGreen = const Color(0xFF53633C); 
    final Color borderGreen = const Color(0xFF8B9D77);
    final Color actionOrange = const Color(0xFFE68C1C);
    final Color bgCream = const Color(0xFFF2F4F0);

    return Scaffold(
      backgroundColor: bgCream,
      // --- BARRA SUPERIOR ---
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryGreen, size: 28),
          onPressed: () {
            Get.offAllNamed(Routes.welcome); 
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icono / Avatar
              Container(
                height: 100, width: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryGreen, width: 2),
                  color: Colors.white,
                ),
                child: Icon(Icons.person, size: 60, color: primaryGreen),
              ),
              const SizedBox(height: 40),

              // --- CAMPO CORREO O USUARIO ---
              TextField(
                controller: controller.emailOrUserController, // <--- Controlador actualizado
                keyboardType: TextInputType.text, // <--- Texto general para permitir usuarios
                style: TextStyle(color: primaryGreen),
                decoration: InputDecoration(
                  labelText: "Correo o Usuario", // <--- Etiqueta actualizada
                  labelStyle: TextStyle(color: borderGreen),
                  prefixIcon: Icon(Icons.person_outline, color: primaryGreen),
                  filled: true, fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: borderGreen),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: primaryGreen, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- CAMPO CONTRASEÑA ---
              Obx(() => TextField(
                controller: controller.passwordController,
                obscureText: controller.isPasswordHidden.value,
                style: TextStyle(color: primaryGreen),
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  labelStyle: TextStyle(color: borderGreen),
                  prefixIcon: Icon(Icons.lock_outline, color: primaryGreen),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility,
                      color: primaryGreen,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                  filled: true, fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: borderGreen),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: primaryGreen, width: 2),
                  ),
                ),
              )),
              
              const SizedBox(height: 10),

              // Checkbox y Olvidaste contraseña
              Row(
                children: [
                  Obx(() => Checkbox(
                    value: controller.rememberMe.value,
                    activeColor: primaryGreen,
                    onChanged: (val) => controller.rememberMe.value = val!,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  )),
                  Text("Recordarme", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      final TextEditingController resetEmailCtrl = TextEditingController();

                      Get.dialog(
                        Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0) 
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min, 
                              children: [
                                const Icon(Icons.lock_reset_rounded, size: 70, color: Color(0xFF53633C)),
                                const SizedBox(height: 20),
                                const Text(
                                  "Recuperar Contraseña",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF53633C)),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Ingresa tu correo electrónico asociado y te enviaremos un enlace de recuperación.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                                const SizedBox(height: 30),
                                TextField(
                                  controller: resetEmailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(color: Color(0xFF53633C)),
                                  decoration: InputDecoration(
                                    labelText: "Correo Electrónico",
                                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF53633C)),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(color: Color(0xFF53633C), width: 2),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      controller.sendResetPassword(resetEmailCtrl.text.trim());
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE68C1C), 
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    ),
                                    child: const Text("ENVIAR CORREO", style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                TextButton(
                                  onPressed: () => Get.back(), 
                                  child: const Text("Cancelar", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "¿Olvidaste la contraseña?",
                      style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 30),

              // Botón Login
              Obx(() => controller.isLoading.value
                  ? Center(child: CircularProgressIndicator(color: actionOrange))
                  : ElevatedButton(
                      onPressed: controller.login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: actionOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 5,
                      ),
                      child: const Text("INICIAR SESIÓN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
              ),

              const SizedBox(height: 20),

              // Link a Registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("¿No tienes cuenta? ", style: TextStyle(color: primaryGreen)),
                  GestureDetector(
                    onTap: controller.goToRegister,
                    child: Text("Regístrate aquí", style: TextStyle(color: actionOrange, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}