import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_provider.dart';
import '../services/student_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  // --- Theme Colors ---
  final Color bgColor = AppTheme.premiumBlack;
  final Color cardColor = const Color(0xFF161618);
  final Color greenAccent = const Color(0xFF2D5A27);
  final Color accentColor = AppTheme.forestEmerald;
  final Color mutedTextColor = const Color(0xFF6B7280);
  final Color dividerColor = const Color(0xFF2A2A2A);
  final Color iconBgColor = const Color(0xFF2D5A27).withOpacity(0.1);

  // --- Mock State ---
  bool _isMatched = true;
  bool _supervisorRevealed = false;
  bool _isPersonalInfoExpanded = false;
  Map<String, dynamic>? _userProfile;
  List<MyProposalData> _proposals = [];
  bool _isLoadingProfile = true;

  late ScrollController _scrollController;
  late AnimationController _revealController;
  late Animation<double> _revealAnimation;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _scrollController = ScrollController();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _revealAnimation = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _fetchProfile() async {
    try {
      final service = StudentService();
      final profile = await service.fetchUserProfile();
      final proposals = await service.fetchMyProposals();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _proposals = proposals;
          if (_proposals.isNotEmpty) {
            _isMatched = _proposals.first.status == 'MATCHED';
          } else {
            _isMatched = false;
          }
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _toggleReveal() {
    setState(() {
      _supervisorRevealed = !_supervisorRevealed;
      if (_supervisorRevealed) {
        _revealController.forward();
      } else {
        _revealController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: bgColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 24),
              onPressed: () {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                  );
                }
              },
            ),
          ],
          title: Text(
            'Profile',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            // Top Green Gradient
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 350,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF1A381A), // Deep dark green
                      bgColor,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),

                    // ── Profile Avatar ──
                    _buildProfileAvatar(),
                    const SizedBox(height: 22),

                    // ── Name & ID ──
                    Text(
                      _userProfile?['fullName'] ?? 'Loading...',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Text(
                        'Student ID: ${_userProfile?['studentId'] ?? ''}',
                        style: GoogleFonts.montserrat(color: mutedTextColor, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // ── Project Status Card ──
                    _buildProjectStatusCard(),
                    const SizedBox(height: 16),

                    // ── Supervisor Reveal Card ──
                    if (_isMatched) ...[
                      _buildSupervisorRevealCard(),
                      const SizedBox(height: 16),
                    ],

                    // ── Personal Information (Editable Form) ──
                    _buildPersonalInfoForm(),
                    const SizedBox(height: 16),

                    // ── Settings ──
                    _buildSectionCard(
                      title: 'Settings',
                      children: [
                        _buildActionTile(
                          icon: Icons.lock_outline,
                          iconColor: const Color(0xFFFBBF24),
                          label: 'Change Password',
                        ),
                        _buildDivider(),
                        _buildActionTile(
                          icon: Icons.notifications_active_outlined,
                          iconColor: const Color(0xFFF472B6),
                          label: 'Notification Preferences',
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Log Out ──
                    _buildLogOutButton(),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════
  //  WIDGET BUILDERS
  // ══════════════════════════════════════════

  Widget _buildProfileAvatar() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
             width: 115,
             height: 115,
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               color: const Color(0xFF1E1E1E),
               border: Border.all(color: greenAccent.withOpacity(0.6), width: 3),
               boxShadow: [
                 BoxShadow(
                   color: greenAccent.withOpacity(0.2),
                   blurRadius: 20,
                   spreadRadius: 5,
                 ),
               ],
             ),
             child: const Icon(Icons.person, size: 60, color: Color(0xFF6B7280)),
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E4F2E),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1B361B), width: 2),
              ),
              child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectStatusCard() {
    if (_proposals.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PROJECT STATUS',
              style: GoogleFonts.montserrat(
                color: mutedTextColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Projects Available',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    final proposal = _proposals.first;
    final String statusLabel = proposal.status;
    final Color statusColor = _isMatched ? const Color(0xFF10B981) : (statusLabel == 'UNDER_REVIEW' ? Colors.blue : accentColor);
    final Color statusBgColor = _isMatched
        ? const Color(0xFF10B981).withOpacity(0.1)
        : accentColor.withOpacity(0.1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROJECT STATUS',
                style: GoogleFonts.montserrat(
                  color: mutedTextColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.8)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      statusLabel,
                      style: GoogleFonts.montserrat(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            proposal.title,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          // Research Tags
          if (proposal.tags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: proposal.tags.map((tag) => _buildResearchTag(tag, const Color(0xFF10B981))).toList(),
            ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildResearchTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: GoogleFonts.montserrat(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildSupervisorRevealCard() {
    return AnimatedBuilder(
      animation: _revealAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF064E3B).withOpacity(0.5),
                const Color(0xFF022C22).withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _supervisorRevealed ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF34D399),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _supervisorRevealed ? 'SUPERVISOR DETAILS' : 'SUPERVISOR HIDDEN',
                    style: GoogleFonts.montserrat(
                      color: const Color(0xFF34D399),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!_supervisorRevealed) ...[
                // Locked state
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.3), size: 32),
                        const SizedBox(height: 10),
                        Text(
                          'Tap below to reveal supervisor identity',
                          style: GoogleFonts.montserrat(color: Colors.white.withOpacity(0.35), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _toggleReveal,
                    icon: const Icon(Icons.lock_open, size: 16),
                    label: Text('Reveal Identity', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981).withOpacity(0.15),
                      foregroundColor: const Color(0xFF34D399),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: const Color(0xFF10B981).withOpacity(0.25)),
                    ),
                  ),
                ),
              ] else ...[
                // Revealed state
                FadeTransition(
                  opacity: _revealAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(_revealAnimation),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _proposals.isNotEmpty ? (_proposals.first.supervisorName ?? 'Unknown Supervisor') : 'Unknown Supervisor',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildSupervisorDetail(Icons.email_outlined, _proposals.isNotEmpty ? (_proposals.first.supervisorEmail ?? 'N/A') : 'N/A'),
                        const SizedBox(height: 8),
                        _buildSupervisorDetail(Icons.location_on_outlined, 'Room 4.12, Computing Building'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.note_add_outlined, size: 16),
                                label: Text('Send Note', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 13)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981).withOpacity(0.15),
                                  foregroundColor: const Color(0xFF34D399),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  side: BorderSide(color: const Color(0xFF10B981).withOpacity(0.25)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.08)),
                              ),
                              child: IconButton(
                                onPressed: _toggleReveal,
                                icon: const Icon(Icons.visibility_off_outlined, color: Colors.white38, size: 20),
                                tooltip: 'Hide details',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSupervisorDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.5), size: 16),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14, height: 1.3),
          ),
        ),
      ],
    );
  }

  // ── Section Card ──
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Divider(color: dividerColor, height: 1, thickness: 0.5),
    );
  }

  // ── Info Tile (for Personal Information) ──
  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Row(
        children: [
          // Icon with colored background
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    color: mutedTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Action Tile (for Settings) ──
  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.chevron_right, color: mutedTextColor, size: 18),
          ),
        ],
      ),
    );
  }

  // ── Log Out Button ──
  Widget _buildLogOutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          await context.read<AuthProvider>().logout();
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        icon: const Icon(Icons.logout, size: 20),
        label: Text(
          'Log Out',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444).withOpacity(0.08),
          foregroundColor: const Color(0xFFEF4444),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: const Color(0xFFEF4444).withOpacity(0.15)),
          ),
          elevation: 0,
        ),
      ),
    );
  }
  // ── Personal Information Form ──
  Widget _buildPersonalInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isPersonalInfoExpanded = !_isPersonalInfoExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Personal Information',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                Icon(
                  _isPersonalInfoExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: mutedTextColor,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormInput('FULL NAME', _userProfile?['fullName'] ?? ''),
                const SizedBox(height: 16),
                _buildFormInput('STUDENT ID', _userProfile?['studentId'] ?? ''),
                const SizedBox(height: 16),
                _buildFormInput('EMAIL ADDRESS', _userProfile?['email'] ?? ''),
                const SizedBox(height: 16),
                _buildFormInput('PHONE NUMBER', '+1 (555) 019-2834'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildFormInput('DEGREE LEVEL', _userProfile?['degree'] ?? '')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildFormInput('MAJOR', 'Computer Science')),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Changes saved successfully.')),
                      );
                      setState(() {
                        _isPersonalInfoExpanded = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5A27),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: Text('Save Changes', style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
          crossFadeState: _isPersonalInfoExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  Widget _buildFormInput(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: mutedTextColor,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: const Color(0xFF262C3A).withOpacity(0.4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: greenAccent.withOpacity(0.5)),
            ),
          ),
        ),
      ],
    );
  }
}
