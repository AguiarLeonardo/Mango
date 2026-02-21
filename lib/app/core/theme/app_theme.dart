import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 1. Paleta de Colores
  static const Color backgroundCream = Color(0xFFFBF9F1);
  static const Color primaryGreen = Color(0xFF81C784);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color textBlack = Color(0xFF1C1C1C);
  static const Color disabledBackground = Color(0xFFE0E0E0);
  static const Color disabledIcon = Color(0xFF9E9E9E);

  // 2. Configuración del ThemeData Global
  static ThemeData get mangoTheme {
    return ThemeData(
      // Fondo general de la app
      scaffoldBackgroundColor: backgroundCream,
      primaryColor: primaryGreen,
      
      // Esquema de colores principal
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: accentOrange,
        surface: backgroundCream,
        onSurface: textBlack, 
      ),

      // 3. Tipografía (Poppins para Títulos, Inter para Cuerpo)
      textTheme: TextTheme(
        // Títulos y Encabezados
        displayLarge: GoogleFonts.poppins(color: textBlack, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.poppins(color: textBlack, fontWeight: FontWeight.w600, fontSize: 20),
        titleMedium: GoogleFonts.poppins(color: textBlack, fontWeight: FontWeight.w500),
        
        // Cuerpo de texto y datos
        bodyLarge: GoogleFonts.inter(color: textBlack, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: textBlack, fontSize: 14),
        bodySmall: GoogleFonts.inter(color: disabledIcon, fontSize: 12), // Textos secundarios
      ),

      // 4. Comportamiento de Botones (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          // Color de fondo dinámico según si está activo o inactivo
          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.disabled)) {
              return disabledBackground; // Gris claro si está agotado
            }
            return primaryGreen; // Verde si está activo
          }),
          // Color del texto dinámico
          foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.disabled)) {
              return disabledIcon; // Texto gris oscuro si está agotado
            }
            return textBlack; // Texto negro UI si está activo
          }),
          // Borde naranja al interactuar (Hover / Presionado)
          side: MaterialStateProperty.resolveWith<BorderSide>((states) {
            if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
              return const BorderSide(color: accentOrange, width: 2);
            }
            return BorderSide.none;
          }),
          // Forma redondeada para ser más amigable
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
    );
  }
}