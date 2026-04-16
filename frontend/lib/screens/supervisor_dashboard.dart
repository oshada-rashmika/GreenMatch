import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/project_service.dart';
import '../widgets/glass_container.dart';
import 'matches_screen.dart';
import 'supervisor_profile_screen.dart';

class SupervisorDashboard extends StatefulWidget {
  const SupervisorDashboard({super.key});

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  late final ProjectService projectService;
  List<AnonymousProject> projects = [];
  bool isLoading = true;
  String? errorMessage;
  final Set<String> matchedProjectIds = {};

  String _selectedFilter = "All";

  List<String> _filters = ["All"];

  @override
  void initState() {
    super.initState();
    projectService = ProjectService();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final fetchedProjects = await projectService.fetchAnonymousProjects();

      final uniqueTags = fetchedProjects
          .expand((p) => p.tags)
          .toSet()
          .toList()
        ..sort();

      setState(() {
        projects = fetchedProjects;
        _filters = ["All", ...uniqueTags];
        isLoading = false;
      });
    } on ProjectServiceException catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.message;
      });
      _showErrorSnackBar(e.message);
    } catch (e) {
      const msg = 'An unexpected error occurred. Please try again.';
      setState(() {
        isLoading = false;
        errorMessage = msg;
      });
      _showErrorSnackBar(msg);
    }
  }

  List<AnonymousProject> get _filteredProjects {
    if (_selectedFilter == "All") {
      return projects;
    }
    return projects.where((p) => p.tags.contains(_selectedFilter)).toList();
  }

  Future<void> _onMatchConfirmed(String projectId) async {
    try {
      await projectService.confirmMatch(projectId);
      if (mounted) {
        setState(() {
          matchedProjectIds.add(projectId);
        });
      }
    } on ProjectServiceException catch (e) {
      _showErrorSnackBar('Failed to match project: ${e.message}');
    } catch (_) {
      _showErrorSnackBar('Failed to match project. Please try again.');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFB00020),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white70,
          onPressed: () =>
              ScaffoldMessenger.of(context).hideCurrentSnackBar(),
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
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            // Background mesh/glow
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
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
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildFilterBar(),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      switchInCurve: Curves.easeOutQuart,
                      switchOutCurve: Curves.easeInQuart,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.05),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                      child: isLoading
                          ? const Center(
                              key: ValueKey('loading'),
                              child: CircularProgressIndicator(
                                color: AppTheme.forestEmerald,
                              ),
                            )
                          : errorMessage != null
                              ? _buildErrorState(errorMessage!)
                              : _buildProjectContent(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: GlassContainer(
        borderRadius: 0,
        opacity: 0.02,
        blur: 15,
        borderColor: Colors.transparent,
        child: AppBar(
          centerTitle: true,
          title: Text(
            "Blind Review",
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              fontSize: 22,
            ),
          ),
          actions: [
            if (matchedProjectIds.isNotEmpty) _buildMatchesButton(),
            _buildAppBarIcon(Icons.notifications_none_rounded),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SupervisorProfileScreen(),
                ),
              ),
              child: _buildAppBarIcon(Icons.person),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchesButton() {
    return Center(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MatchesScreen()),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Badge(
          label: Text(matchedProjectIds.length.toString()),
          backgroundColor: AppTheme.forestEmerald,
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            borderRadius: 12,
            opacity: 0.1,
            borderColor: AppTheme.forestEmerald.withValues(alpha: 0.3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.handshake_outlined,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  "MATCHES",
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildAppBarIcon(IconData icon) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.forestEmerald.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: Colors.white.withValues(alpha: 0.9)),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () => setState(() => _selectedFilter = filter),
              borderRadius: BorderRadius.circular(12),
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                borderRadius: 12,
                opacity: isSelected ? 0.2 : 0.03,
                borderColor: isSelected
                    ? AppTheme.forestEmerald.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.05),
                child: Text(
                  filter,
                  style: GoogleFonts.montserrat(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProjectContent() {
    final filtered = _filteredProjects;
    if (filtered.isEmpty) {
      return _buildEmptyState();
    }
    return _buildBentoGrid(filtered);
  }

  Widget _buildErrorState(String message) {
    return SizedBox.expand(
      child: Container(
        key: const ValueKey('error'),
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFB00020).withValues(alpha: 0.1),
                border: Border.all(
                  color: const Color(0xFFB00020).withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: Color(0xFFB00020),
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: 24),
            Text(
              "Connection Error",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.45),
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2),
            const SizedBox(height: 40),
            InkWell(
              onTap: _fetchProjects,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFB00020).withValues(alpha: 0.4),
                  ),
                  color: const Color(0xFFB00020).withValues(alpha: 0.08),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      color: Color(0xFFB00020),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Retry",
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: const Color(0xFFB00020),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 400.ms).scale(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox.expand(
      child: Container(
        key: const ValueKey('empty'),
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
                  Icons.manage_search_rounded,
                  size: 100,
                  color: Colors.white.withValues(alpha: 0.05),
                )
                .animate()
                .fadeIn(duration: 1.seconds)
                .scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: 24),
            Text(
              "The Archive is Empty",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            const SizedBox(height: 12),
            Text(
              "NO PROJECTS MATCH YOUR CURRENT SELECTION",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                letterSpacing: 3,
                fontWeight: FontWeight.w300,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
            const SizedBox(height: 48),
            InkWell(
              onTap: () => setState(() => _selectedFilter = "All"),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.forestEmerald.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.forestEmerald.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  "Reset Filters",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.forestEmerald,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 600.ms).scale(),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoGrid(List<AnonymousProject> filtered) {
    return LayoutBuilder(
      key: ValueKey(
        _selectedFilter,
      ),
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 900
            ? 3
            : (constraints.maxWidth > 600 ? 2 : 1);

        return MasonryGridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return _buildBentoCard(filtered[index], index);
          },
        );
      },
    );
  }

  Widget _buildBentoCard(AnonymousProject project, int index) {
    return _ProjectCardHolder(
      project: project,
      index: index,
      isMatched: matchedProjectIds.contains(project.id),
      onMatch: () => _onMatchConfirmed(project.id),
    );
  }
}

class _ProjectCardHolder extends StatefulWidget {
  final AnonymousProject project;
  final int index;
  final bool isMatched;
  final Future<void> Function() onMatch;

  const _ProjectCardHolder({
    required this.project,
    required this.index,
    required this.isMatched,
    required this.onMatch,
  });

  @override
  State<_ProjectCardHolder> createState() => _ProjectCardHolderState();
}

class _ProjectCardHolderState extends State<_ProjectCardHolder> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        child:
            GlassContainer(
                  padding: const EdgeInsets.all(20),
                  borderRadius: 24,
                  opacity: _isHovered ? 0.08 : 0.04,
                  borderColor: _isHovered
                      ? AppTheme.forestEmerald.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: widget.project.tags
                                  .map((tag) => _buildTagBadge(tag))
                                  .toList(),
                            ),
                          ),
                          Icon(
                            Icons.more_horiz,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.project.title,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.project.abstract,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: animation,
                                  child: child,
                                ),
                              );
                            },
                        child: widget.isMatched
                            ? _buildRevealedMatch()
                            : _buildMatchAction(widget.project.id),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(
                  duration: 600.ms,
                  delay: (widget.index * 100).ms,
                  curve: Curves.easeOutQuart,
                )
                .slideY(begin: 0.1),
      ),
    );
  }

  Widget _buildTagBadge(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.forestEmerald.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.forestEmerald.withValues(alpha: 0.1)),
      ),
      child: Text(
        tag.toUpperCase(),
        style: GoogleFonts.montserrat(
          color: AppTheme.forestEmerald,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMatchAction(String projectId) {
    return InkWell(
      key: const ValueKey('button'),
      onTap: widget.onMatch,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppTheme.forestEmerald.withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: -5,
              offset: const Offset(0, 5),
            ),
          ],
          gradient: LinearGradient(
            colors: [
              AppTheme.forestEmerald,
              AppTheme.forestEmerald.withRed(
                (((AppTheme.forestEmerald.r * 255.0).round() + 20).clamp(
                  0,
                  255,
                )).toInt(),
              ),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            "Confirm Match",
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRevealedMatch() {
    return Container(
      key: const ValueKey('revealed'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.forestEmerald.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.forestEmerald.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_rounded,
                color: AppTheme.forestEmerald,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "MATCH SECURED",
                style: GoogleFonts.montserrat(
                  color: AppTheme.forestEmerald,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "student.contact@university.dev",
            style: GoogleFonts.montserrat(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
