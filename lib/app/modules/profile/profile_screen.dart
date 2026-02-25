import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'profile_controller.dart';
import 'edit_profile_screen.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text(
          "Mi Perfil",
          style: TextStyle(
            color: AppTheme.textBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Al navegar con Get.to(), Flutter añade la flecha de "Atrás" automáticamente a la izquierda
        actions: [
          // BOTÓN LÁPIZ: Lo pasamos a verde para que resalte
          IconButton(
            icon: const Icon(Icons.edit, color: AppTheme.primaryGreen),
            onPressed: () async {
              await Get.to(() => const EditProfileScreen());
              controller.loadUserProfile();
            },
          ),
        ],
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
              // --- CABECERA DEL PERFIL ---
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                // Si hay URL de foto, mostramos la imagen web
                backgroundImage: controller.avatarUrl.value.isNotEmpty
                    ? NetworkImage(controller.avatarUrl.value)
                    : null,
                // Si no hay URL, mostramos el ícono verde por defecto
                child: controller.avatarUrl.value.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 60,
                        color: AppTheme.primaryGreen,
                      )
                    : null,
              ),
              const SizedBox(height: 12),

              Text(
                controller.emailController.text,
                style: const TextStyle(
                  color: AppTheme.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // --- TARJETA DE INFORMACIÓN ---
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        "Nombre",
                        controller.firstNameController.text,
                        Icons.person,
                      ),
                      const Divider(height: 30, color: Colors.black12),

                      _buildInfoRow(
                        "Apellido",
                        controller.lastNameController.text,
                        Icons.person_outline,
                      ),
                      const Divider(height: 30, color: Colors.black12),

                      _buildInfoRow(
                        "Usuario",
                        controller.usernameController.text,
                        Icons.alternate_email,
                      ),
                      const Divider(height: 30, color: Colors.black12),

                      _buildInfoRow(
                        "Teléfono",
                        controller.phoneController.text,
                        Icons.phone_android,
                      ),
                      const Divider(height: 30, color: Colors.black12),

                      _buildInfoRow(
                        "Dirección",
                        controller.addressController.text,
                        Icons.location_on_outlined,
                      ),
                      const Divider(height: 30, color: Colors.black12),

                      // Nacimiento y Género en la misma fila para ahorrar espacio
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoRow(
                              "Nacimiento",
                              controller.birthdateController.text,
                              Icons.calendar_today,
                              isSmall: true,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.black12,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          Expanded(
                            child: _buildInfoRow(
                              "Género",
                              controller.genderController.text,
                              Icons.wc,
                              isSmall: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // --- BOTÓN DE CERRAR SESIÓN ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    Get.offAllNamed('/login');
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "CERRAR SESIÓN",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
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

  // Diseño para cada fila de información
  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    bool isSmall = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: isSmall ? 20 : 24),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textBlack.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? "Sin información" : value,
                style: const TextStyle(
                  color: AppTheme.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}