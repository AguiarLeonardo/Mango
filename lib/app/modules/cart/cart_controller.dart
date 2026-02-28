import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/pack_model.dart';
import '../../routes/app_routes.dart';

class CartController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Variables reactivas
  var cartItem = Rxn<PackModel>();
  var timeLeft = 0.obs; // Tiempo en segundos
  var isReserving = false.obs;
  
  Timer? _timer;

  // 1. AÑADIR AL CARRITO Y RESERVAR TEMPORALMENTE
  Future<void> addToCart(PackModel pack) async {
    if (cartItem.value != null) {
      Get.snackbar("Aviso", "Ya tienes un pack en el carrito. Finaliza o cancela esa compra primero.");
      return;
    }

    if (pack.quantityAvailable <= 0) {
      Get.snackbar("Agotado", "Este pack ya no está disponible.");
      return;
    }

    try {
      isReserving.value = true;

      // Restamos 1 en Supabase para "bloquearlo" temporalmente
      await _supabase.from('packs').update({
        'quantity_available': pack.quantityAvailable - 1
      }).eq('id', pack.id);

      // Guardamos el pack en el carrito localmente
      cartItem.value = pack;
      
      // Iniciamos el temporizador (Ej: 15 minutos = 900 segundos)
      startTimer(900); 

      Get.toNamed(Routes.cart); // Navegamos a la pantalla del carrito (ruta a crear)
      
    } catch (e) {
      Get.snackbar("Error", "No se pudo reservar el pack.");
    } finally {
      isReserving.value = false;
    }
  }

// 2. INICIAR EL TEMPORIZADOR
  void startTimer(int seconds) {
    timeLeft.value = seconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft.value > 0) {
        timeLeft.value--;
      } else {
        // SI EL TIEMPO SE ACABA: Liberar el pack enviando "true" (es por tiempo agotado)
        releaseCartItem(isTimeout: true);
      }
    });
  }

  // 3. LIBERAR EL PACK (Vuelve a estar disponible)
  // Agregamos el parámetro "isTimeout" que por defecto es falso
  Future<void> releaseCartItem({bool isTimeout = false}) async {
    _timer?.cancel();
    final pack = cartItem.value;
    
    if (pack != null) {
      try {
        // Le devolvemos el +1 a la base de datos
        final response = await _supabase.from('packs').select('quantity_available').eq('id', pack.id).single();
        int currentQty = response['quantity_available'] as int;

        await _supabase.from('packs').update({
          'quantity_available': currentQty + 1
        }).eq('id', pack.id);

        // AQUÍ ESTÁ LA MAGIA: Mensajes diferentes según cómo se canceló
        if (isTimeout) {
          Get.snackbar(
            "Tiempo agotado ⏱️", 
            "Tu tiempo de reserva expiró y el pack volvió a estar disponible.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            "Reserva cancelada 🗑️", 
            "Has eliminado el pack de tu carrito. ¡Sigue explorando!",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.grey[800],
            colorText: Colors.white,
          );
        }

      } catch (e) {
        print("Error liberando stock: $e");
      }
    }
    
    cartItem.value = null; // Vaciamos el carrito
    Get.offAllNamed(Routes.shell); // Lo devolvemos al inicio
  }

// 4. LIMPIAR CARRITO DESPUÉS DE PAGO EXITOSO
// 👇 AQUÍ ESTÁ EL DETALLE: Debe decir Future<void>
  Future<void> clearCartAfterPayment() async {
    _timer?.cancel();
    
    final pack = cartItem.value;
    if (pack != null) {
      try {
        // Devolvemos el stock temporal justo antes de que se cree la orden real
        final response = await _supabase.from('packs').select('quantity_available').eq('id', pack.id).single();
        int currentQty = response['quantity_available'] as int;

        await _supabase.from('packs').update({
          'quantity_available': currentQty + 1
        }).eq('id', pack.id);
      } catch (e) {
        print("Error ajustando stock final: $e");
      }
    }
    
    cartItem.value = null; // Vaciamos el carrito visualmente
  }

  // Formatear el tiempo a MM:SS para la pantalla
  String get formattedTime {
    int minutes = timeLeft.value ~/ 60;
    int seconds = timeLeft.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}