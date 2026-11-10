import 'package:flutter/material.dart';

class AppTheme {
  static const Color primarySky = Color(0xFF0284C7); // Sky / Navy Blue
  static const Color primaryDark = Color(0xFF0369A1);
  static const Color primaryLight = Color(0xFFE0F2FE);
  static const Color accentEmerald = Color(0xFF10B981); // Emerald
  static const Color accentEmeraldDark = Color(0xFF059669);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color borderSubtle = Color(0xFFE2E8F0);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primarySky,
      primary: primarySky,
      onPrimary: Colors.white,
      secondary: accentEmerald,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: slate900,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: slate50,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: slate900,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          color: slate900,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primarySky, width: 1.8),
        ),
        labelStyle: const TextStyle(color: slate600, fontSize: 14),
        hintStyle: const TextStyle(color: slate500, fontSize: 13),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: borderSubtle),
        selectedColor: primarySky,
        checkmarkColor: Colors.white,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primarySky,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: primaryLight,
        elevation: 2,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primarySky,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: slate500,
          );
        }),
      ),
    );
  }
}
