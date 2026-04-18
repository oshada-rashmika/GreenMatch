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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildMassiveNumber('4'),
                          const SizedBox(width: 24),
                          Image.asset(
                            'public/robot.png',
                            height: 220,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 24),
                          _buildMassiveNumber('4'),
                        ],
                      ),
                    ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.9, 0.9)),

                    const SizedBox(height: 60),

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

                    const SizedBox(height: 60),

                    const Center(child: _HoverReturnButton()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMassiveNumber(String number) {
    return Text(
      number,
      style: GoogleFonts.montserrat(
        fontSize: 180,
        fontWeight: FontWeight.w900,
        height: 1.0,
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
    );
  }
}

class _HoverReturnButton extends StatefulWidget {
  const _HoverReturnButton();

  @override
  State<_HoverReturnButton> createState() => _HoverReturnButtonState();
}

class _HoverReturnButtonState extends State<_HoverReturnButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutQuart,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            decoration: BoxDecoration(
              color: _isHovered
                  ? AppTheme.forestEmerald.withValues(alpha: 0.25)
                  : AppTheme.forestEmerald.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isHovered
                    ? AppTheme.forestEmerald
                    : AppTheme.forestEmerald.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: AppTheme.forestEmerald.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: _isHovered ? Colors.white : AppTheme.forestEmerald,
                  size: 16,
                ),
                const SizedBox(width: 16),
                Text(
                  'Return to Base',
                  style: GoogleFonts.montserrat(
                    color: _isHovered ? Colors.white : AppTheme.forestEmerald,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: 1.0,
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
