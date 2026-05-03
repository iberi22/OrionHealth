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
      focusColor: primary.withAlpha(50),
      hoverColor: primary.withAlpha(30),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surfaceContainerHighest: backgroundDark,
        surface: surfaceDark,
        onPrimary: backgroundDark,
        onSecondary: backgroundDark,
        onSurfaceVariant: textDark,
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: backgroundDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) return backgroundDark.withAlpha(20);
            if (states.contains(WidgetState.focused) || states.contains(WidgetState.pressed)) {
              return backgroundDark.withAlpha(40);
            }
            return null;
          }),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          hoverColor: primary.withAlpha(30),
          focusColor: primary.withAlpha(50),
        ),
      ),
    );
  }
}
