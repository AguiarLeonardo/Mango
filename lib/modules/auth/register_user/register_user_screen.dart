import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'register_user_controller.dart';

// ✅ CORRECCIÓN: Cambiamos de GetView a StatelessWidget
class RegisterUserScreen extends StatelessWidget { 
  const RegisterUserScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // ✅ CORRECCIÓN CLAVE: Inyectamos el controlador aquí para que exista al abrir la pantalla
    final RegisterUserController controller = Get.put(RegisterUserController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Cuenta"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- FOTO DE PERFIL ---
            Center(
              child: GestureDetector(
                onTap: controller.pickProfileImage,
                child: Obx(() {
                  return CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: controller.profileImagePath.value != null
                        ? FileImage(File(controller.profileImagePath.value!))
                        : null,
                    child: controller.profileImagePath.value == null
                        ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                        : null,
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            // --- NOMBRES Y APELLIDOS ---
            _buildTextField("Nombres", controller.firstNameController, Icons.person),
            const SizedBox(height: 15),
            _buildTextField("Apellidos", controller.lastNameController, Icons.person_outline),
            
            const SizedBox(height: 15),

            // --- CÉDULA ---
            const Text("Documento de Identidad", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Row(
              children: [
                // Dropdown V/E/J
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: DropdownButton<String>(
                    value: controller.selectedDocType.value,
                    underline: Container(),
                    items: controller.docTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) => controller.selectedDocType.value = val!,
                  ),
                )),
                const SizedBox(width: 10),
                // Input Numérico
                Expanded(
                  child: TextField(
                    controller: controller.cedulaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "12345678",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10)
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // --- TELÉFONO ---
            const Text("Teléfono Celular", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Row(
              children: [
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: DropdownButton<String>(
                    value: controller.selectedPhoneCode.value,
                    underline: Container(),
                    items: controller.phoneCodes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) => controller.selectedPhoneCode.value = val!,
                  ),
                )),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: "1234567",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10)
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // --- USERNAME ---
            _buildTextField("Nombre de Usuario (Opcional)", controller.usernameController, Icons.alternate_email),
            
            const SizedBox(height: 15),

            // --- CORREO ---
            _buildTextField("Correo Electrónico", controller.emailController, Icons.email, isEmail: true),

            const SizedBox(height: 15),

            // --- CONTRASEÑAS ---
            _buildTextField("Contraseña", controller.passwordController, Icons.lock, isPassword: true),
            const SizedBox(height: 15),
            _buildTextField("Confirmar Contraseña", controller.confirmPasswordController, Icons.lock_outline, isPassword: true),

            const SizedBox(height: 30),

            // --- BOTÓN REGISTRAR ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, 
                ),
                onPressed: controller.isLoading.value 
                    ? null 
                    : controller.registerUser, 
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("REGISTRARME", style: TextStyle(color: Colors.white, fontSize: 16)),
              )),
            ),
          ],
        ),
      ),
    );
  }

  // Helper para hacer los TextFields rápido
  Widget _buildTextField(String label, TextEditingController ctrl, IconData icon, {bool isPassword = false, bool isEmail = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}