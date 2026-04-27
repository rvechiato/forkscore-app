import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  // Paleta Terrosa — tons quentes e acolhedores
  static const primaryBrand = Color(0xFFD98A6C); // Terracota pastel suave
  static const primaryDark = Color(0xFF4A3F35); // Marrom café quente
  static const background = Color(0xFFFAF6F0); // Bege suave (creme)
  static const surfaceWhite = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF4A3F35); // Marrom café quente
  static const textSecondary = Color(0xFF8C8177); // Cinza/marrom suave
  static const inputBackground = Color(0xFFFFFFFF);
  static const inputBorder = Color(0xFFE8DCCB); // Areia claro
  static const inputBorderDark = Color(0xFFD4C5B3);
  static const previewBackdrop = Color(0xFFF2EFE9);

  // Acentos sutis (para indicadores discretos)
  static const accentGreen = Color(0xFFA3B18A); // Verde sálvia
  static const accentYellow = Color(0xFFF4CB7E); // Amarelo mostarda suave
  static const accentCoral = Color(0xFFECA392); // Coral suave

  static ThemeData light() {
    // DM Sans: moderna, geométrica e profissional, mas amigável
    final baseTextTheme = GoogleFonts.dmSansTextTheme();

    final textTheme = baseTextTheme.copyWith(
      displaySmall: GoogleFonts.dmSans(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.15,
        letterSpacing: -0.3,
      ),
      headlineLarge: GoogleFonts.dmSans(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.1,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.dmSans(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.15,
      ),
      headlineSmall: GoogleFonts.dmSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: 0,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 0.1,
      ),
      labelLarge: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.3,
      ),
    );

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primaryBrand,
          brightness: Brightness.light,
        ).copyWith(
          primary: primaryBrand,
          secondary: textSecondary,
          surface: surfaceWhite,
          onSurface: textPrimary,
          onPrimary: Colors.white,
          surfaceContainerHighest: const Color(0xFFF4EFE6),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryDark,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: surfaceWhite),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: textSecondary.withValues(alpha: 0.6),
        ),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBrand, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBrand,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            color: primaryBrand,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryBrand,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: inputBorderDark, width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: textTheme.labelLarge?.copyWith(color: textPrimary),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: inputBorder,
        thickness: 1.0,
        space: 1,
      ),
    );
  }
}
