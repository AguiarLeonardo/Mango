import 'package:get/get.dart';
import 'app_routes.dart';

// --- IMPORTS DE PANTALLAS ---
// Asegúrate de que estas carpetas existan en tu proyecto
import '../modules/welcome/welcome_screen.dart';
import '../modules/auth/register_user/register_user_screen.dart';
import '../modules/auth/register_business/register_business_screen.dart';
import '../modules/auth/login/login_screen.dart';
import '../modules/auth/login/login_controller.dart';
import '../modules/auth/update_password/update_password_screen.dart';
import '../home/home_screen.dart';
import '../modules/start/start_screen.dart';

// Imports de los Packs
import '../modules/packs/packs_screen.dart';
import '../modules/packs/pack_detail_screen.dart';

class AppPages {
  // La app arranca en la pantalla de inicio (Start)
  static const initial = Routes.start; 

  static final routes = [
    // Pantalla de Inicio / Splash
    GetPage(
      name: Routes.start,
      page: () => const StartScreen(),
    ),
    
    // Pantalla de Bienvenida
    GetPage(
      name: Routes.welcome,
      page: () => const WelcomeScreen(),
    ),
    
    // Registro Usuario
    GetPage(
      name: Routes.registerUser,
      page: () => const RegisterUserScreen(),
    ),
    
    // Registro Empresa
    GetPage(
      name: Routes.registerBusiness,
      page: () => const RegisterBusinessScreen(),
    ),
    
    // Login
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.put(LoginController());
      }),
    ),
    
    // Home (Pantalla principal)
    GetPage(
      name: Routes.home,
      page: () => HomeScreen(),
    ),
    
    // Actualizar Contraseña
    GetPage(
      name: Routes.updatePassword,
      page: () => const UpdatePasswordScreen(),
    ),

    // --- PANTALLAS DE PACKS (NUEVO) ---
    GetPage(
      name: Routes.packs,
      page: () => PacksScreen(), // Sin 'const' para evitar conflictos con el controlador
    ),

    GetPage(
      name: Routes.packDetail,
      page: () => PackDetailScreen(), // Sin 'const'
    ),

  ];
}