import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- MOCK VIEW MODEL ---
class StudentDashboardViewModel extends ChangeNotifier {
  // Toggle this value to test different states: 'Pending', 'Under Review', 'Matched'
  String _currentStatus = 'Matched';

  String get currentStatus => _currentStatus;

  void setStatus(String newStatus) {
    _currentStatus = newStatus;
    notifyListeners();
  }

  // Mock student data
  final String studentName = "Elena Fisher";
  final String studentId = "ST-2026-9482";

  // Mock proposal data
  final String proposalTitle = "AI-Driven Climate Modeling for Urban Microclimates";
  final String abstractSnippet = "This research focuses on leveraging machine learning to predict temperature spikes in dense urban areas, offering actionable insights for city planning and green infrastructure placement...";
  final String researchArea = "Artificial Intelligence";

  // Mock supervisor data (only used when matched)
  final String supervisorName = "Dr. Alan Turing";
  final String supervisorDepartment = "Faculty of Computer Science";
  final String supervisorEmail = "a.turing@university.edu";
}

// --- MAIN SCREEN ---
class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentDashboardViewModel(),
      child: const _StudentDashboardContent(),
    );
  }
}

class _StudentDashboardContent extends StatelessWidget {
  const _StudentDashboardContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StudentDashboardViewModel>();
    final isDesktop = MediaQuery.of(context).size.width > 900;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Subtle light gray background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Project Approval System",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        actions: [
          // Dropdown to toggle status for testing
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: viewModel.currentStatus,
              underline: const SizedBox(),
              items: ['Pending', 'Under Review', 'Matched']
                  .map((e) => DropdownMenuItem(value: e, child: Text("Test: $e")))
                  .toList(),
              onChanged: (val) {
                if (val != null) viewModel.setStatus(val);
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WelcomeHeader(name: viewModel.studentName, id: viewModel.studentId),
                const SizedBox(height: 32),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const StatusBannerWidget(),
                            const SizedBox(height: 24),
                            const ProposalOverviewCard(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const QuickActionsCard(),
                            const SizedBox(height: 24),
                            if (viewModel.currentStatus == 'Matched')
                              const SupervisorRevealCard(),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const StatusBannerWidget(),
                      const SizedBox(height: 24),
                      const QuickActionsCard(),
                      const SizedBox(height: 24),
                      const ProposalOverviewCard(),
                      const SizedBox(height: 24),
                      if (viewModel.currentStatus == 'Matched')
                        const SupervisorRevealCard(),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- WIDGETS ---

class _WelcomeHeader extends StatelessWidget {
  final String name;
  final String id;
  const _WelcomeHeader({required this.name, required this.id, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome back, $name",
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A), // Deep charcoal
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Student ID: $id",
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF64748B), // Slate gray
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class StatusBannerWidget extends StatelessWidget {
  const StatusBannerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = context.watch<StudentDashboardViewModel>().currentStatus;
    
    Color bgColor;
    Color accentColor;
    IconData icon;
    String description;

    switch (status) {
      case 'Matched':
        bgColor = const Color(0xFFECFDF5); // Emerald 50
        accentColor = const Color(0xFF10B981); // Emerald 500
        icon = Icons.check_circle_rounded;
        description = "Your project proposal has been accepted and matched with a supervisor.";
        break;
      case 'Under Review':
        bgColor = const Color(0xFFFFFBEB); // Amber 50
        accentColor = const Color(0xFFF59E0B); // Amber 500
        icon = Icons.hourglass_bottom_rounded;
        description = "Your proposal is currently being evaluated by the committee.";
        break;
      case 'Pending':
      default:
        bgColor = const Color(0xFFEFF6FF); // Blue 50
        accentColor = const Color(0xFF3B82F6); // Blue 500
        icon = Icons.info_outline_rounded;
        description = "Your proposal has been submitted and is awaiting review.";
        break;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Current Status",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF334155),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ProposalOverviewCard extends StatelessWidget {
  const ProposalOverviewCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StudentDashboardViewModel>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Proposal Overview",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9), // Slate 100
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              viewModel.researchArea,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569), // Slate 600
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            viewModel.proposalTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            viewModel.abstractSnippet,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF64748B),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMatched = context.watch<StudentDashboardViewModel>().currentStatus == 'Matched';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          _ActionButton(
            title: "View Proposal",
            icon: Icons.visibility_outlined,
            onPressed: () {},
            isPrimary: true,
          ),
          if (!isMatched) ...[
            const SizedBox(height: 12),
            _ActionButton(
              title: "Edit Proposal",
              icon: Icons.edit_outlined,
              onPressed: () {},
              isPrimary: false,
            ),
            const SizedBox(height: 12),
            _ActionButton(
              title: "Withdraw",
              icon: Icons.delete_outline,
              onPressed: () {},
              isPrimary: false,
              isDestructive: true,
            ),
          ]
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isDestructive;

  const _ActionButton({
    required this.title,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color tColor;
    Color bColor;

    if (isDestructive) {
      tColor = const Color(0xFFEF4444);
      bColor = const Color(0xFFFEF2F2);
    } else if (isPrimary) {
      tColor = Colors.white;
      bColor = const Color(0xFF0F172A);
    } else {
      tColor = const Color(0xFF334155);
      bColor = const Color(0xFFF1F5F9);
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bColor,
          foregroundColor: tColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: (!isPrimary && !isDestructive)
                ? const BorderSide(color: Color(0xFFE2E8F0))
                : BorderSide.none,
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class SupervisorRevealCard extends StatelessWidget {
  const SupervisorRevealCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StudentDashboardViewModel>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x330F172A),
            blurRadius: 15,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: Color(0xFFFBBF24), size: 28),
              const SizedBox(width: 8),
              Text(
                "Match Successful!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[300],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Congratulations! Your proposal has been approved and you have been assigned an academic supervisor for your project.",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFCBD5E1),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF334155),
                  child: Text(
                    viewModel.supervisorName.substring(0, 1),
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewModel.supervisorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        viewModel.supervisorDepartment,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, color: Color(0xFF94A3B8), size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              viewModel.supervisorEmail,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF94A3B8),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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
  }
}
