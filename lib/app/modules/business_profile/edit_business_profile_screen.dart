import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'business_profile_controller.dart';
import '../../core/theme/app_theme.dart'; // Verifica que esta ruta coincida con tu proyecto

class EditBusinessProfileScreen extends StatelessWidget {
  const EditBusinessProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyectamos el controlador (Asegúrate de haber hecho Get.put antes o usar bindings)
    final controller = Get.put(BusinessProfileController());

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text(
          "Perfil del Negocio",
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
              // --- LOGO DEL NEGOCIO ---
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: controller.logoUrl.value.isNotEmpty
                        ? NetworkImage(controller.logoUrl.value)
                        : null,
                    child: controller.logoUrl.value.isEmpty
                        ? const Icon(Icons.store, size: 60, color: AppTheme.primaryGreen)
                        : null,
                  ),
                  if (controller.isUploadingLogo.value)
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
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => controller.uploadLogo(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen, 
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
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
                label: "Nombre Comercial",
                controller: controller.commercialNameController,
                icon: Icons.storefront,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: "Categoría (Ej. Panadería, Sushi...)",
                controller: controller.categoryController,
                icon: Icons.category,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: "Teléfono",
                controller: controller.phoneController,
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: "Dirección",
                controller: controller.addressController,
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: "Ciudad",
                controller: controller.cityController,
                icon: Icons.location_city,
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