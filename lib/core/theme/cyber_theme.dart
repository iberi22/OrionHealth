import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CyberTheme {
  static const Color primary = Color(0xFF00FF85);
  static const Color secondary = Color(0xFF00E0FF);
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color textDark = Color(0xFFE0E0E0);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        background: backgroundDark,
        surface: surfaceDark,
        onPrimary: backgroundDark,
        onSecondary: backgroundDark,
        onBackground: textDark,
        onSurface: textDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      textTheme: GoogleFonts.spaceGroteskTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        bodyLarge: const TextStyle(color: textDark),
        bodyMedium: const TextStyle(color: textDark),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
