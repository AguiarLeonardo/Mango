import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/pack_model.dart';

class PacksController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Estado
  final isLoading = false.obs;
  final isBusiness = false.obs;
  final packsList = <PackModel>[].obs;

  // --- Formulario Crear Pack ---
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final originalPriceController = TextEditingController();
  final quantityController = TextEditingController();

  final pickupStart = Rxn<DateTime>();
  final pickupEnd = Rxn<DateTime>();

  // Imagen
  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;

  @override
  void onInit() {
    super.onInit();
    checkUserRoleAndFetch();
  }

  // 1. Verificar Rol y Cargar Packs
  Future<void> checkUserRoleAndFetch() async {
    isLoading.value = true;
    final userId = _supabase.auth.currentUser?.id;

    if (userId != null) {
      final businessData = await _supabase
          .from('businesses')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      isBusiness.value = (businessData != null);
    }

    await fetchPacks();
    isLoading.value = false;
  }

  // 2. Traer los Packs de Supabase
  Future<void> fetchPacks() async {
    try {
      var query = _supabase.from('packs').select('*, businesses(*)');

      if (isBusiness.value) {
        final myId = _supabase.auth.currentUser!.id;
        final response = await query
            .eq('business_id', myId)
            .order('created_at', ascending: false);
        packsList.assignAll((response as List<dynamic>)
            .map<PackModel>(
                (e) => PackModel.fromJson(e as Map<String, dynamic>))
            .toList());
      } else {
        final response = await query
            .eq('status', 'available')
            .order('created_at', ascending: false);
        packsList.assignAll((response as List<dynamic>)
            .map<PackModel>(
                (e) => PackModel.fromJson(e as Map<String, dynamic>))
            .toList());
      }
    } catch (e) {
      Get.snackbar("Error", "No se pudieron cargar los packs: $e");
    }
  }

  // 3. Seleccionar Imagen
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      pickedImage = image;
      update(); // Actualiza la vista previa en el modal
    }
  }

  // 4. Crear Pack (Solo Business)
  Future<void> createPack() async {
    if (titleController.text.isEmpty ||
        priceController.text.isEmpty ||
        quantityController.text.isEmpty) {
      Get.snackbar(
          "Faltan datos", "Por favor llena título, precio y cantidad.");
      return;
    }

    if (pickupStart.value == null || pickupEnd.value == null) {
      Get.snackbar("Error", "Debes definir el horario de recogida",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    if (!pickupEnd.value!.isAfter(pickupStart.value!)) {
      Get.snackbar("Error", "El horario de fin debe ser posterior al de inicio",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      Get.back(); // Cierra el modal de creación

      final userId = _supabase.auth.currentUser!.id;
      String? uploadedImageUrl;

      // ✅ SUBIR IMAGEN A SUPABASE CORRECTAMENTE (Web y Móvil)
      if (pickedImage != null) {
        // Leemos la imagen como bytes en lugar de usar File()
        final bytes = await pickedImage!.readAsBytes();

        // Usamos .name para obtener la extensión de forma segura en Web
        final fileExt = pickedImage!.name.split('.').last;
        final fileName =
            '$userId/pack_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

        // Usamos uploadBinary en lugar de upload
        await _supabase.storage.from('packs').uploadBinary(
              fileName,
              bytes,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: true),
            );

        // Obtener la URL pública de la imagen
        uploadedImageUrl =
            _supabase.storage.from('packs').getPublicUrl(fileName);
        print("✅ Imagen subida: $uploadedImageUrl");
      }

      final packData = {
        'business_id': userId,
        'title': titleController.text,
        'description': descController.text.trim().isEmpty ? null : descController.text.trim(),
        'price': double.parse(priceController.text),
        'original_price': originalPriceController.text.isNotEmpty
            ? double.parse(originalPriceController.text)
            : null,
        'quantity_total': int.parse(quantityController.text),
        'quantity_available': int.parse(quantityController.text),
        'pickup_start': pickupStart.value!.toUtc().toIso8601String(),
        'pickup_end': pickupEnd.value!.toUtc().toIso8601String(),
        'image_url': uploadedImageUrl, // Guardamos la URL en la BD
        'status': 'available',
        'is_active': true,
      };

      await _supabase.from('packs').insert(packData);

      // Limpiar formulario
      titleController.clear();
      descController.clear();
      priceController.clear();
      originalPriceController.clear();
      quantityController.clear();
      pickedImage = null;
      pickupStart.value = null;
      pickupEnd.value = null;

      Get.snackbar("¡Listo!", "Pack publicado exitosamente",
          backgroundColor: Colors.green, colorText: Colors.white);

      fetchPacks();
    } catch (e) {
      Get.snackbar("Error", "No se pudo crear el pack: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
      print("❌ Error al crear pack o subir imagen: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Helpers para Fechas
  void setPickupStart(DateTime dt) {
    pickupStart.value = dt;
  }

  void setPickupEnd(DateTime dt) {
    pickupEnd.value = dt;
  }

  // --- MÉTODO PARA RESERVAR ---
  Future<void> reservePack(String packId, String businessId) async {
    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        Get.snackbar("Error", "Debes iniciar sesión para reservar");
        return;
      }

      final response = await _supabase.rpc('reserve_pack', params: {
        'p_pack_id': packId,
        'p_business_id': businessId,
      });

      if (response['success'] == true) {
        Get.snackbar("¡Reserva Exitosa! 🎉",
            "Tu pack ha sido reservado. Ve a 'Mis Órdenes' para ver el código.",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 4));
        fetchPacks();
      } else {
        Get.snackbar("Lo sentimos", "Este pack ya se agotó",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Ocurrió un problema: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
