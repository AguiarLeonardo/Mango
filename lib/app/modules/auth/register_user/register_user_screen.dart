import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import 'register_user_controller.dart';
import '../../../routes/app_routes.dart';

class RegisterUserScreen extends StatelessWidget {
  const RegisterUserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RegisterUserController controller = Get.put(RegisterUserController());

    final OutlineInputBorder roundedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: AppColors.sageGreen, width: 1),
    );

    return Scaffold(
      backgroundColor: AppColors.darkOlive,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.white.withOpacity(0.95),
                  margin: const EdgeInsets.only(top: 10, right: 5),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("CREAR CUENTA", 
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkOlive, letterSpacing: 1.2)
                        ),
                        const SizedBox(height: 20),

                        // --- FOTO DE PERFIL ---
                        GestureDetector(
                          onTap: controller.pickProfileImage,
                          child: Obx(() => CircleAvatar(
                            radius: 45,
                            backgroundColor: AppColors.sageGreen.withOpacity(0.2),
                            backgroundImage: controller.profileImagePath.value != null
                                ? FileImage(File(controller.profileImagePath.value!))
                                : null,
                            child: controller.profileImagePath.value == null
                                ? const Icon(Icons.camera_alt, size: 35, color: AppColors.darkOlive)
                                : null,
                          )),
                        ),
                        const SizedBox(height: 25),

                        // --- CAMPOS DE TEXTO ---
                        _buildStyledTextField("Nombres", controller.firstNameController, Icons.person, roundedBorder),
                        const SizedBox(height: 15),
                        _buildStyledTextField("Apellidos", controller.lastNameController, Icons.person_outline, roundedBorder),
                        const SizedBox(height: 15),

                        // --- CÉDULA / PASAPORTE (LÓGICA DINÁMICA) ---
                        Row(children: [
                          Container(
                            width: 90,
                            margin: const EdgeInsets.only(right: 10),
                            child: Obx(() => _buildDropdown(
                              value: controller.selectedDocType.value,
                              items: controller.docTypes,
                              onChanged: (val) {
                                controller.selectedDocType.value = val!;
                                // Opcional: Limpiar el campo si cambian de tipo para evitar errores de formato
                                controller.cedulaController.clear();
                              },
                              border: roundedBorder,
                            )),
                          ),
                          Expanded(
                            // Envolvemos en Obx para reconstruir el campo si cambia el tipo de documento
                            child: Obx(() {
                              final isPassport = controller.isPassport;
                              return _buildStyledTextField(
                                isPassport ? "Pasaporte" : "Cédula", 
                                controller.cedulaController, 
                                Icons.badge_outlined, 
                                roundedBorder, 
                                // Si es Pasaporte, permitimos Texto y Números. Si es Cédula, solo números.
                                isNumber: !isPassport, 
                                maxLength: isPassport ? 9 : 8, // 9 para pasaporte, 8 para cédula
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

                        // --- TELÉFONO (Límite 7) ---
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
                        const Divider(color: AppColors.sageGreen),
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
                        
                        const Divider(color: AppColors.sageGreen),

                        // --- USUARIO Y PASS ---
                        
                        // [MODIFICADO] Aquí aplicamos el cambio: Ya no es opcional
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
                                foregroundColor: AppColors.darkOlive,
                                side: const BorderSide(color: AppColors.sageGreen),
                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: const Text("Atrás"),
                            ),
                            Obx(() => ElevatedButton(
                              onPressed: controller.isLoading.value ? null : controller.registerUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.orange, 
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 5,
                              ),
                              child: controller.isLoading.value
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("REGISTRARME", style: TextStyle(fontWeight: FontWeight.bold)),
                            )),
                          ],
                        ),

                        // --- ESPACIO SEPARADOR ---
                        const SizedBox(height: 30),
              
                        // --- ENLACE PARA REGISTRO DE EMPRESA (Footer) ---
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "¿Tienes una empresa? ",
                                style: TextStyle(
                                  color: Color(0xFF53633C), // Verde Oliva
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Navega al registro de empresas
                                  Get.toNamed(Routes.registerBusiness); 
                                },
                                child: const Text(
                                  "Regístrala aquí",
                                  style: TextStyle(
                                    color: Color(0xFFE68C1C), // Naranja
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
                      backgroundColor: AppColors.darkOlive, 
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

  // --- WIDGETS AUXILIARES ---

  Widget _buildStyledTextField(
    String label, 
    TextEditingController ctrl, 
    IconData icon, 
    OutlineInputBorder border, 
    {
      bool isPassword = false, 
      bool isEmail = false, 
      bool isNumber = false, // Controla si abre teclado numérico
      String? errorText,          
      Function(String)? onChanged,
      int? maxLength,
    }
  ) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword,
      onChanged: onChanged, 
      // Si es número: teclado numérico. Si es email: email. Si no: texto normal (alfanumérico)
      keyboardType: isEmail ? TextInputType.emailAddress : (isNumber ? TextInputType.number : TextInputType.text),
      maxLength: maxLength,
      // Si isNumber es true, forzamos SOLO dígitos. Si es false (como en pasaporte), permite todo.
      inputFormatters: isNumber 
          ? [FilteringTextInputFormatter.digitsOnly] 
          : [], // Pasaporte permite letras y números, así que lista vacía de filtros
      style: const TextStyle(color: AppColors.darkOlive),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: AppColors.sageGreen),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(borderSide: const BorderSide(color: AppColors.orange, width: 2)),
        
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
  
  // _buildDropdown sigue igual...
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
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        border: border,
        enabledBorder: border,
        prefixIcon: icon != null ? Icon(icon, color: isDisabled ? Colors.grey : AppColors.sageGreen) : null,
        filled: true,
        fillColor: isDisabled ? Colors.grey.shade100 : Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: isDisabled ? const Text("Seleccione...") : null,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.darkOlive),
          items: isDisabled ? [] : items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val, style: const TextStyle(fontSize: 14, color: AppColors.darkOlive)),
            );
          }).toList(),
          onChanged: isDisabled ? null : onChanged,
        ),
      ),
    );
  }
}