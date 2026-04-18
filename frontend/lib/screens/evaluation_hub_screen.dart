import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/auth_provider.dart';
import '../services/evaluation_service.dart';
import '../services/project_service.dart';
import '../widgets/glass_container.dart';

class EvaluationCanvasScreen extends StatelessWidget {
  final String projectId;
  const EvaluationCanvasScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evaluation Canvas')),
      body: Center(child: Text('Evaluating Project: $projectId')),
    );
  }
}

class EvaluationHubScreen extends StatefulWidget {
  const EvaluationHubScreen({super.key});

  @override
  State<EvaluationHubScreen> createState() => _EvaluationHubScreenState();
}

class _EvaluationHubScreenState extends State<EvaluationHubScreen> {
  final EvaluationService _evaluationService = EvaluationService();
  List<SupervisedProject>? _projects;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final authProvider = context.read<AuthProvider>();
    final supervisorId = authProvider.userId;

    if (supervisorId == null) {
      setState(() {
        _error = "Authentication error: Supervisor ID not found.";
        _isLoading = false;
      });
      return;
    }

    try {
      final projects = await _evaluationService.fetchEvaluatedProjects(supervisorId);
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
            const _EvaluationHubBackground(),

            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white10,
                  padding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Project Evaluations',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 60),
            child: Text(
              'Manage and grade your supervised projects.',
              style: GoogleFonts.montserrat(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.forestEmerald),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadProjects,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.forestEmerald),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_projects == null || _projects!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, color: Colors.white10, size: 100),
            const SizedBox(height: 24),
            Text(
              'No Projects Found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white38,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Assigned projects will appear here for grading.',
              style: GoogleFonts.montserrat(color: Colors.white24, fontSize: 13),
            ),
          ],
        ).animate().fadeIn(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: _projects!.length,
      itemBuilder: (context, index) {
        final project = _projects![index];
        return _ProjectEvaluationCard(project: project)
            .animate(delay: (index * 100).ms)
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.1);
      },
    );
  }
}

class _ProjectEvaluationCard extends StatelessWidget {
  final SupervisedProject project;

  const _ProjectEvaluationCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.5),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          project.groupName,
                          style: GoogleFonts.montserrat(
                            color: AppTheme.forestEmerald,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(evaluation: project.evaluation),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                project.abstract,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  color: Colors.white54,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   _TeamSummary(members: project.teamMembers),
                   if (!project.isEvaluated)
                    _EvaluateButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EvaluationCanvasScreen(projectId: project.id),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ProjectEvaluation? evaluation;
  const _StatusBadge({this.evaluation});

  @override
  Widget build(BuildContext context) {
    final isGraded = evaluation != null;
    final color = isGraded ? AppTheme.forestEmerald : Colors.amber;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          if (isGraded)
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGraded ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            isGraded ? 'Graded: ${evaluation!.finalMark}/100' : 'Pending',
            style: GoogleFonts.montserrat(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamSummary extends StatelessWidget {
  final List<StudentIdentity> members;
  const _TeamSummary({required this.members});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: List.generate(
            members.length.clamp(0, 3),
            (i) => Padding(
              padding: EdgeInsets.only(left: i * 16.0),
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white10,
                child: Text(
                  members[i].fullName[0],
                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${members.length} Members',
          style: GoogleFonts.montserrat(
            color: Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _EvaluateButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _EvaluateButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.forestEmerald;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          children: [
            Text(
              'Evaluate',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}

class _EvaluationHubBackground extends StatelessWidget {
  const _EvaluationHubBackground();

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
          color: AppTheme.forestEmerald.withValues(alpha: 0.08),
          size: 400,
          offset: const Offset(400, 300),
          duration: 20.seconds,
        ),
        _GlowOrb(
          color: AppTheme.forestEmerald.withValues(alpha: 0.05),
          size: 500,
          offset: const Offset(100, 600),
          duration: 18.seconds,
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