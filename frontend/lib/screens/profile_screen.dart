import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  // --- Theme Colors ---
  final Color bgColor = const Color(0xFF12151C);
  final Color cardColor = const Color(0xFF1E222D);
  final Color accentColor = const Color(0xFFFACC15);
  final Color mutedTextColor = const Color(0xFF6B7B8F);
  final Color dividerColor = const Color(0xFF282E3A);
  final Color iconBgColor = const Color(0xFF262C3A);

  // --- Mock State ---
  bool _isMatched = true;
  bool _supervisorRevealed = false;
  bool _isPersonalInfoExpanded = false;

  late AnimationController _revealController;
  late Animation<double> _revealAnimation;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _revealAnimation = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
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
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
            const Text(
              'Elena Fisher',
              style: TextStyle(
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
              ),
              child: Text(
                'Student ID: ST-2026-9482',
                style: TextStyle(color: mutedTextColor, fontSize: 13, fontWeight: FontWeight.w500),
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
    );
  }

  // ══════════════════════════════════════════
  //  WIDGET BUILDERS
  // ══════════════════════════════════════════

  Widget _buildProfileAvatar() {
    return Center(
      child: SizedBox(
        width: 130,
        height: 130,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow ring
            Container(
              width: 124,
              height: 124,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    accentColor.withOpacity(0.5),
                    accentColor.withOpacity(0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Inner circle
            Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cardColor,
                border: Border.all(color: accentColor, width: 2.5),
              ),
              child: const Icon(
                Icons.person,
                size: 52,
                color: Color(0xFF5A6577),
              ),
            ),
            // Edit badge
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF12151C), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.edit, color: Color(0xFF1A1A1A), size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectStatusCard() {
    final String statusLabel = _isMatched ? 'MATCHED' : 'PENDING';
    final Color statusColor = _isMatched ? const Color(0xFF10B981) : accentColor;
    final Color statusBgColor = _isMatched
        ? const Color(0xFF10B981).withOpacity(0.1)
        : accentColor.withOpacity(0.1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dividerColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROJECT STATUS',
                style: TextStyle(
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
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: statusColor.withOpacity(0.5), blurRadius: 4),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
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
          const Text(
            'Urban Climate Modeling Using AI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          // Research Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildResearchTag('Artificial Intelligence', const Color(0xFF8B5CF6)),
              _buildResearchTag('Python', const Color(0xFF3B82F6)),
              _buildResearchTag('TensorFlow', const Color(0xFF10B981)),
            ],
          ),
          const SizedBox(height: 6),
          // Demo toggle
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _isMatched = !_isMatched;
                  if (!_isMatched) {
                    _supervisorRevealed = false;
                    _revealController.reverse();
                  }
                });
              },
              icon: Icon(Icons.swap_horiz, size: 14, color: mutedTextColor),
              label: Text(
                _isMatched ? 'Demo: Set Pending' : 'Demo: Set Matched',
                style: TextStyle(fontSize: 11, color: mutedTextColor),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 28),
              ),
            ),
          ),
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
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
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
            borderRadius: BorderRadius.circular(20),
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
                    style: const TextStyle(
                      color: Color(0xFF34D399),
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
                          style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 13),
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
                    label: const Text('Reveal Identity', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
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
                        const Text(
                          'Dr. Alan Turing',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildSupervisorDetail(Icons.email_outlined, 'alan.turing@example.edu'),
                        const SizedBox(height: 8),
                        _buildSupervisorDetail(Icons.location_on_outlined, 'Room 4.12, Computing Building'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.note_add_outlined, size: 16),
                                label: const Text('Send Note', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
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
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.3),
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
            style: const TextStyle(
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
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: dividerColor, width: 0.5),
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
                  style: TextStyle(
                    color: mutedTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
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
              style: const TextStyle(
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
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        icon: const Icon(Icons.logout, size: 20),
        label: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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
                const Text(
                  'Personal Information',
                  style: TextStyle(
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
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: dividerColor, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormInput('FULL NAME', 'Elena Fisher'),
                const SizedBox(height: 16),
                _buildFormInput('STUDENT ID', 'ST-2026-9482'),
                const SizedBox(height: 16),
                _buildFormInput('EMAIL ADDRESS', 'elena.fisher@student.university.edu'),
                const SizedBox(height: 16),
                _buildFormInput('PHONE NUMBER', '+1 (555) 019-2834'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildFormInput('DEGREE LEVEL', 'Undergraduate')),
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
                      backgroundColor: const Color(0xFF34D399).withOpacity(0.9),
                      foregroundColor: const Color(0xFF0F1522),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
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
          style: TextStyle(
            color: mutedTextColor,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
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
              borderSide: BorderSide(color: accentColor.withOpacity(0.5)),
            ),
          ),
        ),
      ],
    );
  }
}
