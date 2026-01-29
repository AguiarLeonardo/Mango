import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../global_widgets/custom_inputs.dart';
import 'register_user_controller.dart';

class RegisterUserScreen extends StatelessWidget {
  const RegisterUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegisterUserController());

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
                  color: AppColors.white.withOpacity(0.95),
                  margin: const EdgeInsets.only(top: 10, right: 10),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("REGISTRO", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.darkOlive, letterSpacing: 1.5)),
                        const SizedBox(height: 30),

                        CustomTextField(label: "Nombres", icon: Icons.person_outline, controller: controller.namesController, onChanged: (val) => controller.user.update((u) => u?.names = val)),
                        const SizedBox(height: 15),
                        CustomTextField(label: "Apellidos", icon: Icons.person_outline, controller: controller.surnamesController, onChanged: (val) => controller.user.update((u) => u?.surnames = val)),
                        const SizedBox(height: 15),
                        Obx(() => CustomTextField(label: "Correo Electrónico", icon: Icons.email_outlined, inputType: TextInputType.emailAddress, controller: controller.emailController, onChanged: controller.validateEmail, errorText: controller.emailError.value)),
                        const SizedBox(height: 15),

                        Row(children: [
                          Container(width: 100, margin: const EdgeInsets.only(right: 10), child: Obx(() => SimpleDropdown(value: controller.user.value.phonePrefix, items: controller.phoneCodes, onChanged: (val) => controller.user.update((u) => u?.phonePrefix = val!)))),
                          Expanded(child: CustomTextField(label: "Número", icon: Icons.phone_outlined, inputType: TextInputType.number, maxLength: 7, inputFormatters: [FilteringTextInputFormatter.digitsOnly], controller: controller.phoneController, onChanged: (val) => controller.user.update((u) => u?.phoneNumber = val))),
                        ]),
                        const SizedBox(height: 15),

                        const Align(alignment: Alignment.centerLeft, child: Text("Ubicación", style: TextStyle(color: AppColors.darkOlive, fontWeight: FontWeight.bold))),
                        const SizedBox(height: 10),
                        Obx(() => CustomDropdown(label: "Estado", icon: Icons.map, value: controller.selectedState.value, items: controller.stateNames.toList(), onChanged: controller.onStateChanged)),
                        const SizedBox(height: 15),
                        Obx(() => CustomDropdown(label: "Ciudad", icon: Icons.location_city, value: controller.selectedCity.value, isDisabled: controller.selectedState.value == null, items: controller.availableCities.map((e) => e['nombre'] as String).toList(), onChanged: controller.onCityChanged)),
                        const SizedBox(height: 15),
                        Obx(() => CustomDropdown(label: "Municipio", icon: Icons.location_on_outlined, value: controller.selectedMunicipality.value, isDisabled: controller.selectedCity.value == null, items: controller.availableMunicipalities.toList(), onChanged: (val) { controller.selectedMunicipality.value = val; controller.user.update((u) => u?.municipality = val); })),

                        const SizedBox(height: 25),
                        const Divider(),
                        
                        CustomTextField(label: "Nombre de Usuario", icon: Icons.account_circle_outlined, controller: controller.usernameController, onChanged: (val) => controller.user.update((u) => u?.username = val)),
                        const SizedBox(height: 15),
                        Obx(() => CustomTextField(label: "Contraseña", icon: Icons.lock_outline, isPassword: true, controller: controller.passwordController, onChanged: (_) => controller.validatePasswords(), errorText: controller.passwordError.value)),
                        const SizedBox(height: 15),
                        Obx(() => CustomTextField(label: "Confirmar Contraseña", icon: Icons.lock_outline, isPassword: true, controller: controller.confirmPasswordController, onChanged: (_) => controller.validatePasswords(), errorText: controller.confirmPasswordError.value)),

                        const SizedBox(height: 20),
                        Row(children: [
                            Obx(() => Checkbox(value: controller.user.value.acceptedTerms, activeColor: AppColors.orange, onChanged: (val) => controller.user.update((u) => u?.acceptedTerms = val ?? false))),
                            Expanded(child: Text("Acepto los términos y condiciones.", style: TextStyle(color: AppColors.darkOlive.withOpacity(0.7), fontSize: 12))),
                        ]),
                        const SizedBox(height: 30),

                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            OutlinedButton(onPressed: () => Get.back(), style: OutlinedButton.styleFrom(foregroundColor: AppColors.darkOlive, side: const BorderSide(color: AppColors.sageGreen), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text("Atrás")),
                            ElevatedButton(onPressed: controller.register, style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text("Registrar", style: TextStyle(fontWeight: FontWeight.bold))),
                        ])
                      ],
                    ),
                  ),
                ),
                Positioned(top: 0, right: 0, child: GestureDetector(onTap: () => Get.back(), child: const CircleAvatar(backgroundColor: AppColors.darkOlive, radius: 18, child: Icon(Icons.close, color: Colors.white, size: 20)))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}