import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Color Palette ──────────────────────────────────────────────────────
  static const Color _background = Color(0xFF0A0A0F);
  static const Color _surface = Color(0xFF12121A);
  static const Color _surfaceVariant = Color(0xFF1A1A2E);
  static const Color _cardColor = Color(0xFF16162A);
  static const Color _divider = Color(0xFF2A2A3E);

  static const Color _primary = Color(0xFF7C3AED);
  static const Color _primaryLight = Color(0xFFA855F7);
  static const Color _primaryContainer = Color(0xFF2D1B69);
  static const Color _onPrimaryContainer = Color(0xFFE8DAFF);

  static const Color _secondary = Color(0xFF14B8A6); // teal accent
  static const Color _tertiary = Color(0xFFFBBF24); // warm yellow

  static const Color _textPrimary = Color(0xFFF1F0F5);
  static const Color _textSecondary = Color(0xFF9896A3);
  static const Color _textMuted = Color(0xFF5C5A66);

  static const Color _error = Color(0xFFEF4444);
  static const Color _positive = Color(0xFF22C55E);
  static const Color _negative = Color(0xFFEF4444);

  // ── Gradients ──────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [_primary, _primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlow = LinearGradient(
    colors: [Color(0x207C3AED), Color(0x00000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Convenience Accessors ──────────────────────────────────────────────
  static Color get surface => _surface;
  static Color get cardColor => _cardColor;
  static Color get dividerColor => _divider;
  static Color get primary => _primary;
  static Color get primaryLight => _primaryLight;
  static Color get secondary => _secondary;
  static Color get tertiary => _tertiary;
  static Color get textSecondary => _textSecondary;
  static Color get textMuted => _textMuted;
  static Color get positive => _positive;
  static Color get negative => _negative;

  // ── Theme Data ─────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final baseText = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _background,
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: _primary,
        onPrimary: Colors.white,
        primaryContainer: _primaryContainer,
        onPrimaryContainer: _onPrimaryContainer,
        secondary: _secondary,
        onSecondary: Colors.white,
        tertiary: _tertiary,
        surface: _surface,
        onSurface: _textPrimary,
        surfaceContainerHighest: _surfaceVariant,
        onSurfaceVariant: _textSecondary,
        error: _error,
        onError: Colors.white,
        outline: _divider,
      ),
      textTheme: baseText.copyWith(
        displayLarge: baseText.displayLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
        displayMedium: baseText.displayMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
        displaySmall: baseText.displaySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: _textPrimary,
        ),
        headlineLarge: baseText.headlineLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
        headlineMedium: baseText.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: _textPrimary,
        ),
        headlineSmall: baseText.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: _textPrimary,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: _textPrimary,
        ),
        titleMedium: baseText.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: _textPrimary,
        ),
        titleSmall: baseText.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: _textSecondary,
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(
          fontWeight: FontWeight.w400,
          color: _textPrimary,
          height: 1.6,
        ),
        bodyMedium: baseText.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400,
          color: _textSecondary,
        ),
        bodySmall: baseText.bodySmall?.copyWith(
          fontWeight: FontWeight.w400,
          color: _textMuted,
        ),
        labelLarge: baseText.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: _textPrimary,
        ),
        labelMedium: baseText.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: _textSecondary,
        ),
        labelSmall: baseText.labelSmall?.copyWith(
          fontWeight: FontWeight.w400,
          color: _textMuted,
        ),
      ),
      cardTheme: CardThemeData(
        color: _cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceVariant,
        labelStyle: baseText.labelSmall?.copyWith(color: _textSecondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        side: BorderSide.none,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surface,
        selectedItemColor: _primary,
        unselectedItemColor: _textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: baseText.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: _textPrimary,
          fontSize: 22,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: _divider,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: baseText.bodyMedium?.copyWith(color: _textMuted),
      ),
    );
  }
}
