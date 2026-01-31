import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

import '../../../core/theme/app_theme.dart';
import '../../../data/models/business_model.dart';
import '../../../data/venezuela_data.dart';
import '../../../routes/app_routes.dart';

class RegisterBusinessController extends GetxController {
  
  final SupabaseClient _supabase = Supabase.instance.client;
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
  final shortDescController = TextEditingController(); 
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
    // Cargar estados de venezuela_data
    stateNames.value = venezuelaData.map((e) => e['estado'] as String).toList();
    
    // Valor por defecto para el prefijo para evitar nulos
    business.update((b) => b?.phonePrefix = phoneCodes.first);
  }

  // ===========================================================================
  // LÓGICA DE UI (DROPDOWNS)
  // ===========================================================================

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

  // ===========================================================================
  // VALIDACIONES
  // ===========================================================================

  bool _validateForm() {
    // 1. Campos de Texto Simples
    if (commercialNameController.text.trim().isEmpty) {
      _showError("El Nombre Comercial es obligatorio.");
      return false;
    }
    if (rifController.text.trim().isEmpty) {
      _showError("El RIF es obligatorio.");
      return false;
    }
    if (legalNameController.text.trim().isEmpty) {
      _showError("La Razón Social es obligatoria.");
      return false;
    }
    if (addressController.text.trim().isEmpty) {
      _showError("La Dirección Fiscal es obligatoria.");
      return false;
    }
    if (phoneController.text.trim().isEmpty || phoneController.text.length < 7) {
      _showError("Ingresa un número de teléfono válido.");
      return false;
    }

    // 2. Dropdowns (Validar que se haya seleccionado algo)
    if (selectedCategory.value == null) {
      _showError("Debes seleccionar una Categoría.");
      return false;
    }
    if (selectedState.value == null) {
      _showError("Selecciona el Estado.");
      return false;
    }
    if (selectedCity.value == null) {
      _showError("Selecciona la Ciudad.");
      return false;
    }
    if (selectedMunicipality.value == null) {
      _showError("Selecciona el Municipio.");
      return false;
    }

    // 3. Auth
    if (emailController.text.trim().isEmpty || !GetUtils.isEmail(emailController.text.trim())) {
      _showError("Ingresa un correo electrónico válido.");
      return false;
    }
    if (passwordController.text.isEmpty || passwordController.text.length < 6) {
      _showError("La contraseña debe tener al menos 6 caracteres.");
      return false;
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
      isLoading.value = true;
      
      // Limpiamos los textos para evitar espacios accidentales
      final rif = rifController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text;

      // --- [CORRECCIÓN CRÍTICA: VALIDACIÓN PREVIA] ---
      // Usamos comillas dobles (") rodeando las variables $rif y $email.
      // Esto evita el Error 400 en PostgREST.
      try {
        final List<dynamic> existingData = await _supabase
            .from('businesses')
            .select('id')
            .or('rif.eq."$rif",email.eq."$email"'); // <--- AQUI ESTÁ LA CLAVE
        
        if (existingData.isNotEmpty) {
          throw "El RIF o el Correo ya están registrados.";
        }
      } on PostgrestException catch (pgError) {
        // Capturamos errores específicos de base de datos para depurar
        print("Error buscando duplicados: ${pgError.message} - ${pgError.details}");
        throw "Error verificando datos: ${pgError.message}";
      }

      // 2. Crear Usuario en Auth
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
        "¡Bienvenido!", 
        "Tu empresa ha sido registrada exitosamente.", 
        backgroundColor: Colors.green[800], // Asegúrate que AppColors exista o usa Colors
        colorText: Colors.white,
        duration: const Duration(seconds: 4)
      );

      Get.offAllNamed(Routes.home);

    } catch (e) {
      String msg = e.toString();
      
      // Limpieza de mensajes de error
      if (msg.startsWith("Exception: ")) {
        msg = msg.replaceAll("Exception: ", "");
      }
      // Si sigue saliendo error 400, mostramos un mensaje amigable pero miramos la consola
      if (msg.contains("400") || msg.contains("PostgrestException")) {
        // Mira la consola para ver el error real gracias al print del catch arriba
        if (!msg.contains("El RIF o el Correo")) {
            msg = "Error de conexión o datos inválidos (400).";
        }
      }
      
      Get.snackbar(
        "No se pudo registrar", 
        msg, 
        backgroundColor: Colors.red, 
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 5)
      );
    } finally {
      isLoading.value = false;
    }
  }
}