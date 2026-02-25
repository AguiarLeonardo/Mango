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

  // --- AQUÍ ESTABA EL ERROR: AHORA SON REACTIVAS (Rxn) ---
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
    // USAMOS .value PARA VERIFICAR
    if (titleController.text.isEmpty ||
        priceController.text.isEmpty ||
        quantityController.text.isEmpty ||
        pickupStart.value == null ||
        pickupEnd.value == null) {
      Get.snackbar(
        "Faltan datos",
        "Por favor llena título, precio, cantidad y horarios.",
      );
      return;
    }

    try {
      isLoading.value = true;
      Get.back(); // Cerrar modal

      final userId = _supabase.auth.currentUser!.id;
      String? uploadedImageUrl;

      // A. Subir imagen
      if (pickedImage != null) {
        final bytes = await pickedImage!.readAsBytes();
        final fileExt = pickedImage!.path.split('.').last;
        final fileName =
            '$userId/pack_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

        await _supabase.storage
            .from('packs')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: FileOptions(
                contentType: 'image/$fileExt',
                upsert: true,
              ),
            );
        uploadedImageUrl = _supabase.storage
            .from('packs')
            .getPublicUrl(fileName);
      }

      // B. Insertar Pack en BD (USAMOS .value PARA LEER LA FECHA)
      final packData = {
        'business_id': userId,
        'title': titleController.text,
        'description': descController.text,
        'price': double.parse(priceController.text),
        'original_price': originalPriceController.text.isNotEmpty
            ? double.parse(originalPriceController.text)
            : null,
        'quantity_total': int.parse(quantityController.text),
        'quantity_available': int.parse(quantityController.text),
        'pickup_start': pickupStart.value!.toIso8601String(), // .value!
        'pickup_end': pickupEnd.value!.toIso8601String(), // .value!
        'image_url': uploadedImageUrl,
        'status': 'available',
      };

      await _supabase.from('packs').insert(packData);

      // Limpiar formulario
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

      fetchPacks();
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

  // Helpers para Fechas (MODIFICADO PARA USAR .value)
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

      final response = await _supabase.rpc(
        'reserve_pack',
        params: {'p_pack_id': packId, 'p_business_id': businessId},
      );

      if (response['success'] == true) {
        Get.snackbar(
          "¡Reserva Exitosa! 🎉",
          "Tu pack ha sido reservado. Ve a 'Mis Órdenes' para ver el código.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        fetchPacks();
        Get.back();
      } else {
        Get.snackbar(
          "Lo sentimos",
          "Este pack ya se agotó",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Ocurrió un problema: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
