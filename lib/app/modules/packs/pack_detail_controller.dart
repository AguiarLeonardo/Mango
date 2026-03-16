import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Asegúrate de importar tu PackModel aquí
// import '../../data/models/pack_model.dart'; 

class PackDetailController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  var isLoadingReviews = true.obs;
  var reviewsList = <Map<String, dynamic>>[].obs;
  var averageRating = 0.0.obs;
  var totalReviews = 0.obs;
  
  // ✅ Variable para saber si el usuario actual es el dueño de este pack
  var isOwner = false.obs;

  // ✅ NUEVA VARIABLE REACTIVA PARA EL ESTADO DEL PACK
  // Por defecto asumimos que está activo hasta que carguemos los datos reales.
  var isActive = true.obs; 

  @override
  void onInit() {
    super.onInit();
    // Verificamos el dueño y el estado apenas se inicie el controlador
    _checkIfOwnerAndStatus();
  }

  // ✅ Nueva función para verificar si el usuario es el creador del pack y su estado
  void _checkIfOwnerAndStatus() {
    final currentUser = _supabase.auth.currentUser;
    // Obtenemos el pack desde los argumentos
    final pack = Get.arguments; 
    
    // ✅ Asignamos el estado inicial del pack a nuestra variable reactiva
    // IMPORTANTE: Asegúrate de que tu PackModel tenga la propiedad 'isActive' (tipo bool)
    // que se cargue desde la columna 'is_active' de Supabase.
    isActive.value = pack.isActive ?? true; 

    if (currentUser != null) {
      // Obtenemos el ID del usuario logueado
      String currentUserId = currentUser.id;
      
      // Comparamos. Ajusta 'businessId' al nombre exacto de la propiedad en tu PackModel
      if (pack.businessId == currentUserId) {
        isOwner.value = true;
      }
    }
  }

  void fetchReviews(String packId) async {
    try {
      isLoadingReviews.value = true;
      
      final response = await _supabase
          .from('ratings')
          .select('rating, comment, created_at')
          .eq('pack_id', packId)
          .order('created_at', ascending: false);

      if (response != null) {
        final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);
        
        reviewsList.value = data;
        totalReviews.value = data.length;

        if (data.isNotEmpty) {
          double sum = 0;
          for (var review in data) {
            sum += (review['rating'] as num).toDouble();
          }
          averageRating.value = sum / data.length;
        } else {
          averageRating.value = 0.0;
        }
      }
    } catch (e) {
      print("Error cargando reseñas: $e");
    } finally {
      isLoadingReviews.value = false;
    }
  }

  // ✅ FUNCIÓN PARA OCULTAR MODIFICADA (Soft Delete)
  Future<void> hidePack(String packId) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // 1. Actualizamos en Supabase
      await _supabase
          .from('packs')
          .update({'is_active': false}) // ✅ Nombre correcto de tu columna
          .eq('id', packId);

      // 2. ✅ ACTUALIZAMOS LA VARIABLE REACTIVA LOCAL
      isActive.value = false; 

      Get.back(); // Cierra el indicador de carga

      Get.snackbar(
        "Éxito",
        "El pack ha sido ocultado correctamente",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );

    } catch (e) {
      Get.back(); // Cierra el indicador de carga
      print("Error ocultando el pack: $e");
      Get.snackbar(
        "Error",
        "No se pudo ocultar el pack",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ✅ NUEVA FUNCIÓN PARA VOLVER A ACTIVAR
  Future<void> reactivatePack(String packId) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // 1. Actualizamos en Supabase a true
      await _supabase
          .from('packs')
          .update({'is_active': true}) // ✅ Nombre correcto de tu columna
          .eq('id', packId);

      // 2. ✅ ACTUALIZAMOS LA VARIABLE REACTIVA LOCAL
      isActive.value = true; 

      Get.back(); // Cierra el indicador de carga

      Get.snackbar(
        "Éxito",
        "El pack ha sido activado nuevamente",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      Get.back(); // Cierra el indicador de carga
      print("Error activando el pack: $e");
      Get.snackbar(
        "Error",
        "No se pudo activar el pack",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ✅ Diálogo de confirmación antes de ocultar
  void confirmHide(String packId) {
    Get.defaultDialog(
      title: "Ocultar Pack",
      middleText: "¿Deseas ocultar este pack? Se pondrá en gris y nadie podrá reservarlo.",
      textCancel: "Cancelar",
      textConfirm: "Sí, ocultar",
      confirmTextColor: Colors.white,
      buttonColor: Colors.orange, // Naranja para advertir, pero no es destructivo
      cancelTextColor: Colors.black,
      onConfirm: () {
        Get.back(); // Cerramos el diálogo
        hidePack(packId); // Llamamos a la función de ocultar
      },
    );
  }

  // ✅ Diálogo de confirmación antes de reactivar
  void confirmReactivate(String packId) {
    Get.defaultDialog(
      title: "Activar Pack",
      middleText: "¿Deseas volver a poner este pack a la venta?",
      textCancel: "Cancelar",
      textConfirm: "Sí, activar",
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      cancelTextColor: Colors.black,
      onConfirm: () {
        Get.back(); // Cerramos el diálogo
        reactivatePack(packId); // Llamamos a la función de reactivar
      },
    );
  }
}