import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import 'profile_screen.dart';

// --- MOCK VIEW MODEL ---
class StudentDashboardViewModel extends ChangeNotifier {
  String _currentStatus = 'Pending';
  String get currentStatus => _currentStatus;

  void setStatus(String newStatus) {
    _currentStatus = newStatus;
    notifyListeners();
  }

  final String studentName = "Elena Fisher";
  final String studentId = "ST-2026-9482";

  final String proposalTitle = "AI-Driven Climate Modeling for Urban Microclimates";
  final String abstractSnippet = "This research focuses on leveraging machine learning to predict temperature spikes in dense urban areas, offering actionable insights for city planning and green infrastructure placement...";
  final String researchArea = "Artificial Intelligence";
  final List<String> techStack = ['Python', 'TensorFlow', 'PostGIS', 'React'];

  final String supervisorName = "Dr. Alan Turing";
  final String supervisorDepartment = "Faculty of Computer Science";
  final String supervisorEmail = "a.turing@university.edu";
}

// --- MAIN SCREEN ---
class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentDashboardViewModel(),
      child: const _StudentDashboardContent(),
    );
  }
}

class _StudentDashboardContent extends StatefulWidget {
  const _StudentDashboardContent({super.key});

  @override
  State<_StudentDashboardContent> createState() => _StudentDashboardContentState();
}

class _StudentDashboardContentState extends State<_StudentDashboardContent> {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StudentDashboardViewModel>();
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFF0F172A), // deep dark background
        appBar: _buildAppBar(viewModel),
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
            ).animate().fadeIn(duration: 800.ms),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
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
                                flex: 3,
                                child: Column(
                                  children: [
                                    const StatusBannerWidget(),
                                    const SizedBox(height: 24),
                                    if (viewModel.currentStatus == 'Matched')
                                      const SupervisorRevealCard()
                                    else
                                      const QuickActionsCard(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 4,
                                child: const ProposalOverviewCard(),
                              ),
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const StatusBannerWidget(),
                              const SizedBox(height: 24),
                              const ProposalOverviewCard(),
                              const SizedBox(height: 24),
                              if (viewModel.currentStatus == 'Matched')
                                const SupervisorRevealCard()
                              else
                                const QuickActionsCard(),
                            ],
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

  PreferredSizeWidget _buildAppBar(StudentDashboardViewModel viewModel) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: GlassContainer(
        borderRadius: 0,
        opacity: 0.02,
        blur: 15,
        borderColor: Colors.transparent,
        child: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Student Dashboard",
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: const Color(0xFF1E293B),
                  style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                  value: viewModel.currentStatus,
                  items: ['Pending', 'Under Review', 'Matched']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) viewModel.setStatus(val);
                  },
                ),
              ),
            ),
            _buildAppBarIcon(Icons.notifications_none_rounded),
            const SizedBox(width: 8),
            _buildAppBarIcon(Icons.person, onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            }),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarIcon(IconData icon, {VoidCallback? onTap}) {
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
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
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final String name;
  final String id;
  const _WelcomeHeader({required this.name, required this.id});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome back, $name",
          style: GoogleFonts.montserrat(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn().slideX(begin: -0.1),
        const SizedBox(height: 6),
        Text(
          "Student ID: $id",
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
      ],
    );
  }
}

class StatusBannerWidget extends StatelessWidget {
  const StatusBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.watch<StudentDashboardViewModel>().currentStatus;

    Color accentColor;
    IconData icon;
    String description;

