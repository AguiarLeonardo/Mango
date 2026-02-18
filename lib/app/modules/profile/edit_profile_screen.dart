import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.green[800], 
      appBar: AppBar(
        title: const Text("Editar Perfil", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
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
              const SizedBox(height: 30),

              // --- FORMULARIO ---
              _buildWhiteTextField("Nombre", controller.firstNameController, Icons.person),
              const SizedBox(height: 15),
              _buildWhiteTextField("Apellido", controller.lastNameController, Icons.person_outline),
              const SizedBox(height: 15),
              _buildWhiteTextField("Nombre de Usuario", controller.usernameController, Icons.alternate_email),
              const SizedBox(height: 15),
              _buildWhiteTextField("Teléfono", controller.phoneController, Icons.phone, isNumber: true),
              const SizedBox(height: 15),
              _buildWhiteTextField("Dirección", controller.addressController, Icons.location_on),
              const SizedBox(height: 15),

              // Calendario
              _buildDatePickerField(context, "Fecha de Nacimiento", controller),
              const SizedBox(height: 15),

              // Género
              _buildGenderDropdown("Género", controller),
              const SizedBox(height: 15),
              
              _buildWhiteTextField("Correo Electrónico", controller.emailController, Icons.email, isReadOnly: true),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, 
                    foregroundColor: Colors.green[800],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                  ),
                  child: const Text("GUARDAR CAMBIOS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildWhiteTextField(String label, TextEditingController ctrl, IconData icon, {bool isNumber = false, bool isReadOnly = false}) {
    return TextField(
      controller: ctrl,
      readOnly: isReadOnly,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16), 
      decoration: _inputDecoration(label, icon),
    );
  }

  Widget _buildDatePickerField(BuildContext context, String label, ProfileController controller) {
    return TextField(
      controller: controller.birthdateController,
      readOnly: true,
      onTap: () => controller.pickDate(context),
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
      decoration: _inputDecoration(label, Icons.calendar_today),
    );
  }

  Widget _buildGenderDropdown(String label, ProfileController controller) {
    return DropdownButtonFormField<String>(
      value: controller.genderController.text.isEmpty || !controller.genderOptions.contains(controller.genderController.text) 
          ? null 
          : controller.genderController.text,
      items: controller.genderOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          controller.genderController.text = newValue;
        }
      },
      decoration: _inputDecoration(label, Icons.wc),
      dropdownColor: Colors.white,
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold),
      prefixIcon: Icon(icon, color: Colors.green[800]),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white, width: 2)),
    );
  }
}