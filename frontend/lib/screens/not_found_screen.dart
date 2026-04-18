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
                              
     mmm     mmmm        mmm  
    m###    ##""##      m###  
   #" ##   ##    ##    #" ##  
 m#"  ##   ## ## ##  m#"  ##  
 ########  ##    ##  ######## 
      ##    ##mm##        ##  
      ""     """"         ""  
                              
                              
''';

    return Scaffold(
      backgroundColor: AppTheme.premiumBlack,
      body: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: 0.05,
              child: Text(
                List.generate(20, (_) => '0 1 1 0 1 0 1 1 0 0 1 0').join('\n'),
                style: GoogleFonts.firaCode(color: AppTheme.forestEmerald, fontSize: 12),
              ),
            ),
          ),

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Text(
                      binary404,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.firaCode(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.forestEmerald,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            color: AppTheme.forestEmerald.withValues(alpha: 0.8),
                            blurRadius: 20,
                          ),
                          Shadow(
                            color: AppTheme.forestEmerald.withValues(alpha: 0.5),
                            blurRadius: 40,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.9, 0.9)),

                    const SizedBox(height: 48),

                    Text(
                      "We only built three dashboards and two login screens...\nHow tf did you end up here?",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                        height: 1.6,
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 800.ms),

                    const SizedBox(height: 60),

                    InkWell(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        borderRadius: 16,
                        borderColor: AppTheme.forestEmerald.withValues(alpha: 0.3),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.terminal_rounded,
                              color: AppTheme.forestEmerald,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Return to Base',
                              style: GoogleFonts.firaCode(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
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
