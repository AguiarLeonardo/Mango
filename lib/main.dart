import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// 1. IMPORTAR LOCALIZACIONES
import 'package:flutter_localizations/flutter_localizations.dart';

// Asegúrate de que esta ruta apunte correctamente a tu nuevo archivo de tema
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/modules/auth/login/login_controller.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Inyectamos el LoginController como "lazy" (se crea cuando se necesita)
    Get.lazyPut(() => LoginController(), fenix: true);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // INICIALIZACIÓN DE FIREBASE (Requisito para Push Notifications)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // INICIALIZACIÓN DE SUPABASE
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
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      initialBinding:
          InitialBinding(), // Añadido para que GetX use tu InitialBinding
      // TEMA PERSONALIZADO NUEVO
      theme: _buildTheme(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,

      // Colores principales de la app
      primaryColor: AppTheme.primaryGreen,
      // El fondo global ahora es crema, para que toda la app se vea limpia
      scaffoldBackgroundColor: AppTheme.backgroundCream,

      // Esquema de colores
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppTheme.primaryGreen,
        primary: AppTheme.primaryGreen,
        secondary: AppTheme.accentOrange,
        surface: Colors.white,
      ),

      // Tema global para las cajas de texto (TextFields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white, // Cajas de texto blancas
        labelStyle: TextStyle(color: AppTheme.textBlack.withOpacity(0.6)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),

        // Borde por defecto
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        // Borde cuando no está seleccionado
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        // Borde Naranja cuando el usuario toca para escribir
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.accentOrange, width: 2),
        ),
      ),
    );
  }
}
