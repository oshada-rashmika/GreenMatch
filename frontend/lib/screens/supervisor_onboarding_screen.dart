import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/auth_provider.dart';
import '../widgets/glass_container.dart';
import 'supervisor_dashboard.dart';
import 'login_screen.dart';

class SupervisorOnboardingScreen extends StatefulWidget {
  const SupervisorOnboardingScreen({super.key});

  @override
  State<SupervisorOnboardingScreen> createState() => _SupervisorOnboardingScreenState();
}

class _SupervisorOnboardingScreenState extends State<SupervisorOnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.forestEmerald.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.forestEmerald.withValues(alpha: 0.1),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
            
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.forestEmerald.withValues(alpha: 0.1),
                          border: Border.all(
                            color: AppTheme.forestEmerald.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          size: 64,
                          color: AppTheme.forestEmerald,
                        ),
                      ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 32),
                      
                      Text(
                        'Welcome to the Team',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        'Before we get started, we need to set up your supervisor profile and matches.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          color: Colors.white60,
                          height: 1.5,
                        ),
                      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                      
                      const SizedBox(height: 48),
                      
                      GlassContainer(
                        padding: const EdgeInsets.all(24),
                        borderRadius: 24,
                        opacity: 0.05,
                        child: Column(
                          children: [
                            Text(
                              'Onboarding Pending',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const CircularProgressIndicator(
                              color: AppTheme.forestEmerald,
                              strokeWidth: 2,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'The detailed onboarding UI is currently under development.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 800.ms).scale(),
                      
                      const SizedBox(height: 48),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const SupervisorDashboard()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.forestEmerald,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Skip to Dashboard (Debug)',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 1.seconds),
                      
                      const SizedBox(height: 16),
                      
                      TextButton(
                        onPressed: () async {
                          await context.read<AuthProvider>().logout();
                          if (mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                        child: Text(
                          'Sign Out',
                          style: GoogleFonts.montserrat(
                            color: Colors.white54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
