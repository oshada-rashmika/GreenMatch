import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/login_design.dart';

class AcademicTextField extends StatelessWidget {
  const AcademicTextField({
    super.key,
    this.label,
    required this.hintText,
    this.controller,
    this.errorText,
    this.obscureText = false,
    this.onChanged,
    this.onTap,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.keyboardType = TextInputType.text,
    this.focusNode,
    this.autofillHints,
    this.validator,
  });

  final String? label;
  final String hintText;
  final TextEditingController? controller;
  final String? errorText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final TextInputType keyboardType;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: LoginTypography.label),
          const SizedBox(height: LoginSpacing.xsmall),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          onTap: onTap,
          autofillHints: autofillHints,
          validator: validator,
          style: GoogleFonts.montserrat(
            fontSize: 15,
            color: LoginColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.montserrat(
              color: LoginColors.textSecondary,
              fontSize: 15,
            ),
            filled: true,
            fillColor: LoginColors.inputFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: LoginColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: LoginColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: LoginColors.borderActive,
                width: 1.6,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: LoginColors.error,
                width: 1.6,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: LoginColors.error,
                width: 1.6,
              ),
            ),
            suffixIcon: suffixIcon != null
                ? GestureDetector(onTap: onSuffixIconTap, child: suffixIcon)
                : null,
            errorText: errorText,
            errorStyle: GoogleFonts.montserrat(
              color: LoginColors.error,
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
