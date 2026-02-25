import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'profile_controller.dart';
import '../../core/theme/app_theme.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos .find() porque el controlador ya se inicializó en la pantalla anterior
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text(
          "Editar Perfil",
          style: TextStyle(
            color: AppTheme.textBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textBlack),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGreen),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            children: [
              // --- FOTO DE PERFIL EDITABLE (CON MAGIA DE SUPABASE) ---
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: controller.avatarUrl.value.isNotEmpty
                        ? NetworkImage(controller.avatarUrl.value)
                        : null,
                    child: controller.avatarUrl.value.isEmpty
                        ? const Icon(Icons.person, size: 60, color: AppTheme.primaryGreen)
                        : null,
                  ),
                  
                  // Capa oscura de carga (si se está subiendo la foto)
                  if (controller.isUploadingAvatar.value)
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ),

                  // Botoncito flotante para cambiar la foto
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => controller.uploadProfilePicture(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen, 
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2), // Borde blanco para resaltar
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- FORMULARIO DE EDICIÓN ---
              _buildTextField(
                label: "Nombre",
                controller: controller.firstNameController,
                icon: Icons.person,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: "Apellido",
                controller: controller.lastNameController,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: "Usuario",
                controller: controller.usernameController,
                icon: Icons.alternate_email,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: "Teléfono",
                controller: controller.phoneController,
                icon: Icons.phone_android,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: "Dirección",
                controller: controller.addressController,
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),

              // --- CAMPO DE FECHA DE NACIMIENTO ---
              GestureDetector(
                onTap: () => controller.pickDate(context),
                child: AbsorbPointer(
                  child: _buildTextField(
                    label: "Nacimiento",
                    controller: controller.birthdateController,
                    icon: Icons.calendar_today,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- DROPDOWN DE GÉNERO ---
              DropdownButtonFormField<String>(
                value: controller.genderController.text.isNotEmpty 
                    ? controller.genderController.text 
                    : null,
                items: controller.genderOptions.map((String gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.genderController.text = value;
                  }
                },
                decoration: InputDecoration(
                  labelText: "Género",
                  prefixIcon: const Icon(Icons.wc, color: AppTheme.primaryGreen),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- BOTÓN DE GUARDAR ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => controller.updateProfile(),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    "GUARDAR CAMBIOS",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // Widget auxiliar para crear los campos de texto más rápido sin repetir tanto código
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryGreen),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}