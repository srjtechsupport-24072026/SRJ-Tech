import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SrjColors {
  static const ink = Color(0xFF000000);
  static const inkSoft = Color(0xFF070B12);
  static const panel = Color(0xFF101826);
  static const line = Color(0xFF2A3648);
  static const mist = Color(0xFFA8B4C4);
  static const paper = Color(0xFFE8EDF4);
  static const silver = Color(0xFFD7DEE8);
  static const accent = Color(0xFF2F6BFF);
  static const accentDeep = Color(0xFF1B4ED8);
  static const glow = Color(0xFF5B8CFF);
  static const lime = Color(0xFF7CFF3A);
  static const limeDeep = Color(0xFF4FD000);
}

ThemeData buildSrjTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: SrjColors.ink,
    colorScheme: const ColorScheme.dark(
      primary: SrjColors.accent,
      secondary: SrjColors.lime,
      surface: SrjColors.inkSoft,
      onPrimary: SrjColors.paper,
      onSecondary: SrjColors.ink,
      onSurface: SrjColors.paper,
    ),
  );

  final display = GoogleFonts.syneTextTheme(base.textTheme).apply(
    bodyColor: SrjColors.paper,
    displayColor: SrjColors.paper,
  );
  final body = GoogleFonts.outfitTextTheme(base.textTheme).apply(
    bodyColor: SrjColors.paper,
    displayColor: SrjColors.paper,
  );

  return base.copyWith(
    textTheme: body.copyWith(
      displayLarge: display.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        height: 1.05,
      ),
      displayMedium: display.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        height: 1.08,
      ),
      headlineLarge: display.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      titleLarge: display.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: body.bodyLarge?.copyWith(
        color: SrjColors.mist,
        height: 1.6,
        fontSize: 17,
      ),
      bodyMedium: body.bodyMedium?.copyWith(
        color: SrjColors.mist,
        height: 1.55,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SrjColors.panel,
      hintStyle: const TextStyle(color: SrjColors.mist),
      labelStyle: const TextStyle(color: SrjColors.mist),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: SrjColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: SrjColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: SrjColors.accent, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: SrjColors.accent,
        foregroundColor: SrjColors.paper,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: 0.2,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: SrjColors.paper,
        side: const BorderSide(color: SrjColors.line),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        textStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    ),
  );
}
