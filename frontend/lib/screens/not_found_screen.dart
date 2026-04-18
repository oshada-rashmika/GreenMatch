import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import 'login_screen.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String binary404 = '''
111 000 111
1 1 0 0 1 1
111 0 0 111
  1 0 0   1
  1 000   1''';

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
                color: AppTheme.forestEmerald.withValues(alpha: 0.15),
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

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 60.0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        binary404,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceMono(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: 2.0,
                          color: AppTheme.forestEmerald,
                          shadows: [
                            Shadow(
                              color: AppTheme.forestEmerald.withValues(alpha: 0.8),
                              blurRadius: 10,
                            ),
                            Shadow(
                              color: AppTheme.forestEmerald.withValues(alpha: 0.6),
                              blurRadius: 20,
                            ),
                            Shadow(
                              color: AppTheme.forestEmerald.withValues(alpha: 0.4),
                              blurRadius: 30,
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.9, 0.9)),

                    const SizedBox(height: 40),
                    Text(
                      "We only got Three Dashboards and Two Login Screen.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 800.ms),

                    const SizedBox(height: 8),

                    Text(
                      "How tf did you endup here?",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white54,
                        letterSpacing: 0.5,
                      ),
                    ).animate().fadeIn(delay: 600.ms, duration: 800.ms),

                    const SizedBox(height: 40),

                    Image.asset(
                      'public/robot.png',
                      height: 250,
                      fit: BoxFit.contain,
                    ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.8, 0.8)),

                    const SizedBox(height: 40),

                    InkWell(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.forestEmerald.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: -5,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.forestEmerald,
                              AppTheme.forestEmerald.withBlue(100),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Return to Base',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2),
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
