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
  final Color mutedTextColor = const Color(0xFF94A3B8);
  final Color dividerColor = const Color(0xFF2B3544);

  // --- Mock State ---
  bool _isMatched = true;
  bool _supervisorRevealed = false;

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
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),

            // --- 1. Profile Avatar ---
            _buildProfileAvatar(),
            const SizedBox(height: 20),

            // --- 2. Name & ID ---
            const Text(
              'Elena Fisher',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Student ID: ST-2026-9482',
              style: TextStyle(color: mutedTextColor, fontSize: 14),
            ),
            const SizedBox(height: 28),

            // --- 3. Project Status Card ---
            _buildProjectStatusCard(),
            const SizedBox(height: 20),

            // --- 4. Supervisor Reveal Card ---
            if (_isMatched) ...[
              _buildSupervisorRevealCard(),
              const SizedBox(height: 20),
            ],

            // --- 5. Personal Information ---
            _buildSectionCard(
              title: 'Personal Information',
              children: [
                _buildInfoRow(Icons.email_outlined, 'Email', 'elena.fisher@example.edu'),
                Divider(color: dividerColor, height: 1, thickness: 0.5),
                _buildInfoRow(Icons.school_outlined, 'Degree', 'BSc Computer Science'),
                Divider(color: dividerColor, height: 1, thickness: 0.5),
                _buildInfoRow(Icons.phone_outlined, 'Phone', '+1 (555) 123-4567'),
              ],
            ),
            const SizedBox(height: 20),

            // --- 6. Settings ---
            _buildSectionCard(
              title: 'Settings',
              children: [
                _buildActionRow(Icons.lock_outline, 'Change Password'),
                Divider(color: dividerColor, height: 1, thickness: 0.5),
                _buildActionRow(Icons.notifications_active_outlined, 'Notification Preferences'),
              ],
            ),
            const SizedBox(height: 28),

            // --- 7. Log Out ---
            _buildLogOutButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ==========================================
  //  WIDGET BUILDERS
  // ==========================================

  Widget _buildProfileAvatar() {
    return Center(
      child: SizedBox(
        width: 130,
        height: 130,
        child: Stack(
          children: [
            // Outer yellow ring
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accentColor, width: 2.5),
                ),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cardColor,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 56,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
            // Edit button overlay
            Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: bgColor, width: 3),
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
    final Color statusColor =
        _isMatched ? const Color(0xFF10B981) : accentColor;
    final Color statusBgColor =
        _isMatched ? const Color(0xFF10B981).withOpacity(0.12) : accentColor.withOpacity(0.12);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
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
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              // Dynamic Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
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
          const SizedBox(height: 12),
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
          const SizedBox(height: 4),
          // Demo toggle for testing
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
              icon: const Icon(Icons.swap_horiz, size: 14),
              label: Text(_isMatched ? 'Demo: Set Pending' : 'Demo: Set Matched', style: const TextStyle(fontSize: 11)),
              style: TextButton.styleFrom(
                foregroundColor: mutedTextColor,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 30),
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
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
                const Color(0xFF064E3B).withOpacity(0.6),
                const Color(0xFF022C22).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF10B981).withOpacity(0.25),
            ),
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
                // Blurred / locked state
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.4), size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to reveal supervisor identity',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _toggleReveal,
                    icon: const Icon(Icons.lock_open, size: 16),
                    label: const Text('Reveal Identity', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981).withOpacity(0.2),
                      foregroundColor: const Color(0xFF34D399),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: const Color(0xFF10B981).withOpacity(0.3)),
                    ),
                  ),
                ),
              ] else ...[
                // Revealed state with animation
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
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.email_outlined, color: Colors.white.withOpacity(0.6), size: 16),
                            const SizedBox(width: 8),
                            const Text(
                              'alan.turing@example.edu',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, color: Colors.white.withOpacity(0.6), size: 16),
                            const SizedBox(width: 8),
                            const Text(
                              'Room 4.12, Computing Building',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                                label: const Text('Message', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981).withOpacity(0.2),
                                  foregroundColor: const Color(0xFF34D399),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  side: BorderSide(color: const Color(0xFF10B981).withOpacity(0.3)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                onPressed: _toggleReveal,
                                icon: const Icon(Icons.visibility_off_outlined, color: Colors.white54, size: 20),
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

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: mutedTextColor, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: mutedTextColor, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: mutedTextColor, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Icon(Icons.chevron_right, color: mutedTextColor, size: 22),
        ],
      ),
    );
  }

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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444).withOpacity(0.08),
          foregroundColor: const Color(0xFFEF4444),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }
}
