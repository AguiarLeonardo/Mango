import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- VARIABLES DE TEXTO ---
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final birthdateController = TextEditingController();
  final genderController = TextEditingController();
  final emailController = TextEditingController();

  // --- VARIABLES DE IMAGEN ---
  final Rx<File?> selectedImage = Rx<File?>(null);

  // --- OPCIONES DE GÉNERO ---
  final List<String> genderOptions = ['Hombre', 'Mujer'];

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  // CARGAR DATOS
  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      final user = _supabase.auth.currentUser;

      if (user != null) {
        emailController.text = user.email ?? '';

        final data = await _supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (data != null) {
          firstNameController.text = data['first_name'] ?? '';
          lastNameController.text = data['last_name'] ?? '';
          usernameController.text = data['username'] ?? '';
          phoneController.text = data['phone'] ?? '';
          addressController.text = data['address'] ?? '';

          birthdateController.text = data['birthdate'] ?? '';

          String loadedGender = data['gender'] ?? '';
          if (genderOptions.contains(loadedGender)) {
            genderController.text = loadedGender;
          } else {
            genderController.clear();
          }
        }
      }
    } catch (e) {
      Get.snackbar("Error", "No se pudieron cargar los datos");
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNCIÓN PARA SELECCIONAR IMAGEN ---
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar("Error", "No se pudo abrir la galería",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- FUNCIÓN CALENDARIO ---
  Future<void> pickDate(BuildContext context) async {
    DateTime? initialDate;
    try {
      if (birthdateController.text.isNotEmpty) {
        initialDate = DateFormat('dd/MM/yyyy').parse(birthdateController.text);
      }
    } catch (_) {}

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green[800]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      birthdateController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  // GUARDAR DATOS
  Future<void> updateProfile() async {
    try {
      isLoading.value = true;
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('users').update({
        'first_name': firstNameController.text.trim(),
        'last_name': lastNameController.text.trim(),
        'username': usernameController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'birthdate': birthdateController.text.trim(),
        'gender': genderController.text.trim(),
      }).eq('id', user.id);

      Get.back();
      Get.snackbar(
        "Éxito",
        "Perfil actualizado correctamente",
        backgroundColor: Colors.white,
        colorText: Colors.green[800],
      );
    } catch (e) {
      Get.snackbar("Error", "Error al actualizar: ${e.toString()}",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
