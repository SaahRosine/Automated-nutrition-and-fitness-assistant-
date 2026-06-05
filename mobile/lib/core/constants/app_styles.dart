import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF3ECFCF);
  static const Color background = Color(0xFF0F1117);
  static const Color surface = Color(0xFF161A24);
  static const Color surfaceVariant = Color(0xFF1F2430);
  static const Color error = Color(0xFFEF5B5B);
  static const Color success = Color(0xFF2DCC9B);
  static const Color warning = Color(0xFFFFB74D);
}

class AppTextStyles {
  static TextStyle heading1(BuildContext context) => GoogleFonts.plusJakartaSans(
        color: Theme.of(context).colorScheme.onBackground,
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
      );

  static TextStyle heading2(BuildContext context) => GoogleFonts.plusJakartaSans(
        color: Theme.of(context).colorScheme.onBackground,
        fontSize: 28,
        fontWeight: FontWeight.w700,
      );

  static TextStyle heading3(BuildContext context) => GoogleFonts.plusJakartaSans(
        color: Theme.of(context).colorScheme.onBackground,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      );

  static TextStyle heading4(BuildContext context) => GoogleFonts.plusJakartaSans(
        color: Theme.of(context).colorScheme.onBackground,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      );

  static TextStyle body(BuildContext context) => GoogleFonts.plusJakartaSans(
        color: Theme.of(context).colorScheme.onBackground,
        fontSize: 15,
        height: 1.45,
      );

  static TextStyle caption(BuildContext context) => GoogleFonts.plusJakartaSans(
        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      );

  static TextStyle button(BuildContext context) => GoogleFonts.plusJakartaSans(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      );

  static TextStyle label(BuildContext context) => GoogleFonts.plusJakartaSans(
        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      background: AppColors.background,
      onBackground: Colors.white,
      surface: AppColors.surface,
      onSurface: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surfaceVariant: AppColors.surfaceVariant,
      onSurfaceVariant: Colors.white70,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    splashFactory: InkRipple.splashFactory,
    cardTheme: CardThemeData(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(
        color: Colors.white.withOpacity(0.4),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      elevation: 0,
      selectedItemColor: AppColors.secondary,
      unselectedItemColor: Colors.white38,
      type: BottomNavigationBarType.fixed,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.secondary,
      foregroundColor: Colors.white,
      elevation: 8,
    ),
  );
}
