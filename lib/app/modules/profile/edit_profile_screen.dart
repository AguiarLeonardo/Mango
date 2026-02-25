import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';
import '../../core/theme/app_theme.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    final OutlineInputBorder roundedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
    );

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textBlack),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGreen),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- CABECERA DE IMAGEN EDITABLE ---
                  Center(
                    child: GestureDetector(
                      onTap: controller.pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Obx(() => CircleAvatar(
                                radius: 50,
                                backgroundColor: AppTheme.backgroundCream,
                                backgroundImage: controller
                                            .selectedImage.value !=
                                        null
                                    ? FileImage(controller.selectedImage.value!)
                                    : null,
                                child: controller.selectedImage.value == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: AppTheme.primaryGreen,
                                      )
                                    : null,
                              )),
                          // Icono '+' en la parte inferior derecha
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- FORMULARIO ---
                  _buildStyledTextField(
                    "Nombre",
                    controller.firstNameController,
                    Icons.person,
                    roundedBorder,
                  ),
                  const SizedBox(height: 15),
                  _buildStyledTextField(
                    "Apellido",
                    controller.lastNameController,
                    Icons.person_outline,
                    roundedBorder,
                  ),
                  const SizedBox(height: 15),
                  _buildStyledTextField(
                    "Nombre de Usuario",
                    controller.usernameController,
                    Icons.alternate_email,
                    roundedBorder,
                  ),
                  const SizedBox(height: 15),
                  _buildStyledTextField(
                    "Teléfono",
                    controller.phoneController,
                    Icons.phone_android,
                    roundedBorder,
                    isNumber: true,
                  ),
                  const SizedBox(height: 15),
                  _buildStyledTextField(
                    "Dirección",
                    controller.addressController,
                    Icons.location_on_outlined,
                    roundedBorder,
                  ),
                  const SizedBox(height: 15),

                  // --- CALENDARIO ---
                  _buildDatePickerField(
                    context,
                    "Fecha de Nacimiento",
                    controller,
                    roundedBorder,
                  ),
                  const SizedBox(height: 15),

                  // --- GÉNERO ---
                  _buildGenderDropdown("Género", controller, roundedBorder),
                  const SizedBox(height: 15),

                  // --- CORREO (Solo lectura) ---
                  _buildStyledTextField(
                    "Correo Electrónico",
                    controller.emailController,
                    Icons.email_outlined,
                    roundedBorder,
                    isReadOnly: true,
                  ),

                  const SizedBox(height: 40),

                  // --- BOTÓN DE GUARDAR ---
                  ElevatedButton(
                    onPressed: controller.updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "GUARDAR CAMBIOS",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // --- WIDGETS AUXILIARES REDISEÑADOS ---

  Widget _buildStyledTextField(
    String label,
    TextEditingController ctrl,
    IconData icon,
    OutlineInputBorder border, {
    bool isNumber = false,
    bool isReadOnly = false,
  }) {
    return TextField(
      controller: ctrl,
      readOnly: isReadOnly,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      style: TextStyle(
        color: isReadOnly ? AppTheme.disabledIcon : AppTheme.textBlack,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.textBlack.withOpacity(0.6)),
        prefixIcon: Icon(
          icon,
          color: isReadOnly ? AppTheme.disabledIcon : AppTheme.primaryGreen,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppTheme.accentOrange, width: 2),
        ),
        filled: true,
        fillColor: isReadOnly ? AppTheme.disabledBackground : Colors.white,
      ),
    );
  }

  Widget _buildDatePickerField(
    BuildContext context,
    String label,
    ProfileController controller,
    OutlineInputBorder border,
  ) {
    return TextField(
      controller: controller.birthdateController,
      readOnly: true,
      onTap: () => controller.pickDate(context),
      style: const TextStyle(color: AppTheme.textBlack, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.textBlack.withOpacity(0.6)),
        prefixIcon: const Icon(
          Icons.calendar_today,
          color: AppTheme.primaryGreen,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppTheme.accentOrange, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildGenderDropdown(
    String label,
    ProfileController controller,
    OutlineInputBorder border,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: controller.genderController.text.isEmpty ||
              !controller.genderOptions.contains(
                controller.genderController.text,
              )
          ? null
          : controller.genderController.text,
      items: controller.genderOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: const TextStyle(color: AppTheme.textBlack, fontSize: 16),
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          controller.genderController.text = newValue;
        }
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.textBlack.withOpacity(0.6)),
        prefixIcon: const Icon(Icons.wc, color: AppTheme.primaryGreen),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppTheme.accentOrange, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      dropdownColor: Colors.white,
      icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryGreen),
    );
  }
}
