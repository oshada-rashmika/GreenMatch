import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/mock_project_service.dart';
import '../widgets/glass_container.dart';

class SupervisorDashboard extends StatefulWidget {
  const SupervisorDashboard({super.key});

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  late final MockProjectService projectService;
  List<Map<String, dynamic>> projects = [];
  bool isLoading = true;
  final Set<String> matchedProjectIds = {};
  
  String _selectedFilter = "All";

  final List<String> _filters = [
    "All",
    "Artificial Intelligence",
    "Web & Mobile",
    "Data Science",
    "Cybersecurity",
  ];

  @override
  void initState() {
    super.initState();
    projectService = MockProjectService();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedProjects = await projectService.fetchAnonymousProjects();
      setState(() {
        projects = fetchedProjects;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching projects: $e')));
      }
    }
  }

  List<Map<String, dynamic>> get _filteredProjects {
    if (_selectedFilter == "All") {
      return projects;
    }
    return projects
        .where((p) => p['researchArea'] == _selectedFilter)
        .toList();
  }

  void _onMatchConfirmed(String projectId) {
    setState(() {
      matchedProjectIds.add(projectId);
    });
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
                  color: AppTheme.forestEmerald.withOpacity(0.15),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.forestEmerald.withOpacity(0.1),
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
                      transitionBuilder: (Widget child, Animation<double> animation) {
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
          title: Text(
            "Blind Review",
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              fontSize: 22,
            ),
          ),
          actions: [
            _buildAppBarIcon(Icons.notifications_none_rounded),
            const SizedBox(width: 8),
            _buildAppBarIcon(Icons.person),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarIcon(IconData icon) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.forestEmerald.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: Colors.white.withOpacity(0.9)),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                borderRadius: 12,
                opacity: isSelected ? 0.2 : 0.03,
                borderColor: isSelected 
                    ? AppTheme.forestEmerald.withOpacity(0.5) 
                    : Colors.white.withOpacity(0.05),
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

  Widget _buildEmptyState() {
    return Container(
      key: const ValueKey('empty'),
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.manage_search_rounded,
            size: 100,
            color: Colors.white.withOpacity(0.05),
          ).animate().fadeIn(duration: 1.seconds).scale(begin: const Offset(0.8, 0.8)),
          const SizedBox(height: 24),
          Text(
            "The Archive is Empty",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.8),
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
              color: Colors.white.withOpacity(0.4),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
          const SizedBox(height: 48),
          InkWell(
            onTap: () => setState(() => _selectedFilter = "All"),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.forestEmerald.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.forestEmerald.withOpacity(0.1),
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
    );
  }

  Widget _buildBentoGrid(List<Map<String, dynamic>> filtered) {
    return LayoutBuilder(
      key: ValueKey(_selectedFilter), // Force rebuild on filter change for new stagger
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
        
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

  Widget _buildBentoCard(Map<String, dynamic> project, int index) {
    return _ProjectCardHolder(
      project: project,
      index: index,
      isMatched: matchedProjectIds.contains(project['id']),
      onMatch: () => _onMatchConfirmed(project['id']),
    );
  }
}

class _ProjectCardHolder extends StatefulWidget {
  final Map<String, dynamic> project;
  final int index;
  final bool isMatched;
  final VoidCallback onMatch;

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
    final techStack = widget.project['techStack'] as List<dynamic>;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: 24,
          opacity: _isHovered ? 0.08 : 0.04,
          borderColor: _isHovered ? AppTheme.forestEmerald.withOpacity(0.3) : Colors.white.withOpacity(0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.forestEmerald.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.project['researchArea'].toString().toUpperCase(),
                      style: GoogleFonts.montserrat(
                        color: AppTheme.forestEmerald,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Icon(Icons.more_horiz, color: Colors.white.withOpacity(0.3)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.project['title'],
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.project['abstract'],
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: techStack.map((tech) => _buildTechBadge(tech)).toList(),
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: widget.isMatched
                    ? _buildRevealedMatch()
                    : _buildMatchAction(widget.project['id']),
              ),
            ],
          ),
        ).animate().fadeIn(
          duration: 600.ms,
          delay: (widget.index * 100).ms,
          curve: Curves.easeOutQuart,
        ).slideY(begin: 0.1),
      ),
    );
  }

  Widget _buildTechBadge(String tech) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Text(
        tech,
        style: GoogleFonts.montserrat(
          color: Colors.white.withOpacity(0.4),
          fontSize: 10,
          fontWeight: FontWeight.w500,
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
              color: AppTheme.forestEmerald.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: -5,
              offset: const Offset(0, 5),
            ),
          ],
          gradient: LinearGradient(
            colors: [
              AppTheme.forestEmerald,
              AppTheme.forestEmerald.withRed((AppTheme.forestEmerald.red + 20).clamp(0, 255)),
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
        color: AppTheme.forestEmerald.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.forestEmerald.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_rounded, color: AppTheme.forestEmerald, size: 20),
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
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
