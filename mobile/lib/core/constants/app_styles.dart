import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF3ECFCF);

  // Background colors
  static const Color darkBackground = Color(0xFF0F1117);
  static const Color lightBackground = Color(0xFFF8F9FA);

  // Surface colors (cards, text fields, etc.)
  static const Color darkSurface = Color(0xFF1C1F2B);
  static const Color darkSurfaceAlt = Color(0xFF1C1E26);
  static const Color darkBorder = Color(0xFF2C2F3E);
  static const Color lightSurface = Color(0xFFF5F5F5); // Colors.grey[100]
  static const Color lightSurfaceAlt = Color(0xFFEEEEEE); // Colors.grey[200]
  static const Color lightBorder = Color(0xFFE0E0E0); // Colors.grey[300]
  static const Color disabledBackground = Color(0x1FFFFFFF); // Colors.white12

  // Status colors
  static const Color error = Color(0xFFD84040);
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Colors.redAccent;
  static const Color warningLight = Color(0x0DFF5252); // redAccent with 0.05 opacity

  // Base colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color white70 = Colors.white70;
  static const Color white54 = Colors.white54;
  static const Color white38 = Colors.white38;
  static const Color white30 = Colors.white30;
  static const Color transparent = Colors.transparent;
  static const Color greyText = Colors.grey;
  static const Color greyTextDark = Color(0xFF757575); // Colors.grey[600]
  static const Color blueGrey = Colors.blueGrey;

  // Gradients
  static const List<Color> primaryGradient = [primary, secondary];
  static const List<Color> primaryGradientReversed = [secondary, primary];

  // Helper method to get the scaffold background based on brightness
  static Color scaffoldBackground(Brightness brightness) {
    return brightness == Brightness.dark ? darkBackground : lightBackground;
  }
}

class AppStyles {
  // Common text styles can go here if needed in the future
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );
}
