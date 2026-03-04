import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/pack_model.dart';

class CartController extends GetxController {
  // ✅ 1. AHORA EL CARRITO ES UNA LISTA DE PACKS (Puede tener repetidos)
  var cartItems = <PackModel>[].obs;

  // ✅ 2. CALCULAMOS EL TOTAL AUTOMÁTICAMENTE
  double get totalCartPrice => cartItems.fold(0.0, (sum, item) => sum + item.price);

  // ✅ 3. AÑADIR AL CARRITO (Con validación de stock y negocio)
  void addToCart(PackModel pack) {
    
    // REGLA 1: Verificar si el pack pertenece al mismo negocio
    if (cartItems.isNotEmpty) {
      final currentBusinessId = cartItems.first.businessId;
      
      if (currentBusinessId != pack.businessId) {
        Get.snackbar(
          "Acción no permitida 🚫", 
          "Solo puedes comprar packs de un mismo negocio a la vez. Termina tu compra actual o vacía el carrito.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return;
      }
    }

    // REGLA 2: Contar cuántos de este MISMO pack ya tienes en el carrito
    int countInCart = cartItems.where((p) => p.id == pack.id).length;
    
    // REGLA 3: Comparar con el stock disponible
    if (countInCart >= pack.quantityAvailable) {
      Get.snackbar(
        "Límite alcanzado ⚠️", 
        "No puedes agregar más de este pack. Solo quedan ${pack.quantityAvailable} disponibles.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Si todo está bien, lo agregamos a la lista
    cartItems.add(pack);
    
    Get.snackbar(
      "¡Añadido! 🛒", 
      "${pack.title} se añadió a tu carrito. (Llevas ${countInCart + 1})",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // ✅ 4. ELIMINAR UN PACK ESPECÍFICO DEL CARRITO
  void removeFromCart(PackModel pack) {
    // remove() elimina solo la primera coincidencia. 
    // Así que si tienes 3 iguales, solo borrará 1 cada vez que le des al basurero. ¡Perfecto!
    cartItems.remove(pack);
    Get.snackbar(
      "Eliminado", 
      "Has quitado un pack de tu carrito.",
      backgroundColor: Colors.grey[800],
      colorText: Colors.white,
    );
  }

  // ✅ 5. VACIAR TODO EL CARRITO DESPUÉS DE PAGAR
  void clearCartAfterPayment() {
    cartItems.clear();
  }
}