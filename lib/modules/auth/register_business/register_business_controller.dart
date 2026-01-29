import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/business_model.dart';
// Importamos la data centralizada
import '../../../data/venezuela_data.dart';

class RegisterBusinessController extends GetxController {
  
  final business = BusinessModel().obs;
  final ImagePicker _picker = ImagePicker();

  // --- Controladores de Texto ---
  final commercialNameController = TextEditingController();
  final shortDescController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final legalNameController = TextEditingController();
  final rifController = TextEditingController();
  final repNameController = TextEditingController();

  // Nuevos controladores para Email/Password de la cuenta del negocio
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // --- Variables Geografía (NUEVO) ---
  final selectedState = RxnString();
  final selectedCity = RxnString();
  final selectedMunicipality = RxnString();
  
  final availableCities = <Map<String, dynamic>>[].obs;
  final availableMunicipalities = <String>[].obs;

  // Lista de nombres de estados para la vista
  final stateNames = <String>[].obs;

  // --- Listas Fijas ---
  final categories = ['Panadería', 'Pizzería', 'Restaurante', 'Supermercado', 'Frutería', 'Farmacia', 'Bodegón', 'Otro'];
  final phoneCodes = ['0412', '0424', '0416', '0414', '0426', '0212'];

  @override
  void onInit() {
    super.onInit();
    // Ordenamos la data importada
    venezuelaData.sort((a, b) => (a['estado'] as String).compareTo(b['estado'] as String));
    // Preparamos la lista de nombres de estados para el dropdown
    stateNames.value = venezuelaData.map((e) => e['estado'] as String).toList();
  }

  @override
  void onClose() {
    commercialNameController.dispose();
    shortDescController.dispose();
    addressController.dispose();
    phoneController.dispose();
    legalNameController.dispose();
    rifController.dispose();
    repNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // --- Lógica Geografía (Cascada) ---
  void onStateChanged(String? val) {
    selectedState.value = val;
    // Aquí podrías guardar el estado en tu BusinessModel si le agregas el campo
    // business.update((b) => b.state = val);
    
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
    selectedMunicipality.value = null;
    if (val != null) {
      var ciudadData = availableCities.firstWhere((e) => e['nombre'] == val);
      availableMunicipalities.value = List<String>.from(ciudadData['municipios']);
    } else {
      availableMunicipalities.clear();
    }
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

  // --- Registro ---
  void register() {
    if (!business.value.acceptedTerms) {
      _showError("Debes aceptar los términos.");
      return;
    }
    
    // Validaciones básicas
    if (commercialNameController.text.isEmpty || 
        rifController.text.isEmpty || 
        business.value.rifImagePath == null) {
        _showError("Faltan campos obligatorios o la foto del RIF.");
        return;
    }

    // Validación Geográfica (Opcional pero recomendada)
    if (selectedState.value == null || selectedCity.value == null) {
       _showError("Por favor selecciona la ubicación (Estado y Ciudad).");
       return;
    }

    print("Registrando Empresa en: ${selectedCity.value}, ${selectedState.value}");
    Get.snackbar("Éxito", "Solicitud enviada.", backgroundColor: AppColors.orange, colorText: Colors.white);
  }

  void _showError(String msg) {
    Get.snackbar("Atención", msg, backgroundColor: Colors.red, colorText: Colors.white);
  }
}