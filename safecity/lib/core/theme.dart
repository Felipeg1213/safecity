import 'package:flutter/material.dart';

class AppTheme {
  // ── Paleta de colores (idéntica al prototipo) ──
  static const Color bgPrimary    = Color(0xFF0A0D12);
  static const Color bgSecondary  = Color(0xFF111419);
  static const Color bgCard       = Color(0xFF161B22);
  static const Color bgCard2      = Color(0xFF1C2230);

  static const Color accent       = Color(0xFF00D4C8);
  static const Color accentDark   = Color(0xFF00A89E);

  static const Color textPrimary   = Color(0xFFE8EDF5);
  static const Color textSecondary = Color(0xFF8892A4);
  static const Color textMuted     = Color(0xFF4A5568);

  static const Color severityCritical = Color(0xFFDC2626);
  static const Color severityHigh     = Color(0xFFEA580C);
  static const Color severityMedium   = Color(0xFFCA8A04);
  static const Color severityLow      = Color(0xFF16A34A);

  static const Color border = Color(0x12FFFFFF);

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgPrimary,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      secondary: accentDark,
      surface: bgSecondary,
      background: bgPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgSecondary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: textSecondary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: bgSecondary,
      selectedItemColor: accent,
      unselectedItemColor: textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: bgPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: textMuted),
    ),
  );
}