    if (status == 'Matched') {
      accentColor = AppTheme.forestEmerald;
      icon = Icons.verified_rounded;
      description = "Your proposal was approved and matched with a supervisor.";
    } else if (status == 'Under Review') {
      accentColor = Colors.orangeAccent;
      icon = Icons.manage_search_rounded;
      description = "Your proposal is being evaluated by the committee.";
    } else {
      accentColor = Colors.amber;
      icon = Icons.schedule_rounded;
      description = "Your proposal has been submitted and is awaiting review.";
    }

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      opacity: 0.04,
      borderColor: Colors.white.withValues(alpha: 0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "STATUS",
                  style: GoogleFonts.montserrat(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.montserrat(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }
}

class ProposalOverviewCard extends StatefulWidget {
  const ProposalOverviewCard({super.key});

  @override
  State<ProposalOverviewCard> createState() => _ProposalOverviewCardState();
}

class _ProposalOverviewCardState extends State<ProposalOverviewCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StudentDashboardViewModel>();
    final isMatched = viewModel.currentStatus == 'Matched';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.01 : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
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
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.forestEmerald.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      viewModel.researchArea.toUpperCase(),
                      style: GoogleFonts.montserrat(
                        color: AppTheme.forestEmerald,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      if (!isMatched)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            children: [
                              _buildActionButton(Icons.edit_outlined, "Edit", Colors.blue),
                              const SizedBox(width: 8),
                              _buildActionButton(Icons.delete_outline, "Withdraw", Colors.redAccent),
                            ],
                          ),
                        ),
                      Icon(Icons.more_horiz, color: Colors.white.withValues(alpha: 0.3)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                viewModel.proposalTitle,
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                viewModel.abstractSnippet,
                style: GoogleFonts.montserrat(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: viewModel.techStack.map((tech) => _buildTechBadge(tech)).toList(),
              ),
              if (!isMatched) ...[
                const SizedBox(height: 32),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        "Resubmit Document",
                        style: GoogleFonts.montserrat(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildTechBadge(String tech) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Text(
        tech,
        style: GoogleFonts.montserrat(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.montserrat(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      opacity: 0.02,
      borderColor: Colors.white.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: Colors.amberAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                "QUICK ACTIONS",
                style: GoogleFonts.montserrat(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _ActionRow(
            icon: Icons.add_box_outlined,
            label: "Submit New Proposal",
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => const _SubmissionModal(),
              );
            },
          ),
          const SizedBox(height: 12),
          const _ActionRow(icon: Icons.chat_bubble_outline, label: "Contact Coordinator"),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionRow({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white70),
            const SizedBox(width: 12),
            Text(label, style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 16, color: Colors.white30),
          ],
        ),
      ),
    );
  }
}

class SupervisorRevealCard extends StatelessWidget {
  const SupervisorRevealCard({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StudentDashboardViewModel>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.forestEmerald.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.forestEmerald.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.forestEmerald.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_rounded, color: AppTheme.forestEmerald, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "MATCH SECURED",
                    style: GoogleFonts.montserrat(
                      color: AppTheme.forestEmerald,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "CONFIDENTIAL",
                  style: GoogleFonts.montserrat(fontSize: 8, color: Colors.white70, fontWeight: FontWeight.w800, letterSpacing: 1),
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                child: Text(
                  viewModel.supervisorName.substring(0, 1),
                  style: GoogleFonts.montserrat(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.supervisorName,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      viewModel.supervisorDepartment,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.email_outlined, color: Colors.white54, size: 16),
                const SizedBox(width: 8),
                Text(
                  viewModel.supervisorEmail,
                  style: GoogleFonts.montserrat(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1);
  }
}

class _SubmissionModal extends StatelessWidget {
  const _SubmissionModal();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: GlassContainer(
        padding: const EdgeInsets.all(32),
        borderRadius: 24,
        opacity: 0.05,
        borderColor: Colors.white.withValues(alpha: 0.1),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Submit New Proposal",
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildLabel("Project Title"),
                _buildTextField(hint: "e.g., Quantum Sensors for Bio-imaging"),
                const SizedBox(height: 24),
                _buildLabel("Abstract"),
                _buildTextField(
                  hint: "Briefly describe the research methodology and goals...",
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Research Area"),
                          _buildDropdown(['Artificial Intelligence', 'Cybersecurity', 'Data Science', 'Software Engineering']),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Technical Stack"),
                          _buildDropdown(['Python', 'React', 'Flutter', 'AWS', 'TensorFlow']),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.montserrat(color: Colors.white54, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.forestEmerald,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.forestEmerald.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Text(
                          "Submit Proposal",
                          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.montserrat(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildTextField({required String hint, int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(color: Colors.white30, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.03),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.forestEmerald.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items) {
    return DropdownButtonFormField<String>(
      dropdownColor: const Color(0xFF1E293B),
      iconDisabledColor: Colors.white54,
      iconEnabledColor: Colors.white54,
      style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.03),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      hint: Text("Select...", style: GoogleFonts.montserrat(color: Colors.white30, fontSize: 14)),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (val) {},
    );
  }
}
