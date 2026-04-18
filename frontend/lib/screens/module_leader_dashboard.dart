import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'profile_screen.dart';

import '../theme/app_theme.dart';
import '../theme/login_design.dart';
import '../services/auth_provider.dart';
import '../services/auth_service.dart';
import '../services/module_leader_service.dart';
import '../services/guideline_service.dart';
import '../models/guideline.dart';
import '../widgets/glass_container.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'create_guideline_sheet.dart';

enum _ModuleLeaderSection {
  overview,
  researchAreas,
  projectAllocations,
  academicModules,
  guidelines,
}

enum _ProjectAllocationFilter { all, pending, matched }

class ModuleLeaderDashboard extends StatefulWidget {
  const ModuleLeaderDashboard({super.key});

  @override
  State<ModuleLeaderDashboard> createState() => _ModuleLeaderDashboardState();
}

class _ModuleLeaderDashboardState extends State<ModuleLeaderDashboard> {
  _ModuleLeaderSection _selectedSection = _ModuleLeaderSection.overview;
  late final AuthService _authService;
  late final ModuleLeaderService _moduleLeaderService;
  late final GuidelineService _guidelineService;
  late Future<_OverviewViewModel> _overviewFuture;
  late Future<List<ModuleLeaderTag>> _tagsFuture;
  late Future<List<ModuleLeaderProject>> _projectsFuture;
  late Future<ModuleLeaderAcademicModulesPayload> _academicModulesFuture;
  late Future<List<Guideline>> _guidelinesFuture;
  bool _isCreatingTag = false;
  bool _isCreatingModule = false;
  bool _isAssigningSupervisors = false;
  _ProjectAllocationFilter _projectFilter = _ProjectAllocationFilter.all;

