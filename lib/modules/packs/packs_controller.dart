import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Si tienes errores de "File", agrega esto:
import 'dart:io';

class PacksController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Estado
  final isLoading = false.obs;
  final isBusiness = false.obs; // Para saber si mostramos el botón de crear
  final packsList = <Map<String, dynamic>>[].obs; // Lista de packs

  // --- Formulario Crear Pack ---
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final originalPriceController = TextEditingController();
  final quantityController = TextEditingController();
  
  // Fechas y Horas
  DateTime? pickupStart;
  DateTime? pickupEnd;
  
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
      // Verificamos si este ID existe en la tabla 'businesses'
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
      // La query base: Traer packs y los datos de la empresa dueña
      var query = _supabase.from('packs').select('*, businesses(commercial_name, address, rif_url)');

      if (isBusiness.value) {
        // Si soy empresa, SOLO veo los mios
        final myId = _supabase.auth.currentUser!.id;
        final response = await query.eq('business_id', myId).order('created_at', ascending: false);
        packsList.value = List<Map<String, dynamic>>.from(response);
      } else {
        // Si soy usuario, veo TODOS los disponibles (status = available)
        final response = await query.eq('status', 'available').order('created_at', ascending: false);
        packsList.value = List<Map<String, dynamic>>.from(response);
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
      update(); // Actualizar UI del modal
    }
  }

  // 4. Crear Pack (Solo Business)
  Future<void> createPack() async {
    if (titleController.text.isEmpty || priceController.text.isEmpty || 
        quantityController.text.isEmpty || pickupStart == null || pickupEnd == null) {
      Get.snackbar("Faltan datos", "Por favor llena título, precio, cantidad y horarios.");
      return;
    }

    try {
      isLoading.value = true;
      Get.back(); // Cerrar modal

      final userId = _supabase.auth.currentUser!.id;
      String? uploadedImageUrl;

      // A. Subir imagen si hay
      if (pickedImage != null) {
        final bytes = await pickedImage!.readAsBytes();
        final fileExt = pickedImage!.path.split('.').last;
        final fileName = '$userId/pack_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        
        await _supabase.storage.from('packs').uploadBinary(
          fileName, bytes, 
          fileOptions: FileOptions(contentType: 'image/$fileExt', upsert: true)
        );
        uploadedImageUrl = _supabase.storage.from('packs').getPublicUrl(fileName);
      }

      // B. Insertar Pack en BD
      final packData = {
        'business_id': userId, // ¡Aquí guardamos la relación!
        'title': titleController.text,
        'description': descController.text,
        'price': double.parse(priceController.text),
        'original_price': originalPriceController.text.isNotEmpty ? double.parse(originalPriceController.text) : null,
        'quantity_total': int.parse(quantityController.text),
        'quantity_available': int.parse(quantityController.text),
        'pickup_start': pickupStart!.toIso8601String(),
        'pickup_end': pickupEnd!.toIso8601String(),
        'image_url': uploadedImageUrl,
        'status': 'available'
      };

      await _supabase.from('packs').insert(packData);

      // Limpiar formulario
      titleController.clear();
      descController.clear();
      priceController.clear();
      originalPriceController.clear();
      quantityController.clear();
      pickedImage = null;
      pickupStart = null;
      pickupEnd = null;

      Get.snackbar("¡Listo!", "Pack publicado exitosamente", backgroundColor: Colors.green, colorText: Colors.white);
      
      // Recargar lista
      fetchPacks();

    } catch (e) {
      Get.snackbar("Error", "No se pudo crear el pack: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Helpers para Fechas
  void setPickupStart(DateTime dt) { pickupStart = dt; update(); }
  void setPickupEnd(DateTime dt) { pickupEnd = dt; update(); }
}
