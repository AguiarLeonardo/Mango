import 'package:get/get.dart';
import 'app_routes.dart';

// --- IMPORTS ---
import 'package:mango/app/modules/start/start_screen.dart';
import 'package:mango/app/modules/welcome/welcome_screen.dart';
import 'package:mango/app/modules/auth/login/login_screen.dart';
import 'package:mango/app/modules/auth/login/login_controller.dart';
import 'package:mango/app/modules/auth/register_user/register_user_screen.dart';
import 'package:mango/app/modules/auth/register_business/register_business_screen.dart';
import 'package:mango/app/modules/auth/update_password/update_password_screen.dart';
import 'package:mango/app/modules/payment/payment_screen.dart';
import 'package:mango/app/modules/orders/orders_screen.dart';
import 'package:mango/app/modules/shell/shell_screen.dart';
import 'package:mango/app/modules/packs/vendedor_packs_screen.dart';
import 'package:mango/app/modules/packs/pack_detail_screen.dart';
import 'package:mango/app/modules/business/business_detail_screen.dart';
import 'package:mango/app/modules/search/search_screen.dart';
import '../modules/shell/shell_binding.dart';
import '../modules/cart/cart_screen.dart';
import '../modules/business_dashboard/business_dashboard_screen.dart';
import '../modules/business_dashboard/business_dashboard_binding.dart';
import '../modules/impact/impact_screen.dart';

class AppPages {
  static const initial = Routes.start;

  static final routes = [
    GetPage(name: Routes.start, page: () => const StartScreen()),
    GetPage(name: Routes.welcome, page: () => const WelcomeScreen()),
    GetPage(name: Routes.registerUser, page: () => const RegisterUserScreen()),
    GetPage(
      name: Routes.registerBusiness,
      page: () => const RegisterBusinessScreen(),
    ),
    GetPage(name: Routes.payment, page: () => const PaymentScreen()),
    GetPage(name: Routes.orders, page: () => OrdersScreen()),
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.put(LoginController());
      }),
    ),
    GetPage(
      name: Routes.updatePassword,
      page: () => const UpdatePasswordScreen(),
    ),
    // ✅ Shell con ShellBinding (inyecta ShellController, WalletRepository, WalletController)
    GetPage(
      name: Routes.shell,
      page: () => ShellScreen(),
      binding: ShellBinding(),
    ),
    GetPage(name: Routes.vendorPacks, page: () => VendorPacksScreen()),
    GetPage(name: Routes.packDetail, page: () => const PackDetailScreen()),

    // 🏢 DETALLE DEL NEGOCIO (¡Aquí está la magia!)
    GetPage(
      name: Routes.businessDetail,
      page: () => BusinessDetailScreen(
        businessData: Get.arguments, // ✅ LE QUITAMOS EL "as Map..."
      ),
    ),

    GetPage(
      name: Routes.cart,
      page: () => const CartScreen(),
      transition: Transition.downToUp, // Un efecto bonito al abrir el carrito
    ),

    // 🔍 SEARCH SCREEN
    GetPage(name: Routes.search, page: () => const SearchScreen()),
    GetPage(
      name: Routes.impact, 
      page: () => const ImpactScreen(),
    ),

    // 📊 BUSINESS DASHBOARD
    GetPage(
      name: Routes.businessDashboard,
      page: () => const BusinessDashboardScreen(),
      binding: BusinessDashboardBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
