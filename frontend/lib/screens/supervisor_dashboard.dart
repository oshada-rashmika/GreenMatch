import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/auth_provider.dart';
import '../services/project_service.dart';
import '../widgets/glass_container.dart';
import 'login_screen.dart';
import 'matches_screen.dart';
import 'profile_screen.dart';
import '../services/shortlist_provider.dart';

class SupervisorDashboard extends StatefulWidget {
  const SupervisorDashboard({super.key});

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  late final ProjectService projectService;
  List<AnonymousProject> projects = [];
  List<SupervisedProject> supervisedProjects = [];
  int _currentTab = 0;
  bool isLoading = true;
  String? errorMessage;
  final Set<String> matchedProjectIds = {};
  bool _isFocusMode = false;

  final List<String> activeSpecifications = [
    'Artificial Intelligence',
    'Python',
    'TensorFlow',
  ];

  String _selectedFilter = "All";
  List<String> _filters = ["All"];

  static const Duration _warningDuration = Duration(minutes: 30);
  static const Duration _logoutDuration  = Duration(minutes: 45);

  Timer? _warningTimer;
  Timer? _logoutTimer;

  bool _showWarning = false;

  int _countdownSeconds = 15 * 60; 
  Timer? _countdownTick;

  @override
  void initState() {
    super.initState();
    projectService = ProjectService();
    _fetchProjects();
    _resetTimers();
  }

  void _resetTimers() {
    _warningTimer?.cancel();
    _logoutTimer?.cancel();
    _countdownTick?.cancel();

    if (_showWarning) {
      setState(() {
        _showWarning = false;
        _countdownSeconds = 15 * 60;
      });
    }

    _warningTimer = Timer(_warningDuration, _onWarningTriggered);
    _logoutTimer  = Timer(_logoutDuration,  _onAutoLogout);
  }

