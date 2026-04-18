import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

class LoginColors {
  static const Color background = AppTheme.premiumBlack;
  static Color surface = Colors.white.withValues(alpha: 0.02);
  static Color panel = Colors.white.withValues(alpha: 0.05);
  static Color border = Colors.white.withValues(alpha: 0.1);
  static Color borderActive = AppTheme.forestEmerald.withValues(alpha: 0.5);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white60;
  static const Color accent = AppTheme.forestEmerald;
  static const Color accentSoft = Color(0xFF34D399);
  static Color inputFill = Colors.white.withValues(alpha: 0.05);
  static const Color shadow = Colors.transparent;
  static const Color link = AppTheme.forestEmerald;
  static const Color error = Color(0xFFCF6679);
}

class LoginTypography {
  static TextStyle headline = GoogleFonts.montserrat(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: LoginColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle subheadline = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: LoginColors.textSecondary,
    height: 1.6,
  );

  static TextStyle label = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: LoginColors.textPrimary,
  );

  static TextStyle body = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: LoginColors.textSecondary,
    height: 1.5,
  );

  static TextStyle button = GoogleFonts.montserrat(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.4,
  );

  static TextStyle link = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: LoginColors.link,
  );
}

class LoginSpacing {
  static const double xsmall = 8;
  static const double small = 12;
  static const double medium = 20;
  static const double large = 28;
  static const double xlarge = 36;
}
