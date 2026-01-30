import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Asegúrate de que estas rutas existan
import '../../../routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class RegisterUserController extends GetxController {
  
  final SupabaseClient _supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();
  
  XFile? _rawImageFile; 
  final profileImagePath = RxnString(); 

  // --- Controladores ---
  final firstNameController = TextEditingController(); 
  final lastNameController = TextEditingController();  
  final cedulaController = TextEditingController();    
  final phoneController = TextEditingController();     
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  final usernameController = TextEditingController(); 

  // Códigos de teléfono
  final selectedPhoneCode = '0412'.obs; 
  final phoneCodes = ['0412', '0424', '0416', '0414', '0426'];

  // Tipo de documento
  final selectedDocType = 'V-'.obs;
  final docTypes = ['V-', 'E-', 'J-', 'P-'];

  // --- SELECCIONAR IMAGEN ---
  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _rawImageFile = image;
        profileImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar("Error", "No se pudo acceder a la galería");
    }
  }

  // --- REGISTRO DE USUARIO ---
  Future<void> registerUser() async {
    // Validaciones
    if (firstNameController.text.isEmpty || 
        lastNameController.text.isEmpty || 
        emailController.text.isEmpty ||
        cedulaController.text.isEmpty ||
        passwordController.text.isEmpty) {
        Get.snackbar("Faltan datos", "Por favor llena los campos obligatorios.", 
          backgroundColor: Colors.red, colorText: Colors.white);
        return;
    }

    if (passwordController.text != confirmPasswordController.text) {
       Get.snackbar("Error", "Las contraseñas no coinciden", 
         backgroundColor: Colors.red, colorText: Colors.white);
       return;
    }

    try {
      isLoading.value = true;

      // 1. Crear usuario en Supabase Auth
      final AuthResponse res = await _supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (res.user == null) throw "No se pudo crear el usuario";
      final userId = res.user!.id;

      // 2. Insertar datos en la tabla 'users'
      // ✅ AHORA SÍ COINCIDEN CON TU FOTO
      await _supabase.from('users').insert({
        'id': userId,
        
        // Según tu imagen image_71c416.png:
        'first_name': firstNameController.text, 
        'last_name': lastNameController.text, 
        'cedula': '${selectedDocType.value}${cedulaController.text}', 
        'phone': '${selectedPhoneCode.value}-${phoneController.text}',
        'username': usernameController.text.isNotEmpty ? usernameController.text : null,
        
        // NOTA: No vi la columna 'email' en tu foto, así que la quité para evitar errores.
        // Si quieres guardarlo, descomenta la siguiente línea y crea la columna en Supabase:
        // 'email': emailController.text.trim(),
      });

      Get.snackbar("¡Bienvenido!", "Tu cuenta ha sido creada.", 
        backgroundColor: Colors.green, colorText: Colors.white);
      
      Get.offAllNamed(Routes.home);

    } catch (e) {
      String msg = e.toString().replaceAll("Exception:", "").trim();
      // Traducción de errores comunes
      if (msg.contains("User already registered")) msg = "Este correo ya está registrado.";
      if (msg.contains("duplicate key")) msg = "Ese usuario o cédula ya existe.";
      if (msg.contains("PGRST204")) msg = "Error de columnas: Recarga el caché en Supabase.";
      
      Get.snackbar("Error", msg, backgroundColor: Colors.red, colorText: Colors.white);
      print("🚨 ERROR DETALLADO: $e");
    } finally {
      isLoading.value = false;
    }
  }
}