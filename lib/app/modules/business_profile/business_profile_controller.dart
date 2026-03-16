import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/location_service.dart';

class BusinessProfileController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- VARIABLES DE TEXTO (Adaptadas a la tabla businesses) ---
  final commercialNameController = TextEditingController();
  final categoryController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final municipalityController = TextEditingController();

  // --- SERVICIOS ---
  final LocationService locationService = Get.find<LocationService>();

  // --- VARIABLES DE IMAGEN ---
  var logoUrl = ''.obs; // 👈 Guarda el link del logo de la empresa
  var isUploadingLogo = false.obs;
  var isLoading = false.obs;
  var isLoadingGPS = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBusinessProfile();
  }

  // CARGAR DATOS DE LA EMPRESA
  Future<void> loadBusinessProfile() async {
    try {
      isLoading.value = true;
      final user = _supabase.auth.currentUser;

      if (user != null) {
        final data = await _supabase
            .from('businesses')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (data != null) {
          commercialNameController.text = data['commercial_name'] ?? '';
          categoryController.text = data['category'] ?? '';
          phoneController.text = data['phone'] ?? '';
          addressController.text = data['address'] ?? '';
          stateController.text = data['state'] ?? '';
          cityController.text = data['city'] ?? '';
          municipalityController.text = data['municipality'] ?? '';
          logoUrl.value = data['logo_url'] ?? ''; 
        }
      }
    } catch (e) {
      Get.snackbar(
        "Error", 
        "No se pudieron cargar los datos de la empresa",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // SUBIR LOGO A SUPABASE
  Future<void> uploadLogo() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      isUploadingLogo.value = true;
      final bytes = await image.readAsBytes();
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final fileExt = image.path.split('.').last;
      final fileName = 'logo_${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // ✅ CAMBIO CLAVE 1: Subimos al nuevo bucket 'business_logos'
      await _supabase.storage.from('business_logos').uploadBinary(
        fileName, 
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );

      // ✅ CAMBIO CLAVE 2: Obtenemos el link público desde 'business_logos'
      final String publicUrl = _supabase.storage.from('business_logos').getPublicUrl(fileName);

      // Guardamos en la tabla businesses
      await _supabase.from('businesses').update({'logo_url': publicUrl}).eq('id', user.id);

      logoUrl.value = publicUrl;

      Get.snackbar(
        "Éxito", 
        "Logo actualizado correctamente",
        backgroundColor: Colors.white, 
        colorText: Colors.green[800],
      );

    } catch (e) {
      Get.snackbar("Error", "No se pudo subir el logo: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
      print("Error detallado al subir logo: $e"); // Para ver en consola si Supabase se queja
    } finally {
      isUploadingLogo.value = false;
    }
  }

  // --- LLENAR UBICACIÓN CON GPS ---
  Future<void> fillLocationWithGPS() async {
    try {
      isLoadingGPS.value = true;
      
      await locationService.fetchCurrentLocation();
      
      final stateName = locationService.currentStateName.value;
      if (stateName.isNotEmpty) {
        stateController.text = stateName;
        // Igual que en el perfil normal, se podría sacar ciudad o municipio si el servicio de geocoding lo provee extra
        Get.snackbar(
          "Ubicación obtenida",
          "Se ha autocompletado tu estado ($stateName) a partir del GPS.",
          backgroundColor: Colors.white,
          colorText: Colors.green[800],
        );
      } else {
        Get.snackbar(
          "Aviso", 
          "No se pudo determinar el Estado desde las coordenadas GPS."
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

  // GUARDAR CAMBIOS
  Future<void> updateProfile() async {
    try {
      isLoading.value = true;
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('businesses').update({
        'commercial_name': commercialNameController.text.trim(),
        'category': categoryController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'state': stateController.text.trim(),
        'city': cityController.text.trim(),
        'municipality': municipalityController.text.trim(),
      }).eq('id', user.id);

      Get.back();
      Get.snackbar(
        "Éxito",
        "Perfil de empresa actualizado correctamente",
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