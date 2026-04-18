import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/auth_provider.dart';
import '../services/supervisor_service.dart';
import '../widgets/glass_container.dart';
import 'supervisor_dashboard.dart';
import 'login_screen.dart';

class SupervisorOnboardingScreen extends StatefulWidget {
  const SupervisorOnboardingScreen({super.key});

  @override
  State<SupervisorOnboardingScreen> createState() => _SupervisorOnboardingScreenState();
}

class _SupervisorOnboardingScreenState extends State<SupervisorOnboardingScreen> {
  final PageController _pageController = PageController();
  final SupervisorService _supervisorService = SupervisorService();
  
  int _currentPage = 0;
  bool _isSubmitting = false;

  final List<String> _availableTags = [
    'AI & Machine Learning',
    'Web Development',
    'Mobile Development',
    'Cloud Computing',
    'Cybersecurity',
    'Data Science',
    'Blockchain',
    'Internet of Things',
    'Software Engineering',
    'Natural Language Processing',
    'Computer Vision',
    'Distributed Systems',
  ];
  
  final List<String> _selectedTags = [];
  double _capacityLimit = 3.0;

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _completeOnboarding() async {
    final authProvider = context.read<AuthProvider>();
    final supervisorId = authProvider.userId;

    if (supervisorId == null) {
      _showError('Authentication error: Unable to identify supervisor.');
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await _supervisorService.updateOnboarding(
      supervisorId: supervisorId,
      specifications: _selectedTags,
      capacityLimit: _capacityLimit.toInt(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (result['success']) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SupervisorDashboard()),
        );
      } else {
        _showError(result['message']);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutQuart,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Positioned(
              top: -150,
              right: -100,
              child: _GlowOrb(color: AppTheme.forestEmerald.withValues(alpha: 0.15), size: 400),
            ),
            Positioned(
              bottom: -100,
              left: -50,
              child: _GlowOrb(color: AppTheme.forestEmerald.withValues(alpha: 0.1), size: 300),
            ),

            PageView(
              controller: _pageController,
              onPageChanged: (int page) => setState(() => _currentPage = page),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildWelcomeStep(),
                _buildSpecsStep(),
                _buildCapacityStep(),
                _buildFinalStep(),
              ],
            ),

            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: _buildNavigationControls(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.forestEmerald.withValues(alpha: 0.1),
              border: Border.all(color: AppTheme.forestEmerald.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.verified_user_rounded, size: 64, color: AppTheme.forestEmerald),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 40),
          Text(
            'Account Provisioned',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1.0,
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
          const SizedBox(height: 16),
          Text(
            "Let's configure your blind-review preferences.",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }

  Widget _buildSpecsStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Research Areas',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ).animate().fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 8),
          Text(
            'Select the tags that best match your expertise.',
            style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white54),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _availableTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return GestureDetector(
                onTap: () => _toggleTag(tag),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: isSelected 
                      ? AppTheme.forestEmerald.withValues(alpha: 0.2) 
                      : Colors.white.withValues(alpha: 0.05),
                    border: Border.all(
                      color: isSelected 
                        ? AppTheme.forestEmerald 
                        : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.95, 0.95)),
        ],
      ),
    );
  }

  Widget _buildCapacityStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Supervision Capacity',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'How many groups can you supervise simultaneously?',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white54),
          ),
          const SizedBox(height: 64),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.forestEmerald.withValues(alpha: 0.1),
                ),
              ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
              Text(
                _capacityLimit.toInt().toString(),
                style: GoogleFonts.montserrat(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.forestEmerald,
                ),
              ).animate().fadeIn(delay: 300.ms),
            ],
          ),
          const SizedBox(height: 48),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.forestEmerald,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
              thumbColor: AppTheme.forestEmerald,
              overlayColor: AppTheme.forestEmerald.withValues(alpha: 0.2),
              trackHeight: 2,
            ),
            child: Slider(
              value: _capacityLimit,
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (val) => setState(() => _capacityLimit = val),
            ),
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 Group', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white38)),
              Text('5 Groups', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white38)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinalStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.forestEmerald.withValues(alpha: 0.1),
            ),
            child: Icon(
              _isSubmitting ? Icons.sync_rounded : Icons.task_alt_rounded,
              size: 80,
              color: AppTheme.forestEmerald,
            ).animate(onPlay: _isSubmitting ? (controller) => controller.repeat() : null).rotate(duration: 2.seconds),
          ).animate().scale(curve: Curves.easeOutBack),
          const SizedBox(height: 40),
          Text(
            _isSubmitting ? 'Syncing Profile...' : 'Ready to Match',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          Text(
            'Your preferences have been saved. Click below to enter the dashboard.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(fontSize: 15, color: Colors.white60, height: 1.5),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0 && _currentPage < 3)
            TextButton(
              onPressed: () => _pageController.previousPage(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutQuart,
              ),
              child: Text(
                'Back',
                style: GoogleFonts.montserrat(color: Colors.white54, fontWeight: FontWeight.w600),
              ),
            )
          else
            const SizedBox(width: 60),
            
          Row(
            children: List.generate(4, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentPage == index 
                    ? AppTheme.forestEmerald 
                    : Colors.white.withValues(alpha: 0.1),
                ),
              );
            }),
          ),

          if (_currentPage < 3)
            SizedBox(
              width: 100,
              height: 48,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.forestEmerald,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text('Next', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
              ),
            )
          else
            SizedBox(
              width: 140,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _completeOnboarding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.forestEmerald,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isSubmitting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Finish', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
