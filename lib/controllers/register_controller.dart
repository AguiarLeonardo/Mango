import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/user_model.dart'; // Asegúrate de importar tu modelo
import '../core/theme/app_theme.dart'; // Para los colores del snackbar

class RegisterController extends GetxController {
  // --- Estado Reactivo ---
  final user = UserModel().obs; // El modelo entero es observable
  
  // Variables para errores visuales (Reactive Strings)
  final emailError = RxnString();
  final passwordError = RxnString();
  final confirmPasswordError = RxnString();

  // Variables para Dropdowns en Cascada
  final selectedState = RxnString();
  final selectedCity = RxnString();
  final selectedMunicipality = RxnString();
  
  final availableCities = <Map<String, dynamic>>[].obs;
  final availableMunicipalities = <String>[].obs;

  // Listas estáticas (no cambian)
  final phoneCodes = ['0412', '0424', '0416', '0414', '0426'];
  final idTypes = ['V-', 'E-'];

  // --- Controladores de Texto ---
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  // (Puedes añadir controllers para nombre, apellido, etc. si quieres validarlos en tiempo real)

  // --- DATA VENEZUELA (Centralizada aquí) ---
  final List<Map<String, dynamic>> _venezuelaData = [
    {
      "estado": "Distrito Capital",
      "ciudades": [
        { "nombre": "Caracas", "municipios": ["Libertador"] }
      ]
    },
    {
      "estado": "Miranda",
      "ciudades": [
        { "nombre": "Caracas (Área Metro)", "municipios": ["Baruta", "Chacao", "El Hatillo", "Sucre"] },
        { "nombre": "Los Teques", "municipios": ["Guaicaipuro"] },
        { "nombre": "Guarenas / Guatire", "municipios": ["Plaza", "Zamora"] },
      ]
    },
     {
       "estado": "Zulia",
       "ciudades": [
         { "nombre": "Maracaibo", "municipios": ["Maracaibo"] },
         { "nombre": "Cabimas", "municipios": ["Cabimas"] }
       ]
    },
    // ... Agrega el resto aquí
  ];

  @override
  void onInit() {
    super.onInit();
    // Ordenar datos al iniciar
    _venezuelaData.sort((a, b) => (a['estado'] as String).compareTo(b['estado'] as String));
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // --- LÓGICA DE NEGOCIO ---

  void validateEmail(String value) {
    user.update((val) => val?.email = value); // Actualiza modelo
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (value.isNotEmpty && !emailRegex.hasMatch(value)) {
      emailError.value = "Correo no válido";
    } else {
      emailError.value = null;
    }
  }

  void validatePasswords() {
    final pass = passwordController.text;
    final confirm = confirmPasswordController.text;
    
    user.update((val) {
      val?.password = pass;
    });

    List<String> requirements = [];
    if (pass.isNotEmpty) {
      if (pass.length < 8) requirements.add("• Mínimo 8 caracteres");
      if (!pass.contains(RegExp(r'[A-Z]'))) requirements.add("• 1 Mayúscula");
      if (!pass.contains(RegExp(r'[a-z]'))) requirements.add("• 1 Minúscula");
      if (!pass.contains(RegExp(r'[0-9]'))) requirements.add("• 1 Número");
    }

    passwordError.value = requirements.isNotEmpty ? "Falta:\n${requirements.join('\n')}" : null;
    confirmPasswordError.value = (confirm.isNotEmpty && pass != confirm) ? "No coinciden" : null;
  }

  // --- Lógica de Geografía (Cascada) ---
  void onStateChanged(String? val) {
    selectedState.value = val;
    user.update((u) => u?.state = val);
    
    // Resetear hijos
    selectedCity.value = null;
    selectedMunicipality.value = null;
    availableMunicipalities.clear();

    if (val != null) {
      var estadoData = _venezuelaData.firstWhere((e) => e['estado'] == val);
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

  void registerUser() {
    if (!user.value.acceptedTerms) {
      Get.snackbar("Error", "Debes aceptar los términos", backgroundColor: AppColors.sageGreen, colorText: Colors.white);
      return;
    }
    // Aquí validas que no haya errores antes de enviar
    if (emailError.value != null || passwordError.value != null) {
       Get.snackbar("Error", "Corrige los campos en rojo", backgroundColor: Colors.red, colorText: Colors.white);
       return;
    }

    print("Registrando usuario: ${user.value.email}");
    // Lógica de backend aquí...
  }
}