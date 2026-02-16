import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminColors {
  static const seed = Color(0xFF1F2A44);
  static const primary = Color(0xFF1F2A44);
  static const secondary = Color(0xFF3D8C8C);
  static const accent = Color(0xFFFFC145);
  static const background = Color(0xFFF4F6FB);
  static const surface = Colors.white;
  static const ink = Color(0xFF1D2433);
  static const softInk = Color(0xFF5E6A7D);
  static const success = Color(0xFF2F8E6F);
}

ThemeData buildAdminTheme() {
  final textTheme = TextTheme(
    displaySmall: GoogleFonts.spaceGrotesk(fontSize: 34, fontWeight: FontWeight.w700),
    headlineMedium: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.w700),
    headlineSmall: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w600),
    titleLarge: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w700),
    titleMedium: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
    bodyLarge: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500),
    bodyMedium: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
    bodySmall: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500),
    labelLarge: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.4),
  );

  final scheme = ColorScheme.fromSeed(
    seedColor: AdminColors.seed,
    primary: AdminColors.primary,
    secondary: AdminColors.secondary,
    surface: AdminColors.surface,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AdminColors.background,
    textTheme: textTheme.apply(bodyColor: AdminColors.ink, displayColor: AdminColors.ink),
    appBarTheme: AppBarTheme(
      backgroundColor: AdminColors.background,
      elevation: 0,
      titleTextStyle: textTheme.titleLarge?.copyWith(color: AdminColors.ink),
      iconTheme: const IconThemeData(color: AdminColors.ink),
    ),
    cardTheme: CardThemeData(
      color: AdminColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  );
}
