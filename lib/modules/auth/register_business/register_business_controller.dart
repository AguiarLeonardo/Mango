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
  
  // Instancia directa de Supabase
  final SupabaseClient _supabase = Supabase.instance.client;

  // Estado de carga visual
  final isLoading = false.obs;

  // Modelo reactivo
  final business = BusinessModel().obs;
  
  // Imagen
  final ImagePicker _picker = ImagePicker();
  XFile? _rawImageFile; 

  // Listas y Opciones
  final phoneCodes = ['0412', '0424', '0416', '0414', '0426'];
  final categories = ['Panadería', 'Restaurante', 'Pastelería', 'Supermercado', 'Cafetería', 'Farmacia', 'Otro'];

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

  // --- Auth ---
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // --- Variables Geografía (Reactivas para Dropdowns) ---
  final selectedState = RxnString();
  final selectedCity = RxnString();
  final selectedMunicipality = RxnString();
  
  final availableCities = <Map<String, dynamic>>[].obs;
  final availableMunicipalities = <String>[].obs;
  final stateNames = <String>[].obs;

  // --- Variable Categoría ---
  final selectedCategory = RxnString();

  @override
  void onInit() {
    super.onInit();
    stateNames.value = venezuelaData.map((e) => e['estado'] as String).toList();
    
    // Valor por defecto para el prefijo para evitar nulos
    business.update((b) => b?.phonePrefix = phoneCodes.first);
  }

  // --- Lógica de Cascada Geográfica ---
  void onStateChanged(String? val) {
    if (val == null) return;
    selectedState.value = val;
    business.update((b) => b?.state = val);
    
    // Resetear hijos
    selectedCity.value = null;
    selectedMunicipality.value = null;
    availableMunicipalities.clear();
    business.update((b) {
      b?.city = null;
      b?.municipality = null;
    });

    // Cargar ciudades
    var estadoData = venezuelaData.firstWhere((e) => e['estado'] == val);
    availableCities.value = List<Map<String, dynamic>>.from(estadoData['ciudades']);
  }

  void onCityChanged(String? val) {
    if (val == null) return;
    selectedCity.value = val;
    business.update((b) => b?.city = val);
    
    // Resetear hijos
    selectedMunicipality.value = null;
    business.update((b) => b?.municipality = null);

    // Cargar municipios
    var ciudadData = availableCities.firstWhere((e) => e['nombre'] == val);
    availableMunicipalities.value = List<String>.from(ciudadData['municipios']);
  }

  void onMunicipalityChanged(String? val) {
    selectedMunicipality.value = val;
    business.update((b) => b?.municipality = val);
  }

  void onCategoryChanged(String? val) {
    selectedCategory.value = val;
    business.update((b) => b?.category = val);
  }

  // ===========================================================================
  // IMÁGENES
  // ===========================================================================

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

  // --- REGISTRO PRINCIPAL (MODO PRUEBA) ---
  Future<void> register() async {
    // 1. Validaciones Locales
    if (!business.value.acceptedTerms) {
      Get.snackbar("Atención", "Debes aceptar los términos.", backgroundColor: AppColors.orange, colorText: Colors.white);
      return;
    }
    
    // ⚠️ COMENTADO: Validaciones estrictas de RIF e Imagen desactivadas para pruebas
    if (commercialNameController.text.isEmpty || 
        // rifController.text.isEmpty ||  <--- DESACTIVADO
        emailController.text.isEmpty ||
        passwordController.text.isEmpty 
        // || _rawImageFile == null       <--- DESACTIVADO
       ) { 
        Get.snackbar("Faltan datos", "Por favor llena Email, Contraseña y Nombre Comercial.", backgroundColor: Colors.red, colorText: Colors.white);
        return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _showError("Las contraseñas no coinciden.");
      return false;
    }

    // 4. Términos
    if (!business.value.acceptedTerms) {
      _showError("Debes aceptar los términos y condiciones.");
      return false;
    }

    return true;
  }

  void _showError(String msg) {
    Get.snackbar("Faltan Datos", msg, 
      backgroundColor: Colors.red, 
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(10)
    );
  }

  // ===========================================================================
  // REGISTRO BLINDADO
  // ===========================================================================

  Future<void> register() async {
    // 1. Ejecutar validaciones locales
    if (!_validateForm()) return;

    try {
<<<<<<< Updated upstream
      isLoading.value = true;

      // Actualizamos el modelo con los datos
      business.update((b) {
        b?.commercialName = commercialNameController.text;
        b?.legalName = legalNameController.text;
        b?.rif = rifController.text;
        b?.phoneNumber = phoneController.text;
        b?.address = addressController.text;
        b?.repName = repNameController.text;
        b?.shortDesc = shortDescController.text;
      });

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
        email: email,
        password: password,
        data: { 'role': 'business' } 
      );

      if (res.user == null) {
        throw "No se pudo crear el usuario. Intenta de nuevo.";
      }

      final String userId = res.user!.id;
      String? uploadedRifUrl;

      // 3. Subir Imagen (Compatible Web/Móvil)
      if (_rawImageFile != null) {
        try {
          final bytes = await _rawImageFile!.readAsBytes();
          
          String fileExt = 'jpg';
          // Validación segura de extensión
          if (!_rawImageFile!.path.toLowerCase().startsWith('blob:')) {
            fileExt = _rawImageFile!.path.split('.').last;
            if (fileExt.isEmpty) fileExt = 'jpg';
          }

          final fileName = '$userId/rif_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

          await _supabase.storage.from('logos').uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(contentType: 'image/$fileExt', upsert: true),
          );
          
          uploadedRifUrl = _supabase.storage.from('logos').getPublicUrl(fileName);
        } catch (e) {
          print("Advertencia: Error subiendo imagen: $e");
          // No detenemos el registro por la imagen, pero lo logueamos
        }
      }

      // 4. Preparar Datos
      final Map<String, dynamic> businessData = {
        'id': userId, 
        'commercial_name': commercialNameController.text.trim(),
        'legal_name': legalNameController.text.trim(),
        'rif': rif,
        'short_desc': shortDescController.text.trim(),
        'category': selectedCategory.value,
        'state': selectedState.value,
        'city': selectedCity.value,
        'municipality': selectedMunicipality.value,
        'address': addressController.text.trim(),
        'phone_prefix': business.value.phonePrefix ?? '0412',
        'phone_number': phoneController.text.trim(),
        'rep_name': repNameController.text.trim(),
        'email': email,
        'rif_url': uploadedRifUrl, 
        'terms_accepted': true,
        'created_at': DateTime.now().toIso8601String(),
      };

      // 5. Insertar en BD
      await _supabase.from('businesses').insert(businessData);

      // 6. Éxito
      Get.snackbar(
        "¡Registro Exitoso!", 
        "Empresa creada (Sin imagen RIF por ahora).", 
        backgroundColor: AppColors.darkOlive, 
        colorText: Colors.white,
        duration: const Duration(seconds: 4)
      );

      // Redirigir
      Get.offAllNamed(Routes.home);
=======
      // Redirigir al Login o Home
      // Get.offAllNamed(Routes.login); 
>>>>>>> Stashed changes

    } catch (e) {
      // 4. Manejo de Errores
      String msg = e.toString().replaceAll("Exception:", "").trim();
      
      if (msg.contains("User already registered")) {
        msg = "Este correo ya está registrado.";
      }

      Get.snackbar("Error de Registro", msg, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}