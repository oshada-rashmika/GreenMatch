import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginColors {
  static const Color background = Color(0xFFF6F6F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color panel = Color(0xFFF3F3F3);
  static const Color border = Color(0xFFDDDDDD);
  static const Color borderActive = Color(0xFF8E8E8E);
  static const Color textPrimary = Color(0xFF141414);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color accent = Color(0xFF111111);
  static const Color accentSoft = Color(0xFF4D4D4D);
  static const Color inputFill = Color(0xFFF5F5F5);
  static const Color shadow = Color(0x22000000);
  static const Color link = Color(0xFF1A1A1A);
  static const Color error = Color(0xFFC62828);
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
    color: LoginColors.surface,
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
