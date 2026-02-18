import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// 1. IMPORTAR LOCALIZACIONES
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/core/theme/app_theme.dart';
import 'app/routes/app_routes.dart'; 
import 'app/routes/app_pages.dart'; 
import 'app/modules/auth/login/login_controller.dart';


class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Inyectamos el LoginController como "lazy" (se crea cuando se necesita)
    // O como "put" directo si lo usas en todos lados.

    Get.lazyPut(() => LoginController(), fenix: true); 
    

  }
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // INICIALIZACIÓN DE SUPABASE
  // Solo inicializamos la conexión. La verificación de sesión 
  // la hará tu StartController cuando arranque la app.
  await Supabase.initialize(
    url: 'https://wssqfdvfcydbxncfrtmy.supabase.co',
    anonKey: 'sb_publishable_lps63HVdjyCRknnoADey7Q_jNIaBPqQ',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mango App',
      debugShowCheckedModeBanner: false,
      
      // 2. CONFIGURACIÓN DE IDIOMA
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Español
      ],

      // CONFIGURACIÓN DE RUTAS
      // AppPages.initial debe ser Routes.start para que StartController haga su magia
      initialRoute: AppPages.initial, 
      getPages: AppPages.routes,      
      
      // TEMA PERSONALIZADO
      theme: _buildTheme(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.darkOlive,
      scaffoldBackgroundColor: AppColors.darkOlive,
      
      // Esquema de colores
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkOlive,
        primary: AppColors.darkOlive,
        secondary: AppColors.orange,
        surface: AppColors.white,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.sageGreen.withOpacity(0.25),
        labelStyle: TextStyle(color: AppColors.darkOlive.withOpacity(0.6)),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.orange, width: 2)),
      ),
    );
  }
}