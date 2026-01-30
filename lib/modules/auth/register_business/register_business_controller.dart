import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/business_model.dart';
import '../../../data/venezuela_data.dart';
// Importamos el servicio
import '../../../data/services/supabase_service.dart';
// Importamos rutas para navegar al terminar
import '../../../routes/app_routes.dart';

class RegisterBusinessController extends GetxController {
  
  // Instancia del servicio
  final SupabaseService _supabaseService = SupabaseService();

  // Estado de carga visual
  final isLoading = false.obs;

  final business = BusinessModel().obs;
  final ImagePicker _picker = ImagePicker();

  // --- Controladores de Texto ---
  final commercialNameController = TextEditingController();
  final shortDescController = TextEditingController(); // Descripción corta
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final legalNameController = TextEditingController();
  final rifController = TextEditingController();
  final repNameController = TextEditingController();

  // Auth
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // --- Variables Geografía ---
  final selectedState = RxnString();
  final selectedCity = RxnString();
  final selectedMunicipality = RxnString();
  
  final availableCities = <Map<String, dynamic>>[].obs;
  final availableMunicipalities = <String>[].obs;

  // Lista de nombres de estados para la vista
  final stateNames = <String>[].obs;

  // Para el Dropdown de Categorías
  final selectedCategory = RxnString();
  final categories = ['Panadería', 'Restaurante', 'Pastelería', 'Supermercado', 'Cafetería'];

  @override
  void onInit() {
    super.onInit();
    // Cargar estados de Venezuela al iniciar
    stateNames.value = venezuelaData.map((e) => e['estado'] as String).toList();
  }

  // --- Lógica de Cascada Geográfica (Igual que en User) ---
  void onStateChanged(String? val) {
    selectedState.value = val;
    business.update((b) => b?.state = val);
    
    selectedCity.value = null;
    selectedMunicipality.value = null;
    availableMunicipalities.clear();

    if (val != null) {
      var estadoData = venezuelaData.firstWhere((e) => e['estado'] == val);
      availableCities.value = List<Map<String, dynamic>>.from(estadoData['ciudades']);
    } else {
      availableCities.clear();
    }
  }

  void onCityChanged(String? val) {
    selectedCity.value = val;
    business.update((b) => b?.city = val);
    selectedMunicipality.value = null;
    
    if (val != null) {
      var ciudadData = availableCities.firstWhere((e) => e['nombre'] == val);
      availableMunicipalities.value = List<String>.from(ciudadData['municipios']);
    } else {
      availableMunicipalities.clear();
    }
  }

  void onMunicipalityChanged(String? val) {
    selectedMunicipality.value = val;
    business.update((b) => b?.municipality = val);
  }

  void onCategoryChanged(String? val) {
    selectedCategory.value = val;
    business.update((b) => b?.category = val);
  }

  // --- Lógica Imágenes ---
  Future<void> pickRifImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        business.update((val) => val?.rifImagePath = image.path);
      }
    } catch (e) {
      Get.snackbar("Error", "No se pudo acceder a la galería", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void removeRifImage() {
    business.update((val) => val?.rifImagePath = null);
  }

  // --- REGISTRO PRINCIPAL ---
  Future<void> register() async {
    // 1. Validaciones Locales
    if (!business.value.acceptedTerms) {
      Get.snackbar("Atención", "Debes aceptar los términos.", backgroundColor: AppColors.orange, colorText: Colors.white);
      return;
    }
    
    if (commercialNameController.text.isEmpty || 
        rifController.text.isEmpty || 
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        business.value.rifImagePath == null) {
        Get.snackbar("Faltan datos", "Por favor llena todos los campos obligatorios y sube el RIF.", backgroundColor: Colors.red, colorText: Colors.white);
        return;
    }

    if (passwordController.text != confirmPasswordController.text) {
       Get.snackbar("Error", "Las contraseñas no coinciden", backgroundColor: Colors.red, colorText: Colors.white);
       return;
    }

    try {
      isLoading.value = true; // Activar spinner (si lo pones en la UI)

      // Actualizamos el modelo con los datos de los TextControllers
      business.update((b) {
        b?.commercialName = commercialNameController.text;
        b?.legalName = legalNameController.text;
        b?.rif = rifController.text;
        b?.phoneNumber = phoneController.text;
        b?.address = addressController.text;
        b?.repName = repNameController.text;
        b?.shortDesc = shortDescController.text;
      });

      // 2. Llamada al Servicio (Backend)
      await _supabaseService.registerBusiness(
        email: emailController.text.trim(),
        password: passwordController.text,
        rifImageFile: File(business.value.rifImagePath!), // Convertimos path a File
        businessDataBuilder: (String userId, String? rifPath) {
          // Inyectamos el ID del usuario creado y la ruta del archivo subido
          business.value.rifUrl = rifPath; 
          return business.value.toSupabaseMap(userId);
        },
      );

      // 3. Éxito
      Get.snackbar(
        "¡Registro Exitoso!", 
        "Tu solicitud ha sido enviada. Un administrador verificará tu RIF pronto.", 
        backgroundColor: AppColors.darkOlive, 
        colorText: Colors.white,
        duration: const Duration(seconds: 4)
      );

      // Redirigir al Login o Home
      // Get.offAllNamed(Routes.login); 

    } catch (e) {
      // 4. Manejo de Errores
      String msg = e.toString().replaceAll("Exception:", "").trim();
      Get.snackbar("Error de Registro", msg, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}