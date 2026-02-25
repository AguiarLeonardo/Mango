import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import 'register_user_controller.dart';
import '../../../routes/app_routes.dart';

class RegisterUserScreen extends StatelessWidget {
  const RegisterUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterUserController controller = Get.put(RegisterUserController());

    final OutlineInputBorder roundedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12), 
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
    );

    return Scaffold(
      backgroundColor: AppTheme.primaryGreen, 
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Card(
                  elevation: 2, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.white, 
                  margin: const EdgeInsets.only(top: 10, right: 5),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("CREAR CUENTA", 
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryGreen, 
                            fontWeight: FontWeight.bold, 
                            letterSpacing: 1.2
                          )
                        ),
                        const SizedBox(height: 20),

                        // --- FOTO DE PERFIL ---
                        GestureDetector(
                          onTap: controller.pickProfileImage,
                          child: Obx(() {
                            final imagePath = controller.profileImagePath.value;
                            ImageProvider? bgImage;
                            
                            if (imagePath != null) {
                              if (GetPlatform.isWeb) {
                                bgImage = NetworkImage(imagePath);
                              } else {
                                bgImage = FileImage(File(imagePath));
                              }
                            }

                            return CircleAvatar(
                              radius: 45,
                              backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                              backgroundImage: bgImage,
                              child: imagePath == null
                                  ? const Icon(Icons.camera_alt, size: 35, color: AppTheme.primaryGreen)
                                  : null,
                            );
                          }),
                        ),
                        const SizedBox(height: 25),

                        // --- CAMPOS DE TEXTO ---
                        _buildStyledTextField("Nombres", controller.firstNameController, Icons.person, roundedBorder),
                        const SizedBox(height: 15),
                        _buildStyledTextField("Apellidos", controller.lastNameController, Icons.person_outline, roundedBorder),
                        const SizedBox(height: 15),

                        // --- CÉDULA / PASAPORTE ---
                        Row(children: [
                          Container(
                            width: 90,
                            margin: const EdgeInsets.only(right: 10),
                            child: Obx(() => _buildDropdown(
                              value: controller.selectedDocType.value,
                              items: controller.docTypes,
                              onChanged: (val) {
                                controller.selectedDocType.value = val!;
                                controller.cedulaController.clear();
                              },
                              border: roundedBorder,
                            )),
                          ),
                          Expanded(
                            child: Obx(() {
                              final isPassport = controller.isPassport;
                              return _buildStyledTextField(
                                isPassport ? "Pasaporte" : "Cédula", 
                                controller.cedulaController, 
                                Icons.badge_outlined, 
                                roundedBorder, 
                                isNumber: !isPassport, 
                                maxLength: isPassport ? 9 : 8,
                              );
                            }),
                          ),
                        ]),
                        const SizedBox(height: 15),

                        // --- CORREO ---
                        Obx(() => _buildStyledTextField(
                          "Correo Electrónico", 
                          controller.emailController, 
                          Icons.email_outlined, 
                          roundedBorder, 
                          isEmail: true,
                          errorText: controller.emailError.value, 
                          onChanged: controller.validateEmail, 
                        )),
                        const SizedBox(height: 15),

                        // --- TELÉFONO ---
                        Row(children: [
                          Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 10),
                            child: Obx(() => _buildDropdown(
                              value: controller.selectedPhoneCode.value,
                              items: controller.phoneCodes,
                              onChanged: (val) => controller.selectedPhoneCode.value = val!,
                              border: roundedBorder,
                            )),
                          ),
                          Expanded(
                            child: _buildStyledTextField(
                              "Teléfono", 
                              controller.phoneController, 
                              Icons.phone_android, 
                              roundedBorder, 
                              isNumber: true,
                              maxLength: 7 
                            ),
                          ),
                        ]),
                        const SizedBox(height: 20),

                        // --- UBICACIÓN ---
                        Divider(color: Colors.grey.shade200),
                        const SizedBox(height: 10),
                        
                        Obx(() => _buildDropdown(
                          label: "Estado",
                          value: controller.selectedState.value,
                          items: controller.stateNames,
                          onChanged: controller.onStateChanged,
                          border: roundedBorder,
                          icon: Icons.map
                        )),
                        const SizedBox(height: 10),
                        Obx(() => _buildDropdown(
                          label: "Ciudad",
                          value: controller.selectedCity.value,
                          items: controller.availableCities.map((e) => e['nombre'] as String).toList(),
                          onChanged: controller.onCityChanged,
                          border: roundedBorder,
                          isDisabled: controller.selectedState.value == null,
                          icon: Icons.location_city
                        )),
                        const SizedBox(height: 10),
                        Obx(() => _buildDropdown(
                          label: "Municipio",
                          value: controller.selectedMunicipality.value,
                          items: controller.availableMunicipalities,
                          onChanged: (val) => controller.selectedMunicipality.value = val,
                          border: roundedBorder,
                          isDisabled: controller.selectedCity.value == null,
                          icon: Icons.location_on
                        )),
                         const SizedBox(height: 10),
                        _buildStyledTextField("Dirección detallada", controller.addressController, Icons.home_filled, roundedBorder),
                        const SizedBox(height: 20),
                        
                        Divider(color: Colors.grey.shade200),

                        // --- USUARIO Y PASS ---
                        _buildStyledTextField(
                          "Nombre de Usuario", 
                          controller.usernameController, 
                          Icons.alternate_email, 
                          roundedBorder
                        ),
                        
                        const SizedBox(height: 15),
                        
                        Obx(() => _buildStyledTextField(
                          "Contraseña", 
                          controller.passwordController, 
                          Icons.lock_outline, 
                          roundedBorder, 
                          isPassword: true,
                          errorText: controller.passwordError.value,
                          onChanged: controller.validatePassword
                        )),
                        const SizedBox(height: 15),
                        _buildStyledTextField("Confirmar Contraseña", controller.confirmPasswordController, Icons.lock_outline, roundedBorder, isPassword: true),

                        const SizedBox(height: 30),

                        // --- BOTONES (Atrás y Registrar) ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.textBlack.withOpacity(0.6),
                                side: BorderSide(color: Colors.grey.shade400),
                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
                              ),
                              child: const Text("Atrás"),
                            ),
                            Obx(() => ElevatedButton(
                              onPressed: controller.isLoading.value ? null : controller.registerUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentOrange, 
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: controller.isLoading.value
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("REGISTRARME", style: TextStyle(fontWeight: FontWeight.bold)),
                            )),
                          ],
                        ),

                        const SizedBox(height: 30),
              
                        // --- ENLACE PARA REGISTRO DE EMPRESA ---
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "¿Tienes una empresa? ",
                                style: TextStyle(
                                  color: AppTheme.textBlack.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Get.toNamed(Routes.registerBusiness),
                                child: const Text(
                                  "Regístrala aquí",
                                  style: TextStyle(
                                    color: AppTheme.accentOrange, 
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0, right: 0, 
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: const CircleAvatar(
                      backgroundColor: AppTheme.textBlack, 
                      radius: 18, 
                      child: Icon(Icons.close, color: Colors.white, size: 20)
                    )
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // AQUÍ ESTÁN LOS MÉTODOS QUE FALTABAN
  // ==========================================

  Widget _buildStyledTextField(
    String label, 
    TextEditingController ctrl, 
    IconData icon, 
    OutlineInputBorder border, 
    {
      bool isPassword = false, 
      bool isEmail = false, 
      bool isNumber = false, 
      String? errorText,          
      Function(String)? onChanged,
      int? maxLength,
    }
  ) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword,
      onChanged: onChanged, 
      keyboardType: isEmail ? TextInputType.emailAddress : (isNumber ? TextInputType.number : TextInputType.text),
      maxLength: maxLength,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.textBlack.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: AppTheme.primaryGreen),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(borderSide: const BorderSide(color: AppTheme.accentOrange, width: 2)), 
        
        errorText: errorText, 
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12), 
        errorBorder: border.copyWith(borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
        focusedErrorBorder: border.copyWith(borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
        errorMaxLines: 3,

        counterText: "", 
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
  
  Widget _buildDropdown({
    required String? value, 
    required List<String> items, 
    required Function(String?) onChanged, 
    required OutlineInputBorder border, 
    String? label,
    IconData? icon,
    bool isDisabled = false
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDisabled ? AppTheme.disabledIcon : AppTheme.textBlack.withOpacity(0.6)),
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(borderSide: const BorderSide(color: AppTheme.accentOrange, width: 2)),
        prefixIcon: icon != null ? Icon(icon, color: isDisabled ? AppTheme.disabledIcon : AppTheme.primaryGreen) : null,
        filled: true,
        fillColor: isDisabled ? AppTheme.disabledBackground : Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: isDisabled ? const Text("Seleccione...") : null,
          icon: Icon(Icons.arrow_drop_down, color: isDisabled ? AppTheme.disabledIcon : AppTheme.primaryGreen),
          items: isDisabled ? [] : items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: isDisabled ? null : onChanged,
        ),
      ),
    );
  }
}