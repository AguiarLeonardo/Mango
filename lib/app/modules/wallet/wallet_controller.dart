import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/wallet_repository.dart';

/// Controller GetX para la billetera del usuario.
/// Se inyecta mediante Binding (clean DI), NO con Get.put en la UI.
class WalletController extends GetxController {
  final WalletRepository _repository;

  WalletController({required WalletRepository repository})
      : _repository = repository;

  // ─── Estado reactivo ───
  final RxDouble balance = 0.0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString currency = 'USD'.obs;

  // Lista reactiva de movimientos (historial)
  final RxList<Map<String, dynamic>> transactions =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchWalletData();
  }

  /// Obtiene saldo + transacciones de Supabase.
  Future<void> fetchWalletData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // 1. Saldo
      final wallet = await _repository.fetchWallet();
      balance.value = wallet.balance;
      currency.value = wallet.currency;

      // 2. Historial de transacciones
      final txList = await _repository.fetchTransactions();
      transactions.assignAll(txList);
    } on WalletException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Error inesperado: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Formatea el saldo como string para mostrar en la UI.
  /// Ej: "$15.50"
  String get formattedBalance => '\$${balance.value.toStringAsFixed(2)}';

  /// Recargar saldo (Próximamente)
  void topUp() {
    Get.snackbar(
      'Próximamente',
      'La función de recarga estará disponible pronto.',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Retirar saldo (Próximamente)
  void withdraw() {
    Get.snackbar(
      'Próximamente',
      'La función de retiro estará disponible pronto.',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
