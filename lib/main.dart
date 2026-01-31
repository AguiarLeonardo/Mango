import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart'; 
import 'routes/app_pages.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. INICIALIZACIÓN DE SUPABASE
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
      
      // CONFIGURACIÓN DE RUTAS
      // Asegúrate que en app_pages.dart, 'initial' sea Routes.start
      initialRoute: AppPages.initial, 
      getPages: AppPages.routes,      
      
      // TEMA PERSONALIZADO
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.darkOlive,
        scaffoldBackgroundColor: AppColors.darkOlive,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.sageGreen.withOpacity(0.25),
          labelStyle: TextStyle(color: AppColors.darkOlive.withOpacity(0.6)),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.orange, width: 2)),
        ),
      ),
    );
  }
}