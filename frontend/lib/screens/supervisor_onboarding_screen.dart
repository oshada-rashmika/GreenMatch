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
            const _AmbientBackground(),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.03),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                        child: Column(
                          children: [
                            Expanded(
                              child: PageView(
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
                            ),
                            
                            _buildNavigationControls(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppTheme.forestEmerald.withValues(alpha: 0.2), AppTheme.forestEmerald.withValues(alpha: 0.0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: AppTheme.forestEmerald.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.forestEmerald.withValues(alpha: 0.1),
                blurRadius: 30,
                spreadRadius: 5,
              )
            ],
          ),
          child: const Icon(Icons.verified_user_rounded, size: 72, color: AppTheme.forestEmerald),
        ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 48),
        Text(
          'Account Provisioned',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -1.0,
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
        const SizedBox(height: 20),
        Text(
          "Let's configure your blind-review preferences for a premium matching experience.",
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            color: Colors.white60,
            height: 1.6,
            fontWeight: FontWeight.w400,
          ),
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildSpecsStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Your Research Areas',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ).animate().fadeIn().slideY(begin: -0.1),
        const SizedBox(height: 12),
        Text(
          'Select the tags that define your academic expertise.',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white54, fontWeight: FontWeight.w500),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 40),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 14,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return _PremiumTagChip(
                  label: tag,
                  isSelected: isSelected,
                  onTap: () => _toggleTag(tag),
                );
              }).toList(),
            ),
          ),
        ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.98, 0.98)),
      ],
    );
  }

  Widget _buildCapacityStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Supervision Capacity',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Maximum number of simultaneous groups.',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white54),
        ),
        const SizedBox(height: 60),
        _CapacityDisplay(value: _capacityLimit.toInt()),
        const SizedBox(height: 60),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppTheme.forestEmerald,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.05),
            thumbColor: Colors.white,
            overlayColor: AppTheme.forestEmerald.withValues(alpha: 0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 10),
          ),
          child: Slider(
            value: _capacityLimit,
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (val) => setState(() => _capacityLimit = val),
          ),
        ).animate().fadeIn(delay: 500.ms),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Minimal', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white38, fontWeight: FontWeight.w600)),
            Text('Maximum', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white38, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildFinalStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _AnimatedStatusIcon(isSubmitting: _isSubmitting),
        const SizedBox(height: 48),
        Text(
          _isSubmitting ? 'Syncing...' : 'Ready to Match',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 20),
        Text(
          'Your profile settings will now be applied to the dashboard.',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 15, 
            color: Colors.white60, 
            height: 1.6,
            fontWeight: FontWeight.w400,
          ),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildNavigationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentPage > 0 && _currentPage < 3)
          _TransparentButton(
            onPressed: () => _pageController.previousPage(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutQuart,
            ),
            label: 'Back',
          )
        else
          const SizedBox(width: 80),

        Row(
          children: List.generate(4, (index) {
            final active = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 28 : 8,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: active ? AppTheme.forestEmerald : Colors.white.withValues(alpha: 0.1),
              ),
            );
          }),
        ),

        if (_currentPage < 3)
          _ActionButton(
            onPressed: _nextPage,
            label: 'Next',
            width: 100,
          )
        else
          _ActionButton(
            onPressed: _isSubmitting ? null : _completeOnboarding,
            label: 'Finish',
            width: 120,
            isLoading: _isSubmitting,
          ),
      ],
    );
  }
}

class _PremiumTagChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PremiumTagChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PremiumTagChip> createState() => _PremiumTagChipState();
}

class _PremiumTagChipState extends State<_PremiumTagChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: widget.isSelected 
                ? AppTheme.forestEmerald.withValues(alpha: 0.8) 
                : Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: widget.isSelected 
                  ? AppTheme.forestEmerald.withValues(alpha: 0.8) 
                  : Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: widget.isSelected ? [
              BoxShadow(
                color: AppTheme.forestEmerald.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ] : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isSelected) ...[
                const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: widget.isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CapacityDisplay extends StatelessWidget {
  final int value;
  const _CapacityDisplay({required this.value});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.03),
            border: Border.all(color: AppTheme.forestEmerald.withValues(alpha: 0.15), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.forestEmerald.withValues(alpha: 0.05),
                blurRadius: 30,
                spreadRadius: 5,
              )
            ],
          ),
        ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.toString(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                color: AppTheme.forestEmerald,
              ),
            ),
            Text(
              'GROUPS',
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppTheme.forestEmerald.withValues(alpha: 0.6),
                letterSpacing: 2,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }
}

class _AnimatedStatusIcon extends StatelessWidget {
  final bool isSubmitting;
  const _AnimatedStatusIcon({required this.isSubmitting});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.forestEmerald.withValues(alpha: 0.05),
        border: Border.all(color: AppTheme.forestEmerald.withValues(alpha: 0.1)),
      ),
      child: Icon(
        isSubmitting ? Icons.sync_rounded : Icons.task_alt_rounded,
        size: 96,
        color: AppTheme.forestEmerald,
      ).animate(
        onPlay: isSubmitting ? (c) => c.repeat() : null,
      ).rotate(duration: 2.seconds),
    ).animate().scale(curve: Curves.easeOutBack);
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double width;
  final bool isLoading;

  const _ActionButton({
    required this.label,
    this.onPressed,
    this.width = 120,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.forestEmerald,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 10,
          shadowColor: AppTheme.forestEmerald.withValues(alpha: 0.3),
        ),
        child: isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label, style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 15)),
      ),
    );
  }
}

class _TransparentButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _TransparentButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          color: Colors.white.withValues(alpha: 0.4),
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppTheme.premiumBlack),
        _GlowOrb(
          color: AppTheme.forestEmerald.withValues(alpha: 0.15),
          size: 600,
          offset: const Offset(-200, -200),
          duration: 10.seconds,
        ),
        _GlowOrb(
          color: AppTheme.forestEmerald.withValues(alpha: 0.1),
          size: 400,
          offset: const Offset(400, 400),
          duration: 15.seconds,
        ),
        _GlowOrb(
          color: AppTheme.forestEmerald.withValues(alpha: 0.08),
          size: 500,
          offset: const Offset(-100, 600),
          duration: 12.seconds,
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  final Offset offset;
  final Duration duration;

  const _GlowOrb({
    required this.color,
    required this.size,
    this.offset = Offset.zero,
    this.duration = const Duration(seconds: 10),
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: offset.dy,
      left: offset.dx,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true))
       .move(begin: const Offset(-20, -20), end: const Offset(20, 20), duration: duration, curve: Curves.easeInOut),
    );
  }
}
