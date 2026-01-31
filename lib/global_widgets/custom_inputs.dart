import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
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
        style: const TextStyle(color: AppColors.darkOlive),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.darkOlive.withOpacity(0.6)),
          errorText: errorText,
          errorMaxLines: 3,
          counterText: "",
          prefixIcon: Icon(icon, color: AppColors.darkOlive),
          filled: true,
          fillColor: AppColors.sageGreen.withOpacity(0.25),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.darkOlive, width: 1.5)),
        ),
      ),
    );
  }
}

// --- 2. Dropdown Grande ---
class CustomDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: isDisabled ? null : onChanged,
        icon: Icon(Icons.arrow_drop_down, color: isDisabled ? Colors.grey : AppColors.darkOlive),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDisabled ? Colors.grey : AppColors.darkOlive.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: isDisabled ? Colors.grey : AppColors.darkOlive),
          filled: true,
          fillColor: isDisabled ? Colors.grey.withOpacity(0.1) : AppColors.sageGreen.withOpacity(0.25),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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

  const SimpleDropdown({super.key, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: AppColors.sageGreen.withOpacity(0.25), borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.darkOlive),
          items: items.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}