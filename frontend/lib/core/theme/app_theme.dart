import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF800080),
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFE6E6FA),
        onPrimaryContainer: Color(0xFF1A001A),
        secondary: Color(0xFF800080), // Fallback
        onSecondary: Color(0xFFFFFFFF),
        error: Color(0xFFB3261E),
        onError: Color(0xFFFFFFFF),
        surface: Color(0xFFF3E5F5),
        onSurface: Color(0xFF1A001A),
        surfaceContainerHighest: Color(0xFFE1BEE7),
        onSurfaceVariant: Color(0xFF49454F),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.w600),
        displayMedium: TextStyle(fontWeight: FontWeight.w600),
        displaySmall: TextStyle(fontWeight: FontWeight.w600),
        headlineLarge: TextStyle(fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontWeight: FontWeight.w400, height: 1.5),
        bodyMedium: TextStyle(fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontWeight: FontWeight.w400),
      ),
      cardTheme: const CardThemeData(
        elevation: 0.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
      ),
      chipTheme: const ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFFC3B1E1),
        onPrimary: Color(0xFF1A001A),
        primaryContainer: Color(0xFF483248),
        onPrimaryContainer: Color(0xFFE6E6FA),
        secondary: Color(0xFFC3B1E1),
        onSecondary: Color(0xFF1A001A),
        error: Color(0xFFF2B8B5),
        onError: Color(0xFF601410),
        surface: Color(0xFF301934),
        onSurface: Color(0xFFE6E6FA),
        surfaceContainerHighest: Color(0xFF51414F),
        onSurfaceVariant: Color(0xFFCAC4D0),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.w600),
        displayMedium: TextStyle(fontWeight: FontWeight.w600),
        displaySmall: TextStyle(fontWeight: FontWeight.w600),
        headlineLarge: TextStyle(fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontWeight: FontWeight.w400, height: 1.5),
        bodyMedium: TextStyle(fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontWeight: FontWeight.w400),
      ),
      cardTheme: const CardThemeData(
        elevation: 0.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
      ),
      chipTheme: const ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
      ),
    );
  }
}
