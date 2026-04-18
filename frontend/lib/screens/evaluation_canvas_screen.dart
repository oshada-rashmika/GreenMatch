import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/auth_provider.dart';
import '../services/evaluation_service.dart';
import '../services/project_service.dart';

class EvaluationCanvasScreen extends StatefulWidget {
  final SupervisedProject project;
  const EvaluationCanvasScreen({super.key, required this.project});

  @override
  State<EvaluationCanvasScreen> createState() => _EvaluationCanvasScreenState();
}

class _EvaluationCanvasScreenState extends State<EvaluationCanvasScreen> {
  final EvaluationService _evaluationService = EvaluationService();
  final TextEditingController _feedbackController = TextEditingController();
  
  double _feasibilityScale = 50;
  double _innovationScale = 50;
  double _scopeScale = 50;
  bool _isSubmitting = false;

  int get _finalMark => ((_feasibilityScale + _innovationScale + _scopeScale) / 3).round();

  Future<void> _submitEvaluation() async {
    final authProvider = context.read<AuthProvider>();
    final supervisorId = authProvider.userId;

    if (supervisorId == null) {
      _showBasicError('Authentication error: Supervisor ID not found.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _evaluationService.submitEvaluation(
        projectId: widget.project.id,
        supervisorId: supervisorId,
        finalMark: _finalMark,
        feedbackText: _feedbackController.text.trim(),
        criteriaScores: {
          'technicalFeasibility': _feasibilityScale.round(),
          'innovation': _innovationScale.round(),
          'scope': _scopeScale.round(),
        },
      );

      if (mounted) {
        _showGlassSnackBar(context, 'Evaluation submitted successfully!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showBasicError(e.toString());
      }
    }
  }

  void _showBasicError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showGlassSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 2500),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 120,
          left: 20,
          right: 20,
        ),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.forestEmerald.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.forestEmerald.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.forestEmerald.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppTheme.forestEmerald,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      message,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            const _CanvasBackground(),

            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildTopNav(),
                        const SizedBox(height: 30),
                        _buildFinalMarkGauge(),
                        const SizedBox(height: 40),
                        _buildProjectInfo(),
                        const SizedBox(height: 32),
                        _buildGradingSection(),
                        const SizedBox(height: 24),
                        _buildFeedbackSection(),
                        const SizedBox(height: 40),
                        _buildSubmitButton(),
                        const SizedBox(height: 40),
                      ],
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

  Widget _buildTopNav() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded, color: Colors.white70),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white10,
            padding: const EdgeInsets.all(12),
          ),
        ),
        Text(
          'Grading Canvas',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white38,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 48),
      ],
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildFinalMarkGauge() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.forestEmerald.withValues(alpha: 0.1),
                  width: 8,
                ),
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: _finalMark / 100),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutQuart,
              builder: (context, value, child) {
                return SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 8,
                    backgroundColor: Colors.transparent,
                    color: AppTheme.forestEmerald,
                  ),
                );
              },
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_finalMark',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'FINAL MARK',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white38,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
           decoration: BoxDecoration(
             color: AppTheme.forestEmerald.withValues(alpha: 0.1),
             borderRadius: BorderRadius.circular(20),
             border: Border.all(color: AppTheme.forestEmerald.withValues(alpha: 0.2)),
           ),
           child: Text(
             'Averaged weighting applied',
             style: GoogleFonts.montserrat(
               fontSize: 11,
               color: AppTheme.forestEmerald,
               fontWeight: FontWeight.w600,
             ),
           ),
        ),
      ],
    ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack);
  }

  Widget _buildProjectInfo() {
    return Column(
      children: [
        Text(
          widget.project.title,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Supervised Group: ${widget.project.groupName}',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: Colors.white54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildGradingSection() {
    return Column(
      children: [
        _buildCriterionSlider(
          label: 'Technical Feasibility',
          value: _feasibilityScale,
          onChanged: (val) => setState(() => _feasibilityScale = val),
        ),
        const SizedBox(height: 20),
        _buildCriterionSlider(
          label: 'Innovation & Research',
          value: _innovationScale,
          onChanged: (val) => setState(() => _innovationScale = val),
        ),
        const SizedBox(height: 20),
        _buildCriterionSlider(
          label: 'Project Scope & Execution',
          value: _scopeScale,
          onChanged: (val) => setState(() => _scopeScale = val),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildCriterionSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.montserrat(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${value.round()}/100',
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.forestEmerald,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.forestEmerald,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              thumbColor: Colors.white,
              overlayColor: AppTheme.forestEmerald.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              onChanged: (val) {
                if (val.round() != value.round()) {
                  HapticFeedback.selectionClick();
                }
                onChanged(val);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Feedback Notes',
            style: GoogleFonts.montserrat(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _feedbackController,
            maxLines: null,
            minLines: 4,
            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14),
            cursorColor: AppTheme.forestEmerald,
            decoration: InputDecoration(
              hintText: 'Provide detailed qualitative feedback...',
              hintStyle: GoogleFonts.montserrat(color: Colors.white24, fontSize: 14),
              filled: true,
              fillColor: Colors.black12,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildSubmitButton() {
     return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.forestEmerald.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitEvaluation,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.forestEmerald,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Submit Final Grade',
                    style: GoogleFonts.montserrat(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.send_rounded, size: 20),
                ],
              ),
      ),
    ).animate().fadeIn(delay: 1.seconds);
  }
}

class _CanvasBackground extends StatelessWidget {
  const _CanvasBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppTheme.premiumBlack),
        _GlowOrb(
          color: AppTheme.forestEmerald.withValues(alpha: 0.12),
          size: 600,
          offset: const Offset(-200, -200),
          duration: 15.seconds,
        ),
        _GlowOrb(
          color: AppTheme.forestEmerald.withValues(alpha: 0.06),
          size: 500,
          offset: const Offset(300, 500),
          duration: 20.seconds,
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
       .move(begin: const Offset(-30, -30), end: const Offset(30, 30), duration: duration, curve: Curves.easeInOut),
    );
  }
}
