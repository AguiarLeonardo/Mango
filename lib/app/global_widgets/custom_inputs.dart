import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Asegúrate de que esta ruta coincida con la ubicación de tu app_theme.dart
import '../core/theme/app_theme.dart';

// --- 1. Input de Texto Genérico ---
class CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextInputType inputType;
  final int? maxLength;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.inputType = TextInputType.text,
    this.maxLength,
    this.maxLines = 1,
    this.inputFormatters,
    this.controller,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.04), // Sombra muy sutil para dar elevación
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLength: maxLength,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        obscureText: isPassword,
        keyboardType: inputType,
        // Al no poner 'style' explícito, tomará automáticamente Inter y Negro UI del AppTheme
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppTheme.textBlack.withOpacity(0.6)),
          errorText: errorText,
          errorMaxLines: 3,
          counterText: "",
          prefixIcon: Icon(icon,
              color: AppTheme.primaryGreen), // Verde Mango para los íconos
          filled: true,
          fillColor: Colors
              .white, // Blanco puro para contrastar con el fondo crema general
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: AppTheme.accentOrange,
                width: 2), // Borde Naranja al tocar (Interacción)
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// --- 2. Dropdown Grande ---
class CustomDropdown extends StatelessWidget {
  final String label;
  final IconData
      icon; // IMPORTANTE: Debe ser minúscula para no ocultar el Widget Icon
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool isDisabled;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items
            .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis)))
            .toList(),
        onChanged: isDisabled ? null : onChanged,
        icon: Icon(Icons.arrow_drop_down,
            color: isDisabled
                ? AppTheme.disabledIcon
                : AppTheme
                    .primaryGreen // Gris si está inactivo, Verde si está activo
            ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: isDisabled
                  ? AppTheme.disabledIcon
                  : AppTheme.textBlack.withOpacity(0.6)),
          prefixIcon: Icon(icon,
              color:
                  isDisabled ? AppTheme.disabledIcon : AppTheme.primaryGreen),
          filled: true,
          fillColor: isDisabled
              ? AppTheme.disabledBackground
              : Colors.white, // Pasa a Gris Claro si se desactiva
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: AppTheme.accentOrange, width: 2), // Borde naranja
          ),
        ),
      ),
    );
  }
}

// --- 3. Dropdown Pequeño ---
class SimpleDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const SimpleDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryGreen),
          items: items
              .map((val) => DropdownMenuItem(value: val, child: Text(val)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
