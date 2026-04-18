import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.premiumBlack,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.forestEmerald.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.forestEmerald.withValues(alpha: 0.05),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GlassContainer(
                      padding: const EdgeInsets.all(32),
                      borderRadius: 40,
                      child: Icon(
                        Icons.explore_off_rounded,
                        size: 80,
                        color: AppTheme.forestEmerald.withValues(alpha: 0.6),
                      ),
                    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: 48),

                    Text(
                      '404',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 100,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -5,
                      ),
                    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2),

                    Text(
                      'Lost in the Review?',
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 800.ms),

                    const SizedBox(height: 16),

                    Text(
                      "The route you're looking for doesn't exist or has been moved in the latest update.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.white38,
                        height: 1.6,
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 800.ms),

                    const SizedBox(height: 48),

                    InkWell(
                      onTap: () => Navigator.of(context).pushReplacementNamed('/'),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.forestEmerald,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.forestEmerald.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Text(
                          'Back to Orbit',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms).scale(duration: 400.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
