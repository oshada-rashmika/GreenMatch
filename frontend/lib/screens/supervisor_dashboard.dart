import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/mock_project_service.dart';

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
    // 2. Initialization: Instantiate MockProjectService and fetch data
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
    // 4. Match Logic: Add ID to matchedProjectIds and call setState()
    setState(() {
      matchedProjectIds.add(projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Blind Review Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                    ),
                  )
                : _buildProjectList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              selectedColor: AppTheme.primaryGreen.withAlpha(25),
              checkmarkColor: AppTheme.primaryGreen,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryGreen : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : Colors.grey.shade300,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProjectList() {
    final filtered = _filteredProjects;

    if (filtered.isEmpty) {
      return const Center(child: Text("No projects found for this category."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final project = filtered[index];
        final id = project['id'] as String;
        final isMatched = matchedProjectIds.contains(id);

        return _buildProjectCard(project, isMatched);
      },
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project, bool isMatched) {
    final theme = Theme.of(context);
    final techStack = project['techStack'] as List<dynamic>;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project['title'],
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    project['researchArea'],
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              project['abstract'],
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: techStack.map((tech) {
                return Chip(
                  label: Text(tech, style: const TextStyle(fontSize: 11)),
                  backgroundColor: theme.brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.grey.shade100,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isMatched
                  ? _buildRevealedState()
                  : _buildBlindState(project['id']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlindState(String projectId) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _onMatchConfirmed(projectId),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text(
          "Confirm Match",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildRevealedState() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? Colors.green.withAlpha(40)
        : Colors.green.shade50;
    final borderColor = isDark
        ? Colors.green.withAlpha(100)
        : Colors.green.shade200;
    final textColor = isDark ? Colors.green.shade300 : Colors.green.shade700;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: textColor),
              const SizedBox(width: 8),
              Text(
                "Matched!",
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // 5. Reveal UI Transition: Student contact details
          Text(
            "Student Email: lead.student@university.edu",
            style: TextStyle(color: textColor, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
