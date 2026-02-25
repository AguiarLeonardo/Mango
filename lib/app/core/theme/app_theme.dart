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
        displayLarge: GoogleFonts.poppins(
          color: textBlack,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.poppins(
          color: textBlack,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        titleMedium: GoogleFonts.poppins(
          color: textBlack,
          fontWeight: FontWeight.w500,
        ),

        // Cuerpo de texto y datos
        bodyLarge: GoogleFonts.inter(color: textBlack, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: textBlack, fontSize: 14),
        bodySmall: GoogleFonts.inter(
          color: disabledIcon,
          fontSize: 12,
        ), // Textos secundarios
      ),

      // 4. Comportamiento de Botones (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          // Color de fondo dinámico según si está activo o inactivo
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return disabledBackground; // Gris claro si está agotado
            }
            return primaryGreen; // Verde si está activo
          }),
          // Color del texto dinámico
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return disabledIcon; // Texto gris oscuro si está agotado
            }
            return textBlack; // Texto negro UI si está activo
          }),
          // Borde naranja al interactuar (Hover / Presionado)
          side: WidgetStateProperty.resolveWith<BorderSide>((states) {
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.pressed)) {
              return const BorderSide(color: accentOrange, width: 2);
            }
            return BorderSide.none;
          }),
          // Forma redondeada para ser más amigable
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
        ),
      ),

      // 5. 🟢 TIP PRO: Configuración Global del AppBar (NAVBAR SUPERIOR)
      appBarTheme: AppBarTheme(
        backgroundColor: primaryGreen, // Fondo siempre verde
        elevation: 0, // Sin sombra para un look moderno
        centerTitle: true, // Títulos siempre centrados
        iconTheme: const IconThemeData(
          color:
              backgroundCream, // Íconos (como la flecha de volver o tuercas) en crema
        ),
        titleTextStyle: GoogleFonts.poppins(
          // Tipografía Poppins integrada
          color: backgroundCream, // Título siempre en crema
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}
