import 'package:flutter/material.dart';

enum ProposalStatus { pending, underReview, matched }

class _ProposalData {
  String title;
  String abstractText;
  String techStack;
  String researchArea;
  ProposalStatus status;
  String? supervisorName;
  String? supervisorContact;

  _ProposalData({
    required this.title,
    required this.abstractText,
    required this.techStack,
    required this.researchArea,
    this.status = ProposalStatus.pending,
    this.supervisorName,
    this.supervisorContact,
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

  void _showSubmissionForm({bool isEditing = false}) {
    final titleController = TextEditingController(text: isEditing ? _proposal?.title : '');
    final abstractController = TextEditingController(text: isEditing ? _proposal?.abstractText : '');
    final techStackController = TextEditingController(text: isEditing ? _proposal?.techStack : '');
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

  String _getStatusDescription() {
    switch (_proposal?.status) {
      case ProposalStatus.matched: return "A supervisor has been assigned! View details below.";
      case ProposalStatus.underReview: return "Your proposal is being evaluated by the committee.";
      case ProposalStatus.pending:
      default: return "Your proposal has been submitted and is awaiting review.";
    }
  }

  IconData _getStatusIcon() {
    switch (_proposal?.status) {
      case ProposalStatus.matched: return Icons.check_circle;
      case ProposalStatus.underReview: return Icons.published_with_changes;
      case ProposalStatus.pending:
      default: return Icons.access_time_filled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Student Dashboard',
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
          _buildCircleButton(Icons.notifications_none, cardColor),
          const SizedBox(width: 8),
          _buildCircleButton(Icons.person_outline, cardColor),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back, Elena\nFisher',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
            ),
            const SizedBox(height: 8),
            Text(
              'Student ID: ST-2026-9482',
              style: TextStyle(color: mutedTextColor, fontSize: 14),
            ),
            const SizedBox(height: 32),

            if (_proposal == null)
              _buildEmptyState()
            else ...[
              _buildStatusCard(),
              const SizedBox(height: 24),
              if (_proposal!.status == ProposalStatus.matched) ...[
                _buildRevealCard(),
                const SizedBox(height: 24),
              ],
              _buildProposalCard(),
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
          ElevatedButton.icon(
            onPressed: () => _showSubmissionForm(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create Proposal', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final statusColor = _getStatusColor();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_getStatusIcon(), color: statusColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STATUS',
                  style: TextStyle(
                    color: mutedTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getStatusDescription(),
                  style: TextStyle(
                    color: mutedTextColor,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                GestureDetector(
                  onTap: () => _withdrawProposal(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.delete_outline, size: 14, color: Color(0xFFEF4444)),
                        SizedBox(width: 4),
                        Text('Withdraw', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.w600)),
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
          const SizedBox(height: 24),
          Text(
            _proposal!.title,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
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

  Widget _buildCircleButton(IconData icon, Color bgColor) {
    return Container(
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: () {},
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
}
