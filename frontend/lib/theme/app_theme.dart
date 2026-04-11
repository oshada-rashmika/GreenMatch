import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Palette
  static const Color premiumBlack = Color(0xFF0A0A0A);
  static const Color forestEmerald = Color(0xFF2D5A27);
  static const Color glassWhite = Color(0x1AFFFFFF); // 10% white
  static const Color glassBorder = Color(0x33FFFFFF); // 20% white

  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color pureWhite = Color(0xFFFFFFFF);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: forestEmerald,
      scaffoldBackgroundColor: premiumBlack,
      // Global font switched to Montserrat as requested
      textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: forestEmerald,
        secondary: forestEmerald,
        surface: Color(0xFF161616),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF161616),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: glassBorder, width: 0.5),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: forestEmerald,
      scaffoldBackgroundColor: pureWhite,
      textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme),
      colorScheme: ColorScheme.fromSeed(
        seedColor: forestEmerald,
        brightness: Brightness.light,
      ),
    );
  }
}
