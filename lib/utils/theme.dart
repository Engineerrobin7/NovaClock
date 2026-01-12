import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Nebula Glass Palette
  static const Color _primaryColor = Color(0xFF7F5AF0); // Neon Purple
  static const Color _secondaryColor = Color(0xFF2CB67D); // Neon Green
  static const Color _backgroundColor = Color(0xFF16161A); // Deep Space
  static const Color _cardColor = Color(0xFF242629); // Lighter Space
  static const Color _textColor = Color(0xFFFFFFFE); // Starlight White
  
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: _backgroundColor,
    textTheme: GoogleFonts.outfitTextTheme(
      ThemeData.dark().textTheme,
    ).apply(
      bodyColor: _textColor,
      displayColor: _textColor,
    ),
    colorScheme: const ColorScheme.dark(
      primary: _primaryColor,
      secondary: _secondaryColor,
      surface: _cardColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: _textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        elevation: 8,
        shadowColor: _primaryColor.withOpacity(0.5),
      ),
    ),
    cardTheme: CardThemeData(
      color: _cardColor.withOpacity(0.7), // Glass effect base
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: _textColor.withOpacity(0.1), width: 1),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: _primaryColor,
      unselectedItemColor: _textColor.withOpacity(0.5),
      showUnselectedLabels: false,
      elevation: 0,
    ),
  );
}