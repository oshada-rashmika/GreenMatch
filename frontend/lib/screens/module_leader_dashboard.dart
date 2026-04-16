import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/login_design.dart';
import '../services/auth_service.dart';
import '../services/module_leader_service.dart';

enum _ModuleLeaderSection { overview, researchAreas, projectAllocations }

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
  late Future<_OverviewViewModel> _overviewFuture;
  late Future<List<ModuleLeaderTag>> _tagsFuture;
  late Future<List<ModuleLeaderProject>> _projectsFuture;
  bool _isCreatingTag = false;
  _ProjectAllocationFilter _projectFilter = _ProjectAllocationFilter.all;

  static const double _sidebarWidth = 288;
  static const double _wideLayoutBreakpoint = 1040;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _moduleLeaderService = ModuleLeaderService();
    _overviewFuture = _loadOverviewData();
    _tagsFuture = _loadTagsData();
    _projectsFuture = _loadProjectsData();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.monochromeTheme,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWideLayout = constraints.maxWidth >= _wideLayoutBreakpoint;

          return Scaffold(
            backgroundColor: LoginColors.background,
            appBar: isWideLayout
                ? null
                : AppBar(
                    backgroundColor: LoginColors.surface,
                    elevation: 0,
                    title: Text(
                      'Module Leader',
                      style: LoginTypography.label.copyWith(fontSize: 16),
                    ),
                  ),
            drawer: isWideLayout
                ? null
                : Drawer(
                    backgroundColor: LoginColors.surface,
                    child: SafeArea(child: _buildSidebar(compact: true)),
                  ),
            body: SafeArea(
              child: isWideLayout
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          _buildSidebar(),
                          const SizedBox(width: 20),
                          Expanded(child: _buildMainContent()),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildMainContent(),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSidebar({bool compact = false}) {
    return Container(
      width: compact ? null : _sidebarWidth,
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(compact ? 0 : 24),
        border: Border.all(color: LoginColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: LoginColors.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: LoginColors.surface,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Module Leader',
                        style: LoginTypography.label.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Administrative Control Center',
                        style: LoginTypography.body.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Navigation',
              style: LoginTypography.label.copyWith(
                color: LoginColors.textSecondary,
                fontSize: 12,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            _buildNavItem(
              title: 'Overview',
              subtitle: 'System Health',
              icon: Icons.dashboard_outlined,
              section: _ModuleLeaderSection.overview,
            ),
            _buildNavItem(
              title: 'Research Areas',
              subtitle: 'Tags',
              icon: Icons.sell_outlined,
              section: _ModuleLeaderSection.researchAreas,
            ),
            _buildNavItem(
              title: 'Project Allocations',
              subtitle: 'Assignments',
              icon: Icons.assignment_ind_outlined,
              section: _ModuleLeaderSection.projectAllocations,
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LoginColors.panel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: LoginColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Context',
                    style: LoginTypography.label.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Switch between oversight, tagging, and allocation tasks without losing your place.',
                    style: LoginTypography.body.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required _ModuleLeaderSection section,
  }) {
    final isSelected = _selectedSection == section;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedSection = section;
          });
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? LoginColors.panel : LoginColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? LoginColors.borderActive : LoginColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? LoginColors.accent
                    : LoginColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: LoginTypography.label.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: LoginTypography.body.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: LoginColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
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
        decoration: BoxDecoration(
          color: LoginColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: LoginColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
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
                style: LoginTypography.headline.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: LoginTypography.body.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: LoginColors.panel,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: LoginColors.border),
          ),
          child: Text(
            'Live administrative view',
            style: LoginTypography.label.copyWith(fontSize: 12),
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
    };
  }

  Widget _buildOverviewContent() {
    return FutureBuilder<_OverviewViewModel>(
      future: _overviewFuture,
      builder: (context, snapshot) {
        final viewModel = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting ||
            viewModel == null) {
          return _buildOverviewSkeleton();
        }

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
                    _MetricCard(
                      title: 'Total Projects',
                      value: viewModel.statistics.totalProjects.toString(),
                      detail: 'All active and pending project records',
                      width: _metricWidth(constraints.maxWidth, columns),
                    ),
                    _MetricCard(
                      title: 'Pending Blind Matches',
                      value: viewModel.statistics.pendingBlindMatches
                          .toString(),
                      detail: 'Projects waiting for blind review assignment',
                      width: _metricWidth(constraints.maxWidth, columns),
                    ),
                    _MetricCard(
                      title: 'Ghosted/Missed Meetings',
                      value: viewModel.statistics.ghostedMissedMeetings
                          .toString(),
                      detail: 'Meetings that require immediate follow-up',
                      accentColor: LoginColors.error,
                      width: _metricWidth(constraints.maxWidth, columns),
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
                  Text(
                    'Project groups with a meeting status of MISSED',
                    style: LoginTypography.body.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  _ActionRequiredTable(items: viewModel.actionRequiredGroups),
                ],
              ),
            ),
          ],
        );
      },
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
                    'Current Tags in the System',
                    style: LoginTypography.body.copyWith(fontSize: 13),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isCreatingTag ? null : _showCreateTagSheet,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Research Area'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SectionPanel(
              title: 'Tag Catalog',
              child: _TagsPaginatedTable(tags: tags),
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
              color: LoginColors.surface,
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
                  decoration: const InputDecoration(
                    labelText: 'Tag name',
                    hintText: 'Machine Learning',
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
                      child: const Text('Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    controller.dispose();
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
          child: Column(
            children: List.generate(
              5,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: index == 4 ? 0 : 10),
                child: const _TagTableSkeletonRow(),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: LoginColors.panel,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: LoginColors.border),
                  ),
                  child: Text(
                    '${filteredProjects.length} records',
                    style: LoginTypography.label.copyWith(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SectionPanel(
              title: 'Allocation Queue',
              child: _ProjectsPaginatedTable(projects: filteredProjects),
            ),
          ],
        );
      },
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

  List<ModuleLeaderProject> _filteredProjects(List<ModuleLeaderProject> projects) {
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
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.detail,
    required this.width,
    this.accentColor,
  });

  final String title;
  final String value;
  final String detail;
  final double width;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width < 220 ? double.infinity : width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor ?? LoginColors.border),
        boxShadow: [
          BoxShadow(
            color: (accentColor ?? LoginColors.shadow).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: LoginTypography.body.copyWith(fontSize: 12)),
          const SizedBox(height: 10),
          Text(
            value,
            style: LoginTypography.headline.copyWith(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: accentColor ?? LoginColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(detail, style: LoginTypography.body.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}

class _TagsPaginatedTable extends StatelessWidget {
  const _TagsPaginatedTable({required this.tags});

  final List<ModuleLeaderTag> tags;

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable(
      header: Text(
        'All Tags',
        style: LoginTypography.label.copyWith(fontSize: 14),
      ),
      rowsPerPage: tags.length < 10 ? tags.length.clamp(1, 10) : 10,
      availableRowsPerPage: const [5, 10, 20],
      columns: const [
        DataColumn(label: Text('Tag')),
        DataColumn(label: Text('Tag ID')),
      ],
      source: _TagsDataSource(tags),
      columnSpacing: 32,
      showCheckboxColumn: false,
      horizontalMargin: 20,
    );
  }
}

class _ProjectsPaginatedTable extends StatelessWidget {
  const _ProjectsPaginatedTable({required this.projects});

  final List<ModuleLeaderProject> projects;

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: LoginColors.panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LoginColors.border),
        ),
        child: Text(
          'No projects match the selected filter.',
          style: LoginTypography.body.copyWith(fontSize: 13),
        ),
      );
    }

    return PaginatedDataTable(
      header: Text(
        'All Projects',
        style: LoginTypography.label.copyWith(fontSize: 14),
      ),
      rowsPerPage: projects.length < 10 ? projects.length.clamp(1, 10) : 10,
      availableRowsPerPage: const [5, 10, 20],
      columns: const [
        DataColumn(label: Text('Project Title')),
        DataColumn(label: Text('Module')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Supervisor')),
      ],
      source: _ProjectsDataSource(projects),
      columnSpacing: 28,
      showCheckboxColumn: false,
      horizontalMargin: 20,
    );
  }
}

