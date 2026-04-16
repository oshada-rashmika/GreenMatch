import 'package:flutter/material.dart';
import '../theme/login_design.dart';

class ModuleLeaderDashboard extends StatelessWidget {
  const ModuleLeaderDashboard({super.key});

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
                  Icons.manage_accounts_outlined,
                  size: 48,
                  color: LoginColors.accent,
                ),
                const SizedBox(height: 16),
                Text(
                  'Module Leader Dashboard',
                  textAlign: TextAlign.center,
                  style: LoginTypography.headline.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Review projects, manage supervision, and keep tasks moving.',
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
