import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../global_widgets/custom_inputs.dart';
import 'register_business_controller.dart';


class RegisterBusinessScreen extends StatelessWidget {
  const RegisterBusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyectamos el controlador
    final controller = Get.put(RegisterBusinessController());

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- ENCABEZADO ---
                        const Center(
                          child: Text("EMPRESA", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.darkOlive, letterSpacing: 1.5)),
                        ),
                        const Center(
                          child: Text("Únete a Mango", style: TextStyle(color: AppColors.sageGreen, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 30),

                        // --- SECCIONES DEL FORMULARIO ---
                        
                        // 1. Datos Comerciales
                        _buildSectionTitle("1. Información Comercial"),
                        _buildCommercialSection(controller),
                        const SizedBox(height: 25),

                        // 2. Datos Operativos (Ubicación Geográfica)
                        _buildSectionTitle("2. Datos Operativos"),
                        _buildOperationalDataSection(controller),
                        const SizedBox(height: 25),

                        // 3. Datos Legales (RIF y Foto)
                        _buildSectionTitle("3. Datos Legales"),
                        _buildLegalSection(controller),
                        const SizedBox(height: 25),

                        // 4. Seguridad (Nuevo)
                        _buildSectionTitle("4. Seguridad de la Cuenta"),
                        _buildSecuritySection(controller),
                        const SizedBox(height: 30),

                        // Términos y Botones
                        _buildTermsAndActions(controller),
                      ],
                    ),
                  ),
                ),
                
                // Botón Cerrar (X)
                Positioned(
                  top: 0, right: 0,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: const CircleAvatar(backgroundColor: AppColors.darkOlive, radius: 18, child: Icon(Icons.close, color: Colors.white, size: 20)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGETS DE SECCIÓN (Para mantener el código ordenado)
  // ===========================================================================

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Text(
        title, 
        style: const TextStyle(color: AppColors.darkOlive, fontWeight: FontWeight.bold, fontSize: 16)
      ),
    );
  }

  // --- SECCIÓN 1: COMERCIAL ---
  Widget _buildCommercialSection(RegisterBusinessController controller) {
    return Column(
      children: [
        CustomTextField(
          label: "Nombre Comercial *", 
          icon: Icons.store_mall_directory_outlined, 
          controller: controller.commercialNameController, 
          onChanged: (val) => controller.business.update((b) => b?.commercialName = val)
        ),
        const SizedBox(height: 15),
        CustomTextField(
          label: "Slogan / Descripción Corta", 
          icon: Icons.description_outlined, 
          controller: controller.shortDescController, 
          maxLength: 100, 
          onChanged: (val) => controller.business.update((b) => b?.shortDesc = val)
        ),
        const SizedBox(height: 15),
        Obx(() => CustomDropdown(
          label: "Categoría *", 
          icon: Icons.category_outlined, 
          value: controller.business.value.category, 
          items: controller.categories, 
          onChanged: (val) => controller.business.update((b) => b?.category = val)
        )),
      ],
    );
  }

  // --- SECCIÓN 2: OPERATIVA (UBICACIÓN + CONTACTO) ---
  Widget _buildOperationalDataSection(RegisterBusinessController controller) {
    return Column(
      children: [
        // Dropdown Estado
        Obx(() => CustomDropdown(
          label: "Estado",
          icon: Icons.map,
          value: controller.selectedState.value,
          items: controller.stateNames.toList(),
          onChanged: controller.onStateChanged,
        )),
        const SizedBox(height: 15),
        
        // Dropdown Ciudad
        Obx(() => CustomDropdown(
          label: "Ciudad",
          icon: Icons.location_city,
          value: controller.selectedCity.value,
          isDisabled: controller.selectedState.value == null,
          items: controller.availableCities.map((e) => e['nombre'] as String).toList(),
          onChanged: controller.onCityChanged,
        )),
        const SizedBox(height: 15),

        // Dropdown Municipio
        Obx(() => CustomDropdown(
          label: "Municipio",
          icon: Icons.location_on_outlined,
          value: controller.selectedMunicipality.value,
          isDisabled: controller.selectedCity.value == null,
          items: controller.availableMunicipalities.toList(),
          onChanged: (val) => controller.selectedMunicipality.value = val,
        )),
        const SizedBox(height: 15),

        // Dirección Física
        CustomTextField(
          label: "Dirección Escrita (Calle/Edificio) *", 
          icon: Icons.map_outlined,
          maxLines: 2,
          controller: controller.addressController,
          onChanged: (val) => controller.business.update((b) => b?.address = val)
        ),
        const SizedBox(height: 15),

        // Teléfono
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100, 
              margin: const EdgeInsets.only(right: 10), 
              child: Obx(() => SimpleDropdown(
                value: controller.business.value.phonePrefix, 
                items: controller.phoneCodes, 
                onChanged: (val) => controller.business.update((b) => b?.phonePrefix = val!)
              ))
            ),
            Expanded(
              child: CustomTextField(
                label: "Teléfono *", 
                icon: Icons.phone_outlined, 
                inputType: TextInputType.number, 
                maxLength: 7, 
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
                controller: controller.phoneController, 
                onChanged: (val) => controller.business.update((b) => b?.phoneNumber = val)
              )
            ),
          ],
        ),
      ],
    );
  }

  // --- SECCIÓN 3: LEGAL (RIF + FOTO) ---
  Widget _buildLegalSection(RegisterBusinessController controller) {
    return Column(
      children: [
        CustomTextField(
          label: "Razón Social", 
          icon: Icons.gavel_outlined, 
          controller: controller.legalNameController, 
          onChanged: (val) => controller.business.update((b) => b?.legalName = val)
        ),
        const SizedBox(height: 15),
        CustomTextField(
          label: "RIF (J-12345678-9) *", 
          icon: Icons.numbers, 
          controller: controller.rifController, 
          onChanged: (val) => controller.business.update((b) => b?.rif = val)
        ),
        
        // ZONA DE FOTO DEL RIF
        const SizedBox(height: 20),
        const Align(
          alignment: Alignment.centerLeft, 
          child: Text(" Foto del RIF Digital *", style: TextStyle(color: AppColors.darkOlive, fontSize: 13, fontWeight: FontWeight.bold))
        ),
        const SizedBox(height: 8),

        Obx(() {
          final imagePath = controller.business.value.rifImagePath;
          final hasImage = imagePath != null && imagePath.isNotEmpty;
          return GestureDetector(
            onTap: controller.pickRifImage,
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: hasImage ? Colors.transparent : AppColors.sageGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: hasImage ? AppColors.orange : AppColors.sageGreen, width: hasImage ? 2 : 1.5),
                image: hasImage ? DecorationImage(image: FileImage(File(imagePath)), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken)) : null,
              ),
              child: hasImage
                ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: AppColors.white, size: 40), Text("Imagen Cargada", style: TextStyle(color: Colors.white))])
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt_outlined, color: AppColors.darkOlive.withOpacity(0.7), size: 40), Text("Toca para subir foto", style: TextStyle(color: AppColors.darkOlive.withOpacity(0.8)))]),
            ),
          );
        }),
        Obx(() { 
          if (controller.business.value.rifImagePath != null) { 
            return Align(
              alignment: Alignment.centerRight, 
              child: TextButton.icon(
                onPressed: controller.removeRifImage, 
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18), 
                label: const Text("Eliminar foto", style: TextStyle(color: Colors.red))
              )
            ); 
          } 
          return const SizedBox.shrink(); 
        }),
        
        const SizedBox(height: 15),
        CustomTextField(
          label: "Nombre del Representante", 
          icon: Icons.person_outline, 
          controller: controller.repNameController, 
          onChanged: (val) => controller.business.update((b) => b?.repName = val)
        ),
      ],
    );
  }

  // --- SECCIÓN 4: SEGURIDAD (NUEVO) ---
  Widget _buildSecuritySection(RegisterBusinessController controller) {
    return Column(
      children: [
        CustomTextField(
          label: "Correo Electrónico (Usuario)",
          icon: Icons.email_outlined,
          inputType: TextInputType.emailAddress,
          controller: controller.emailController,
          // Aquí no hay validación visual en tiempo real en el ejemplo, 
          // pero el controller ya guarda el texto para validarlo al final.
        ),
        const SizedBox(height: 15),
        CustomTextField(
          label: "Contraseña",
          icon: Icons.lock_outline,
          isPassword: true, // Importante: Oculta texto
          controller: controller.passwordController,
        ),
        const SizedBox(height: 15),
        CustomTextField(
          label: "Confirmar Contraseña",
          icon: Icons.lock_outline,
          isPassword: true, // Importante: Oculta texto
          controller: controller.confirmPasswordController,
        ),
      ],
    );
  }

  // --- TÉRMINOS Y BOTONES ---
  Widget _buildTermsAndActions(RegisterBusinessController controller) {
    return Column(
      children: [
        Row(
          children: [
            Obx(() => Checkbox(
              value: controller.business.value.acceptedTerms, 
              activeColor: AppColors.orange, 
              onChanged: (val) => controller.business.update((b) => b?.acceptedTerms = val ?? false)
            )),
            Expanded(
              child: Text(
                "Declaro que los datos son reales y acepto los términos.", 
                style: TextStyle(color: AppColors.darkOlive.withOpacity(0.7), fontSize: 12)
              )
            ),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            OutlinedButton(
              onPressed: () => Get.back(), 
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.darkOlive, 
                side: const BorderSide(color: AppColors.sageGreen), 
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ), 
              child: const Text("Atrás")
            ),
            ElevatedButton(
              onPressed: controller.register, 
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange, 
                foregroundColor: Colors.white, 
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ), 
              child: const Text("Registrar", style: TextStyle(fontWeight: FontWeight.bold))
            ),
          ]
        ),
      ],
    );
  }
}