import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/venezuela_data.dart';
// Importamos el servicio de Supabase
import '../../../data/services/supabase_service.dart';

class RegisterUserController extends GetxController {
  
  // Instancia del servicio para comunicar con la BD
  final SupabaseService _supabaseService = SupabaseService();

  // Estado de carga para bloquear el botón mientras registra
  final isLoading = false.obs;

  final user = UserModel().obs;

  // --- Controladores de Texto ---
  final namesController = TextEditingController();
  final surnamesController = TextEditingController();
  final phoneController = TextEditingController();
  
  // Controlador para el número de cédula/documento
  final documentNumberController = TextEditingController();
  
  final addressController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // --- Errores Reactivos ---
  final emailError = RxnString();
  final passwordError = RxnString();
  final confirmPasswordError = RxnString();
  
  // --- Listas Fijas ---
  final phoneCodes = ['0412', '0424', '0416', '0414', '0426', '0212'];
  // Tipos de documento actualizados
  final documentTypes = ['V-', 'E-', 'P-'];

  // --- Variables Geografía ---
  final selectedState = RxnString();
  final selectedCity = RxnString();
  final selectedMunicipality = RxnString();
  
  final availableCities = <Map<String, dynamic>>[].obs;
  final availableMunicipalities = <String>[].obs;
  final stateNames = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    // 1. Inicializamos valores por defecto
    user.update((u) => u?.documentType = 'V-');
    
    // 2. Ordenamos y cargamos la data geográfica
    venezuelaData.sort((a, b) => (a['estado'] as String).compareTo(b['estado'] as String));
    stateNames.value = venezuelaData.map((e) => e['estado'] as String).toList();
  }
  
  @override
  void onClose() {
    namesController.dispose();
    surnamesController.dispose();
    phoneController.dispose();
    documentNumberController.dispose(); 
    addressController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // --- Lógica Documento de Identidad ---
  void onDocumentTypeChanged(String? val) {
    if (val == null) return;
    
    // Actualizamos el tipo
    user.update((u) => u?.documentType = val);
    
    // Limpiamos el campo de texto para evitar errores de formato (letras en campo numérico)
    documentNumberController.clear();
    user.update((u) => u?.documentNumber = '');
  }

  // --- Lógica Geografía (Cascada) ---
  void onStateChanged(String? val) {
    selectedState.value = val;
    user.update((u) => u?.state = val);
    
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
    user.update((u) => u?.city = val);
    
    selectedMunicipality.value = null;
    
    if (val != null) {
      var ciudadData = availableCities.firstWhere((e) => e['nombre'] == val);
      availableMunicipalities.value = List<String>.from(ciudadData['municipios']);
    } else {
      availableMunicipalities.clear();
    }
  }

  // --- Validaciones ---
  void validateEmail(String value) {
    user.update((val) => val?.email = value);
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    emailError.value = (value.isNotEmpty && !emailRegex.hasMatch(value)) ? "Correo inválido" : null;
  }

  void validatePasswords() {
    final pass = passwordController.text;
    final confirm = confirmPasswordController.text;
    user.update((val) => val?.password = pass);

    List<String> requirements = [];
    if (pass.isNotEmpty) {
      if (pass.length < 6) requirements.add("• Mínimo 6 caracteres"); 
    }
    passwordError.value = requirements.isNotEmpty ? "Falta:\n${requirements.join('\n')}" : null;
    confirmPasswordError.value = (confirm.isNotEmpty && pass != confirm) ? "No coinciden" : null;
  }

  // --- MÉTODO DE REGISTRO CON SUPABASE ---
  Future<void> register() async {
    // 1. Validaciones básicas
    if (!user.value.acceptedTerms) {
      Get.snackbar("Error", "Debes aceptar los términos", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    
    if (documentNumberController.text.isEmpty) {
       Get.snackbar("Falta información", "Debes ingresar tu número de documento", backgroundColor: Colors.red, colorText: Colors.white);
       return;
    }

    // --- VALIDACIÓN ESPECÍFICA DE DOCUMENTO ---
    String docType = user.value.documentType ?? 'V-';
    String docNumber = documentNumberController.text;

    if (docType == 'P-') {
      // Pasaporte: Debe tener exactamente 9 caracteres
      if (docNumber.length != 9) {
        Get.snackbar("Error en Pasaporte", "El pasaporte debe tener 9 caracteres (Ej: AA1234567)", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
    } else {
      // Cédula (V- o E-): Mínimo 6 y Máximo 8
      if (docNumber.length < 6 || docNumber.length > 8) {
        Get.snackbar("Error en Cédula", "La cédula debe tener entre 6 y 8 dígitos", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
    }
    // ------------------------------------------

    if (emailError.value != null || passwordError.value != null) {
       Get.snackbar("Error", "Corrige los errores en rojo", backgroundColor: Colors.red, colorText: Colors.white);
       return;
    }

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
       Get.snackbar("Error", "Correo y contraseña son obligatorios", backgroundColor: Colors.red, colorText: Colors.white);
       return;
    }

    try {
      isLoading.value = true;

      // 2. Actualizamos el modelo con la data final
      user.update((val) {
        val?.names = namesController.text;
        val?.surnames = surnamesController.text;
        val?.documentNumber = documentNumberController.text; 
        val?.phoneNumber = phoneController.text;
        val?.address = addressController.text;
        val?.username = usernameController.text;
      });

      // 3. Llamada al Servicio
      await _supabaseService.registerUser(
        email: emailController.text.trim(),
        password: passwordController.text,
        profileData: user.value.toSupabaseMap(), 
      );

      // 4. Éxito
      Get.snackbar("Bienvenido", "Usuario registrado correctamente", backgroundColor: AppColors.orange, colorText: Colors.white);
      
      // Get.offAllNamed(Routes.home); 

    } catch (e) {
      // 5. Manejo de Errores
      String errorMessage = e.toString();
      if (errorMessage.contains("Exception:")) {
        errorMessage = errorMessage.replaceAll("Exception: ", "");
      }
      Get.snackbar("Error de Registro", errorMessage, backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 4));
      
    } finally {
      isLoading.value = false;
    }
  }
}