import 'package:flutter/material.dart';
import '../theme/login_design.dart';

class SimpleDashboard extends StatelessWidget {
  const SimpleDashboard({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.background,
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            decoration: BoxDecoration(
              color: LoginColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: LoginColors.border),
              boxShadow: const [
                BoxShadow(
                  color: LoginColors.shadow,
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: LoginTypography.headline.copyWith(
                fontSize: 34,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}