import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/venezuela_data.dart'; 
import '../../../routes/app_routes.dart';

class RegisterUserController extends GetxController {
  
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  
  final isLoading = false.obs;
  
  // --- Imagen de Perfil ---
  final profileImagePath = RxnString(); 

  // --- Controladores de Texto ---
  final firstNameController = TextEditingController(); 
  final lastNameController = TextEditingController();  
  final cedulaController = TextEditingController();    
  final phoneController = TextEditingController();     
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final addressController = TextEditingController();
  
  // --- ERRORES REACTIVOS ---
  final emailError = RxnString();
  final passwordError = RxnString();

  // --- Listas y Selectores ---
  final selectedPhoneCode = '0412'.obs; 
  final phoneCodes = ['0412', '0424', '0416', '0414', '0426', '0212'];

  final selectedDocType = 'V-'.obs;
  final docTypes = ['V-', 'E-', 'P-']; 

  bool get isPassport => selectedDocType.value == 'P-';

  // --- VARIABLES GEOGRÁFICAS ---
  final selectedState = RxnString();
  final selectedCity = RxnString();
  final selectedMunicipality = RxnString();
  
  final availableCities = <Map<String, dynamic>>[].obs;
  final availableMunicipalities = <String>[].obs;
  final stateNames = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    try {
      if (venezuelaData.isEmpty) {
        print("PELIGRO: venezuelaData está vacío.");
      } else {
        venezuelaData.sort((a, b) => (a['estado'] as String).compareTo(b['estado'] as String));
        stateNames.value = venezuelaData.map((e) => e['estado'] as String).toList();
      }
    } catch (e) {
      print("Error cargando venezuela_data: $e");
    }
  }

  // --- VALIDACIONES ---
  void validateEmail(String value) {
    if (value.isEmpty) { emailError.value = null; return; }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    emailError.value = !emailRegex.hasMatch(value) ? "Correo inválido" : null;
  }

  void validatePassword(String value) {
    if (value.isEmpty) { passwordError.value = null; return; }
    List<String> errors = [];
    if (value.length < 8) errors.add("• Mínimo 8 caracteres");
    if (!value.contains(RegExp(r'[A-Z]'))) errors.add("• Al menos 1 Mayúscula");
    if (!value.contains(RegExp(r'[0-9]'))) errors.add("• Al menos 1 Número");
    passwordError.value = errors.isNotEmpty ? "Falta:\n${errors.join('\n')}" : null;
  }

  // --- LOGICA UBICACIÓN ---
  void onStateChanged(String? val) {
    selectedState.value = val;
    selectedCity.value = null;
    selectedMunicipality.value = null;
    availableMunicipalities.clear();
    availableCities.clear();

    if (val != null) {
      try {
        var estadoData = venezuelaData.firstWhere((e) => e['estado'] == val);
        availableCities.value = List<Map<String, dynamic>>.from(estadoData['ciudades']);
      } catch (e) {
        print("Error buscando ciudades: $e");
      }
    }
  }

  void onCityChanged(String? val) {
    selectedCity.value = val;
    selectedMunicipality.value = null;
    availableMunicipalities.clear();
    
    if (val != null) {
      try {
        var ciudadData = availableCities.firstWhere((e) => e['nombre'] == val);
        availableMunicipalities.value = List<String>.from(ciudadData['municipios']);
      } catch (e) {
        print("Error buscando municipios: $e");
      }
    }
  }

  Future<void> pickProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) profileImagePath.value = image.path;
  }

  // ===========================================================================
  // REGISTRO DE USUARIO (BLINDADO)
  // ===========================================================================
  Future<void> registerUser() async {
    // 1. REVISAR ERRORES VISUALES
    if (emailError.value != null || passwordError.value != null) {
       Get.snackbar("Datos inválidos", "Corrige los campos marcados en rojo.", backgroundColor: Colors.red, colorText: Colors.white);
       return;
    }

    // 2. REVISAR CAMPOS VACÍOS
    if (firstNameController.text.isEmpty || 
        lastNameController.text.isEmpty || 
        emailController.text.isEmpty ||
        cedulaController.text.isEmpty ||
        phoneController.text.isEmpty || 
        passwordController.text.isEmpty) {
        
        Get.snackbar("Faltan datos", "Todos los campos de texto son obligatorios.", 
          backgroundColor: Colors.red, colorText: Colors.white);
        return;
    }

    // 3. REVISAR UBICACIÓN
    if (selectedState.value == null || selectedCity.value == null || selectedMunicipality.value == null) {
       Get.snackbar("Ubicación incompleta", "Debes seleccionar Estado, Ciudad y Municipio.", 
         backgroundColor: Colors.red, colorText: Colors.white);
       return;
    }

    // 4. REVISAR CONTRASEÑAS
    if (passwordController.text != confirmPasswordController.text) {
       Get.snackbar("Error", "Las contraseñas no coinciden", backgroundColor: Colors.red, colorText: Colors.white);
       return;
    }

    try {
      isLoading.value = true;
      
      final fullCedula = '${selectedDocType.value}${cedulaController.text}';
      final email = emailController.text.trim();

      // --- [NUEVO] PRE-VERIFICACIÓN DE SEGURIDAD ---
      // Verificamos si la CÉDULA ya existe antes de crear la cuenta.
      // Nota: No chequeamos el correo aquí porque Supabase Auth ya lo hace, 
      // pero la cédula es un dato personalizado que Supabase Auth ignora.
      
      final List<dynamic> existingUser = await _supabase
          .from('users')
          .select('id')
          .eq('cedula', fullCedula); // Buscamos coincidencia exacta de cédula

      if (existingUser.isNotEmpty) {
        throw "La cédula $fullCedula ya está registrada.";
      }
      // ----------------------------------------------

      // 5. CREAR USUARIO EN AUTH (Solo si la cédula está libre)
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: passwordController.text,
      );

      if (res.user == null) {
        throw "El usuario no se creó (respuesta nula)";
      }
      
      final userId = res.user!.id;

      // 6. INSERTAR EN LA TABLA DE DATOS
      final fullPhone = '${selectedPhoneCode.value}-${phoneController.text}';
      
      await _supabase.from('users').insert({
        'id': userId,
        'first_name': firstNameController.text, 
        'last_name': lastNameController.text, 
        'cedula': fullCedula, 
        'phone': fullPhone,
        'username': usernameController.text.isNotEmpty ? usernameController.text : null,
        'state': selectedState.value, 
        'city': selectedCity.value,
        'municipality': selectedMunicipality.value,
        'address': addressController.text,
      });

      // 7. SUBIR FOTO (OPCIONAL)
      // Agregamos esto por si decides subir la foto de perfil
      if (profileImagePath.value != null) {
        try {
          final file = File(profileImagePath.value!);
          final fileExt = file.path.split('.').last;
          final fileName = '$userId/profile.$fileExt';
          
          await _supabase.storage.from('avatars').upload(fileName, file, 
            fileOptions: const FileOptions(upsert: true));
            
          // Opcional: Podrías actualizar el campo 'avatar_url' en la tabla users aquí
        } catch (e) {
          print("Error subiendo avatar: $e"); // No detenemos el flujo por esto
        }
      }

      Get.snackbar(
        "¡Bienvenido!", 
        "Cuenta creada exitosamente.", 
        backgroundColor: Colors.green, 
        colorText: Colors.white,
        duration: const Duration(seconds: 3)
      );
      
      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed(Routes.login); 

    } catch (e) {
      String msg = e.toString();
      
      if (msg.contains("Exception:")) {
         msg = msg.replaceAll("Exception:", "").trim();
      }
      
      // Manejo de errores comunes
      if (msg.contains("User already registered")) {
        msg = "Este correo ya está registrado.";
      } else if (msg.contains("duplicate key")) {
        msg = "La cédula o usuario ya existe.";
      }

      Get.snackbar("Error de Registro", msg, backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 4));
    
    } finally {
      isLoading.value = false;
    }
  }
}