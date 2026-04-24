import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const primary = Color(0xFF8E4B2A);
    const surface = Color(0xFFFFFBF5);
    const text = Color(0xFF2E2118);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(primary: primary, surface: surface, onSurface: text);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(fontSize: 44),
        headlineSmall: TextStyle(fontSize: 28),
        bodyLarge: TextStyle(fontSize: 18),
      ),
    );
  }
}
