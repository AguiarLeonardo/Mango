import 'package:get/get.dart';
import 'app_routes.dart';
import '../modules/payment/payment_screen.dart';
// --- IMPORTS (Todos absolutos para evitar errores) ---

// Start & Welcome
import 'package:mango/app/modules/start/start_screen.dart';
import 'package:mango/app/modules/welcome/welcome_screen.dart';

// Auth
import 'package:mango/app/modules/auth/login/login_screen.dart';
import 'package:mango/app/modules/auth/login/login_controller.dart';
import 'package:mango/app/modules/auth/register_user/register_user_screen.dart';
import 'package:mango/app/modules/auth/register_business/register_business_screen.dart';
import 'package:mango/app/modules/auth/update_password/update_password_screen.dart';
import '../modules/orders/orders_screen.dart';
// Home (Corregido para usar package:mango)
import 'package:mango/app/modules/home/home_screen.dart';

// Packs
import 'package:mango/app/modules/packs/packs_screen.dart';
import 'package:mango/app/modules/packs/pack_detail_screen.dart';

class AppPages {
  static const initial = Routes.start;

  static final routes = [
    GetPage(name: Routes.start, page: () => const StartScreen()),
    GetPage(name: Routes.welcome, page: () => const WelcomeScreen()),
    GetPage(name: Routes.registerUser, page: () => const RegisterUserScreen()),
    GetPage(name: Routes.registerBusiness, page: () => const RegisterBusinessScreen()),
    GetPage(
      name: Routes.payment,
      page: () => const PaymentScreen(),
    ),
    
    GetPage(
      name: Routes.orders,
      page: () => OrdersScreen(), 
    ),
    // LOGIN: Aquí se inyecta el controlador
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.put(LoginController());
      }),
    ),

    GetPage(name: Routes.updatePassword, page: () => const UpdatePasswordScreen()),
    GetPage(name: Routes.home, page: () => HomeScreen()),
    GetPage(name: Routes.packs, page: () => PacksScreen()),
    GetPage(name: Routes.packDetail, page: () => const PackDetailScreen()),
  ];
}