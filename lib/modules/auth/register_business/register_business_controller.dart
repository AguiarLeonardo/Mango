import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

import '../../../core/theme/app_theme.dart';
import '../../../data/models/business_model.dart';
import '../../../data/venezuela_data.dart';
<<<<<<< Updated upstream
=======
// Importamos el servicio
import '../../../data/services/supabase_service.dart';
// Importamos rutas para navegar al terminar
>>>>>>> Stashed changes
import '../../../routes/app_routes.dart';

class RegisterBusinessController extends GetxController {
  
<<<<<<< Updated upstream
  // Instancia directa de Supabase
  final SupabaseClient _supabase = Supabase.instance.client;
=======
  // Instancia del servicio
  final SupabaseService _supabaseService = SupabaseService();
>>>>>>> Stashed changes

  // Estado de carga visual
  final isLoading = false.obs;

  final business = BusinessModel().obs;
  final ImagePicker _picker = ImagePicker();
  
  // Variable para guardar el archivo original
  XFile? _rawImageFile; 

  // Lista de códigos
  final phoneCodes = ['0412', '0424', '0416', '0414', '0426'];

  // --- Controladores de Texto ---
  final commercialNameController = TextEditingController();
<<<<<<< Updated upstream
  final shortDescController = TextEditingController(); 
=======
  final shortDescController = TextEditingController(); // Descripción corta
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
    stateNames.value = venezuelaData.map((e) => e['estado'] as String).toList();
  }

  // --- Lógica de Cascada Geográfica ---
=======
    // Cargar estados de Venezuela al iniciar
    stateNames.value = venezuelaData.map((e) => e['estado'] as String).toList();
  }

  // --- Lógica de Cascada Geográfica (Igual que en User) ---
>>>>>>> Stashed changes
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
        _rawImageFile = image; 
        business.update((val) => val?.rifImagePath = image.path);
      }
    } catch (e) {
      Get.snackbar("Error", "No se pudo acceder a la galería", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void removeRifImage() {
    _rawImageFile = null;
    business.update((val) => val?.rifImagePath = null);
  }

<<<<<<< Updated upstream
  // --- REGISTRO PRINCIPAL (MODO PRUEBA) ---
=======
  // --- REGISTRO PRINCIPAL ---
>>>>>>> Stashed changes
  Future<void> register() async {
    // 1. Validaciones Locales
    if (!business.value.acceptedTerms) {
      Get.snackbar("Atención", "Debes aceptar los términos.", backgroundColor: AppColors.orange, colorText: Colors.white);
      return;
    }
    
<<<<<<< Updated upstream
    // ⚠️ COMENTADO: Validaciones estrictas de RIF e Imagen desactivadas para pruebas
    if (commercialNameController.text.isEmpty || 
        // rifController.text.isEmpty ||  <--- DESACTIVADO
        emailController.text.isEmpty ||
        passwordController.text.isEmpty 
        // || _rawImageFile == null       <--- DESACTIVADO
       ) { 
        Get.snackbar("Faltan datos", "Por favor llena Email, Contraseña y Nombre Comercial.", backgroundColor: Colors.red, colorText: Colors.white);
=======
    if (commercialNameController.text.isEmpty || 
        rifController.text.isEmpty || 
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        business.value.rifImagePath == null) {
        Get.snackbar("Faltan datos", "Por favor llena todos los campos obligatorios y sube el RIF.", backgroundColor: Colors.red, colorText: Colors.white);
>>>>>>> Stashed changes
        return;
    }

    if (passwordController.text != confirmPasswordController.text) {
       Get.snackbar("Error", "Las contraseñas no coinciden", backgroundColor: Colors.red, colorText: Colors.white);
       return;
    }

    try {
<<<<<<< Updated upstream
      isLoading.value = true;

      // Actualizamos el modelo con los datos
=======
      isLoading.value = true; // Activar spinner (si lo pones en la UI)

      // Actualizamos el modelo con los datos de los TextControllers
>>>>>>> Stashed changes
      business.update((b) {
        b?.commercialName = commercialNameController.text;
        b?.legalName = legalNameController.text;
        b?.rif = rifController.text;
        b?.phoneNumber = phoneController.text;
        b?.address = addressController.text;
        b?.repName = repNameController.text;
        b?.shortDesc = shortDescController.text;
      });

<<<<<<< Updated upstream
      // ⚠️ COMENTADO: Bloque de subida de imagen (Paso A)
      /* final bytes = await _rawImageFile!.readAsBytes();
      final fileExt = _rawImageFile!.path.split('.').last;
      final fileName = 'rif_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await _supabase.storage.from('logos').uploadBinary(
        fileName,
        bytes,
        fileOptions: FileOptions(
          contentType: 'image/$fileExt',
          upsert: true,
        ),
      );

      final imageUrl = _supabase.storage.from('logos').getPublicUrl(fileName);
      business.update((b) => b?.rifUrl = imageUrl);
      */

      // --- PASO B: CREAR USUARIO EN AUTH ---
      final AuthResponse res = await _supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (res.user == null) {
        throw "No se pudo crear el usuario";
      }

      final userId = res.user!.id;

      // --- PASO C: INSERTAR DATOS ---
      final businessData = business.value.toSupabaseMap(userId);
      
      // ⚠️ COMENTADO: No enviamos la URL de la imagen
      // businessData['rif_url'] = imageUrl; 

      await _supabase.from('businesses').insert(businessData);

      // 3. Éxito
      Get.snackbar(
        "¡Registro Exitoso!", 
        "Empresa creada (Sin imagen RIF por ahora).", 
=======
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
>>>>>>> Stashed changes
        backgroundColor: AppColors.darkOlive, 
        colorText: Colors.white,
        duration: const Duration(seconds: 4)
      );

<<<<<<< Updated upstream
      // Redirigir
      Get.offAllNamed(Routes.home);
=======
      // Redirigir al Login o Home
      // Get.offAllNamed(Routes.login); 
>>>>>>> Stashed changes

    } catch (e) {
      // 4. Manejo de Errores
      String msg = e.toString().replaceAll("Exception:", "").trim();
<<<<<<< Updated upstream
      
      if (msg.contains("User already registered")) {
        msg = "Este correo ya está registrado.";
      }

=======
>>>>>>> Stashed changes
      Get.snackbar("Error de Registro", msg, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}