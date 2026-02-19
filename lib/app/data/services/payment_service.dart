import 'dart:math';

class PaymentService {
  Future<bool> processPayment({required double amount, required String currency}) async {
    await Future.delayed(const Duration(seconds: 2));

    final random = Random();
    int scenario = random.nextInt(10); 

    if (scenario < 2) { 
      throw Exception("Error de conexión con el banco. Verifique su internet.");
    }
    if (scenario < 4) {
      throw Exception("Fondos insuficientes o tarjeta rechazada.");
    }
    return true; 
  }
}