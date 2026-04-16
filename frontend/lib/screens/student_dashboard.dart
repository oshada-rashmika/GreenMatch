import 'package:flutter/material.dart';
import '../theme/login_design.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 48,
                  color: LoginColors.accent,
                ),
                const SizedBox(height: 16),
                Text(
                  'Student Dashboard',
                  textAlign: TextAlign.center,
                  style: LoginTypography.headline.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Track your projects, submissions, and updates here.',
                  textAlign: TextAlign.center,
                  style: LoginTypography.body.copyWith(
                    color: LoginColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
