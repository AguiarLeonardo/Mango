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

  @override
  void onInit() {
    super.onInit();
    fetchWalletBalance();
  }

  /// Obtiene el saldo de la billetera desde el repositorio.
  Future<void> fetchWalletBalance() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final wallet = await _repository.fetchWallet();

      balance.value = wallet.balance;
      currency.value = wallet.currency;
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
}
