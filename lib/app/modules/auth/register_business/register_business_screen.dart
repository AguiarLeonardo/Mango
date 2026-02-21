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
      // Usamos el Verde Principal de Mango para el fondo, resaltando la tarjeta blanca
      backgroundColor: AppTheme.primaryGreen,
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
                  color: Colors.white, // Tarjeta blanca pura para contrastar
                  margin: const EdgeInsets.only(top: 10, right: 10),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- ENCABEZADO ---
                        Center(
                          child: Text(
                            "REGISTRO EMPRESA", 
                            // Llamamos a Poppins desde el tema y le ponemos nuestro verde
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.primaryGreen, 
                              fontWeight: FontWeight.bold, 
                              letterSpacing: 1.2
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Center(
                          child: Text(
                            "Únete a Mango y gestiona tus pedidos", 
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textBlack.withOpacity(0.6), 
                            )
                          ),
                        ),
                        const SizedBox(height: 30),

                        // --- SECCIONES ---
                        _buildSectionTitle("1. Información Comercial"),
                        _buildCommercialSection(controller),
                        const SizedBox(height: 25),

                        _buildSectionTitle("2. Ubicación y Contacto"),
                        _buildOperationalDataSection(controller),
                        const SizedBox(height: 25),

                        _buildSectionTitle("3. Datos Legales"),
                        _buildLegalSection(controller),
                        const SizedBox(height: 25),

                        _buildSectionTitle("4. Cuenta y Seguridad"),
                        _buildSecuritySection(controller),
                        const SizedBox(height: 30),

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
                    child: const CircleAvatar(
                      backgroundColor: AppTheme.textBlack, // Negro UI para el botón cerrar
                      radius: 18, 
                      child: Icon(Icons.close, color: Colors.white, size: 20)
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 16)),
        Divider(color: AppTheme.primaryGreen.withOpacity(0.3), thickness: 1),
        const SizedBox(height: 10),
      ],
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
        ),
        const SizedBox(height: 15),
        CustomTextField(
          label: "Slogan / Descripción Corta", 
          icon: Icons.description_outlined, 
          controller: controller.shortDescController, 
          maxLength: 100, 
        ),
        const SizedBox(height: 15),
        Obx(() => CustomDropdown(
          label: "Categoría *", 
          icon: Icons.category_outlined, 
          value: controller.selectedCategory.value, 
          items: controller.categories, 
          onChanged: controller.onCategoryChanged,
        )),
      ],
    );
  }

  // --- SECCIÓN 2: OPERATIVA ---
  Widget _buildOperationalDataSection(RegisterBusinessController controller) {
    return Column(
      children: [
        Obx(() => CustomDropdown(
          label: "Estado *",
          icon: Icons.map,
          value: controller.selectedState.value,
          items: controller.stateNames.toList(),
          onChanged: controller.onStateChanged,
        )),
        const SizedBox(height: 15),
        
        Obx(() => CustomDropdown(
          label: "Ciudad *",
          icon: Icons.location_city,
          value: controller.selectedCity.value,
          isDisabled: controller.selectedState.value == null,
          items: controller.availableCities.map((e) => e['nombre'] as String).toList(),
          onChanged: controller.onCityChanged,
        )),
        const SizedBox(height: 15),

        Obx(() => CustomDropdown(
          label: "Municipio *",
          icon: Icons.location_on_outlined,
          value: controller.selectedMunicipality.value,
          isDisabled: controller.selectedCity.value == null,
          items: controller.availableMunicipalities.toList(),
          onChanged: controller.onMunicipalityChanged,
        )),
        const SizedBox(height: 15),

        CustomTextField(
          label: "Dirección Exacta *", 
          icon: Icons.map_outlined,
          maxLines: 2,
          controller: controller.addressController,
        ),
        const SizedBox(height: 15),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 90, 
              margin: const EdgeInsets.only(right: 10), 
              child: Obx(() => SimpleDropdown(
                value: controller.business.value.phonePrefix ?? '0412',
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
              )
            ),
          ],
        ),
      ],
    );
  }

  // --- SECCIÓN 3: LEGAL ---
  Widget _buildLegalSection(RegisterBusinessController controller) {
    return Column(
      children: [
        CustomTextField(
          label: "Razón Social *", 
          icon: Icons.gavel_outlined, 
          controller: controller.legalNameController, 
        ),
        const SizedBox(height: 15),
        CustomTextField(
          label: "RIF (J-12345678-9) *", 
          icon: Icons.numbers, 
          controller: controller.rifController, 
        ),
        
        const SizedBox(height: 20),
        const Align(
          alignment: Alignment.centerLeft, 
          child: Text(" Foto del RIF Digital (Opcional)", style: TextStyle(color: AppTheme.textBlack, fontSize: 13, fontWeight: FontWeight.bold))
        ),
        const SizedBox(height: 8),

        Obx(() {
          final imagePath = controller.business.value.rifImagePath;
          final hasImage = imagePath != null && imagePath.isNotEmpty;
          
          ImageProvider? bgImage;
          if (hasImage) {
            if (GetPlatform.isWeb) {
               bgImage = NetworkImage(imagePath!);
            } else {
               bgImage = FileImage(File(imagePath!));
            }
          }

          return GestureDetector(
            onTap: controller.pickRifImage,
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: hasImage ? Colors.transparent : AppTheme.primaryGreen.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasImage ? AppTheme.accentOrange : AppTheme.primaryGreen.withOpacity(0.5), 
                  width: 1.5
                ),
                image: hasImage ? DecorationImage(image: bgImage!, fit: BoxFit.cover) : null,
              ),
              child: hasImage
                ? const Center(child: Icon(Icons.check_circle, color: Colors.white, size: 50))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: [
                      Icon(Icons.camera_alt_outlined, color: AppTheme.primaryGreen.withOpacity(0.8), size: 35), 
                      Text("Toca para cargar foto", style: TextStyle(color: AppTheme.textBlack.withOpacity(0.6)))
                    ]
                  ),
            ),
          );
        }),
        
        Obx(() { 
          if (controller.business.value.rifImagePath != null) { 
            return Align(
              alignment: Alignment.centerRight, 
              child: TextButton.icon(
                onPressed: controller.removeRifImage, 
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18), 
                label: const Text("Quitar foto", style: TextStyle(color: Colors.redAccent))
              )
            ); 
          } 
          return const SizedBox.shrink(); 
        }),
        
        const SizedBox(height: 15),
        CustomTextField(
          label: "Nombre del Representante *", 
          icon: Icons.person_outline, 
          controller: controller.repNameController, 
        ),
      ],
    );
  }

  // --- SECCIÓN 4: SEGURIDAD ---
  Widget _buildSecuritySection(RegisterBusinessController controller) {
    return Column(
      children: [
        CustomTextField(
          label: "Correo Electrónico *",
          icon: Icons.email_outlined,
          inputType: TextInputType.emailAddress,
          controller: controller.emailController,
        ),
        const SizedBox(height: 15),
        CustomTextField(
          label: "Contraseña *",
          icon: Icons.lock_outline,
          isPassword: true, 
          controller: controller.passwordController,
        ),
        const SizedBox(height: 15),
        CustomTextField(
          label: "Confirmar Contraseña *",
          icon: Icons.lock_outline,
          isPassword: true, 
          controller: controller.confirmPasswordController,
        ),
      ],
    );
  }

  // --- ACTIONS ---
  Widget _buildTermsAndActions(RegisterBusinessController controller) {
    return Column(
      children: [
        Row(
          children: [
            Obx(() => Checkbox(
              value: controller.business.value.acceptedTerms, 
              activeColor: AppTheme.accentOrange, // Naranja para la interacción
              onChanged: (val) => controller.business.update((b) => b?.acceptedTerms = val ?? false)
            )),
            Expanded(
              child: Text(
                "Acepto los términos y condiciones de Mango.", 
                style: TextStyle(color: AppTheme.textBlack.withOpacity(0.8), fontSize: 13)
              )
            ),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            TextButton(
              onPressed: () => Get.back(), 
              child: const Text("Cancelar", style: TextStyle(color: AppTheme.disabledIcon))
            ),
            
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.register, 
              // ¡Mira qué limpio queda el botón! 
              // Le quitamos todo el código de diseño porque el AppTheme ya hace el trabajo.
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: controller.isLoading.value
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("REGISTRAR EMPRESA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
              )
            )),
          ]
        ),
      ],
    );
  }
}