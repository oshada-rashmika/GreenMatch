import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../services/shortlist_provider.dart';
import '../services/project_service.dart';
import '../widgets/glass_container.dart';
import 'supervisor_dashboard.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final ProjectService _projectService = ProjectService();
  List<AnonymousProject> _allProjects = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> activeSpecifications = [
    'Artificial Intelligence',
    'Python',
    'TensorFlow',
  ];

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    try {
      final projects = await _projectService.fetchAnonymousProjects();
      if (mounted) {
        setState(() {
          _allProjects = projects;
          _isLoading = false;
        });
      }
    } on ProjectServiceException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onMatchConfirmed(String projectId) async {
    try {
      await _projectService.confirmMatch(projectId);
      if (mounted) {
        setState(() {
          _allProjects.removeWhere((p) => p.id == projectId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Match Successfully Confirmed!',
                    style: TextStyle(color: Colors.white, fontSize: 13),
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
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Failed to match project. Please try again.',
                    style: TextStyle(color: Colors.white, fontSize: 13),
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
              onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(context),
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
              child: Consumer<ShortlistProvider>(
                builder: (context, shortlistProvider, child) {
                  final List<AnonymousProject> bookmarkedProjects = _allProjects
                      .where((p) => shortlistProvider.isShortlisted(p.id))
                      .toList();

                  return AnimatedSwitcher(
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
                    child: _isLoading
                        ? const Center(
                            key: ValueKey('loading'),
                            child: CircularProgressIndicator(color: AppTheme.forestEmerald),
                          )
                        : _errorMessage != null
                            ? _buildErrorState(_errorMessage!)
                            : bookmarkedProjects.isEmpty
                                ? _buildEmptyState()
                                : _buildBentoGrid(bookmarkedProjects),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: GlassContainer(
        borderRadius: 0,
        opacity: 0.02,
        blur: 15,
        borderColor: Colors.transparent,
        child: AppBar(
          centerTitle: false,
          leading: IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                color: Colors.white.withValues(alpha: 0.05),
              ),
              child: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.white),
            ),
          ),
          title: Text(
            "Bookmarks",
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              fontSize: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox.expand(
      child: Container(
        key: const ValueKey('empty_bookmarks'),
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFBBF24).withValues(alpha: 0.05),
                border: Border.all(
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.1),
                ),
              ),
              child: Icon(
                Icons.bookmark_rounded,
                size: 80,
                color: const Color(0xFFFBBF24).withValues(alpha: 0.4),
              ),
            )
            .animate()
            .fadeIn(duration: 800.ms)
            .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
            const SizedBox(height: 32),
            Text(
              "Your Shortlist is Empty",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white.withValues(alpha: 0.9),
                letterSpacing: -0.5,
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            const SizedBox(height: 16),
            Text(
              "Explore available projects and bookmark them to review later.",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
            const SizedBox(height: 48),
            InkWell(
              onTap: () => Navigator.pop(context),
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
                  color: AppTheme.forestEmerald.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.forestEmerald.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  "Explore Projects",
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

  Widget _buildBentoGrid(List<AnonymousProject> projects) {
    return LayoutBuilder(
      key: const ValueKey('bookmarks_grid'),
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 900
            ? 3
            : (constraints.maxWidth > 600 ? 2 : 1);

        return MasonryGridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return ProjectCard(
              project: project,
              index: index,
              activeSpecifications: activeSpecifications,
              isMatched: false,
              onMatch: () => _onMatchConfirmed(project.id),
            );
          },
        );
      },
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
}