class _ProjectsDataSource extends DataTableSource {
  _ProjectsDataSource(this.projects);

  final List<ModuleLeaderProject> projects;

  @override
  DataRow? getRow(int index) {
    if (index >= projects.length) return null;
    final project = projects[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          Text(project.title, style: LoginTypography.label.copyWith(fontSize: 13)),
        ),
        DataCell(
          Text(
            project.moduleCode.isNotEmpty ? project.moduleCode : '—',
            style: LoginTypography.body.copyWith(fontSize: 12),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: project.isMatched
                  ? LoginColors.accent.withValues(alpha: 0.08)
                  : LoginColors.panel,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: project.isMatched
                    ? LoginColors.accent
                    : LoginColors.border,
              ),
            ),
            child: Text(
              project.status,
              style: LoginTypography.label.copyWith(
                fontSize: 11,
                color: project.isMatched
                    ? LoginColors.accent
                    : LoginColors.textPrimary,
              ),
            ),
          ),
        ),
        DataCell(
          Text(
            project.isMatched
                ? (project.supervisorName ?? 'Unassigned')
                : 'Unassigned',
            style: LoginTypography.body.copyWith(fontSize: 12),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => projects.length;

  @override
  int get selectedRowCount => 0;
}

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

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: enabled
          ? (_) => onChanged(filter)
          : null,
      selectedColor: LoginColors.panel,
      backgroundColor: LoginColors.surface,
      labelStyle: LoginTypography.label.copyWith(
        fontSize: 12,
        color: isSelected ? LoginColors.accent : LoginColors.textSecondary,
      ),
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? LoginColors.borderActive : LoginColors.border,
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
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LoginColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: LoginColors.panel,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: LoginColors.panel,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                color: LoginColors.panel,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: LoginColors.panel,
                borderRadius: BorderRadius.circular(999),
              ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LoginColors.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LoginColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: LoginTypography.body.copyWith(fontSize: 13)),
          const SizedBox(height: 14),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _TagsDataSource extends DataTableSource {
  _TagsDataSource(this.tags);

  final List<ModuleLeaderTag> tags;

  @override
  DataRow? getRow(int index) {
    if (index >= tags.length) return null;
    final tag = tags[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          Text(tag.name, style: LoginTypography.label.copyWith(fontSize: 13)),
        ),
        DataCell(
          Text(tag.id, style: LoginTypography.body.copyWith(fontSize: 12)),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => tags.length;

  @override
  int get selectedRowCount => 0;
}

class _TagTableSkeletonRow extends StatelessWidget {
  const _TagTableSkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: LoginColors.panel,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: LoginColors.surface,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: LoginColors.surface,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricSkeleton extends StatelessWidget {
  const _MetricSkeleton({required this.width, this.isCritical = false});

  final double width;
  final bool isCritical;

  @override
  Widget build(BuildContext context) {
    final borderColor = isCritical ? LoginColors.error : LoginColors.border;

    return Container(
      width: width < 220 ? double.infinity : width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 10,
            decoration: BoxDecoration(
              color: LoginColors.panel,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: 64,
            height: 30,
            decoration: BoxDecoration(
              color: LoginColors.panel,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 10,
            decoration: BoxDecoration(
              color: LoginColors.panel,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRequiredTable extends StatelessWidget {
  const _ActionRequiredTable({required this.items});

  final List<ModuleLeaderActionRequiredGroup> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: LoginColors.panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LoginColors.border),
        ),
        child: Text(
          'No MISSED meetings at the moment.',
          style: LoginTypography.body.copyWith(fontSize: 13),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 720),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: LoginColors.panel,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: LoginColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Project Group',
                      style: LoginTypography.label.copyWith(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Meeting Date',
                      style: LoginTypography.label.copyWith(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Status',
                      style: LoginTypography.label.copyWith(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Supervisor',
                      style: LoginTypography.label.copyWith(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: LoginColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: LoginColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.groupName?.isNotEmpty == true
                                  ? item.groupName!
                                  : 'Group ${item.groupId}',
                              style: LoginTypography.label.copyWith(
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.projectTitle.isNotEmpty
                                  ? item.projectTitle
                                  : 'Project title unavailable',
                              style: LoginTypography.body.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.meetingDate == null
                              ? 'TBD'
                              : item.meetingDate!
                                    .toLocal()
                                    .toIso8601String()
                                    .split('T')
                                    .first,
                          style: LoginTypography.body.copyWith(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: LoginColors.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: LoginColors.error),
                          ),
                          child: Text(
                            item.meetingStatus,
                            textAlign: TextAlign.center,
                            style: LoginTypography.label.copyWith(
                              fontSize: 11,
                              color: LoginColors.error,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.supervisorName ?? 'Unassigned',
                          style: LoginTypography.body.copyWith(fontSize: 12),
                        ),
                      ),
                    ],
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

class _TableSkeletonRow extends StatelessWidget {
  const _TableSkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LoginColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: LoginColors.panel,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: LoginColors.panel,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                color: LoginColors.panel,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: LoginColors.panel,
                borderRadius: BorderRadius.circular(999),
              ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LoginColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: LoginTypography.label.copyWith(fontSize: 15)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
