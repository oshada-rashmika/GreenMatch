import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'my_proposals_screen.dart';

enum ProposalStatus { pending, underReview, matched }

class _Activity {
  final String date;
  final String description;
  final IconData icon;
  final Color color;
  _Activity(this.date, this.description, this.icon, this.color);
}

class _ProposalData {
  String title;
  String abstractText;
  String techStack;
  String researchArea;
  ProposalStatus status;
  String? supervisorName;
  String? supervisorContact;
  DateTime submittedDate;
  DateTime expectedDecisionDate;
  List<String> impactBadges;
  List<_Activity> activityLog;

  _ProposalData({
    required this.title,
    required this.abstractText,
    required this.techStack,
    required this.researchArea,
    this.status = ProposalStatus.pending,
    this.supervisorName,
    this.supervisorContact,
    required this.submittedDate,
    required this.expectedDecisionDate,
    required this.impactBadges,
    required this.activityLog,
  });
}

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final Color bgColor = const Color(0xFF0F1522);
  final Color cardColor = const Color(0xFF1A2235);
  final Color accentColor = const Color(0xFFFACC15); // Yellow
  final Color mutedTextColor = const Color(0xFF94A3B8); // Slate 400

  _ProposalData? _proposal;

  void _showSubmissionForm({bool isEditing = false, String? defaultTitle, String? defaultAbstract, String? defaultTechStack}) {
    final titleController = TextEditingController(text: isEditing ? _proposal?.title : (defaultTitle ?? ''));
    final abstractController = TextEditingController(text: isEditing ? _proposal?.abstractText : (defaultAbstract ?? ''));
    final techStackController = TextEditingController(text: isEditing ? _proposal?.techStack : (defaultTechStack ?? ''));
    String researchArea = isEditing ? (_proposal?.researchArea ?? 'Artificial Intelligence') : 'Artificial Intelligence';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Edit Proposal' : 'Submit Proposal',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(titleController, 'Title'),
                    const SizedBox(height: 16),
                    _buildTextField(abstractController, 'Abstract', maxLines: 3),
                    const SizedBox(height: 16),
                    _buildTextField(techStackController, 'Tech Stack (comma separated)'),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: researchArea,
                      dropdownColor: bgColor,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Research Area',
                        labelStyle: TextStyle(color: mutedTextColor),
                        filled: true,
                        fillColor: bgColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      items: ['Artificial Intelligence', 'Web & Mobile', 'Internet of Things', 'Cybersecurity']
                          .map((area) => DropdownMenuItem(value: area, child: Text(area)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => researchArea = val);
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2B364E),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (titleController.text.trim().isEmpty || abstractController.text.trim().isEmpty) return;
                          setState(() {
                            _proposal = _ProposalData(
                              title: titleController.text,
                              abstractText: abstractController.text,
                              techStack: techStackController.text,
                              researchArea: researchArea,
                              status: isEditing ? _proposal!.status : ProposalStatus.pending,
                              supervisorName: _proposal?.supervisorName,
                              supervisorContact: _proposal?.supervisorContact,
                              submittedDate: isEditing ? _proposal!.submittedDate : DateTime.now(),
                              expectedDecisionDate: isEditing ? _proposal!.expectedDecisionDate : DateTime.now().add(const Duration(days: 14)),
                              impactBadges: ['UN SDG 13: Climate Action', 'Tech for Good'],
                              activityLog: isEditing ? _proposal!.activityLog : [
                                _Activity('Just now', 'Proposal submitted for committee review.', Icons.upload_file, const Color(0xFFFACC15)),
                              ],
                            );
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          isEditing ? 'Save Changes' : 'Submit Document',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: mutedTextColor),
        filled: true,
        fillColor: bgColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  void _withdrawProposal() {
    setState(() {
      _proposal = null;
    });
  }

  Color _getStatusColor() {
    switch (_proposal?.status) {
      case ProposalStatus.matched: return const Color(0xFF10B981); // Emerald
      case ProposalStatus.underReview: return const Color(0xFF3B82F6); // Blue
      case ProposalStatus.pending:
      default: return accentColor; // Yellow
    }
  }

  String _getStatusText() {
    switch (_proposal?.status) {
      case ProposalStatus.matched: return "MATCHED";
      case ProposalStatus.underReview: return "UNDER REVIEW";
      case ProposalStatus.pending:
      default: return "PENDING";
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: bgColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: cardColor,
              border: const Border(bottom: BorderSide(color: Color(0xFF2B364E), width: 1)),
            ),
            accountName: const Text('Elena Fisher', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            accountEmail: Text('ST-2026-9482', style: TextStyle(color: mutedTextColor)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: accentColor,
              child: const Icon(Icons.person, color: Colors.black, size: 36),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Color(0xFFFACC15)),
            title: const Text('Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.description_outlined, color: mutedTextColor),
            title: Text('My Proposals', style: TextStyle(color: mutedTextColor)),
            onTap: () {
              Navigator.pop(context); // close drawer first
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyProposalsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.menu_book, color: mutedTextColor),
            title: Text('Formatting Guidelines', style: TextStyle(color: mutedTextColor)),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening University Guidelines...')));
            },
          ),
          const Divider(color: Color(0xFF2B364E), thickness: 1, indent: 16, endIndent: 16, height: 32),
          ListTile(
            leading: Icon(Icons.settings_outlined, color: mutedTextColor),
            title: Text('Settings', style: TextStyle(color: mutedTextColor)),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          }
        ),
        title: const Text(
          'Student Portal',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_proposal != null)
            Center(
              child: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: cardColor,
                ),
                child: DropdownButton<ProposalStatus>(
                  value: _proposal!.status,
                  icon: const Icon(Icons.bug_report, color: Colors.white, size: 16),
                  underline: const SizedBox(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  items: const [
                    DropdownMenuItem(value: ProposalStatus.pending, child: Text('Demo: Pending')),
                    DropdownMenuItem(value: ProposalStatus.underReview, child: Text('Demo: Review')),
                    DropdownMenuItem(value: ProposalStatus.matched, child: Text('Demo: Matched')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _proposal!.status = val;
                        if (val == ProposalStatus.matched) {
                          _proposal!.supervisorName = "Dr. Alan Turing";
                          _proposal!.supervisorContact = "alan.turing@example.edu";
                          _proposal!.activityLog.insert(0, _Activity('Today', 'Supervisor Dr. Alan Turing conditionally accepted the proposal.', Icons.check_circle, const Color(0xFF10B981)));
                        } else if (val == ProposalStatus.underReview) {
                          _proposal!.supervisorName = null;
                          _proposal!.supervisorContact = null;
                          _proposal!.activityLog.insert(0, _Activity('Yesterday', 'Proposal is now under review by the coordination committee.', Icons.remove_red_eye, const Color(0xFF3B82F6)));
                        } else {
                          _proposal!.supervisorName = null;
                          _proposal!.supervisorContact = null;
                        }
                      });
                    }
                  },
                ),
              ),
            ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            color: cardColor,
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: _buildCircleButtonWidget(Icons.notifications_none, cardColor),
            itemBuilder: (context) => [
              const PopupMenuItem(
                child: Text('Guidelines for Fall 2026 published', style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
              const PopupMenuItem(
                child: Text('Reminder: Deadline in 14 days', style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(width: 8),
          _buildCircleButtonWidget(Icons.person_outline, cardColor, onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeadlineBanner(),
            const Text(
              'Welcome back, Elena\nFisher',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
            ),
            const SizedBox(height: 8),
            Text(
              'Dashboard Overview',
              style: TextStyle(color: mutedTextColor, fontSize: 14),
            ),
            const SizedBox(height: 32),

            if (_proposal == null) ...[
              _buildEmptyState(),
              const SizedBox(height: 32),
              _buildSuggestedResearchCarousel(),
              const SizedBox(height: 32),
              _buildHowItWorksTimeline(),
              const SizedBox(height: 32),
              _buildProfileCompleteness(),
            ] else ...[
              _buildTimelineStatusCard(),
              const SizedBox(height: 24),
              if (_proposal!.status == ProposalStatus.matched) ...[
                _buildRevealCard(),
                const SizedBox(height: 24),
              ],
              _buildProposalCard(),
              const SizedBox(height: 24),
              _buildActivityLog(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.note_add_outlined, size: 64, color: Color(0xFF475569)),
          const SizedBox(height: 16),
          const Text('No Proposal Found', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Submit a project proposal to start the matching process.',
            textAlign: TextAlign.center,
            style: TextStyle(color: mutedTextColor, height: 1.5),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showSubmissionForm(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Start from Scratch', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                color: cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (value) {
                  if (value == 'capstone') {
                    _showSubmissionForm(defaultTitle: '[Capstone Project] ', defaultAbstract: 'This capstone project aims to...', defaultTechStack: 'Flutter, Firebase');
                  } else if (value == 'grant') {
                    _showSubmissionForm(defaultTitle: 'Grant Proposal: ', defaultAbstract: 'This research aims to investigate the impact of...', defaultTechStack: 'Python, TensorFlow');
                  } else if (value == 'industry') {
                    _showSubmissionForm(defaultTitle: 'Industry Partnership: ', defaultAbstract: 'In collaboration with [Company], we will develop...', defaultTechStack: 'React, Node.js');
                  } else if (value == 'thesis') {
                    _showSubmissionForm(defaultTitle: 'Master\'s Thesis: ', defaultAbstract: 'A comprehensive study to evaluate the performance of...', defaultTechStack: 'R, SQL');
                  } else if (value == 'open_source') {
                    _showSubmissionForm(defaultTitle: 'Open Source Initiative: ', defaultAbstract: 'This project focuses on enhancing the core libraries of...', defaultTechStack: 'Rust, WebAssembly');
                  } else {
                    _showSubmissionForm();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'capstone', child: Text('Capstone Template', style: TextStyle(color: Colors.white))),
                  const PopupMenuItem(value: 'thesis', child: Text('Master\'s Thesis', style: TextStyle(color: Colors.white))),
                  const PopupMenuItem(value: 'industry', child: Text('Industry Partnership', style: TextStyle(color: Colors.white))),
                  const PopupMenuItem(value: 'grant', child: Text('Research Grant', style: TextStyle(color: Colors.white))),
                  const PopupMenuItem(value: 'open_source', child: Text('Open Source Project', style: TextStyle(color: Colors.white))),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B364E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.copy, size: 16, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Use Template', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Icon(Icons.arrow_drop_down, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton.icon(
             onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening University Guidelines...')));
             },
             icon: const Icon(Icons.menu_book, size: 16),
             label: const Text('View Formatting Guidelines'),
             style: TextButton.styleFrom(foregroundColor: mutedTextColor),
          )
        ],
      ),
    );
  }

  Widget _buildTimelineStatusCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('STATUS TIMELINE', style: TextStyle(color: mutedTextColor, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
              Text(_getStatusText(), style: TextStyle(color: _getStatusColor(), fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _buildTimelineNode('Submitted', true, true),
              _buildTimelineLine(true),
              _buildTimelineNode('Under Review', _proposal!.status == ProposalStatus.underReview || _proposal!.status == ProposalStatus.matched, _proposal!.status == ProposalStatus.underReview),
              _buildTimelineLine(_proposal!.status == ProposalStatus.matched),
              _buildTimelineNode('Matched', _proposal!.status == ProposalStatus.matched, _proposal!.status == ProposalStatus.matched),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date Submitted', style: TextStyle(color: mutedTextColor, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text('Oct 15, 2026', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Expected Decision', style: TextStyle(color: mutedTextColor, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text('Oct 29, 2026', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTimelineNode(String label, bool isCompleted, bool isActive) {
    Color nodeColor = isCompleted ? const Color(0xFF10B981) : const Color(0xFF334155);
    Color textColor = isCompleted || isActive ? Colors.white : mutedTextColor;
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isActive && !isCompleted ? nodeColor.withOpacity(0.2) : nodeColor,
              shape: BoxShape.circle,
              border: isActive && !isCompleted ? Border.all(color: nodeColor, width: 2) : null,
            ),
            child: isActive && !isCompleted 
                 ? Center(child: Container(width: 12, height: 12, decoration: BoxDecoration(color: nodeColor, shape: BoxShape.circle))) 
                 : (isCompleted ? const Icon(Icons.check, size: 16, color: Colors.white) : null),
          ),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildTimelineLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? const Color(0xFF10B981) : const Color(0xFF334155),
        margin: const EdgeInsets.only(bottom: 24),
      ),
    );
  }

  Widget _buildRevealCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF022C22)], // Emerald dark
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.verified, color: Color(0xFF34D399), size: 20),
              SizedBox(width: 8),
              Text('SUCCESSFUL MATCH', style: TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, letterSpacing: 1.1, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Supervisor Assigned:', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text(_proposal!.supervisorName ?? '', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.email_outlined, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(_proposal!.supervisorContact ?? '', style: const TextStyle(color: Colors.white, decoration: TextDecoration.underline, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.chat_bubble_outline, size: 16),
              label: const Text('Contact Supervisor', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981).withOpacity(0.2),
                foregroundColor: const Color(0xFF34D399),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: const Color(0xFF10B981).withOpacity(0.3)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProposalCard() {
    final int wordCount = _proposal!.abstractText.split(RegExp(r'\s+')).length + _proposal!.title.split(RegExp(r'\s+')).length + 50; // Mock count
    final int percentage = _proposal!.status == ProposalStatus.pending ? 80 : 100;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F3D24), 
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _proposal!.researchArea.toUpperCase(),
                      style: const TextStyle(color: Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1),
                    ),
                  ),
                  if (_proposal!.status != ProposalStatus.matched) ...[
                    GestureDetector(
                      onTap: () => _showSubmissionForm(isEditing: true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.edit, size: 14, color: Color(0xFF60A5FA)),
                            SizedBox(width: 4),
                            Text('Edit', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                     Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF374151).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.lock_outline, size: 14, color: Color(0xFF9CA3AF)),
                            SizedBox(width: 4),
                            Text('Locked', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                     ),
                  ]
                ],
              ),
              if (_proposal!.status == ProposalStatus.pending)
                Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(12)),
                   child: Text('$percentage% Completeness', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_proposal!.impactBadges.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _proposal!.impactBadges.map((e) => _buildImpactBadge(e)).toList(),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            _proposal!.title,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
          ),
          const SizedBox(height: 8),
          Text(
            '$wordCount words',
            style: TextStyle(color: mutedTextColor, fontSize: 12, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          Text(
            _proposal!.abstractText,
            style: TextStyle(color: mutedTextColor, fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _proposal!.techStack.split(',').where((e) => e.trim().isNotEmpty).map((e) => _buildTechTag(e.trim())).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.public, size: 14, color: Color(0xFFA78BFA)),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Color(0xFFA78BFA), fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildActivityLog() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ACTIVITY LOG', style: TextStyle(color: mutedTextColor, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
              Icon(Icons.history, color: mutedTextColor, size: 16),
            ],
          ),
          const SizedBox(height: 20),
          ..._proposal!.activityLog.map((activity) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: activity.color.withOpacity(0.15), shape: BoxShape.circle),
                  child: Icon(activity.icon, size: 16, color: activity.color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(activity.description, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
                      const SizedBox(height: 6),
                      Text(activity.date, style: TextStyle(color: mutedTextColor, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildCircleButtonWidget(IconData icon, Color bgColor, {VoidCallback? onPressed}) {
    return Container(
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildTechTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildDeadlineBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: Color(0xFF60A5FA), size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Upcoming Deadline: Fall 2026 Proposal Submissions close in 14 days.',
              style: TextStyle(color: Color(0xFFDBEAFE), fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Nov 1, 2026',
              style: TextStyle(color: Color(0xFF60A5FA), fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How it Works',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildProcessStep('1', 'Submit\nProposal', Icons.description_outlined),
            _buildProcessArrow(),
            _buildProcessStep('2', 'Faculty\nReview', Icons.school_outlined),
            _buildProcessArrow(),
            _buildProcessStep('3', 'Matched with\nSupervisor', Icons.handshake_outlined),
          ],
        ),
      ],
    );
  }

  Widget _buildProcessStep(String number, String title, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2B364E)),
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: mutedTextColor, fontSize: 13, height: 1.3, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessArrow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0), // Align with circles
      child: Icon(Icons.arrow_forward, color: mutedTextColor.withOpacity(0.3), size: 20),
    );
  }

  Widget _buildProfileCompleteness() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2B364E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text('Profile Prerequisites', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('80% Complete', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.8,
              backgroundColor: bgColor,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Complete your profile by adding your major and past courses to unlock proposal submission and find the perfect supervisor.',
            style: TextStyle(color: mutedTextColor, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Complete Profile'),
              style: TextButton.styleFrom(
                foregroundColor: accentColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedResearchCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inspiration & Trending Ideas',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildIdeaCard('AI in Healthcare', 'Explore predictive modeling for early disease detection.', Icons.medical_services_outlined, const Color(0xFF10B981)),
              _buildIdeaCard('Sustainable Blockchain', 'Reduce the carbon footprint of distributed ledgers.', Icons.eco_outlined, const Color(0xFF3B82F6)),
              _buildIdeaCard('Smart IoT Agriculture', 'Optimize water usage using real-time soil sensors.', Icons.water_drop_outlined, const Color(0xFFFACC15)),
              _buildIdeaCard('Cyber-physical Security', 'New frameworks for protecting critical grid infrastructure.', Icons.security_outlined, const Color(0xFF8B5CF6)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIdeaCard(String title, String description, IconData icon, Color iconColor) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2B364E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(description, style: TextStyle(color: mutedTextColor, fontSize: 12, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
