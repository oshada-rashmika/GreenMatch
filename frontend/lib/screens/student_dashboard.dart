import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/student_service.dart';
import 'login_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import 'profile_screen.dart';
import 'my_proposals_screen.dart';
import 'login_screen.dart';

enum ProposalStatus { pending, underReview, matched }

class _Activity {
  final String date;
  final String description;
  final IconData icon;
  final Color color;
  _Activity(this.date, this.description, this.icon, this.color);
}

class _ProposalData {
  String id;
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

  DateTime? milestoneMatchDate;
  DateTime? milestoneReviewDate;
  DateTime? milestoneMidtermDate;
  DateTime? milestoneFinalDate;
  DateTime? milestoneVivaDate;

  _ProposalData({
    required this.id,
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
    this.milestoneMatchDate,
    this.milestoneReviewDate,
    this.milestoneMidtermDate,
    this.milestoneFinalDate,
    this.milestoneVivaDate,
  });
}

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final Color bgColor = AppTheme.premiumBlack;
  final Color cardColor = Colors.white.withValues(alpha: 0.03); // Glass fallback
  final Color accentColor = AppTheme.forestEmerald;
  final Color mutedTextColor = Colors.white60;

  List<_ProposalData> _proposals = [];
  int _activeProjectIndex = 0;
  _ProposalData? get _proposal => _proposals.isNotEmpty ? _proposals[_activeProjectIndex] : null;
  List<MeetingData> _meetings = [];

  bool _isLoadingData = true;
  List<ModuleData> _modules = [];
  List<TagData> _tags = [];
  String? _selectedModuleId;
  String? _selectedTagId;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final service = StudentService();
      final fetchedModules = await service.fetchModules();
      final fetchedTags = await service.fetchTags();
      final myProposalsList = await service.fetchMyProposals();
      final fetchedMeetings = await service.fetchMyMeetings();

      if (mounted) {
        setState(() {
          _modules = fetchedModules;
          _tags = fetchedTags;
          _meetings = fetchedMeetings;

          if (_modules.isNotEmpty) _selectedModuleId = _modules.first.id;
          if (_tags.isNotEmpty) _selectedTagId = _tags.first.id;

          if (myProposalsList.isNotEmpty) {
            _proposals = myProposalsList.map((myP) {
              ProposalStatus mappedStatus;
              switch (myP.status) {
                case 'MATCHED': mappedStatus = ProposalStatus.matched; break;
                case 'UNDER_REVIEW': mappedStatus = ProposalStatus.underReview; break;
                default: mappedStatus = ProposalStatus.pending;
              }
              return _ProposalData(
                id: myP.id,
                title: myP.title,
                abstractText: myP.abstractText,
                techStack: myP.tags.join(', '),
                researchArea: (myP.tags.isNotEmpty) ? myP.tags.first : 'N/A',
                status: mappedStatus,
                supervisorName: myP.supervisorName,
                supervisorContact: myP.supervisorEmail,
                submittedDate: DateTime.now(), // Fallback
                expectedDecisionDate: DateTime.now().add(const Duration(days: 14)),
                impactBadges: [],
                activityLog: [],
                milestoneMatchDate: myP.milestoneMatchDate,
                milestoneReviewDate: myP.milestoneReviewDate,
                milestoneMidtermDate: myP.milestoneMidtermDate,
                milestoneFinalDate: myP.milestoneFinalDate,
                milestoneVivaDate: myP.milestoneVivaDate,
              );
            }).toList();
            _activeProjectIndex = 0; // Default to most recently submitted
          } else {
            _proposals = [];
          }

          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showSubmissionForm({bool isEditing = false, String? defaultTitle, String? defaultAbstract}) {
    final titleController = TextEditingController(text: isEditing ? _proposal?.title : (defaultTitle ?? ''));
    final abstractController = TextEditingController(text: isEditing ? _proposal?.abstractText : (defaultAbstract ?? ''));
    final groupNameController = TextEditingController();

    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.premiumBlack,
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
                      style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    if (_isLoadingData)
                      const Center(child: CircularProgressIndicator(color: AppTheme.forestEmerald))
                    else ...[
                      _buildTextField(titleController, 'Project Title'),
                      const SizedBox(height: 16),
                      _buildTextField(abstractController, 'Abstract', maxLines: 3),
                      const SizedBox(height: 16),
                      _buildTextField(groupNameController, 'Group Name (Optional)'),
                      const SizedBox(height: 16),
                      if (_modules.isEmpty)
                        const Text("No Modules Available. Please wait or referesh.", style: TextStyle(color: Colors.redAccent))
                      else
                        DropdownButtonFormField<String>(
                          value: _modules.any((m) => m.id == _selectedModuleId) ? _selectedModuleId : _modules.first.id,
                          dropdownColor: AppTheme.premiumBlack,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Academic Module',
                            labelStyle: TextStyle(color: mutedTextColor),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          items: _modules
                              .map((mod) => DropdownMenuItem(value: mod.id, child: Text('${mod.moduleCode} - ${mod.moduleName}', overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => _selectedModuleId = val);
                          },
                        ),
                      const SizedBox(height: 16),
                      if (_tags.isEmpty)
                        const Text("No Research Areas Available.", style: TextStyle(color: Colors.redAccent))
                      else
                        DropdownButtonFormField<String>(
                          value: _tags.any((t) => t.id == _selectedTagId) ? _selectedTagId : _tags.first.id,
                          dropdownColor: AppTheme.premiumBlack,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Research Area / Tech Stack',
                            labelStyle: TextStyle(color: mutedTextColor),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          items: _tags
                              .map((tag) => DropdownMenuItem(value: tag.id, child: Text(tag.name)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => _selectedTagId = val);
                          },
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.forestEmerald,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: isSubmitting ? null : () async {
                            if (titleController.text.trim().isEmpty || abstractController.text.trim().isEmpty || _selectedModuleId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields.')));
                              return;
                            }
                            setModalState(() => isSubmitting = true);
                            try {
                              await StudentService().submitProposal(
                                title: titleController.text.trim(),
                                abstractText: abstractController.text.trim(),
                                moduleId: _selectedModuleId!,
                                groupName: groupNameController.text.trim().isEmpty ? null : groupNameController.text.trim(),
                                tagIds: _selectedTagId != null ? [_selectedTagId!] : null,
                              );
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proposal Submitted Successfully!')));
                                _fetchInitialData(); // Re-fetch entire environment to populate the new project safely
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                setModalState(() => isSubmitting = false);
                              }
                            }
                          },
                          child: isSubmitting 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(
                                isEditing ? 'Save Changes' : 'Submit Document',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                        ),
                      ),
                    ],
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
      if (_proposals.isNotEmpty) {
        _proposals.removeAt(_activeProjectIndex);
        if (_activeProjectIndex > 0 && _activeProjectIndex >= _proposals.length) {
          _activeProjectIndex--;
        }
      }
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
      default: return "WAITING FOR SUPERVISOR";
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
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFEF4444)),
            title: const Text('Log Out', style: TextStyle(color: Color(0xFFEF4444))),
            onTap: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: bgColor,
        extendBodyBehindAppBar: true,
        drawer: _buildDrawer(),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: GlassContainer(
            borderRadius: 0,
            opacity: 0.02,
            blur: 15,
            borderColor: Colors.transparent,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  );
                }
              ),
               title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Flexible(
                     child: Container(
                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                       decoration: BoxDecoration(
                         color: _getStatusColor().withOpacity(0.15),
                         borderRadius: BorderRadius.circular(20),
                         border: Border.all(color: _getStatusColor().withOpacity(0.5)),
                       ),
                       child: Row(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           Icon(Icons.radio_button_checked, color: _getStatusColor(), size: 12),
                           const SizedBox(width: 6),
                           Flexible(
                             child: Text(
                               _getStatusText(),
                               style: TextStyle(color: _getStatusColor(), fontSize: 12, fontWeight: FontWeight.w700),
                               overflow: TextOverflow.ellipsis,
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),
                ],
              ),
        actions: [
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
          _buildCircleButtonWidget(
            Icons.add, 
            cardColor, 
            onPressed: () => _showSubmissionForm(),
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
    ),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
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
            const SizedBox(height: 24),

            _buildSavedResourcesCarousel(),
            const SizedBox(height: 32),

            if (_proposals.length > 1) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(_proposals.length, (index) {
                    final curr = _proposals[index];
                    final isSelected = index == _activeProjectIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _activeProjectIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.fastOutSlowIn,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.forestEmerald : cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppTheme.forestEmerald : Colors.white.withValues(alpha: 0.05),
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: AppTheme.forestEmerald.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]
                                : [],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected ? Icons.rocket_launch : Icons.folder_outlined,
                                color: isSelected ? Colors.white : mutedTextColor,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                curr.title.length > 18 ? '${curr.title.substring(0, 18)}...' : curr.title,
                                style: GoogleFonts.montserrat(
                                  color: isSelected ? Colors.white : mutedTextColor,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 32),
            ] else if (_proposals.length == 1) ...[
              const SizedBox(height: 32),
            ] else ...[
              const SizedBox(height: 32),
            ],


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
                _buildNextActionHighlight(),
                const SizedBox(height: 24),
                _buildDeliverablesChecklist(),
                const SizedBox(height: 24),
                _buildPostMatchMilestones(),
                const SizedBox(height: 24),
              ],
              _buildProposalCard(),
              const SizedBox(height: 24),
              if (_proposal != null) ...[
                _buildMeetingsSection(),
                const SizedBox(height: 24),
              ],
              _buildActivityLog(),
            ],
          ],
        ),
      ),
    ),
  ],
),
      ),
    );
  }

  Widget _buildEmptyState() {
    return GlassContainer(
      padding: const EdgeInsets.all(32),
      borderRadius: 24,
      opacity: 0.03,
      borderColor: Colors.white.withValues(alpha: 0.05),
      child: SizedBox(
        width: double.infinity,
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
                  backgroundColor: AppTheme.forestEmerald,
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
                    _showSubmissionForm(defaultTitle: '[Capstone Project] ', defaultAbstract: 'This capstone project aims to...');
                  } else if (value == 'grant') {
                    _showSubmissionForm(defaultTitle: 'Grant Proposal: ', defaultAbstract: 'This research aims to investigate the impact of...');
                  } else if (value == 'industry') {
                    _showSubmissionForm(defaultTitle: 'Industry Partnership: ', defaultAbstract: 'In collaboration with [Company], we will develop...');
                  } else if (value == 'thesis') {
                    _showSubmissionForm(defaultTitle: 'Master\'s Thesis: ', defaultAbstract: 'A comprehensive study to evaluate the performance of...');
                  } else if (value == 'open_source') {
                    _showSubmissionForm(defaultTitle: 'Open Source Initiative: ', defaultAbstract: 'This project focuses on enhancing the core libraries of...');
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
                    color: AppTheme.forestEmerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.forestEmerald.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.copy, size: 16, color: AppTheme.forestEmerald),
                      SizedBox(width: 8),
                      Text('Use Template', style: TextStyle(color: AppTheme.forestEmerald, fontWeight: FontWeight.bold)),
                      Icon(Icons.arrow_drop_down, color: AppTheme.forestEmerald),
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
      ),
    );
  }

  Widget _buildTimelineStatusCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      opacity: 0.03,
      borderColor: Colors.white.withValues(alpha: 0.05),
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
    Color nodeColor = isCompleted ? const Color(0xFF10B981) : Colors.white.withValues(alpha: 0.1);
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
        color: isActive ? const Color(0xFF10B981) : Colors.white.withValues(alpha: 0.1),
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

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      opacity: 0.03,
      borderColor: Colors.white.withValues(alpha: 0.05),
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
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      opacity: 0.03,
      borderColor: Colors.white.withValues(alpha: 0.05),
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
    if (_proposal == null) return const SizedBox.shrink();

    final projectMeetings = _meetings.where((m) => m.projectId == _proposal!.id).toList();
    final unmissed = projectMeetings.where((m) => m.status != 'MISSED' && m.status != 'COMPLETED').toList();
    if (unmissed.isEmpty) return const SizedBox.shrink();
    
    unmissed.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    final upcoming = unmissed.first;

    final dateStr = '${upcoming.scheduledDate.year}-${upcoming.scheduledDate.month.toString().padLeft(2, '0')}-${upcoming.scheduledDate.day.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_available, color: Color(0xFF34D399), size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Upcoming Meeting with Supervisor.',
              style: TextStyle(color: Color(0xFFD1FAE5), fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              dateStr,
              style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 12),
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
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      opacity: 0.03,
      borderColor: const Color(0xFF2B364E),
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

  String _formatMilestoneDate(DateTime? d) {
    if (d == null) return 'TBD';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
  }

  Widget _buildPostMatchMilestones() {
    final p = _proposal;
    if (p == null) return const SizedBox();

    bool matchCompleted = p.status == ProposalStatus.matched;
    bool reviewCompleted = p.milestoneReviewDate != null && p.milestoneReviewDate!.isBefore(DateTime.now());
    bool midtermCompleted = p.milestoneMidtermDate != null && p.milestoneMidtermDate!.isBefore(DateTime.now());
    bool finalCompleted = p.milestoneFinalDate != null && p.milestoneFinalDate!.isBefore(DateTime.now());
    bool vivaCompleted = p.milestoneVivaDate != null && p.milestoneVivaDate!.isBefore(DateTime.now());

    int completeCount = (matchCompleted ? 1 : 0) + (reviewCompleted ? 1 : 0) + (midtermCompleted ? 1 : 0) + (finalCompleted ? 1 : 0) + (vivaCompleted ? 1 : 0);
    int percentage = (completeCount / 5 * 100).round();

    bool matchActive = !matchCompleted;
    bool reviewActive = matchCompleted && !reviewCompleted;
    bool midtermActive = reviewCompleted && !midtermCompleted;
    bool finalActive = midtermCompleted && !finalCompleted;
    bool vivaActive = finalCompleted && !vivaCompleted;

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      opacity: 0.03,
      borderColor: const Color(0xFF2B364E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('PROJECT MILESTONES', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$percentage% Complete', style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildMilestoneRow(title: 'Supervisor Matched', date: _formatMilestoneDate(p.milestoneMatchDate), isCompleted: matchCompleted, isActive: matchActive, isLast: false),
          _buildMilestoneRow(title: 'Literature Review Submitted', date: 'Due: ${_formatMilestoneDate(p.milestoneReviewDate)}', isCompleted: reviewCompleted, isActive: reviewActive, isLast: false),
          _buildMilestoneRow(title: 'Mid-term Defense', date: _formatMilestoneDate(p.milestoneMidtermDate), isCompleted: midtermCompleted, isActive: midtermActive, isLast: false),
          _buildMilestoneRow(title: 'Final Thesis/Code Submission', date: _formatMilestoneDate(p.milestoneFinalDate), isCompleted: finalCompleted, isActive: finalActive, isLast: false),
          _buildMilestoneRow(title: 'Final Viva/Presentation', date: _formatMilestoneDate(p.milestoneVivaDate), isCompleted: vivaCompleted, isActive: vivaActive, isLast: true),
        ],
      ),
    );
  }

  Widget _buildMilestoneRow({required String title, required String date, required bool isCompleted, bool isActive = false, required bool isLast}) {
    Color iconColor = isCompleted ? const Color(0xFF10B981) : (isActive ? accentColor : const Color(0xFF334155));
    Color lineColor = isCompleted ? const Color(0xFF10B981) : const Color(0xFF334155);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted ? iconColor : (isActive ? iconColor.withOpacity(0.2) : Colors.transparent),
                  shape: BoxShape.circle,
                  border: Border.all(color: isActive && !isCompleted ? iconColor : (isCompleted ? Colors.transparent : const Color(0xFF334155)), width: 2),
                ),
                child: isCompleted 
                     ? const Icon(Icons.check, size: 14, color: Colors.white) 
                     : (isActive ? Center(child: Container(width: 8, height: 8, decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle))) : null),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: lineColor,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isCompleted || isActive ? Colors.white : mutedTextColor,
                      fontSize: 15,
                      fontWeight: isCompleted || isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      color: isActive ? accentColor : mutedTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextActionHighlight() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A).withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               Container(
                 padding: const EdgeInsets.all(6),
                 decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.2), shape: BoxShape.circle),
                 child: const Icon(Icons.bolt, color: Color(0xFF60A5FA), size: 18),
               ),
               const SizedBox(width: 12),
               const Text('CURRENT NEXT STEP', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Submit Initial Literature Review', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Your supervisor expects the first draft of your literature review covering at least 15 sources.', style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Color(0xFFFACC15), size: 16),
              const SizedBox(width: 8),
              const Text('Due in 12 Days', style: TextStyle(color: Color(0xFFFACC15), fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_file, size: 18),
              label: const Text('Upload Document', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDeliverablesChecklist() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      opacity: 0.03,
      borderColor: const Color(0xFF2B364E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('DELIVERABLES CHECKLIST', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('1/4 Completed', style: TextStyle(color: Color(0xFF60A5FA), fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.25,
              backgroundColor: bgColor,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 24),
          _buildChecklistItem(title: 'Connect GitHub Repository', isDone: true),
          _buildChecklistItem(title: 'Submit Literature Review Draft', isDone: false),
          _buildChecklistItem(title: 'Achieve 80% Test Coverage', isDone: false),
          _buildChecklistItem(title: 'Get Supervisor Final Signature', isDone: false),
        ],
      ),
    );
  }

  Widget _buildChecklistItem({required String title, required bool isDone}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFF10B981) : Colors.transparent,
              border: Border.all(color: isDone ? const Color(0xFF10B981) : const Color(0xFF475569)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: isDone ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isDone ? Colors.white : mutedTextColor,
                fontSize: 14,
                decoration: isDone ? TextDecoration.lineThrough : null,
                decorationColor: mutedTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingsSection() {
    if (_proposal == null) return const SizedBox.shrink();
    final projectMeetings = _meetings.where((m) => m.projectId == _proposal!.id).toList();

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      opacity: 0.03,
      borderColor: const Color(0xFF2B364E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SCHEDULED MEETINGS', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.video_camera_front_outlined, color: Color(0xFF60A5FA), size: 16),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (projectMeetings.isEmpty)
            Text('No upcoming meetings scheduled.', style: TextStyle(color: mutedTextColor, fontSize: 14))
          else
            ...projectMeetings.map((meeting) => _buildMeetingCard(meeting)),
        ],
      ),
    );
  }

  Widget _buildMeetingCard(MeetingData meeting) {
    bool isExpired = DateTime.now().isAfter(meeting.windowExpiry);
    bool isScheduled = meeting.status == 'SCHEDULED';
    bool canAttend = isScheduled && !isExpired;

    Color statusColor;
    String statusText;

    if (meeting.status == 'ATTENDED') {
      statusColor = const Color(0xFF10B981);
      statusText = 'ATTENDED';
    } else if (meeting.status == 'MISSED' || (isScheduled && isExpired)) {
      statusColor = const Color(0xFFEF4444);
      statusText = 'MISSED';
    } else {
      statusColor = const Color(0xFFFACC15);
      statusText = 'SCHEDULED';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2B364E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(meeting.supervisorName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_month, size: 14, color: mutedTextColor),
              const SizedBox(width: 4),
              Text(
                '${meeting.scheduledDate.year}-${meeting.scheduledDate.month}-${meeting.scheduledDate.day} at ${meeting.scheduledDate.hour}:${meeting.scheduledDate.minute.toString().padLeft(2, '0')}',
                style: TextStyle(color: mutedTextColor, fontSize: 13),
              ),
            ],
          ),
          if (meeting.supervisorNotes != null && meeting.supervisorNotes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Notes: ${meeting.supervisorNotes}', style: TextStyle(color: mutedTextColor, fontSize: 13, fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canAttend ? () => _markAttendance(meeting.id) : null,
              icon: Icon(canAttend ? Icons.how_to_reg : Icons.block, size: 16),
              label: Text(canAttend ? 'Mark Attendance' : (meeting.status == 'ATTENDED' ? 'Attendance Recorded' : 'Window Expired'), style: const TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: canAttend ? const Color(0xFF3B82F6) : Colors.grey.withOpacity(0.2),
                foregroundColor: canAttend ? Colors.white : Colors.white54,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _markAttendance(String meetingId) async {
    try {
      await StudentService().attendMeeting(meetingId);
      await _fetchInitialData(); // Refresh UI fully
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance Successfully Recorded!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to record attendance: $e')));
      }
    }
  }

  Widget _buildSavedResourcesCarousel() {
    final resources = [
      {'title': 'University Fall 2026 Guidelines', 'type': 'PDF', 'size': '2.4 MB'},
      {'title': 'AI Climate Modeling Architectures', 'type': 'PDF', 'size': '5.1 MB'},
      {'title': 'GreenMatch Portal Documentation', 'type': 'Link', 'size': '--'},
      {'title': 'TensorFlow for Environmental Data', 'type': 'PDF', 'size': '1.2 MB'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pinned Resources',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: GoogleFonts.montserrat(
                  color: AppTheme.forestEmerald,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: resources.map((res) {
              final isPdf = res['type'] == 'PDF';
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GlassContainer(
                  width: 200,
                  padding: const EdgeInsets.all(16),
                  borderRadius: 20,
                  opacity: 0.03,
                  borderColor: Colors.white.withValues(alpha: 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isPdf ? const Color(0xFFEF4444).withValues(alpha: 0.1) : const Color(0xFF3B82F6).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isPdf ? Icons.picture_as_pdf_outlined : Icons.link,
                              color: isPdf ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
                              size: 18,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.push_pin, color: mutedTextColor.withValues(alpha: 0.5), size: 14),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        res['title']!,
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${res['type']} • ${res['size']}',
                        style: GoogleFonts.montserrat(
                          color: mutedTextColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
