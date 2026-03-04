import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/pack_model.dart';
import '../../routes/app_routes.dart';

class CartController extends GetxController {
  // ✅ 1. AHORA EL CARRITO ES UNA LISTA DE PACKS
  var cartItems = <PackModel>[].obs;

  // ✅ 2. CALCULAMOS EL TOTAL AUTOMÁTICAMENTE
  double get totalCartPrice => cartItems.fold(0.0, (sum, item) => sum + item.price);

  // ✅ 3. AÑADIR AL CARRITO (Sin bloquear en base de datos, estilo Amazon)
  void addToCart(PackModel pack) {
    // Evitamos agregar el mismo pack dos veces
    if (cartItems.any((p) => p.id == pack.id)) {
      Get.snackbar(
        "Aviso", 
        "Este pack ya está en tu carrito.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (pack.quantityAvailable <= 0) {
      Get.snackbar("Agotado", "Este pack ya no está disponible.");
      return;
    }

    cartItems.add(pack);
    
    Get.snackbar(
      "¡Añadido! 🛒", 
      "${pack.title} se añadió a tu carrito.",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // ✅ 4. ELIMINAR UN PACK ESPECÍFICO DEL CARRITO
  void removeFromCart(PackModel pack) {
    cartItems.remove(pack);
    Get.snackbar(
      "Eliminado", 
      "Has quitado el pack de tu carrito.",
      backgroundColor: Colors.grey[800],
      colorText: Colors.white,
    );
  }

  // ✅ 5. VACIAR TODO EL CARRITO DESPUÉS DE PAGAR
  void clearCartAfterPayment() {
    cartItems.clear();
  }
}