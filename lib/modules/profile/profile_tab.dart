import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_controller.dart';
import 'edit_profile_screen.dart'; // <--- IMPORTANTE: Importamos la pantalla de editar

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.green[800],
      appBar: AppBar(
        title: const Text("Mi Perfil", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // BOTÓN LÁPIZ: Ahora sí funcionará porque EditProfileScreen existe
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              await Get.to(() => const EditProfileScreen());
              controller.loadUserProfile(); 
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 60, color: Colors.green),
              ),
              const SizedBox(height: 10),
              
              Text(
                controller.emailController.text,
                style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              
              const SizedBox(height: 30),

              // DATOS SOLO LECTURA
              _buildReadOnlyField("Nombre", controller.firstNameController.text, Icons.person),
              const SizedBox(height: 15),
              _buildReadOnlyField("Apellido", controller.lastNameController.text, Icons.person_outline),
              const SizedBox(height: 15),
              _buildReadOnlyField("Usuario", controller.usernameController.text, Icons.alternate_email),
              const SizedBox(height: 15),
              _buildReadOnlyField("Teléfono", controller.phoneController.text, Icons.phone),
              const SizedBox(height: 15),
              _buildReadOnlyField("Dirección", controller.addressController.text, Icons.location_on),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(child: _buildReadOnlyField("Nacimiento", controller.birthdateController.text, Icons.calendar_today)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildReadOnlyField("Género", controller.genderController.text, Icons.wc)),
                ],
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    Get.offAllNamed('/login'); 
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text("CERRAR SESIÓN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF5350),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
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

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[800], size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? "Sin información" : value,
                  style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}