  void _onWarningTriggered() {
    if (!mounted) return;
    setState(() {
      _showWarning = true;
      _countdownSeconds = 15 * 60;
    });
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTick?.cancel();
    _countdownTick = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_countdownSeconds <= 0) {
        t.cancel();
        return;
      }
      setState(() => _countdownSeconds--);
    });
  }

  Future<void> _onAutoLogout() async {
    _warningTimer?.cancel();
    _countdownTick?.cancel();
    if (!mounted) return;
    await _performSecureLogout();
  }

  Future<void> _performSecureLogout() async {
    const FlutterSecureStorage storage = FlutterSecureStorage();
    await storage.deleteAll();
    if (!mounted) return;
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _handlePointerEvent(PointerEvent event) {
    _resetTimers();
  }

  String _formatCountdown(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _fetchProjects() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final fetchedProjects = await projectService.fetchAnonymousProjects();
      final mySupervised = await projectService.fetchMySupervisedProjects();

      final uniqueTags = fetchedProjects
          .expand((p) => p.tags)
          .toSet()
          .toList()
        ..sort();

      setState(() {
        projects = fetchedProjects;
        supervisedProjects = mySupervised;
        _filters = ["All", "My Shortlist", ...uniqueTags];
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


  @override
  void dispose() {
    _warningTimer?.cancel();
    _logoutTimer?.cancel();
    _countdownTick?.cancel();
    super.dispose();
  }

  Future<void> _onMatchConfirmed(String projectId) async {
    try {
      await projectService.confirmMatch(projectId);
      if (mounted) {
        setState(() {
          projects.removeWhere((p) => p.id == projectId);
        });
        _showSuccessSnackBar('Match Successfully Confirmed!');
      }
    } on ProjectServiceException catch (e) {
      if (e.statusCode == 400) {
        _showErrorSnackBar('Project already claimed by another supervisor');
        _fetchProjects(); 
      } else {
        _showErrorSnackBar('Failed to match project: ${e.message}');
      }
    } catch (_) {
      _showErrorSnackBar('Failed to match project. Please try again.');
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
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
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
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
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _handlePointerEvent,
        onPointerMove: _handlePointerEvent,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(),
          body: Stack(
            children: [
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
                    _buildTabToggle(),
                    const SizedBox(height: 10),
                    if (_currentTab == 0) _buildFilterBar(),
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
                                : (_currentTab == 0 ? _buildProjectContent() : _buildSupervisedContent()),
                      ),
                    ),
                  ],
                ),
              ),

              if (_showWarning)
                _SessionWarningOverlay(
                  countdownText: _formatCountdown(_countdownSeconds),
                  onExtend: _resetTimers,
                  onLogoutNow: _performSecureLogout,
                ),
            ],
          ),
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
            const SizedBox(width: 8),
            _buildFocusToggle(),
            _buildAppBarIcon(Icons.notifications_none_rounded),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
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

  Widget _buildFocusToggle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _isFocusMode = !_isFocusMode);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isFocusMode 
                    ? AppTheme.forestEmerald.withValues(alpha: 0.15) 
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isFocusMode 
                      ? AppTheme.forestEmerald.withValues(alpha: 0.3) 
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                child: Icon(
                  _isFocusMode ? Icons.view_carousel_rounded : Icons.view_agenda_rounded,
                  key: ValueKey(_isFocusMode),
                  size: 22,
                  color: _isFocusMode ? AppTheme.forestEmerald : Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(4),
        borderRadius: 16,
        opacity: 0.05,
        borderColor: AppTheme.forestEmerald.withValues(alpha: 0.2),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _currentTab = 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _currentTab == 0 ? AppTheme.forestEmerald : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Available Projects', 
                      style: GoogleFonts.montserrat(
                        color: _currentTab == 0 ? Colors.white : Colors.white60,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      )
                    )
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _currentTab = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _currentTab == 1 ? AppTheme.forestEmerald : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'My Supervised', 
                      style: GoogleFonts.montserrat(
                        color: _currentTab == 1 ? Colors.white : Colors.white60,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      )
                    )
                  ),
                ),
              ),
            ),
          ],
        ),
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
    final shortlistProvider = context.watch<ShortlistProvider>();
    List<AnonymousProject> filtered;
    
    if (_selectedFilter == "All") {
      filtered = projects;
    } else if (_selectedFilter == "My Shortlist") {
      filtered = projects.where((p) => shortlistProvider.isShortlisted(p.id)).toList();
    } else {
      filtered = projects.where((p) => p.tags.contains(_selectedFilter)).toList();
    }

    if (filtered.isEmpty) {
      if (_selectedFilter == "My Shortlist") {
        return _buildEmptyShortlistState();
      }
      return _buildEmptyState();
    }
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutQuart,
      switchOutCurve: Curves.easeInQuart,
      transitionBuilder: (child, animation) {
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
      child: _isFocusMode
          ? _buildFocusModePlaceholder(filtered)
          : _buildBentoGrid(filtered),
    );
  }

  Widget _buildFocusModePlaceholder(List<AnonymousProject> projects) {
    return Container(
      key: const ValueKey('focus_mode_placeholder'),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.view_carousel_rounded, size: 64, color: AppTheme.forestEmerald.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              "Focus Mode (Swipe View)",
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${projects.length} projects ready to review.",
              style: GoogleFonts.montserrat(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildEmptyShortlistState() {
    return SizedBox.expand(
      child: Container(
        key: const ValueKey('empty_shortlist'),
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
                  Icons.bookmark_outline_rounded,
                  size: 100,
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                )
                .animate()
                .fadeIn(duration: 1.seconds)
                .scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: 24),
            Text(
              "Your Shortlist is Empty",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            const SizedBox(height: 12),
            Text(
              "BOOKMARK PROJECTS TO REVIEW THEM LATER",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
                color: AppTheme.forestEmerald,
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
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
      activeSpecifications: activeSpecifications,
      isMatched: matchedProjectIds.contains(project.id),
      onMatch: () => _onMatchConfirmed(project.id),
    );
  }

  Widget _buildSupervisedContent() {
    if (supervisedProjects.isEmpty) {
      return _buildEmptyState();
    }
    return LayoutBuilder(
      key: const ValueKey('supervised_projects_tab'),
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
        return MasonryGridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          itemCount: supervisedProjects.length,
          itemBuilder: (context, index) {
            return _SupervisedProjectCardHolder(
              project: supervisedProjects[index],
              index: index,
              onSchedule: () => _showScheduleMeetingModal(supervisedProjects[index]),
            );
          },
        );
      },
    );
  }

  Future<void> _showScheduleMeetingModal(SupervisedProject project) async {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    DateTime? expiryDate;
    TimeOfDay? expiryTime;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (bCtx, setModalState) {
          final sDateStr = selectedDate != null
              ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
              : 'Select Date';
          final sTimeStr = selectedTime != null ? selectedTime!.format(context) : 'Select Time';

          final eDateStr = expiryDate != null
              ? '${expiryDate!.year}-${expiryDate!.month.toString().padLeft(2, '0')}-${expiryDate!.day.toString().padLeft(2, '0')}'
              : 'Select Date';
          final eTimeStr = expiryTime != null ? expiryTime!.format(context) : 'Select Time';

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(bCtx).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1F14),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: AppTheme.forestEmerald.withValues(alpha: 0.3)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SCHEDULE CHECK-IN',
                    style: GoogleFonts.montserrat(
                      color: AppTheme.forestEmerald,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Group: ${project.groupName}',
                    style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  _buildDateTimePickerRow(
                    label: 'Meeting Time',
                    dateStr: sDateStr,
                    timeStr: sTimeStr,
                    onDatePick: () async {
                      final val = await showDatePicker(context: bCtx, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                      if (val != null) setModalState(() => selectedDate = val);
                    },
                    onTimePick: () async {
                      final val = await showTimePicker(context: bCtx, initialTime: TimeOfDay.now());
                      if (val != null) setModalState(() => selectedTime = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDateTimePickerRow(
                    label: 'Window Expiry (Anti-ghosting)',
                    dateStr: eDateStr,
                    timeStr: eTimeStr,
                    onDatePick: () async {
                      final val = await showDatePicker(context: bCtx, initialDate: selectedDate ?? DateTime.now(), firstDate: selectedDate ?? DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                      if (val != null) setModalState(() => expiryDate = val);
                    },
                    onTimePick: () async {
                      final val = await showTimePicker(context: bCtx, initialTime: TimeOfDay.now());
                      if (val != null) setModalState(() => expiryTime = val);
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.forestEmerald,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: isSubmitting ? null : () async {
                        if (selectedDate == null || selectedTime == null || expiryDate == null || expiryTime == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select all dates and times.')));
                          return;
                        }

                        final sched = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, selectedTime!.hour, selectedTime!.minute);
                        final exp = DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day, expiryTime!.hour, expiryTime!.minute);

                        if (exp.isBefore(sched)) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expiry must be after meeting time!')));
                          return;
                        }
                        if (sched.isBefore(DateTime.now())) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot schedule in the past.')));
                          return;
                        }

                        setModalState(() => isSubmitting = true);
                        try {
                          await projectService.scheduleMeeting(project.groupId, sched, exp);
                          Navigator.pop(bCtx);
                          _showSuccessSnackBar('Meeting Scheduled! Anti-ghosting enabled.');
                          _fetchProjects();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                        } finally {
                          if (mounted) setModalState(() => isSubmitting = false);
                        }
                      },
                      child: isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Schedule Check-in', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildDateTimePickerRow({
    required String label,
    required String dateStr,
    required String timeStr,
    required VoidCallback onDatePick,
    required VoidCallback onTimePick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onDatePick,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(dateStr, style: const TextStyle(color: Colors.white))),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: onTimePick,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(timeStr, style: const TextStyle(color: Colors.white))),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SupervisedProjectCardHolder extends StatefulWidget {
  final SupervisedProject project;
  final int index;
  final VoidCallback onSchedule;

  const _SupervisedProjectCardHolder({required this.project, required this.index, required this.onSchedule});

  @override
  State<_SupervisedProjectCardHolder> createState() => _SupervisedProjectCardHolderState();
}

class _SupervisedProjectCardHolderState extends State<_SupervisedProjectCardHolder> {
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
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: 24,
          opacity: _isHovered ? 0.08 : 0.04,
          borderColor: _isHovered ? AppTheme.forestEmerald.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: widget.project.tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.forestEmerald.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                  child: Text(tag.toUpperCase(), style: GoogleFonts.montserrat(color: AppTheme.forestEmerald, fontSize: 9, fontWeight: FontWeight.w800)),
                )).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'GROUP: ${widget.project.groupName.toUpperCase()}',
                style: GoogleFonts.montserrat(
                  color: AppTheme.forestEmerald,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(widget.project.title, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2)),
              const SizedBox(height: 12),
              Text(widget.project.abstract, maxLines: 3, overflow: TextOverflow.ellipsis, style: GoogleFonts.montserrat(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, height: 1.5)),
              const SizedBox(height: 16),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
              const SizedBox(height: 16),
              Text('TEAM MEMBERS', style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
              const SizedBox(height: 8),
              ...widget.project.teamMembers.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: AppTheme.forestEmerald),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.fullName, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          Text(m.email, style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              )).toList(),
              const SizedBox(height: 24),
              InkWell(
                onTap: widget.onSchedule,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.forestEmerald.withValues(alpha: 0.15),
                    border: Border.all(color: AppTheme.forestEmerald.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text('Schedule Check-in', style: GoogleFonts.montserrat(color: AppTheme.forestEmerald, fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectCardHolder extends StatefulWidget {
  final AnonymousProject project;
  final int index;
  final bool isMatched;
  final List<String> activeSpecifications;
  final Future<void> Function() onMatch;

  const _ProjectCardHolder({
    required this.project,
    required this.index,
    required this.isMatched,
    required this.activeSpecifications,
    required this.onMatch,
  });

  @override
  State<_ProjectCardHolder> createState() => _ProjectCardHolderState();
}

class _ProjectCardHolderState extends State<_ProjectCardHolder> {
  bool _isHovered = false;
  bool _isMatching = false;

  double get _fraction {
    if (widget.project.tags.isEmpty) return 0.0;
    int matches = widget.project.tags
        .where((tag) => widget.activeSpecifications
            .map((s) => s.toLowerCase())
            .contains(tag.toLowerCase()))
        .length;
    return matches / widget.project.tags.length;
  }

  int get _score => (_fraction * 100).round();

  Color get _scoreColor {
    if (_score >= 80) return AppTheme.forestEmerald;      // Premium Green
    if (_score >= 50) return const Color(0xFFFBBF24);       // Amber
    return Colors.white.withValues(alpha: 0.15);            // Muted, frosted grey
  }

  Widget _buildMatchScoreIndicator() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _scoreColor.withValues(alpha: 0.1),
        boxShadow: [
          BoxShadow(
            color: _scoreColor.withValues(alpha: _score >= 50 ? 0.2 : 0.0),
            blurRadius: 10,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: CircularProgressIndicator(
              value: _fraction,
              strokeWidth: 3.5,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(_scoreColor),
            ),
          ),
          Text(
            '$_score%',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkButton() {
    return Consumer<ShortlistProvider>(
      builder: (context, shortlistProvider, child) {
        final isShortlisted = shortlistProvider.isShortlisted(widget.project.id);
        
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.lightImpact();
            shortlistProvider.toggleShortlist(widget.project.id);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isShortlisted 
                  ? const Color(0xFFFBBF24).withValues(alpha: 0.15) 
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isShortlisted 
                    ? const Color(0xFFFBBF24).withValues(alpha: 0.3) 
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isShortlisted ? Icons.bookmark : Icons.bookmark_border,
                key: ValueKey<bool>(isShortlisted),
                color: isShortlisted ? const Color(0xFFFBBF24) : Colors.white54,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }

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
                          const SizedBox(width: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildBookmarkButton(),
                              const SizedBox(width: 10),
                              _buildMatchScoreIndicator(),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ANONYMOUS STUDENT GROUP',
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
      onTap: _isMatching ? null : () async {
        setState(() => _isMatching = true);
        await widget.onMatch();
        if (mounted) setState(() => _isMatching = false);
      },
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
          child: _isMatching 
            ? const SizedBox(
                width: 20, 
                height: 20, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              )
            : Text(
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

// ─────────────────────────────────────────────────────────────────────────────
//  SESSION WARNING OVERLAY
// ─────────────────────────────────────────────────────────────────────────────

class _SessionWarningOverlay extends StatefulWidget {
  final String countdownText;
  final VoidCallback onExtend;
  final Future<void> Function() onLogoutNow;

  const _SessionWarningOverlay({
    required this.countdownText,
    required this.onExtend,
    required this.onLogoutNow,
  });

  @override
  State<_SessionWarningOverlay> createState() => _SessionWarningOverlayState();
}

class _SessionWarningOverlayState extends State<_SessionWarningOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  bool _logoutInProgress = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutQuart),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      // Semi-transparent frosted full-screen backdrop
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _buildCard(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1F14).withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFFFAA00).withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFAA00).withValues(alpha: 0.12),
                blurRadius: 40,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFAA00).withValues(alpha: 0.12),
                  border: Border.all(
                    color: const Color(0xFFFFAA00).withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.lock_clock_outlined,
                  color: Color(0xFFFFAA00),
                  size: 28,
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(
                    begin: 1.0,
                    end: 1.08,
                    duration: 1200.ms,
                    curve: Curves.easeInOut,
                  ),

              const SizedBox(height: 20),

              // Title
              Text(
                'Session Expiring Soon',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.95),
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'You\'ve been inactive for 30 minutes.\nYou will be automatically signed out in:',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  height: 1.55,
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 24),

              // Countdown display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFFFAA00).withValues(alpha: 0.08),
                  border: Border.all(
                    color: const Color(0xFFFFAA00).withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  widget.countdownText,
                  style: GoogleFonts.montserrat(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFFAA00),
                    letterSpacing: 4,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Extend Session button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _logoutInProgress ? null : widget.onExtend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.forestEmerald,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.refresh_rounded,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Extend Session',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Logout Now link
              GestureDetector(
                onTap: _logoutInProgress
                    ? null
                    : () async {
                        setState(() => _logoutInProgress = true);
                        await widget.onLogoutNow();
                      },
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _logoutInProgress ? 0.4 : 1.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: _logoutInProgress
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFFF4545),
                            ),
                          )
                        : Text(
                            'Sign out now',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFF4545).withValues(
                                alpha: 0.75,
                              ),
                              decoration: TextDecoration.underline,
                              decorationColor: const Color(
                                0xFFFF4545,
                              ).withValues(alpha: 0.4),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
