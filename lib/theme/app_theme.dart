import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../standalone/my_perc_branding.dart';

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: MyPercBranding.scaffoldBackground,
      colorScheme: const ColorScheme.dark(
        primary: MyPercBranding.primaryAccent,
        secondary: MyPercBranding.secondaryAccent,
        surface: MyPercBranding.surface,
        onPrimary: Color(0xFF1A1208),
        onSecondary: Color(0xFF0A1A18),
        onSurface: MyPercBranding.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: MyPercBranding.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: MyPercBranding.borderSubtle),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: MyPercBranding.scaffoldBackground,
        foregroundColor: MyPercBranding.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MyPercBranding.surfaceElevated,
        labelStyle: const TextStyle(color: MyPercBranding.textSecondary),
        hintStyle: const TextStyle(color: MyPercBranding.textMuted),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: MyPercBranding.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: MyPercBranding.primaryAccent),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: MyPercBranding.textPrimary,
        displayColor: MyPercBranding.textPrimary,
      ),
      dividerColor: MyPercBranding.borderSubtle,
    );
  }
}