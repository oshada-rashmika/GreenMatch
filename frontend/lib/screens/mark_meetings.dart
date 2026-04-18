import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/project_service.dart';
import '../services/meeting_service.dart';
import '../widgets/glass_container.dart';


class MarkMeetingsProjectListScreen extends StatefulWidget {
  const MarkMeetingsProjectListScreen({super.key});

  @override
  State<MarkMeetingsProjectListScreen> createState() =>
      _MarkMeetingsProjectListScreenState();
}

class _MarkMeetingsProjectListScreenState
    extends State<MarkMeetingsProjectListScreen> {
  late final ProjectService _projectService;
  List<SupervisedProject> _projects = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _projectService = ProjectService();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final projects = await _projectService.fetchMySupervisedProjects();
      if (mounted) {
        setState(() {
          _projects = projects.where((p) => p.status == 'MATCHED').toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.premiumBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mark Meetings',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background gradient orbs
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.forestEmerald.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.forestEmerald.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState()
                    : _projects.isEmpty
                        ? _buildEmptyState()
                        : _buildProjectList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.forestEmerald),
          const SizedBox(height: 20),
          Text(
            'Loading your projects...',
            style: GoogleFonts.montserrat(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 56),
            const SizedBox(height: 20),
            Text(
              'Failed to load projects',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchProjects,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.forestEmerald,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Retry',
                  style: GoogleFonts.montserrat(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded,
              color: Colors.white.withValues(alpha: 0.15), size: 80),
          const SizedBox(height: 20),
          Text(
            'No Active Projects',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no matched projects to mark meetings for.',
            style: GoogleFonts.montserrat(
              color: Colors.white38,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text(
            'SELECT A PROJECT',
            style: GoogleFonts.montserrat(
              color: AppTheme.forestEmerald,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Text(
            'Choose a project to mark meeting days',
            style: GoogleFonts.montserrat(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Text(
            'At least 7 meetings must be marked per project',
            style: GoogleFonts.montserrat(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ),

        // Project cards
        Expanded(
          child: RefreshIndicator(
            color: AppTheme.forestEmerald,
            onRefresh: _fetchProjects,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              itemCount: _projects.length,
              itemBuilder: (context, index) {
                return _ProjectCard(
                  project: _projects[index],
                  index: index,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MeetingDaysGridScreen(
                          project: _projects[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}


class _ProjectCard extends StatefulWidget {
  final SupervisedProject project;
  final int index;
  final VoidCallback onTap;

  const _ProjectCard({
    required this.project,
    required this.index,
    required this.onTap,
  });

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: 20,
            opacity: 0.05,
            borderColor: Colors.white.withValues(alpha: 0.08),
            child: Row(
              children: [
                // Meeting icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.forestEmerald.withValues(alpha: 0.3),
                        AppTheme.forestEmerald.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.event_note_rounded,
                    color: AppTheme.forestEmerald,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Project info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.project.groupName.toUpperCase(),
                        style: GoogleFonts.montserrat(
                          color: AppTheme.forestEmerald,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.project.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.people_outline_rounded,
                              color: Colors.white38, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.project.teamMembers.length} members',
                            style: GoogleFonts.montserrat(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.forestEmerald.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.project.status,
                              style: GoogleFonts.montserrat(
                                color: AppTheme.forestEmerald,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white38,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(
            duration: 400.ms,
            delay: Duration(milliseconds: 80 * widget.index),
          ).slideX(
            begin: 0.05,
            duration: 400.ms,
            delay: Duration(milliseconds: 80 * widget.index),
          ),
    );
  }
}


class MeetingDaysGridScreen extends StatefulWidget {
  final SupervisedProject project;

  const MeetingDaysGridScreen({super.key, required this.project});

  @override
  State<MeetingDaysGridScreen> createState() => _MeetingDaysGridScreenState();
}

class _MeetingDaysGridScreenState extends State<MeetingDaysGridScreen>
    with SingleTickerProviderStateMixin {
  final MeetingService _meetingService = MeetingService();
  Map<int, MeetingMark> _markedMeetings = {};
  bool _isLoading = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _fetchMarks();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _fetchMarks() async {
    setState(() => _isLoading = true);
    try {
      final marks =
          await _meetingService.getProjectMeetingMarks(widget.project.groupId);
      if (mounted) {
        setState(() {
          _markedMeetings = {for (var m in marks) m.meetingNumber: m};
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load meeting marks: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showMarkDialog(int meetingNumber) {
    final bool isAlreadyMarked = _markedMeetings.containsKey(meetingNumber);
    final MeetingMark? existingMark = _markedMeetings[meetingNumber];
    DateTime selectedDate = existingMark?.scheduledDate ?? DateTime.now();

    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(bCtx).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1F14),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                  color: AppTheme.forestEmerald.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Meeting number badge
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isAlreadyMarked
                              ? [
                                  AppTheme.forestEmerald,
                                  AppTheme.forestEmerald
                                      .withValues(alpha: 0.7),
                                ]
                              : [
                                  Colors.white.withValues(alpha: 0.1),
                                  Colors.white.withValues(alpha: 0.05),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isAlreadyMarked
                            ? [
                                BoxShadow(
                                  color: AppTheme.forestEmerald
                                      .withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: -5,
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          '$meetingNumber',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      isAlreadyMarked
                          ? 'Meeting Day $meetingNumber'
                          : 'Mark Meeting Day $meetingNumber',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.project.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // If already marked, show date info
                    if (isAlreadyMarked && existingMark != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.forestEmerald.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                AppTheme.forestEmerald.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: AppTheme.forestEmerald, size: 20),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MARKED ON',
                                  style: GoogleFonts.montserrat(
                                    color: AppTheme.forestEmerald,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('MMMM dd, yyyy')
                                      .format(existingMark.scheduledDate),
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Unmark button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            try {
                              await _meetingService.unmarkMeetingDay(
                                groupId: widget.project.groupId,
                                meetingNumber: meetingNumber,
                              );
                              Navigator.pop(bCtx);
                              _fetchMarks();
                              _showSuccessSnackBar(
                                  'Meeting $meetingNumber unmarked');
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed: $e'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.close_rounded, size: 18),
                          label: Text(
                            'Unmark Meeting',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: BorderSide(
                              color: Colors.redAccent.withValues(alpha: 0.5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Date picker row
                      GestureDetector(
                        onTap: () async {
                          final val = await showDatePicker(
                            context: bCtx,
                            initialDate: selectedDate,
                            firstDate:
                                DateTime.now().subtract(const Duration(days: 365)),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: AppTheme.forestEmerald,
                                    surface: Color(0xFF0F1F14),
                                    onSurface: Colors.white,
                                  ), dialogTheme: DialogThemeData(backgroundColor: const Color(0xFF0F1F14)),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (val != null) {
                            setModalState(() => selectedDate = val);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  color: AppTheme.forestEmerald, size: 20),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MEETING DATE',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white38,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('MMMM dd, yyyy')
                                        .format(selectedDate),
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Icon(Icons.edit_rounded,
                                  color: Colors.white.withValues(alpha: 0.3),
                                  size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Mark button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await _meetingService.markMeetingDay(
                                groupId: widget.project.groupId,
                                meetingNumber: meetingNumber,
                                meetingDate: selectedDate,
                              );
                              Navigator.pop(bCtx);
                              _fetchMarks();
                              _showSuccessSnackBar(
                                'Meeting $meetingNumber marked ✓',
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to mark: $e'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.check_rounded,
                              color: Colors.white),
                          label: Text(
                            'Mark Meeting Day',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.forestEmerald,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(message,
                style: GoogleFonts.montserrat(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: AppTheme.forestEmerald,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalMeetings = 21;
    final int markedCount = _markedMeetings.length;
    final double progress = markedCount / totalMeetings;

    return Scaffold(
      backgroundColor: AppTheme.premiumBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Meeting Days',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              widget.project.groupName,
              style: GoogleFonts.montserrat(
                color: AppTheme.forestEmerald,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background orbs
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.forestEmerald.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.forestEmerald.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppTheme.forestEmerald))
                : Column(
                    children: [
                      const SizedBox(height: 8),

                      // Project title card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(16),
                          borderRadius: 18,
                          opacity: 0.06,
                          borderColor:
                              AppTheme.forestEmerald.withValues(alpha: 0.15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.project.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Progress bar
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.08),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                AppTheme.forestEmerald),
                                        minHeight: 6,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '$markedCount / $totalMeetings',
                                    style: GoogleFonts.montserrat(
                                      color: AppTheme.forestEmerald,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05),

                      const SizedBox(height: 8),

                      // Legend
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            _buildLegendDot(AppTheme.forestEmerald, 'Marked'),
                            const SizedBox(width: 20),
                            _buildLegendDot(
                                Colors.white.withValues(alpha: 0.1),
                                'Unmarked'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Grid of meeting boxes
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: totalMeetings,
                            itemBuilder: (context, index) {
                              final num = index + 1;
                              final isMarked =
                                  _markedMeetings.containsKey(num);
                              final mark = _markedMeetings[num];

                              return _MeetingDayBox(
                                meetingNumber: num,
                                isMarked: isMarked,
                                mark: mark,
                                animationDelay: index,
                                onTap: () => _showMarkDialog(num),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}


class _MeetingDayBox extends StatefulWidget {
  final int meetingNumber;
  final bool isMarked;
  final MeetingMark? mark;
  final int animationDelay;
  final VoidCallback onTap;

  const _MeetingDayBox({
    required this.meetingNumber,
    required this.isMarked,
    this.mark,
    required this.animationDelay,
    required this.onTap,
  });

  @override
  State<_MeetingDayBox> createState() => _MeetingDayBoxState();
}

class _MeetingDayBoxState extends State<_MeetingDayBox> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            gradient: widget.isMarked
                ? LinearGradient(
                    colors: [
                      AppTheme.forestEmerald,
                      AppTheme.forestEmerald.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.06),
                      Colors.white.withValues(alpha: 0.03),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isMarked
                  ? AppTheme.forestEmerald.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: widget.isMarked
                ? [
                    BoxShadow(
                      color: AppTheme.forestEmerald.withValues(alpha: 0.2),
                      blurRadius: 16,
                      spreadRadius: -4,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Meeting number
              Text(
                '${widget.meetingNumber}',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: widget.isMarked ? 32 : 28,
                  fontWeight: FontWeight.w800,
                ),
              ),

              if (widget.isMarked && widget.mark != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    DateFormat('MMM dd').format(widget.mark!.scheduledDate),
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 4),
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.white.withValues(alpha: 0.2),
                  size: 16,
                ),
              ],

              if (widget.isMarked)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 14,
                  ),
                ),
            ],
          ),
        ),
      ).animate().fadeIn(
            duration: 350.ms,
            delay: Duration(milliseconds: 40 * widget.animationDelay),
          ).scale(
            begin: const Offset(0.85, 0.85),
            duration: 350.ms,
            delay: Duration(milliseconds: 40 * widget.animationDelay),
            curve: Curves.easeOutBack,
          ),
    );
  }
}
