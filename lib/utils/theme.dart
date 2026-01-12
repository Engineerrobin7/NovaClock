import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Nebula Glass Palette - Dark Mode
  static const Color _darkBackgroundColor = Color(0xFF16161A); // Deep Space
  static const Color _darkCardColor = Color(0xFF242629); // Lighter Space
  static const Color _darkTextColor = Color(0xFFFFFFFE); // Starlight White
  
  // Light Mode Colors
  static const Color _lightBackgroundColor = Color(0xFFFAFAFA);
  static const Color _lightCardColor = Color(0xFFFFFFFF);
  static const Color _lightTextColor = Color(0xFF16161A);

  // Accent Color Palette
  static const List<Color> accentColors = [
    Color(0xFF7F5AF0), // Purple (Default)
    Color(0xFF00D9FF), // Cyan
    Color(0xFF00FF88), // Neon Green
    Color(0xFFFF006E), // Hot Pink
    Color(0xFFFFBE0B), // Gold
    Color(0xFF8338EC), // Violet
  ];

  static const List<String> accentColorNames = [
    'Purple',
    'Cyan',
    'Neon Green',
    'Hot Pink',
    'Gold',
    'Violet',
  ];

  // Build Dark Theme
  static ThemeData buildDarkTheme({int accentColorIndex = 0}) {
    final primaryColor = accentColors[accentColorIndex.clamp(0, accentColors.length - 1)];
    final secondaryColor = Color(0xFF2CB67D); // Neon Green

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: _darkBackgroundColor,
      useMaterial3: true,
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: _darkTextColor,
        displayColor: _darkTextColor,
      ),
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: _darkCardColor,
        background: _darkBackgroundColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: _darkTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 8,
          shadowColor: primaryColor.withOpacity(0.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: _darkCardColor.withOpacity(0.7),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: _darkTextColor.withOpacity(0.1), width: 1),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: primaryColor,
        unselectedItemColor: _darkTextColor.withOpacity(0.5),
        showUnselectedLabels: false,
        elevation: 0,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return Colors.grey.withOpacity(0.3);
        }),
      ),
    );
  }

  // Build Light Theme
  static ThemeData buildLightTheme({int accentColorIndex = 0}) {
    final primaryColor = accentColors[accentColorIndex.clamp(0, accentColors.length - 1)];
    final secondaryColor = Color(0xFF2CB67D);

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: _lightBackgroundColor,
      useMaterial3: true,
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.light().textTheme,
      ).apply(
        bodyColor: _lightTextColor,
        displayColor: _lightTextColor,
      ),
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: _lightCardColor,
        background: _lightBackgroundColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 4,
          shadowColor: primaryColor.withOpacity(0.3),
        ),
      ),
      cardTheme: CardThemeData(
        color: _lightCardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        elevation: 8,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return Colors.grey.withOpacity(0.3);
        }),
      ),
    );
  }

  // Legacy dark theme for backward compatibility
  static ThemeData get darkTheme => buildDarkTheme();
}