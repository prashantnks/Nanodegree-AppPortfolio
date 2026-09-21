import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizForgeTheme {
  static const ink = Color(0xFF14221F);
  static const paper = Color(0xFFF3EBDD);
  static const cream = Color(0xFFFFF8EE);
  static const pine = Color(0xFF1F6F54);
  static const moss = Color(0xFF3C8F6E);
  static const clay = Color(0xFFD4684A);
  static const correct = Color(0xFF2F6F4F);
  static const wrong = Color(0xFFA33B3B);

  static ThemeData light() {
    final base = ColorScheme.fromSeed(
      seedColor: pine,
      brightness: Brightness.light,
      primary: pine,
      secondary: clay,
      surface: cream,
    );

    final textTheme = GoogleFonts.figtreeTextTheme().copyWith(
      displaySmall: GoogleFonts.fraunces(
        fontWeight: FontWeight.w600,
        color: ink,
        height: 1.05,
      ),
      headlineMedium: GoogleFonts.fraunces(
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      headlineSmall: GoogleFonts.fraunces(
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      titleLarge: GoogleFonts.fraunces(
        fontWeight: FontWeight.w600,
        color: ink,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: paper,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: cream,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: ink.withValues(alpha: 0.08)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: pine,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.figtree(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          side: BorderSide(color: ink.withValues(alpha: 0.18)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: ink.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: ink.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: pine, width: 1.6),
        ),
      ),
    );
  }
}
