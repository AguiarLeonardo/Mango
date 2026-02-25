import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PacksController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Estado
  final isLoading = false.obs;
  final isBusiness = false.obs;
  final packsList = <Map<String, dynamic>>[].obs;

  // --- Formulario Crear Pack ---
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final originalPriceController = TextEditingController();
  final quantityController = TextEditingController();

  // --- FECHAS REACTIVAS (Rxn) ---
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
      var query = _supabase
          .from('packs')
          .select('*, businesses(commercial_name, address, rif_url)');

      if (isBusiness.value) {
        final myId = _supabase.auth.currentUser!.id;
        final response = await query
            .eq('business_id', myId)
            .order('created_at', ascending: false);
        packsList.value = List<Map<String, dynamic>>.from(response);
      } else {
        final response = await query
            .eq('status', 'available')
            .order('created_at', ascending: false);
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
      update(); // Actualizar UI del modal (si usas GetBuilder para la imagen)
    }
  }

  // 4. Crear Pack (Solo Business)
  Future<void> createPack() async {
    // ✅ VALIDACIÓN CORREGIDA: Salimos de la función si falta algo
    if (titleController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        quantityController.text.trim().isEmpty ||
        pickupStart.value == null ||
        pickupEnd.value == null) {
      Get.snackbar(
        "Faltan datos",
        "Por favor llena título, precio, cantidad y asegúrate de seleccionar los horarios.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return; // Detiene la ejecución aquí si faltan datos
    }

    try {
      isLoading.value = true;

      // Cerramos el modal/bottom sheet solo si estamos seguros de que va a procesar
      if (Get.isBottomSheetOpen == true || Get.isDialogOpen == true) {
        Get.back();
      }

      final userId = _supabase.auth.currentUser!.id;
      String? uploadedImageUrl;

      // A. Subir imagen (Si el usuario seleccionó una)
      if (pickedImage != null) {
        final bytes = await pickedImage!.readAsBytes();
        final fileExt = pickedImage!.path.split('.').last;
        final fileName =
            '$userId/pack_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

        await _supabase.storage.from('packs').uploadBinary(
              fileName,
              bytes,
              fileOptions: FileOptions(
                contentType: 'image/$fileExt',
                upsert: true,
              ),
            );
        uploadedImageUrl =
            _supabase.storage.from('packs').getPublicUrl(fileName);
      }

      // B. Insertar Pack en BD
      // Usamos el '!' porque la validación de arriba nos asegura que no son null
      final packData = {
        'business_id': userId,
        'title': titleController.text.trim(),
        'description': descController.text.trim(),
        'price': double.tryParse(priceController.text) ?? 0.0,
        'original_price': originalPriceController.text.isNotEmpty
            ? (double.tryParse(originalPriceController.text) ?? 0.0)
            : null,
        'quantity_total': int.tryParse(quantityController.text) ?? 1,
        'quantity_available': int.tryParse(quantityController.text) ?? 1,
        'pickup_start': pickupStart.value!.toIso8601String(),
        'pickup_end': pickupEnd.value!.toIso8601String(),
        'image_url': uploadedImageUrl,
        'status': 'available',
      };

      await _supabase.from('packs').insert(packData);

      // Limpiar formulario después de crear exitosamente
      titleController.clear();
      descController.clear();
      priceController.clear();
      originalPriceController.clear();
      quantityController.clear();
      pickedImage = null;

      // RESETEAR VALORES REACTIVOS
      pickupStart.value = null;
      pickupEnd.value = null;

      Get.snackbar(
        "¡Listo!",
        "Pack publicado exitosamente",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Recargar la lista para mostrar el nuevo pack
      await fetchPacks();
    } catch (e) {
      Get.snackbar(
        "Error",
        "No se pudo crear el pack: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

      // Llamamos a la función RPC en Supabase
      final response = await _supabase.rpc(
        'reserve_pack',
        params: {'p_pack_id': packId, 'p_business_id': businessId},
      );

      if (response != null && response['success'] == true) {
        print(
            "✅ PASO 1: Stock restado con éxito. Intentando crear la orden en Supabase...");

        try {
          final orderResponse = await _supabase.from('orders').insert({
            'pack_id': packId,
            'business_id': businessId,
            'user_id': userId,
            'status': 'completed',
          }).select(); // <-- El .select() obliga a Supabase a decirnos si falló o triunfó

          print(
              "✅ PASO 2: ¡Orden creada exitosamente en Supabase!: $orderResponse");

          await fetchPacks();
          Get.snackbar("Éxito", "Compra realizada",
              backgroundColor: Colors.green);
        } catch (e) {
          // Si Supabase lo rechaza por RLS o falta de datos, caerá aquí.
          print("🚨 ERROR CRÍTICO AL CREAR LA ORDEN: $e");
          Get.snackbar("Error oculto", "Mira la consola",
              backgroundColor: Colors.red);
        }
      } else {
        Get.snackbar(
          "Lo sentimos",
          "Este pack ya se agotó o no está disponible.",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        throw Exception(
            "Pack agotado"); // Lanzamos error para que la pasarela lo sepa
      }
    } catch (e) {
      throw Exception(e.toString()); // Propagamos el error a la pasarela
    } finally {
      isLoading.value = false;
    }
  }
}
