import 'package:get/get.dart';
import 'app_routes.dart';

// Importa tus pantallas
import '../modules/welcome/welcome_screen.dart';
import '../modules/auth/register_user/register_user_screen.dart';
import '../modules/auth/register_business/register_business_screen.dart';

class AppPages {
  // Definimos cuál es la ruta inicial
  static const initial = Routes.welcome;

  static final routes = [
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
    // Más adelante agregarás:
    // GetPage(name: Routes.LOGIN, page: () => LoginScreen()),
  ];
}