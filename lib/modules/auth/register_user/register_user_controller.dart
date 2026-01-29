import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
// IMPORTANTE: Importamos la data centralizada
import '../../../data/venezuela_data.dart'; 

class RegisterUserController extends GetxController {
  
  final user = UserModel().obs;

  // --- Controladores ---
  final namesController = TextEditingController();
  final surnamesController = TextEditingController();
  final phoneController = TextEditingController();
  final idNumberController = TextEditingController();
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
  final phoneCodes = ['0412', '0424', '0416', '0414', '0426'];
  final idTypes = ['V-', 'E-'];

  // --- Variables Geografía ---
  final selectedState = RxnString();
  final selectedCity = RxnString();
  final selectedMunicipality = RxnString();
  
  // Listas dinámicas para los dropdowns
  final availableCities = <Map<String, dynamic>>[].obs;
  final availableMunicipalities = <String>[].obs;

  // Lista de nombres de estados para la vista
  final stateNames = <String>[].obs;

  // YA NO definimos la lista _venezuelaData aquí adentro.
  // Usaremos la variable global 'venezuelaData' importada.

  @override
  void onInit() {
    super.onInit();
    // Ordenamos la data importada
    venezuelaData.sort((a, b) => (a['estado'] as String).compareTo(b['estado'] as String));
    // Preparamos la lista de nombres de estados
    stateNames.value = venezuelaData.map((e) => e['estado'] as String).toList();
  }

  @override
  void onClose() {
    namesController.dispose();
    surnamesController.dispose();
    phoneController.dispose();
    idNumberController.dispose();
    addressController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // --- Lógica Geografía (Cascada) ---
  void onStateChanged(String? val) {
    selectedState.value = val;
    user.update((u) => u?.state = val);
    
    // Resetear hijos
    selectedCity.value = null;
    selectedMunicipality.value = null;
    availableMunicipalities.clear();

    if (val != null) {
      // Buscamos en la data importada
      var estadoData = venezuelaData.firstWhere((e) => e['estado'] == val);
      availableCities.value = List<Map<String, dynamic>>.from(estadoData['ciudades']);
    } else {
      availableCities.clear();
    }
  }

  void onCityChanged(String? val) {
    selectedCity.value = val;
    user.update((u) => u?.city = val);
    
    // Resetear hijo
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
      if (pass.length < 8) requirements.add("• Mínimo 8 caracteres");
      if (!pass.contains(RegExp(r'[A-Z]'))) requirements.add("• 1 Mayúscula");
      if (!pass.contains(RegExp(r'[0-9]'))) requirements.add("• 1 Número");
    }
    passwordError.value = requirements.isNotEmpty ? "Falta:\n${requirements.join('\n')}" : null;
    confirmPasswordError.value = (confirm.isNotEmpty && pass != confirm) ? "No coinciden" : null;
  }

  void register() {
    if (!user.value.acceptedTerms) {
      Get.snackbar("Error", "Debes aceptar los términos", backgroundColor: AppColors.sageGreen, colorText: Colors.white);
      return;
    }
    if (emailError.value != null || passwordError.value != null) {
       Get.snackbar("Error", "Corrige los errores en rojo", backgroundColor: Colors.red, colorText: Colors.white);
       return;
    }
    print("Registrando: ${user.value.names} en ${user.value.city}");
    Get.snackbar("Éxito", "Usuario registrado", backgroundColor: AppColors.orange, colorText: Colors.white);
  }
}