  static const double _sidebarWidth = 288;
  static const double _wideLayoutBreakpoint = 1040;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _moduleLeaderService = ModuleLeaderService();
    _guidelineService = GuidelineService();
    _overviewFuture = _loadOverviewData();
    _tagsFuture = _loadTagsData();
    _projectsFuture = _loadProjectsData();
    _academicModulesFuture = _loadAcademicModulesData();
    _guidelinesFuture = _loadGuidelines();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: AppTheme.premiumBlack,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Module Leader',
            style: LoginTypography.label.copyWith(fontSize: 16),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
                  child: CircleAvatar(
                    backgroundColor: AppTheme.forestEmerald.withValues(alpha: 0.2),
                    child: const Icon(Icons.person, color: AppTheme.forestEmerald),
                  ),
                ),
              ),
            ),
          ],
        ),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTabToggle(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildMainContent(),
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

  Widget _buildTabToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTabButton('Overview', _ModuleLeaderSection.overview),
            _buildTabButton('Research Areas', _ModuleLeaderSection.researchAreas),
            _buildTabButton('Project Allocations', _ModuleLeaderSection.projectAllocations),
            _buildTabButton('Academic Modules', _ModuleLeaderSection.academicModules),
            _buildTabButton('Guidelines', _ModuleLeaderSection.guidelines),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, _ModuleLeaderSection section) {
    bool isSelected = _selectedSection == section;
    return GestureDetector(
      onTap: () => setState(() => _selectedSection = section),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.forestEmerald : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
    );
  }



  Widget _buildMainContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: Container(
        key: ValueKey(_selectedSection),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSectionContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final (title, subtitle) = switch (_selectedSection) {
      _ModuleLeaderSection.overview => (
        'Overview',
        'System health at a glance.',
      ),
      _ModuleLeaderSection.researchAreas => (
        'Research Areas',
        'Maintain the canonical set of project tags.',
      ),
      _ModuleLeaderSection.projectAllocations => (
        'Project Allocations',
        'Review and adjust faculty or student assignments.',
      ),
      _ModuleLeaderSection.academicModules => (
        'Academic Modules',
        'Create modules and manage supervisor assignment.',
      ),
      _ModuleLeaderSection.guidelines => (
        'Guidelines',
        'Manage and distribute formatting rules and university guidelines.',
      ),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        if (_selectedSection == _ModuleLeaderSection.guidelines)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: _buildCreateGuidelineButton(),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.forestEmerald.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppTheme.forestEmerald.withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.admin_panel_settings, color: AppTheme.forestEmerald, size: 16),
                SizedBox(width: 8),
                Text(
                  'Live Administrative View',
                  style: TextStyle(
                    color: AppTheme.forestEmerald,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSectionContent() {
    return switch (_selectedSection) {
      _ModuleLeaderSection.overview => _buildOverviewContent(),
      _ModuleLeaderSection.researchAreas => _buildResearchAreasContent(),
      _ModuleLeaderSection.projectAllocations =>
        _buildProjectAllocationsContent(),
      _ModuleLeaderSection.academicModules => _buildAcademicModulesContent(),
      _ModuleLeaderSection.guidelines => _buildGuidelinesContent(),
    };
  }

  Widget _buildGuidelinesContent() {
    return FutureBuilder<List<Guideline>>(
      future: _guidelinesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.forestEmerald));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
        }

        final guidelines = snapshot.data ?? [];
        if (guidelines.isEmpty) {
          return _buildGuidelinesEmptyState();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 850;
            return MasonryGridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isDesktop ? 3 : 1,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              itemCount: guidelines.length,
              itemBuilder: (context, index) {
                return _GuidelineCard(guideline: guidelines[index]);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOverviewContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<_OverviewViewModel>(
            future: _overviewFuture,
            builder: (context, snapshot) {
              final viewModel = snapshot.data;
              if (snapshot.connectionState == ConnectionState.waiting || viewModel == null) {
                return _buildOverviewSkeleton();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 900 ? 3 : constraints.maxWidth >= 620 ? 2 : 1;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _MetricCard(
                            title: 'TOTAL PROJECTS',
                            value: viewModel.statistics.totalProjects.toString(),
                            detail: 'All active and pending records',
                            width: _metricWidth(constraints.maxWidth, columns),
                            accentColor: const Color(0xFF6366F1),
                            iconData: Icons.folder_open_rounded,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) => FutureBuilder<List<ModuleLeaderProject>>(
                                  future: _projectsFuture,
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return SizedBox(
                                        height: MediaQuery.of(context).size.height * 0.85,
                                        child: const Center(child: CircularProgressIndicator(color: AppTheme.forestEmerald)),
                                      );
                                    }
                                    return _SmartProjectsPopup(
                                      projects: snapshot.data!,
                                      title: 'Total Projects',
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          _MetricCard(
                            title: 'PENDING BLIND MATCHES',
                            value: viewModel.statistics.pendingBlindMatches.toString(),
                            detail: 'Waiting for blind review assignment',
                            width: _metricWidth(constraints.maxWidth, columns),
                            accentColor: AppTheme.forestEmerald,
                            iconData: Icons.shield_outlined,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) => FutureBuilder<List<ModuleLeaderProject>>(
                                  future: _projectsFuture,
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return SizedBox(
                                        height: MediaQuery.of(context).size.height * 0.85,
                                        child: const Center(child: CircularProgressIndicator(color: AppTheme.forestEmerald)),
                                      );
                                    }
                                    final pendingProjects = snapshot.data!.where((p) => p.status.toUpperCase() == 'PENDING').toList();
                                    return _SmartProjectsPopup(
                                      projects: pendingProjects,
                                      title: 'Pending Matches',
                                      onRunAutoMatch: _executeGodModeMatcher,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          _MetricCard(
                            title: 'GHOSTED MEETINGS',
                            value: viewModel.statistics.ghostedMissedMeetings.toString(),
                            detail: 'Requires immediate follow-up',
                            accentColor: const Color(0xFFEF4444), // Red
                            width: _metricWidth(constraints.maxWidth, columns),
                            iconData: Icons.warning_amber_rounded,
                            onTap: () {},
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _SectionPanel(
                    title: 'Action Required',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Project groups directly escalating MISSED meeting statuses.',
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        _ActionRequiredTable(items: viewModel.actionRequiredGroups),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          FutureBuilder<ModuleLeaderAcademicModulesPayload>(
             future: _academicModulesFuture,
             builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                   return _buildAcademicModulesSkeleton();
                }
                final payload = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionPanel(
                       title: 'ACADEMIC MODULES',
                       child: SizedBox(
                          height: 180,
                          child: ListView.separated(
                             scrollDirection: Axis.horizontal,
                             itemCount: payload.modules.length,
                             separatorBuilder: (_, __) => const SizedBox(width: 16),
                             itemBuilder: (context, index) {
                               final module = payload.modules[index];
                               return GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (_) => FutureBuilder<List<ModuleLeaderProject>>(
                                        future: _projectsFuture,
                                        builder: (context, projSnap) {
                                          if (!projSnap.hasData) {
                                            return SizedBox(
                                              height: MediaQuery.of(context).size.height * 0.85,
                                              child: const Center(child: CircularProgressIndicator(color: AppTheme.forestEmerald)),
                                            );
                                          }
                                          final filtered = projSnap.data!.where((p) => p.moduleCode == module.moduleCode).toList();
                                          return _SmartProjectsPopup(
                                            projects: filtered,
                                            title: module.moduleName,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.75,
                                    constraints: const BoxConstraints(maxWidth: 320),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppTheme.forestEmerald.withValues(alpha: 0.12),
                                          const Color(0xFF1E293B).withValues(alpha: 0.4),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(color: AppTheme.forestEmerald.withValues(alpha: 0.2)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.forestEmerald.withValues(alpha: 0.05),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.forestEmerald.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(module.moduleCode, style: const TextStyle(color: AppTheme.forestEmerald, fontWeight: FontWeight.bold, fontSize: 11)),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(module.moduleName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                                        const Spacer(),
                                        Text('${module.batch} • ${module.academicYear}', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                               );
                             },
                          ),
                       ),
                    ),
                    const SizedBox(height: 32),
                    _SectionPanel(
                       title: 'SUPERVISOR POOL',
                       child: SizedBox(
                          height: 110,
                          child: ListView.separated(
                             scrollDirection: Axis.horizontal,
                             itemCount: payload.supervisors.length,
                             separatorBuilder: (_, __) => const SizedBox(width: 16),
                             itemBuilder: (context, index) {
                               final supervisor = payload.supervisors[index];
                               return Container(
                                 width: MediaQuery.of(context).size.width * 0.7,
                                 constraints: const BoxConstraints(maxWidth: 250),
                                 padding: const EdgeInsets.all(12),
                                 decoration: BoxDecoration(
                                   color: Colors.white.withValues(alpha: 0.02),
                                   borderRadius: BorderRadius.circular(30),
                                   border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                 ),
                                 child: Row(
                                   children: [
                                     CircleAvatar(
                                       radius: 20,
                                       backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
                                       child: Text(
                                         supervisor.fullName.substring(0, 1).toUpperCase(),
                                         style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold),
                                       ),
                                     ),
                                     const SizedBox(width: 16),
                                     Expanded(
                                       child: Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         mainAxisAlignment: MainAxisAlignment.center,
                                         children: [
                                           Text(supervisor.fullName, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                           const SizedBox(height: 6),
                                           Text(supervisor.email, style: const TextStyle(color: Colors.white54, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                                         ],
                                       ),
                                     ),
                                   ],
                                 ),
                               );
                             },
                          ),
                       ),
                    ),
                  ],
                );
             }
          ),

          const SizedBox(height: 32),
          
          FutureBuilder<List<ModuleLeaderTag>>(
            future: _tagsFuture,
            builder: (context, snapshot) {
               if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();
               return _SectionPanel(
                 title: 'AVAILABLE RESEARCH TOPICS',
                 child: _TagsMasonryGrid(tags: snapshot.data!),
               );
            }
          ),
          
          const SizedBox(height: 48), // Padding bottom
        ]
      )
    );
  }

  Future<_OverviewViewModel> _loadOverviewData() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      return _OverviewViewModel.fallback();
    }

    try {
      final results = await Future.wait([
        _moduleLeaderService.fetchOverviewStatistics(jwtToken: token),
        _moduleLeaderService.fetchActionRequiredMissedGroups(jwtToken: token),
      ]);

      return _OverviewViewModel(
        statistics: results.first as ModuleLeaderOverviewStatistics,
        actionRequiredGroups:
            results.last as List<ModuleLeaderActionRequiredGroup>,
      );
    } catch (_) {
      return _OverviewViewModel.fallback();
    }
  }

  Widget _buildOverviewSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900
                ? 3
                : constraints.maxWidth >= 620
                ? 2
                : 1;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _MetricSkeleton(
                  width: _metricWidth(constraints.maxWidth, columns),
                ),
                _MetricSkeleton(
                  width: _metricWidth(constraints.maxWidth, columns),
                ),
                _MetricSkeleton(
                  width: _metricWidth(constraints.maxWidth, columns),
                  isCritical: true,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        _SectionPanel(
          title: 'Action Required',
          child: Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: index == 2 ? 0 : 12),
                child: const _TableSkeletonRow(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResearchAreasContent() {
    return FutureBuilder<List<ModuleLeaderTag>>(
      future: _tagsFuture,
      builder: (context, snapshot) {
        final tags = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting ||
            tags == null) {
          return _buildTagsSkeleton();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Categorized Research Boundaries',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                  ),
                ),
                InkWell(
                  onTap: _isCreatingTag ? null : _showCreateTagSheet,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.forestEmerald.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.forestEmerald.withValues(alpha: 0.3)),
                    ),
                    child: _isCreatingTag
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.forestEmerald))
                        : const Row(
                            children: [
                              Icon(Icons.add_circle_outline, color: AppTheme.forestEmerald, size: 18),
                              SizedBox(width: 8),
                              Text('New Tag', style: TextStyle(color: AppTheme.forestEmerald, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionPanel(
              title: 'AVAILABLE RESEARCH TOPICS',
              child: _TagsMasonryGrid(tags: tags),
            ),
          ],
        );
      },
    );
  }

  Future<List<ModuleLeaderTag>> _loadTagsData() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      return _fallbackTags();
    }

    try {
      return await _moduleLeaderService.fetchTags(jwtToken: token);
    } catch (_) {
      return _fallbackTags();
    }
  }

  Future<void> _refreshTags() async {
    setState(() {
      _tagsFuture = _loadTagsData();
    });
  }

  Future<void> _refreshOverviewData() async {
    setState(() {
      _loadOverviewData();
    });
  }

  Future<List<Guideline>> _loadGuidelines() async {
    final authProvider = context.read<AuthProvider>();
    final token = await _authService.getToken();
    final leaderId = authProvider.userId;

    if (token == null || token.isEmpty || leaderId == null || leaderId.isEmpty) {
      return [];
    }

    try {
      return await _guidelineService.fetchGuidelinesForLeader(leaderId);
    } catch (e) {
      debugPrint('Error loading guidelines: $e');
      return [];
    }
  }

  Future<void> _refreshGuidelines() async {
    setState(() {
      _guidelinesFuture = _loadGuidelines();
    });
  }


  Future<void> _executeGodModeMatcher() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) return;

    try {
      final matchesMade = await _moduleLeaderService.runAutoMatchAlgorithm(jwtToken: token);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✨ Algorithm successfully paired $matchesMade orphaned projects!'),
          backgroundColor: AppTheme.forestEmerald,
        ),
      );

      // Force refresh overarching state organically
      _refreshOverviewData();
      _refreshProjects();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to execute auto-matcher pipeline.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _showCreateTagSheet() async {
    final controller = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.premiumBlack,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border.all(color: LoginColors.border),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Research Area',
                  style: LoginTypography.headline.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Create a new tag for the research taxonomy.',
                  style: LoginTypography.body.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Tag name',
                    hintText: 'Machine Learning',
                    labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                    hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.forestEmerald.withValues(alpha: 0.5)),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.03),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.forestEmerald,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: _isCreatingTag
                          ? null
                          : () async {
                              final name = controller.text.trim();
                              if (name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter a tag name.'),
                                  ),
                                );
                                return;
                              }

                              Navigator.of(sheetContext).pop();
                              await _createTag(name);
                            },
                      child: const Text('Create', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      controller.dispose();
    });
  }

  Future<void> _createTag(String name) async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be signed in to add tags.')),
      );
      return;
    }

    setState(() {
      _isCreatingTag = true;
    });

    try {
      await _moduleLeaderService.createTag(jwtToken: token, name: name);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Created "$name" successfully.')));
      await _refreshTags();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create tag: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingTag = false;
        });
      }
    }
  }

  List<ModuleLeaderTag> _fallbackTags() {
    return const [
      ModuleLeaderTag(id: 'tag_001', name: 'Next.js'),
      ModuleLeaderTag(id: 'tag_002', name: 'Machine Learning'),
      ModuleLeaderTag(id: 'tag_003', name: 'Cybersecurity'),
      ModuleLeaderTag(id: 'tag_004', name: 'Flutter'),
      ModuleLeaderTag(id: 'tag_005', name: 'Data Science'),
      ModuleLeaderTag(id: 'tag_006', name: 'Cloud Computing'),
    ];
  }

  Widget _buildTagsSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 160,
            height: 42,
            decoration: BoxDecoration(
              color: LoginColors.panel,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _SectionPanel(
          title: 'Tag Catalog',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              5,
              (index) => Container(
                width: 80 + (index * 15.0),
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectAllocationsContent() {
    return FutureBuilder<List<ModuleLeaderProject>>(
      future: _projectsFuture,
      builder: (context, snapshot) {
        final projects = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting ||
            projects == null) {
          return _buildProjectsSkeleton();
        }

        if (snapshot.hasError) {
          return _SectionPanel(
            title: 'Project Allocations',
            child: _ErrorState(
              message: 'Unable to load project allocations.',
              onRetry: _refreshProjects,
            ),
          );
        }

        final filteredProjects = _filteredProjects(projects);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _ProjectFilterToggle(
                    selectedFilter: _projectFilter,
                    onChanged: (filter) {
                      setState(() {
                        _projectFilter = filter;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.forestEmerald.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppTheme.forestEmerald.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${filteredProjects.length} records',
                      style: const TextStyle(color: AppTheme.forestEmerald, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            _SectionPanel(
              title: 'Allocation Queue',
              child: _ProjectAllocationList(projects: filteredProjects),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAcademicModulesContent() {
    return FutureBuilder<ModuleLeaderAcademicModulesPayload>(
      future: _academicModulesFuture,
      builder: (context, snapshot) {
        final payload = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting ||
            payload == null) {
          return _buildAcademicModulesSkeleton();
        }

        if (snapshot.hasError) {
          return _SectionPanel(
            title: 'Academic Modules',
            child: _ErrorState(
              message: 'Unable to load modules.',
              onRetry: _refreshAcademicModules,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Manage active modules and their supervisor pool.',
                    style: LoginTypography.body.copyWith(fontSize: 13),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isCreatingModule ? null : _showCreateModuleSheet,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create New Module'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SectionPanel(
              title: 'Active Modules',
              child: _AcademicModulesGrid(
                modules: payload.modules,
                availableSupervisors: payload.supervisors,
                onAssignSupervisors: _showAssignSupervisorsSheet,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<ModuleLeaderAcademicModulesPayload> _loadAcademicModulesData() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      return _fallbackAcademicModules();
    }

    try {
      return await _moduleLeaderService.fetchAcademicModules(jwtToken: token);
    } catch (_) {
      return _fallbackAcademicModules();
    }
  }

  Future<void> _refreshAcademicModules() async {
    setState(() {
      _academicModulesFuture = _loadAcademicModulesData();
    });
  }

  Future<void> _showCreateModuleSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _CreateModuleSheetWidget(
          onCreate: (code, name, year, batch, mDate, rDate, midDate, fDate, vDate) async {
            Navigator.of(sheetContext).pop();
            await _createAcademicModule(
              moduleCode: code,
              moduleName: name,
              academicYear: year,
              batch: batch,
              milestoneMatchDate: mDate,
              milestoneReviewDate: rDate,
              milestoneMidtermDate: midDate,
              milestoneFinalDate: fDate,
              milestoneVivaDate: vDate,
            );
          },
        );
      },
    );
  }

  Future<void> _createAcademicModule({
    required String moduleCode,
    required String moduleName,
    required String academicYear,
    required String batch,
    DateTime? milestoneMatchDate,
    DateTime? milestoneReviewDate,
    DateTime? milestoneMidtermDate,
    DateTime? milestoneFinalDate,
    DateTime? milestoneVivaDate,
  }) async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be signed in to create modules.')),
      );
      return;
    }

    setState(() {
      _isCreatingModule = true;
    });

    try {
      await _moduleLeaderService.createAcademicModule(
        jwtToken: token,
        moduleCode: moduleCode,
        moduleName: moduleName,
        academicYear: academicYear,
        batch: batch,
        milestoneMatchDate: milestoneMatchDate,
        milestoneReviewDate: milestoneReviewDate,
        milestoneMidtermDate: milestoneMidtermDate,
        milestoneFinalDate: milestoneFinalDate,
        milestoneVivaDate: milestoneVivaDate,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Created module $moduleCode successfully.')),
      );
      await _refreshAcademicModules();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create module: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingModule = false;
        });
      }
    }
  }

  Future<void> _showAssignSupervisorsSheet(
    ModuleLeaderAcademicModule module,
    List<ModuleLeaderSupervisor> allSupervisors,
  ) async {
    final selectedSupervisorIds = module.assignedSupervisors
        .map((supervisor) => supervisor.id)
        .toSet();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(sheetContext).size.height * 0.72,
              decoration: BoxDecoration(
                color: AppTheme.premiumBlack,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border.all(color: LoginColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assign Supervisors',
                      style: LoginTypography.headline.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${module.moduleCode} • ${module.moduleName}',
                      style: LoginTypography.body.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: allSupervisors.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: LoginColors.panel,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: LoginColors.border),
                              ),
                              child: Text(
                                'No supervisors found in the database.',
                                style: LoginTypography.body.copyWith(fontSize: 13),
                              ),
                            )
                          : ListView.separated(
                              itemCount: allSupervisors.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final supervisor = allSupervisors[index];
                                final isSelected = selectedSupervisorIds.contains(
                                  supervisor.id,
                                );

                                return InkWell(
                                  onTap: () {
                                    setSheetState(() {
                                      if (isSelected) {
                                        selectedSupervisorIds.remove(supervisor.id);
                                      } else {
                                        selectedSupervisorIds.add(supervisor.id);
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? LoginColors.panel
                                          : LoginColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? LoginColors.borderActive
                                            : LoginColors.border,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: isSelected,
                                          onChanged: (_) {
                                            setSheetState(() {
                                              if (isSelected) {
                                                selectedSupervisorIds.remove(
                                                  supervisor.id,
                                                );
                                              } else {
                                                selectedSupervisorIds.add(
                                                  supervisor.id,
                                                );
                                              }
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                supervisor.fullName,
                                                style: LoginTypography.label
                                                    .copyWith(fontSize: 13),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                supervisor.email,
                                                style: LoginTypography.body
                                                    .copyWith(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.forestEmerald,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          onPressed: _isAssigningSupervisors
                              ? null
                              : () async {
                                  Navigator.of(sheetContext).pop();
                                  await _assignSupervisorsToModule(
                                    module.id,
                                    selectedSupervisorIds.toList(),
                                  );
                                },
                          child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _assignSupervisorsToModule(
    String moduleId,
    List<String> supervisorIds,
  ) async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be signed in to assign supervisors.')),
      );
      return;
    }

    setState(() {
      _isAssigningSupervisors = true;
    });

    try {
      await _moduleLeaderService.assignSupervisorsToModule(
        jwtToken: token,
        moduleId: moduleId,
        supervisorIds: supervisorIds,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supervisor assignment updated.')),
      );
      await _refreshAcademicModules();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign supervisors: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAssigningSupervisors = false;
        });
      }
    }
  }

  ModuleLeaderAcademicModulesPayload _fallbackAcademicModules() {
    return const ModuleLeaderAcademicModulesPayload(
      modules: [
        ModuleLeaderAcademicModule(
          id: 'mod_001',
          moduleCode: 'PUSL2020',
          moduleName: 'Software Development Tools',
          academicYear: '2026/2027',
          batch: 'Batch 24',
          assignedSupervisors: [
            ModuleLeaderSupervisor(
              id: 'sup_1',
              fullName: 'Dr. Perera',
              email: 'perera@nsbm.edu',
            ),
          ],
        ),
        ModuleLeaderAcademicModule(
          id: 'mod_002',
          moduleCode: 'PUSL3022',
          moduleName: 'Enterprise Applications',
          academicYear: '2026/2027',
          batch: 'Batch 23',
          assignedSupervisors: [],
        ),
      ],
      supervisors: [
        ModuleLeaderSupervisor(
          id: 'sup_1',
          fullName: 'Dr. Perera',
          email: 'perera@nsbm.edu',
        ),
        ModuleLeaderSupervisor(
          id: 'sup_2',
          fullName: 'Dr. Silva',
          email: 'silva@nsbm.edu',
        ),
      ],
    );
  }

  Widget _buildAcademicModulesSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 180,
            height: 42,
            decoration: BoxDecoration(
              color: LoginColors.panel,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _SectionPanel(
          title: 'Active Modules',
          child: Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: index == 2 ? 0 : 12),
                child: const _ModuleCardSkeleton(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<List<ModuleLeaderProject>> _loadProjectsData() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      return _fallbackProjects();
    }

    try {
      return await _moduleLeaderService.fetchAllProjects(jwtToken: token);
    } catch (_) {
      return _fallbackProjects();
    }
  }

  Future<void> _refreshProjects() async {
    setState(() {
      _projectsFuture = _loadProjectsData();
    });
  }

  List<ModuleLeaderProject> _filteredProjects(
    List<ModuleLeaderProject> projects,
  ) {
    return switch (_projectFilter) {
      _ProjectAllocationFilter.all => projects,
      _ProjectAllocationFilter.pending =>
        projects.where((project) => project.isPending).toList(),
      _ProjectAllocationFilter.matched =>
        projects.where((project) => project.isMatched).toList(),
    };
  }

  List<ModuleLeaderProject> _fallbackProjects() {
    return const [
      ModuleLeaderProject(
        id: 'proj_001',
        title: 'AI-Based Student Support',
        status: 'PENDING',
        moduleCode: 'PUSL2020',
        moduleName: 'Software Development Tools',
        supervisorName: null,
        groupName: 'Group Atlas',
      ),
      ModuleLeaderProject(
        id: 'proj_002',
        title: 'Green Campus Analytics',
        status: 'MATCHED',
        moduleCode: 'PUSL3022',
        moduleName: 'Enterprise Applications',
        supervisorName: 'Dr. Fernando',
        groupName: 'Group Verde',
      ),
    ];
  }

  Widget _buildProjectsSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProjectFilterToggle(
          selectedFilter: _projectFilter,
          onChanged: (_) {},
          enabled: false,
        ),
        const SizedBox(height: 20),
        _SectionPanel(
          title: 'Allocation Queue',
          child: Column(
            children: List.generate(
              4,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: index == 3 ? 0 : 12),
                child: const _ProjectTableSkeletonRow(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _metricWidth(double availableWidth, int columns) {
    final totalSpacing = (columns - 1) * 16;
    return (availableWidth - totalSpacing) / columns;
  }

  Widget _buildCreateGuidelineButton() {
    return InkWell(
      onTap: () async {
        final result = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const CreateGuidelineSheet(),
        );

        if (result == true && mounted) {
          _showGlassSnackBar(context, '🚀 Guideline published & workspace synchronized!');
          _refreshGuidelines();
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.forestEmerald,
              AppTheme.forestEmerald.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.forestEmerald.withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
          border: Border.all(color: Colors.white24),
        ),
        child: const Row(
          children: [
            Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Create New Guideline',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    ).animate().shimmer(duration: 2.seconds, color: Colors.white24);
  }

  Widget _buildGuidelinesEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book, size: 80, color: AppTheme.forestEmerald.withValues(alpha: 0.2)),
          const SizedBox(height: 24),
          const Text(
            'No Guidelines Yet',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your academic guidelines will appear here.',
            style: TextStyle(color: Colors.white54, fontSize: 15),
          ),
        ],
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
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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
}



class _MetricCard extends StatefulWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.detail,
    required this.width,
    super.key,
    this.accentColor,
    this.iconData = Icons.analytics,
    this.onTap,
  });

  final String title;
  final String value;
  final String detail;
  final double width;
  final Color? accentColor;
  final IconData iconData;
  final VoidCallback? onTap;

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _glowAnimation = Tween<double>(begin: 0.15, end: 0.35).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.accentColor ?? const Color(0xFF3B82F6);
    return SizedBox(
      width: widget.width < 220 ? double.infinity : widget.width,
      child: MouseRegion(
        cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) {
          if (widget.onTap != null) {
            setState(() => _isHovered = true);
            _controller.forward();
          }
        },
        onExit: (_) {
          if (widget.onTap != null) {
            setState(() => _isHovered = false);
            _controller.reverse();
          }
        },
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) {
            if (widget.onTap != null) {
              setState(() => _isHovered = true);
              _controller.forward();
            }
          },
          onTapUp: (_) {
            if (widget.onTap != null) {
              setState(() => _isHovered = false);
              _controller.reverse();
            }
          },
          onTapCancel: () {
            if (widget.onTap != null) {
              setState(() => _isHovered = false);
              _controller.reverse();
            }
          },
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        effectiveColor.withValues(alpha: _isHovered ? 0.2 : 0.12),
                        const Color(0xFF0F172A),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: effectiveColor.withValues(alpha: _glowAnimation.value + 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: effectiveColor.withValues(alpha: _isHovered ? 0.15 : 0.05),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -15,
                        bottom: -15,
                        child: Transform.rotate(
                          angle: -0.2,
                          child: Icon(
                            widget.iconData,
                            size: 110,
                            color: effectiveColor.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: effectiveColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(widget.iconData, color: effectiveColor, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.title.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  widget.value,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: MediaQuery.of(context).size.width < 600 ? 40 : 48,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.0,
                                    shadows: [
                                      Shadow(
                                        color: effectiveColor.withValues(alpha: _glowAnimation.value * 2),
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: LoginColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                              ),
                              child: Text(
                                widget.detail,
                                style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TagsMasonryGrid extends StatelessWidget {
  const _TagsMasonryGrid({required this.tags});

  final List<ModuleLeaderTag> tags;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: const Text('No tags currently populate the system.', style: TextStyle(color: Colors.white54)),
      );
    }
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tag, color: Color(0xFF818CF8), size: 14),
              const SizedBox(width: 4),
              Text(
                tag.name,
                style: const TextStyle(
                  color: Color(0xFFE0E7FF),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ProjectAllocationList extends StatelessWidget {
  const _ProjectAllocationList({required this.projects});

  final List<ModuleLeaderProject> projects;

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: const Text('No projects match the selected filter.', style: TextStyle(color: Colors.white54)),
      );
    }

    return Column(
      children: projects.map((project) {
        final bool isPending = project.status.toUpperCase() == 'PENDING';
        final Color statusColor = isPending ? const Color(0xFFEAB308) : AppTheme.forestEmerald;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: 20,
            opacity: 0.02,
            borderColor: Colors.white.withValues(alpha: 0.05),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPending ? Icons.pending_actions_rounded : Icons.check_circle_rounded, 
                        color: statusColor, 
                        size: 20
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.title,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${project.moduleCode} - ${project.moduleName}',
                            style: const TextStyle(color: Colors.white54, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        project.status,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Supervisor', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              project.supervisorName ?? 'Unassigned',
                              style: TextStyle(
                                color: project.supervisorName == null ? const Color(0xFFEF4444) : Colors.white,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.white.withValues(alpha: 0.1),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Group', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              project.groupName ?? 'No Group',
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AcademicModulesGrid extends StatelessWidget {
  const _AcademicModulesGrid({
    required this.modules,
    required this.availableSupervisors,
    required this.onAssignSupervisors,
  });

  final List<ModuleLeaderAcademicModule> modules;
  final List<ModuleLeaderSupervisor> availableSupervisors;
  final Future<void> Function(
    ModuleLeaderAcademicModule module,
    List<ModuleLeaderSupervisor> supervisors,
  )
  onAssignSupervisors;

  @override
  Widget build(BuildContext context) {
    if (modules.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: const Text('No modules found. Create your first module to begin.', style: TextStyle(color: Colors.white54, fontSize: 13)),
      );
    }

    return Column(
      children: modules.map((module) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            borderRadius: 20,
            opacity: 0.03,
            borderColor: AppTheme.forestEmerald.withValues(alpha: 0.15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.forestEmerald.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.school_rounded, color: AppTheme.forestEmerald, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            module.moduleCode,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Montserrat'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      module.moduleName,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.forestEmerald.withValues(alpha: 0.15),
                          foregroundColor: AppTheme.forestEmerald,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          side: BorderSide(color: AppTheme.forestEmerald.withValues(alpha: 0.3)),
                        ),
                        onPressed: () => onAssignSupervisors(module, availableSupervisors),
                        icon: const Icon(Icons.group_add_rounded, size: 16),
                        label: const Text('Assign Supervisors'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetaPill(icon: Icons.calendar_today_rounded, label: 'Year ${module.academicYear}'),
                    _MetaPill(icon: Icons.people_alt_rounded, label: 'Batch ${module.batch}'),
                    _MetaPill(icon: Icons.assignment_ind_rounded, label: '${module.assignedSupervisors.length} Faculty Assigned'),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 16),
                const Text('ASSIGNED SUPERVISORS', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 12),
                if (module.assignedSupervisors.isEmpty)
                  const Text('No faculty members assigned to this module.', style: TextStyle(color: Colors.white38, fontSize: 13, fontStyle: FontStyle.italic))
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: module.assignedSupervisors.map((supervisor) {
                      return IntrinsicWidth(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.white12,
                                child: Icon(Icons.person, size: 12, color: Colors.white54),
                              ),
                              const SizedBox(width: 8),
                              Text(supervisor.fullName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white54, size: 14),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ModuleCardSkeleton extends StatelessWidget {
  const _ModuleCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 140, height: 20, color: Colors.white.withValues(alpha: 0.05)),
          const SizedBox(height: 12),
          Container(width: 240, height: 14, color: Colors.white.withValues(alpha: 0.05)),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                 width: 80, height: 32, 
                 decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white.withValues(alpha: 0.05)),
              ),
              const SizedBox(width: 12),
              Container(
                 width: 80, height: 32, 
                 decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white.withValues(alpha: 0.05)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Legacy data sources stripped.

class _ProjectFilterToggle extends StatelessWidget {
  const _ProjectFilterToggle({
    required this.selectedFilter,
    required this.onChanged,
    this.enabled = true,
  });

  final _ProjectAllocationFilter selectedFilter;
  final ValueChanged<_ProjectAllocationFilter> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildFilterChip('All', _ProjectAllocationFilter.all),
        _buildFilterChip('Pending (Blind)', _ProjectAllocationFilter.pending),
        _buildFilterChip('Matched', _ProjectAllocationFilter.matched),
      ],
    );
  }

  Widget _buildFilterChip(String label, _ProjectAllocationFilter filter) {
    final isSelected = selectedFilter == filter;

    return InkWell(
      onTap: enabled ? () => onChanged(filter) : null,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.forestEmerald : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [BoxShadow(color: AppTheme.forestEmerald.withValues(alpha: 0.3), blurRadius: 10)] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ProjectTableSkeletonRow extends StatelessWidget {
  const _ProjectTableSkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: 220, color: Colors.white.withValues(alpha: 0.05)),
                const SizedBox(height: 8),
                Container(height: 10, width: 140, color: Colors.white.withValues(alpha: 0.05)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      opacity: 0.05,
      blur: 20,
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      borderColor: const Color(0xFFEF4444).withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 48),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white70, fontSize: 13), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.2),
              foregroundColor: const Color(0xFFEF4444),
              elevation: 0,
            ),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry Connection'),
          ),
        ],
      ),
    );
  }
}

// Legacy skeleton stripped.

class _MetricSkeleton extends StatelessWidget {
  const _MetricSkeleton({required this.width, this.isCritical = false});

  final double width;
  final bool isCritical;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width < 220 ? double.infinity : width,
      height: 180,
      child: GlassContainer(
        opacity: 0.02,
        blur: 10,
        borderRadius: 24,
        borderColor: Colors.white.withValues(alpha: 0.05),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 100, height: 16, color: Colors.white.withValues(alpha: 0.05)),
            const SizedBox(height: 24),
            Container(width: 60, height: 40, color: Colors.white.withValues(alpha: 0.05)),
            const Spacer(),
            Container(width: double.infinity, height: 12, color: Colors.white.withValues(alpha: 0.05)),
          ],
        ),
      ),
    );
  }
}
// Formatting cleaned up

class _ActionRequiredTable extends StatelessWidget {
  const _ActionRequiredTable({required this.items});

  final List<ModuleLeaderActionRequiredGroup> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: const Text(
          'No MISSED meetings at the moment.',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
      );
    }

    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: 16,
            opacity: 0.02,
            borderColor: const Color(0xFFEF4444).withValues(alpha: 0.2), // Red outline
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.groupName?.isNotEmpty == true ? item.groupName! : 'Group ${item.groupId}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.projectTitle.isNotEmpty ? item.projectTitle : 'Project title unavailable',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Supervisor', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(item.supervisorName ?? 'Unassigned', style: const TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        item.meetingStatus,
                        style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TableSkeletonRow extends StatelessWidget {
  const _TableSkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: 120, color: Colors.white.withValues(alpha: 0.05)),
                const SizedBox(height: 8),
                Container(height: 10, width: 200, color: Colors.white.withValues(alpha: 0.05)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewViewModel {
  const _OverviewViewModel({
    required this.statistics,
    required this.actionRequiredGroups,
  });

  factory _OverviewViewModel.fallback() {
    return const _OverviewViewModel(
      statistics: ModuleLeaderOverviewStatistics(
        totalProjects: 24,
        pendingBlindMatches: 7,
        ghostedMissedMeetings: 3,
      ),
      actionRequiredGroups: [
        ModuleLeaderActionRequiredGroup(
          groupId: 'grp_1001',
          groupName: 'Group Atlas',
          projectTitle: 'AI-Based Student Support',
          meetingStatus: 'MISSED',
          meetingDate: null,
          supervisorName: 'Dr. Perera',
        ),
        ModuleLeaderActionRequiredGroup(
          groupId: 'grp_1004',
          groupName: 'Group Nova',
          projectTitle: 'Secure Campus Access',
          meetingStatus: 'MISSED',
          meetingDate: null,
          supervisorName: 'Dr. Silva',
        ),
        ModuleLeaderActionRequiredGroup(
          groupId: 'grp_1010',
          groupName: 'Group Verde',
          projectTitle: 'Green Campus Analytics',
          meetingStatus: 'MISSED',
          meetingDate: null,
          supervisorName: 'Dr. Fernando',
        ),
      ],
    );
  }

  final ModuleLeaderOverviewStatistics statistics;
  final List<ModuleLeaderActionRequiredGroup> actionRequiredGroups;
}

class _SectionPanel extends StatelessWidget {
  const _SectionPanel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      opacity: 0.02,
      blur: 20,
      padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 16 : 24),
      borderRadius: 24,
      borderColor: Colors.white.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on_rounded, color: AppTheme.forestEmerald, size: 20),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _CreateModuleSheetWidget extends StatefulWidget {
  final Future<void> Function(
      String code, String name, String year, String batch, DateTime? mDate, DateTime? rDate, DateTime? midDate, DateTime? fDate, DateTime? vDate) onCreate;

  const _CreateModuleSheetWidget({required this.onCreate});

  @override
  State<_CreateModuleSheetWidget> createState() => _CreateModuleSheetWidgetState();
}

class _CreateModuleSheetWidgetState extends State<_CreateModuleSheetWidget> {
  final codeController = TextEditingController();
  final nameController = TextEditingController();
  final yearController = TextEditingController();
  final batchController = TextEditingController();

  DateTime? matchDate;
  DateTime? reviewDate;
  DateTime? midtermDate;
  DateTime? finalDate;
  DateTime? vivaDate;

  @override
  void dispose() {
    codeController.dispose();
    nameController.dispose();
    yearController.dispose();
    batchController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(String label, DateTime? current, Function(DateTime) onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.forestEmerald,
              onPrimary: Colors.white,
              surface: AppTheme.premiumBlack,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => onPicked(picked));
    }
  }

  Widget _buildDatePickerField(String label, DateTime? date, Function(DateTime) onPicked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: () => _pickDate(label, date, onPicked),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              Text(
                date == null ? 'Select Date' : '${date.day}/${date.month}/${date.year}',
                style: TextStyle(
                  color: date == null ? Colors.white38 : AppTheme.forestEmerald,
                  fontWeight: date == null ? FontWeight.normal : FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {bool isAllCaps = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        textCapitalization: isAllCaps ? TextCapitalization.characters : TextCapitalization.none,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.forestEmerald.withValues(alpha: 0.5)),
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.03),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: AppTheme.premiumBlack,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: LoginColors.border),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create New Module', style: LoginTypography.headline.copyWith(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text('Define an academic module and its project milestones.', style: LoginTypography.body.copyWith(fontSize: 13)),
              const SizedBox(height: 20),
              _buildTextField(codeController, 'Module Code', 'PUSL2020', isAllCaps: true),
              _buildTextField(nameController, 'Module Name', 'Software Development Tools'),
              _buildTextField(yearController, 'Academic Year', '2026/2027'),
              _buildTextField(batchController, 'Batch', 'Batch 24'),
              
              const SizedBox(height: 12),
              Text('Project Milestones (Optional)', style: LoginTypography.label.copyWith(fontSize: 14)),
              const SizedBox(height: 8),
              _buildDatePickerField('Supervisor Match Deadline', matchDate, (d) => matchDate = d),
              _buildDatePickerField('Literature Review Due', reviewDate, (d) => reviewDate = d),
              _buildDatePickerField('Mid-term Defense', midtermDate, (d) => midtermDate = d),
              _buildDatePickerField('Final Thesis Submission', finalDate, (d) => finalDate = d),
              _buildDatePickerField('Final Viva Presentation', vivaDate, (d) => vivaDate = d),
              
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.forestEmerald,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      final moduleCode = codeController.text.trim();
                      final moduleName = nameController.text.trim();
                      final academicYear = yearController.text.trim();
                      final batch = batchController.text.trim();
                      if (moduleCode.isEmpty || moduleName.isEmpty || academicYear.isEmpty || batch.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete all text fields.')));
                        return;
                      }
                      widget.onCreate(moduleCode, moduleName, academicYear, batch, matchDate, reviewDate, midtermDate, finalDate, vivaDate);
                    },
                    child: const Text('Create Module', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmartProjectsPopup extends StatefulWidget {
  const _SmartProjectsPopup({
    required this.projects,
    required this.title,
    this.onRunAutoMatch,
    super.key,
  });

  final List<ModuleLeaderProject> projects;
  final String title;
  final Future<void> Function()? onRunAutoMatch;

  @override
  State<_SmartProjectsPopup> createState() => _SmartProjectsPopupState();
}

class _SmartProjectsPopupState extends State<_SmartProjectsPopup> {
  String _selectedModuleCode = 'All';
  bool _isRunningAlgo = false;

  @override
  Widget build(BuildContext context) {
    final Set<String> moduleCodes = {'All'};
    for (var p in widget.projects) {
      if (p.moduleCode.isNotEmpty) {
        moduleCodes.add(p.moduleCode);
      }
    }

    final filteredProjects = widget.projects.where((p) {
      if (_selectedModuleCode == 'All') return true;
      return p.moduleCode == _selectedModuleCode;
    }).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: AppTheme.premiumBlack,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: LoginColors.border),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      Text('${filteredProjects.length} records found', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            if (moduleCodes.length > 1) ...[
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: moduleCodes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final code = moduleCodes.elementAt(index);
                    final isSelected = _selectedModuleCode == code;
                    return InkWell(
                      onTap: () => setState(() => _selectedModuleCode = code),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.forestEmerald : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppTheme.forestEmerald : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            code,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white12, height: 1),
            ],
            
            Expanded(
              child: filteredProjects.isEmpty
                  ? const Center(child: Text('No projects available in this category.', style: TextStyle(color: Colors.white54)))
                  : ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: filteredProjects.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final project = filteredProjects[index];
                        final isPending = project.status.toUpperCase() == 'PENDING';
                        final statusColor = isPending ? const Color(0xFFEAB308) : AppTheme.forestEmerald;
                        
                        return GlassContainer(
                          padding: const EdgeInsets.all(20),
                          borderRadius: 20,
                          opacity: 0.02,
                          borderColor: Colors.white.withValues(alpha: 0.05),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isPending ? Icons.pending_actions_rounded : Icons.check_circle_rounded, 
                                      color: statusColor, 
                                      size: 20
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          project.title,
                                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${project.moduleCode} - ${project.moduleName}',
                                          style: const TextStyle(color: Colors.white54, fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                                    ),
                                    child: Text(
                                      project.status,
                                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.02),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Supervisor', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Text(
                                            project.supervisorName ?? 'Unassigned',
                                            style: TextStyle(
                                              color: project.supervisorName == null ? const Color(0xFFEF4444) : Colors.white,
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 30,
                                      color: Colors.white.withValues(alpha: 0.1),
                                      margin: const EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Group', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Text(
                                            project.groupName ?? 'No Group',
                                            style: const TextStyle(color: Colors.white, fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            if (widget.onRunAutoMatch != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.premiumBlack,
                  border: const Border(top: BorderSide(color: Colors.white12)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.forestEmerald.withValues(alpha: 0.1),
                      blurRadius: 40,
                      offset: const Offset(0, -10),
                    )
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ).copyWith(
                    elevation: WidgetStateProperty.all(0),
                  ),
                  onPressed: _isRunningAlgo 
                    ? null 
                    : () async {
                        setState(() => _isRunningAlgo = true);
                        await widget.onRunAutoMatch!();
                        if (mounted) {
                          setState(() => _isRunningAlgo = false);
                          Navigator.of(context).pop();
                        }
                      },
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.forestEmerald.withValues(alpha: 0.8),
                          const Color(0xFF6366F1).withValues(alpha: 0.8), // Deep Indigo
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      constraints: const BoxConstraints(minHeight: 56),
                      child: _isRunningAlgo
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                              SizedBox(width: 12),
                              Text(
                                'RUN AUTO-MATCH ALGORITHM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
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
}

class _GuidelineCard extends StatelessWidget {
  final Guideline guideline;

  const _GuidelineCard({required this.guideline});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _GuidelineBadge(label: guideline.module?.moduleCode ?? 'N/A'),
                    const Icon(Icons.more_horiz, color: Colors.white38),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  guideline.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.forestEmerald.withValues(alpha: 0.8)),
                    const SizedBox(width: 8),
                    Text(
                      'Due: ${DateFormat('MMM dd, yyyy').format(guideline.deadline)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (guideline.deliverables.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: guideline.deliverables.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FrostedChip(label: entry.key),
                            if (entry.value.trim().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  entry.value,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.68),
                                    fontSize: 12,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

class _GuidelineBadge extends StatelessWidget {
  final String label;

  const _GuidelineBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.forestEmerald.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.forestEmerald.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.forestEmerald.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.forestEmerald,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _FrostedChip extends StatelessWidget {
  final String label;

  const _FrostedChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

