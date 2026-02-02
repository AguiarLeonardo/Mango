import 'package:get/get.dart';
import 'app_routes.dart';

// Importa tus pantallas
import '../modules/welcome/welcome_screen.dart';
import '../modules/auth/register_user/register_user_screen.dart';
import '../modules/auth/register_business/register_business_screen.dart';
import '../modules/auth/login/login_screen.dart';
import '../modules/auth/login/login_controller.dart';
import '../modules/auth/update_password/update_password_screen.dart';
import '../../home/home_screen.dart';
import '../modules/start/start_screen.dart';
import '../modules/packs/packs_screen.dart';
import '../modules/packs/pack_detail_screen.dart';
class AppPages {
  // CAMBIO IMPORTANTE: La app arranca en START
  static const initial = Routes.start; 

  static final routes = [
    GetPage(
      name: Routes.start,
      page: () => const StartScreen(),
    ),
    GetPage(
      name: Routes.welcome,
      page: () => const WelcomeScreen(),
    ),
    GetPage(
      name: Routes.registerUser,
      page: () => const RegisterUserScreen(),
      // Aquí podrías agregar bindings más adelante si quieres optimizar memoria
    ),
    GetPage(
      name: Routes.registerBusiness,
      page: () => const RegisterBusinessScreen(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(), // <--- Debe decir LoginScreen
      binding: BindingsBuilder(() {
        Get.put(LoginController());
      }),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: Routes.updatePassword,
      page: () => const UpdatePasswordScreen(),
    ),
    GetPage(
  name: Routes.packs,
  page: () => const PacksScreen(),
),
GetPage(
  name: Routes.packDetail,
  page: () => const PackDetailScreen(),
),
  ];
}