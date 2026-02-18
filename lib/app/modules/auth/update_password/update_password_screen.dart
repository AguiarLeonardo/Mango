import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../routes/app_routes.dart'; 

class UpdatePasswordController extends GetxController {
  final passwordController = TextEditingController();
  final isLoading = false.obs;

  Future<void> updatePassword() async {
    if (passwordController.text.length < 6) {
      Get.snackbar("Error", "La contraseña debe tener al menos 6 caracteres", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      // Actualizamos el usuario con la nueva clave
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: passwordController.text),
      );

      Get.snackbar("¡Éxito!", "Contraseña actualizada correctamente", backgroundColor: Colors.green, colorText: Colors.white);
      
      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed(Routes.home); // O al Login si prefieres

    } catch (e) {
      Get.snackbar("Error", "No se pudo actualizar: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}

class UpdatePasswordScreen extends StatelessWidget {
  const UpdatePasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdatePasswordController());
    
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F0), // Crema
      appBar: AppBar(title: const Text("Nueva Contraseña"), backgroundColor: Colors.transparent, elevation: 0, foregroundColor: const Color(0xFF53633C)),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Crea tu nueva contraseña", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF53633C))),
            const SizedBox(height: 20),
            TextField(
              controller: controller.passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Nueva Contraseña",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 30),
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE68C1C), // Naranja
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: controller.isLoading.value 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("ACTUALIZAR CONTRASEÑA", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )),
          ],
        ),
      ),
    );
  }
}