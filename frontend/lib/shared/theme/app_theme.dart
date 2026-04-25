import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  static const terracotta = Color(0xFFC05D43);
  static const moss = Color(0xFF4A6B53);
  static const softBlue = Color(0xFF5C82A6);
  static const cream = Color(0xFFFAF6F0);
  static const charcoal = Color(0xFF3E2723);
  static const previewBackdrop = Color(0xFFE6E1DA);
  static const textMuted = Color(0xFF796B63);
  static const inputBorder = Color(0xFFE5DFD5);
  static const inputBorderDark = Color(0xFFD7CEC2);

  static ThemeData light() {
    final textTheme = GoogleFonts.interTextTheme().copyWith(
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 31,
        fontWeight: FontWeight.w700,
        color: charcoal,
        height: 1,
        letterSpacing: -0.6,
      ),
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 44,
        fontWeight: FontWeight.w700,
        color: charcoal,
        height: 1.05,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: charcoal,
        height: 1.08,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: charcoal,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: charcoal,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: charcoal,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: charcoal,
        height: 1.55,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: charcoal,
        height: 1.45,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: charcoal,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: terracotta,
          brightness: Brightness.light,
        ).copyWith(
          primary: terracotta,
          secondary: moss,
          tertiary: softBlue,
          surface: cream,
          onSurface: charcoal,
          onPrimary: Colors.white,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: cream,
      textTheme: textTheme,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: charcoal,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: cream),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textMuted),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: charcoal.withValues(alpha: 0.45),
        ),
        prefixIconColor: charcoal.withValues(alpha: 0.45),
        suffixIconColor: charcoal.withValues(alpha: 0.45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: terracotta, width: 1.3),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: charcoal,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
      ),
    );
  }
}
