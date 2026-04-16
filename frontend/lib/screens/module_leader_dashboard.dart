import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/login_design.dart';

enum _ModuleLeaderSection { overview, researchAreas, projectAllocations }

class ModuleLeaderDashboard extends StatefulWidget {
  const ModuleLeaderDashboard({super.key});

  @override
  State<ModuleLeaderDashboard> createState() => _ModuleLeaderDashboardState();
}

class _ModuleLeaderDashboardState extends State<ModuleLeaderDashboard> {
  _ModuleLeaderSection _selectedSection = _ModuleLeaderSection.overview;

  static const double _sidebarWidth = 288;
  static const double _wideLayoutBreakpoint = 1040;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900 ? 4 : 2;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _MetricCard(
                  title: 'Active Projects',
                  value: '24',
                  detail: 'Across all research areas',
                  width: _metricWidth(constraints.maxWidth, columns),
                ),
                _MetricCard(
                  title: 'Pending Reviews',
                  value: '7',
                  detail: 'Awaiting your allocation',
                  width: _metricWidth(constraints.maxWidth, columns),
                ),
                _MetricCard(
                  title: 'Research Tags',
                  value: '18',
                  detail: 'Canonical taxonomy items',
                  width: _metricWidth(constraints.maxWidth, columns),
                ),
                _MetricCard(
                  title: 'Open Alerts',
                  value: '3',
                  detail: 'Needs attention today',
                  width: _metricWidth(constraints.maxWidth, columns),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        _SectionPanel(
          title: 'Operational Notes',
          child: Column(
            children: const [
              _InfoRow(label: 'System health', value: 'Stable'),
              _DividerSpacer(),
              _InfoRow(label: 'Latest sync', value: '2 minutes ago'),
              _DividerSpacer(),
              _InfoRow(label: 'Review queue', value: 'Moderate'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResearchAreasContent() {
    final tags = <String>[
      'Artificial Intelligence',
      'Data Science',
      'Cybersecurity',
      'Web & Mobile',
      'Cloud Computing',
      'IoT',
      'Human-Computer Interaction',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionPanel(
          title: 'Current Tag Set',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: tags
                .map(
                  (tag) => Container(
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
                      tag,
                      style: LoginTypography.label.copyWith(fontSize: 12),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        _SectionPanel(
          title: 'Tag Administration',
          child: Column(
            children: const [
              _InfoRow(label: 'Add new tag', value: 'Ready'),
              _DividerSpacer(),
              _InfoRow(label: 'Duplicate checks', value: 'Enabled'),
              _DividerSpacer(),
              _InfoRow(label: 'Review status', value: 'Pending updates'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProjectAllocationsContent() {
    final allocations = <Map<String, String>>[
      {
        'project': 'AI-Based Student Support',
        'owner': 'Dr. Perera',
        'status': 'Assigned',
      },
      {
        'project': 'Secure Campus Access',
        'owner': 'Dr. Silva',
        'status': 'Awaiting review',
      },
      {
        'project': 'Green Campus Analytics',
        'owner': 'Dr. Fernando',
        'status': 'Needs allocation',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionPanel(
          title: 'Allocation Queue',
          child: Column(
            children: allocations
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: LoginColors.panel,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: LoginColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['project'] ?? '',
                                  style: LoginTypography.label.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Owner: ${item['owner']}',
                                  style: LoginTypography.body.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: LoginColors.surface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: LoginColors.border),
                            ),
                            child: Text(
                              item['status'] ?? '',
                              style: LoginTypography.label.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
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
  });

  final String title;
  final String value;
  final String detail;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width < 220 ? double.infinity : width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LoginColors.border),
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
            ),
          ),
          const SizedBox(height: 8),
          Text(detail, style: LoginTypography.body.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: LoginTypography.body.copyWith(fontSize: 13)),
        Text(value, style: LoginTypography.label.copyWith(fontSize: 13)),
      ],
    );
  }
}

class _DividerSpacer extends StatelessWidget {
  const _DividerSpacer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Divider(height: 1, color: LoginColors.border),
    );
  }
}
