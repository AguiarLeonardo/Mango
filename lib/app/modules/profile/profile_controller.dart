
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/location_service.dart';

class ProfileController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- VARIABLES DE TEXTO ---
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final municipalityController = TextEditingController();
  
  final birthdateController = TextEditingController();
  final genderController = TextEditingController();
  final emailController = TextEditingController();

  // --- SERVICIOS ---
  final LocationService locationService = Get.find<LocationService>();

  // --- VARIABLES DE IMAGEN ---
  var avatarUrl = ''.obs; // 👈 Guarda el link de la foto que viene de Supabase
  var isUploadingAvatar = false.obs; // 👈 Controla el estado de carga de la foto

  // --- OPCIONES DE GÉNERO ---
  final List<String> genderOptions = ['Hombre', 'Mujer'];

  var isLoading = false.obs;
  var isLoadingGPS = false.obs;

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
          stateController.text = data['state'] ?? '';
          cityController.text = data['city'] ?? '';
          municipalityController.text = data['municipality'] ?? '';
          birthdateController.text = data['birthdate'] ?? '';
          avatarUrl.value = data['avatar_url'] ?? ''; // 👈 Cargamos la URL de la foto

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

  // --- FUNCIÓN PARA SELECCIONAR Y SUBIR IMAGEN A SUPABASE ---
  Future<void> uploadProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    try {
      // 1. Abrir galería
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return; // Si cancela, no hacemos nada

      isUploadingAvatar.value = true; // Mostramos el circulito de carga

      // 2. Preparar imagen y datos
      final bytes = await image.readAsBytes();
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final fileExt = image.path.split('.').last;
      final fileName = 'avatar_${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // 3. Subir a Supabase Storage (asegúrate de haber creado el bucket 'avatars' como PÚBLICO)
      await _supabase.storage.from('avatars').uploadBinary(
        fileName, 
        bytes,
        fileOptions: const FileOptions(upsert: true), // Sobrescribe si por casualidad hay uno igual
      );

      // 4. Obtener link público
      final String publicUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);

      // 5. Guardar el link en la tabla 'users'
      await _supabase.from('users').update({'avatar_url': publicUrl}).eq('id', user.id);

      // 6. Actualizar la variable reactiva en pantalla
      avatarUrl.value = publicUrl;

      Get.snackbar(
        "Éxito", 
        "Foto de perfil actualizada correctamente",
        backgroundColor: Colors.white, 
        colorText: Colors.green[800],
      );

    } catch (e) {
      Get.snackbar("Error", "No se pudo subir la foto: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isUploadingAvatar.value = false; // Quitamos el circulito de carga
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

  // --- LLENAR UBICACIÓN CON GPS ---
  Future<void> fillLocationWithGPS() async {
    try {
      isLoadingGPS.value = true;
      
      // Intentamos obtener la ubicación fresca
      await locationService.fetchCurrentLocation();
      
      final stateName = locationService.currentStateName.value;
      final cityName = locationService.currentCityName.value;
      final municipalityName = locationService.currentMunicipalityName.value;

      bool anyFilled = false;

      if (stateName.isNotEmpty) {
        stateController.text = stateName;
        anyFilled = true;
      }
      if (cityName.isNotEmpty) {
        cityController.text = cityName;
        anyFilled = true;
      }
      if (municipalityName.isNotEmpty) {
        municipalityController.text = municipalityName;
        anyFilled = true;
      }

      if (anyFilled) {
        Get.snackbar(
          "Ubicación obtenida",
          "Se ha autocompletado tu ubicación a partir del GPS.",
          backgroundColor: Colors.white,
          colorText: Colors.green[800],
        );
      } else {
        Get.snackbar(
          "Aviso", 
          "No se pudo determinar la ubicación desde las coordenadas GPS."
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error GPS", 
        "Hubo un problema al tratar de usar el GPS: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoadingGPS.value = false;
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
        'state': stateController.text.trim(),
        'city': cityController.text.trim(),
        'municipality': municipalityController.text.trim(),
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