import 'package:get/get.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../core/services/push_notification_controller.dart';
import '../wallet/wallet_controller.dart';
import 'shell_controller.dart';

/// Binding principal del Shell.
/// Inyecta las dependencias globales que deben estar disponibles
/// en toda la app mientras el usuario está autenticado.
class ShellBinding extends Bindings {
  @override
  void dependencies() {
    // Shell controller (navegación + nombre de usuario)
    Get.lazyPut<ShellController>(() => ShellController());

    // UserRepository para FCM y perfil
    Get.lazyPut<UserRepository>(() => UserRepository());

    // Notificaciones Push (se inyecta globalmente cuando inicia el Shell)
    Get.put<PushNotificationController>(
      PushNotificationController(userRepository: Get.find<UserRepository>()),
      permanent: true,
    );

    // Wallet: Repository → Controller (Clean DI)
    Get.lazyPut<WalletRepository>(() => WalletRepository());
    Get.lazyPut<WalletController>(
      () => WalletController(repository: Get.find<WalletRepository>()),
    );
  }
}
