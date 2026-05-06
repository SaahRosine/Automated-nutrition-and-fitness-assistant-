import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF3ECFCF);

  static const Color darkBackground = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF161A24);
  static const Color darkSurfaceAlt = Color(0xFF1F2430);
  static const Color darkBorder = Color(0xFF2E3446);
  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color white54 = Colors.white54;
  static const Color white38 = Colors.white38;
  static const Color white30 = Colors.white30;
  static const Color white10 = Color(0x1AFFFFFF);
  static const Color white12 = Color(0x1FFFFFFF);
  static const Color black = Colors.black;
  static const Color error = Color(0xFFEF5B5B);
  static const Color success = Color(0xFF2DCC9B);
  static const Color warning = Color(0xFFFFB74D);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color greyText = Color(0xFF8B95A1);
  static const Color greyTextDark = Color(0xFFBEC8DA);
  static const Color lightSurface = Color(0xFFF5F7FB);
  static const Color lightBorder = Color(0xFFE5E9F1);
  static const Color disabledBackground = Color(0xFF2E3446);
  static const Color blueGrey = Color(0xFF627A8A);
  static const Color transparent = Colors.transparent;

  static const List<Color> primaryGradient = [primary, secondary];
  static const List<Color> primaryGradientReversed = [secondary, primary];
}

class AppTextStyles {
  static TextStyle get heading1 => GoogleFonts.plusJakartaSans(
        color: AppColors.white,
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
      );

  static TextStyle get heading2 => GoogleFonts.plusJakartaSans(
        color: AppColors.white,
        fontSize: 28,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get heading3 => GoogleFonts.plusJakartaSans(
        color: AppColors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get heading4 => GoogleFonts.plusJakartaSans(
        color: AppColors.white,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get body => GoogleFonts.plusJakartaSans(
        color: AppColors.white,
        fontSize: 15,
        height: 1.45,
      );

  static TextStyle get caption => GoogleFonts.plusJakartaSans(
        color: AppColors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get button => GoogleFonts.plusJakartaSans(
        color: AppColors.white,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      );

  static TextStyle? get label => null;
}

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.white,
      background: AppColors.darkBackground,
      onBackground: AppColors.white,
      surface: AppColors.darkSurface,
      onSurface: AppColors.white,
      error: AppColors.error,
      onError: AppColors.white,
      primaryContainer: AppColors.primary,
      secondaryContainer: AppColors.secondary,
      surfaceVariant: AppColors.darkSurfaceAlt,
      onSurfaceVariant: AppColors.white70,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.white),
      titleTextStyle: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.w700),
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(const TextTheme()).apply(bodyColor: AppColors.white, displayColor: AppColors.white),
    splashFactory: InkRipple.splashFactory,
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white10,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      hintStyle: const TextStyle(color: AppColors.white38),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F7FB),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.white,
      background: Color(0xFFF5F7FB),
      onBackground: AppColors.black,
      surface: Colors.white,
      onSurface: AppColors.black,
      error: AppColors.error,
      onError: AppColors.white,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(const TextTheme()).apply(bodyColor: AppColors.black, displayColor: AppColors.black),
    appBarTheme: const AppBarTheme(backgroundColor: Colors.white, elevation: 0, iconTheme: IconThemeData(color: AppColors.black)),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF0F2F7),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      hintStyle: const TextStyle(color: Colors.black45),
    ),
  );
}
