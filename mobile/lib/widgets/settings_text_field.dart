import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/theme_provider.dart';
import 'package:mobile/core/constants/app_styles.dart';

class SettingsTextField extends StatelessWidget {
  const SettingsTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: context.watch<ThemeProvider>().isDarkMode
            ? AppColors.darkSurfaceAlt
            : Colors.grey[100],
      ),
    );
  }
}
