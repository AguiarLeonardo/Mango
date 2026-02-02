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
  // Tip para UI: Asegúrate de tener los items de dropdown cargados
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

  // --- Variables Geografía ---
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
    try {
      stateNames.value = venezuelaData.map((e) => e['estado'] as String).toList();
    } catch (e) {
      print("Error cargando data de Venezuela: $e");
    }
    business.update((b) => b?.phonePrefix = phoneCodes.first);
  }

  // ... (Tus funciones onStateChanged, onCityChanged, etc. se quedan igual) ...
  void onStateChanged(String? val) {
    if (val == null) return;
    selectedState.value = val;
    selectedCity.value = null;
    selectedMunicipality.value = null;
    availableMunicipalities.clear();
    
    var estadoData = venezuelaData.firstWhere((e) => e['estado'] == val);
    availableCities.value = List<Map<String, dynamic>>.from(estadoData['ciudades']);
  }

  void onCityChanged(String? val) {
    if (val == null) return;
    selectedCity.value = val;
    selectedMunicipality.value = null;
    var ciudadData = availableCities.firstWhere((e) => e['nombre'] == val);
    availableMunicipalities.value = List<String>.from(ciudadData['municipios']);
  }

  void onMunicipalityChanged(String? val) => selectedMunicipality.value = val;
  void onCategoryChanged(String? val) => selectedCategory.value = val;

  // --- IMÁGENES ---
  Future<void> pickRifImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _rawImageFile = image; 
        update(); // Refrescar UI si es necesario
      }
    } catch (e) {
      Get.snackbar("Error", "No se pudo acceder a la galería");
    }
  }

  void removeRifImage() {
    _rawImageFile = null;
    update();
  }

  // --- REGISTRO ---
  Future<void> register() async {
    // Validaciones básicas visuales
    if (commercialNameController.text.isEmpty || 
        rifController.text.isEmpty || 
        emailController.text.isEmpty || 
        passwordController.text.isEmpty) {
      Get.snackbar("Faltan Datos", "Por favor llena los campos obligatorios", 
        backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      
      final rif = rifController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text;

      // 1. Verificación previa de duplicados (Opcional pero recomendado)
      // Nota: Si esto falla mucho, puedes comentarlo y dejar que Auth maneje el error
      try {
        final existing = await _supabase.from('businesses')
          .select('id')
          .or('rif.eq.$rif,email.eq.$email')
          .maybeSingle(); // Usamos maybeSingle para no dar error si está vacío
        
        if (existing != null) throw "El RIF o Correo ya están registrados en el sistema.";
      } catch (e) {
         // Si es error de conexión lo dejamos pasar, si es "ya registrado" lo lanzamos
         if (e.toString().contains("ya están registrados")) rethrow;
      }

      // 2. Crear Usuario Auth
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: { 'role': 'business' } 
      );

      if (res.user == null) throw "No se pudo crear el usuario Auth";
      final userId = res.user!.id;

      // 3. Subir Imagen (Si existe)
      String? uploadedRifUrl;
      if (_rawImageFile != null) {
        try {
          final bytes = await _rawImageFile!.readAsBytes();
          final fileExt = _rawImageFile!.path.split('.').last;
          final fileName = '$userId/rif_image.$fileExt';

          await _supabase.storage.from('logos').uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(contentType: 'image/$fileExt', upsert: true),
          );
          uploadedRifUrl = _supabase.storage.from('logos').getPublicUrl(fileName);
        } catch (e) {
          print("Error subiendo imagen: $e"); // No detenemos el registro por esto
        }
      }

      // 4. Insertar en Base de Datos
      // AQUI ESTABA EL ERROR: Los nombres deben coincidir con el SQL del Paso 1
      final businessData = {
        'id': userId,
        'commercial_name': commercialNameController.text.trim(),
        'legal_name': legalNameController.text.trim(),
        'rif': rif,
        'email': email,
        'phone': '${business.value.phonePrefix ?? "0412"}-${phoneController.text.trim()}', // Unimos prefijo y numero
        
        // Ubicación
        'state': selectedState.value,
        'city': selectedCity.value,
        'municipality': selectedMunicipality.value,
        'address': addressController.text.trim(),

        // Detalles
        'category': selectedCategory.value,
        'short_description': shortDescController.text.trim(),
        'representative_name': repNameController.text.trim(),
        'rif_url': uploadedRifUrl, // URL de la imagen
      };

      await _supabase.from('businesses').insert(businessData);

      Get.snackbar("¡Éxito!", "Empresa registrada correctamente", 
        backgroundColor: Colors.green, colorText: Colors.white);
      
      Get.offAllNamed(Routes.home);

    } catch (e) {
      String msg = e.toString();
      if (msg.contains("User already registered")) msg = "Este correo ya está registrado.";
      if (msg.contains("duplicate key")) msg = "El RIF o correo ya existen.";
      
      Get.snackbar("Error", msg, backgroundColor: Colors.red, colorText: Colors.white);
      print("🚨 ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }
}