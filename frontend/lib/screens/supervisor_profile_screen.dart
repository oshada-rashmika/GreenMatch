import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/auth_provider.dart';
import 'login_screen.dart';

class SupervisorProfileScreen extends StatefulWidget {
  const SupervisorProfileScreen({super.key});

  @override
  State<SupervisorProfileScreen> createState() =>
      _SupervisorProfileScreenState();
}

class _SupervisorProfileScreenState extends State<SupervisorProfileScreen>
    with TickerProviderStateMixin {
  String _supervisorName = 'Dr. James Anderson';
  static const String _supervisorEmail = 'j.anderson@university.ac.uk';
  bool _isEditingName = false;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();

  final List<String> _specifications = [];
  final TextEditingController _specController = TextEditingController();
  bool _isAddingSpec = false;
  final FocusNode _specFocus = FocusNode();

  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _nameController.text = _supervisorName;
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    _specController.dispose();
    _specFocus.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _startEditingName() {
    setState(() => _isEditingName = true);
    _nameController.text = _supervisorName;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocus.requestFocus();
      _nameController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _nameController.text.length,
      );
    });
  }

  void _saveName() {
    final trimmed = _nameController.text.trim();
    if (trimmed.isNotEmpty) {
      setState(() {
        _supervisorName = trimmed;
        _isEditingName = false;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _cancelEditingName() {
    setState(() => _isEditingName = false);
    _nameController.text = _supervisorName;
  }

  void _startAddingSpec() {
    setState(() => _isAddingSpec = true);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _specFocus.requestFocus(),
    );
  }

  void _commitSpec() {
    final text = _specController.text.trim();
    if (text.isNotEmpty && !_specifications.contains(text)) {
      setState(() => _specifications.add(text));
      HapticFeedback.selectionClick();
    }
    _specController.clear();
    setState(() => _isAddingSpec = false);
  }

  void _removeSpec(String spec) {
    setState(() => _specifications.remove(spec));
    HapticFeedback.lightImpact();
  }

  Future<void> _performSecureLogout(BuildContext context) async {
    const FlutterSecureStorage storage = FlutterSecureStorage();
    await storage.deleteAll();

    if (context.mounted) {
      await context.read<AuthProvider>().logout();
    }

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppTheme.premiumBlack,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            Positioned(
              top: -120,
              right: -80,
              child: _GlowOrb(
                color: AppTheme.forestEmerald,
                size: 340,
                blurRadius: 160,
                opacity: 0.18,
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: _GlowOrb(
                color: const Color(0xFF1A3A2A),
                size: 260,
                blurRadius: 130,
                opacity: 0.25,
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIdentityCard()
                        .animate(controller: _entranceController)
                        .fadeIn(duration: 600.ms, curve: Curves.easeOutQuart)
                        .slideY(
                          begin: 0.12,
                          duration: 700.ms,
                          curve: Curves.easeOutQuart,
                        ),

                    const SizedBox(height: 24),

                    _buildSpecificationsSection()
                        .animate(controller: _entranceController)
                        .fadeIn(
                          delay: 200.ms,
                          duration: 600.ms,
                          curve: Curves.easeOutQuart,
                        )
                        .slideY(
                          begin: 0.12,
                          delay: 200.ms,
                          duration: 700.ms,
                          curve: Curves.easeOutQuart,
                        ),

                    const SizedBox(height: 40),

                    _AnimatedLogoutButton(onLogout: _performSecureLogout)
                        .animate(controller: _entranceController)
                        .fadeIn(
                          delay: 400.ms,
                          duration: 600.ms,
                          curve: Curves.easeOutQuart,
                        )
                        .slideY(
                          begin: 0.12,
                          delay: 400.ms,
                          duration: 700.ms,
                          curve: Curves.easeOutQuart,
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            color: Colors.white.withValues(alpha: 0.02),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                'Profile',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityCard() {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.forestEmerald.withValues(alpha: 0.7),
                      AppTheme.forestEmerald.withValues(alpha: 0.2),
                    ],
                  ),
                  border: Border.all(
                    color: AppTheme.forestEmerald.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.forestEmerald.withValues(alpha: 0.25),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _supervisorName.isNotEmpty
                        ? _supervisorName[0].toUpperCase()
                        : 'S',
                    style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusBadge(label: 'SUPERVISOR'),
                  const SizedBox(height: 8),
                  Text(
                    'Academic Staff',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.4),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 28),
          _Divider(),
          const SizedBox(height: 24),

          _buildProfileField(
            label: 'FULL NAME',
            value: _supervisorName,
            isEditing: _isEditingName,
            controller: _nameController,
            focusNode: _nameFocus,
            showEditIcon: true,
            onEditTap: _startEditingName,
            onSave: _saveName,
            onCancel: _cancelEditingName,
            icon: Icons.person_outline_rounded,
          ),

          const SizedBox(height: 20),

          _buildProfileField(
            label: 'EMAIL ADDRESS',
            value: _supervisorEmail,
            isEditing: false,
            controller: null,
            focusNode: null,
            showEditIcon: false,
            onEditTap: null,
            onSave: null,
            onCancel: null,
            icon: Icons.alternate_email_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required String value,
    required bool isEditing,
    required TextEditingController? controller,
    required FocusNode? focusNode,
    required bool showEditIcon,
    required VoidCallback? onEditTap,
    required VoidCallback? onSave,
    required VoidCallback? onCancel,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: AppTheme.forestEmerald),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: AppTheme.forestEmerald.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        AnimatedCrossFade(
          duration: const Duration(milliseconds: 280),
          crossFadeState:
              isEditing ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.92),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              if (showEditIcon)
                GestureDetector(
                  onTap: onEditTap,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppTheme.forestEmerald.withValues(alpha: 0.1),
                      border: Border.all(
                        color: AppTheme.forestEmerald.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 14,
                      color: AppTheme.forestEmerald,
                    ),
                  ),
                ),
            ],
          ),
          secondChild: isEditing
              ? _NameEditorField(
                  controller: controller!,
                  focusNode: focusNode!,
                  onSave: onSave!,
                  onCancel: onCancel!,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSpecificationsSection() {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppTheme.forestEmerald.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppTheme.forestEmerald.withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(
                  Icons.psychology_alt_rounded,
                  size: 18,
                  color: AppTheme.forestEmerald,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Specifications',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.95),
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Your areas of expertise',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _isAddingSpec ? null : _startAddingSpec,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _isAddingSpec
                        ? Colors.white.withValues(alpha: 0.04)
                        : AppTheme.forestEmerald.withValues(alpha: 0.15),
                    border: Border.all(
                      color: _isAddingSpec
                          ? Colors.white.withValues(alpha: 0.08)
                          : AppTheme.forestEmerald.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        size: 14,
                        color: _isAddingSpec
                            ? Colors.white30
                            : AppTheme.forestEmerald,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'ADD',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: _isAddingSpec
                              ? Colors.white30
                              : AppTheme.forestEmerald,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutQuart,
            child: _isAddingSpec
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _SpecInputField(
                      controller: _specController,
                      focusNode: _specFocus,
                      onCommit: _commitSpec,
                      onCancel: () {
                        _specController.clear();
                        setState(() => _isAddingSpec = false);
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          _specifications.isEmpty && !_isAddingSpec
              ? _buildEmptySpecState()
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _specifications
                      .asMap()
                      .entries
                      .map(
                        (entry) => _SpecChip(
                          label: entry.value,
                          index: entry.key,
                          onRemove: () => _removeSpec(entry.value),
                        ),
                      )
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildEmptySpecState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.02),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.hub_outlined,
            size: 36,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          const SizedBox(height: 10),
          Text(
            'No specifications added yet',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.25),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap ADD to define your expertise areas',
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  final double blurRadius;
  final double opacity;

  const _GlowOrb({
    required this.color,
    required this.size,
    required this.blurRadius,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity * 0.6),
            blurRadius: blurRadius,
            spreadRadius: blurRadius * 0.3,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.12),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  const _StatusBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: AppTheme.forestEmerald.withValues(alpha: 0.15),
        border: Border.all(color: AppTheme.forestEmerald.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: AppTheme.forestEmerald,
          letterSpacing: 1.8,
        ),
      ),
    );
  }
}

class _NameEditorField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _NameEditorField({
    required this.controller,
    required this.focusNode,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: GoogleFonts.montserrat(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.95),
              letterSpacing: -0.3,
            ),
            cursorColor: AppTheme.forestEmerald,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              hintText: 'Enter your name',
              hintStyle: GoogleFonts.montserrat(
                color: Colors.white30,
                fontSize: 15,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.forestEmerald.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.forestEmerald.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
            ),
            onSubmitted: (_) => onSave(),
            textInputAction: TextInputAction.done,
          ),
        ),
        const SizedBox(width: 8),
        _IconBtn(
          icon: Icons.check_rounded,
          color: AppTheme.forestEmerald,
          bgColor: AppTheme.forestEmerald.withValues(alpha: 0.15),
          borderColor: AppTheme.forestEmerald.withValues(alpha: 0.35),
          onTap: onSave,
        ),
        const SizedBox(width: 6),
        _IconBtn(
          icon: Icons.close_rounded,
          color: Colors.white38,
          bgColor: Colors.white.withValues(alpha: 0.04),
          borderColor: Colors.white.withValues(alpha: 0.08),
          onTap: onCancel,
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: bgColor,
          border: Border.all(color: borderColor),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

class _SpecInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onCommit;
  final VoidCallback onCancel;

  const _SpecInputField({
    required this.controller,
    required this.focusNode,
    required this.onCommit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            cursorColor: AppTheme.forestEmerald,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.04),
              hintText: 'e.g., Machine Learning, Web Dev…',
              hintStyle: GoogleFonts.montserrat(
                color: Colors.white24,
                fontSize: 13,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.forestEmerald.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
            ),
            onSubmitted: (_) => onCommit(),
          ),
        ),
        const SizedBox(width: 8),
        _IconBtn(
          icon: Icons.add_rounded,
          color: AppTheme.forestEmerald,
          bgColor: AppTheme.forestEmerald.withValues(alpha: 0.15),
          borderColor: AppTheme.forestEmerald.withValues(alpha: 0.35),
          onTap: onCommit,
        ),
        const SizedBox(width: 6),
        _IconBtn(
          icon: Icons.close_rounded,
          color: Colors.white38,
          bgColor: Colors.white.withValues(alpha: 0.04),
          borderColor: Colors.white.withValues(alpha: 0.08),
          onTap: onCancel,
        ),
      ],
    );
  }
}

class _SpecChip extends StatelessWidget {
  final String label;
  final int index;
  final VoidCallback onRemove;

  const _SpecChip({
    required this.label,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onRemove,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: AppTheme.forestEmerald.withValues(alpha: 0.12),
          border: Border.all(
            color: AppTheme.forestEmerald.withValues(alpha: 0.28),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.forestEmerald.withValues(alpha: 0.08),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.forestEmerald.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close_rounded,
                size: 13,
                color: AppTheme.forestEmerald.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(
            delay: (index * 60).ms,
            duration: 400.ms,
            curve: Curves.easeOutQuart,
          )
          .scale(
            begin: const Offset(0.8, 0.8),
            delay: (index * 60).ms,
            duration: 400.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }
}

class _AnimatedLogoutButton extends StatefulWidget {
  final Future<void> Function(BuildContext context) onLogout;
  const _AnimatedLogoutButton({required this.onLogout});

  @override
  State<_AnimatedLogoutButton> createState() => _AnimatedLogoutButtonState();
}

class _AnimatedLogoutButtonState extends State<_AnimatedLogoutButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _doorController;
  late Animation<double> _doorAngle;
  late Animation<double> _shakeX;
  late Animation<double> _glowOpacity;

  bool _isConfirming = false;
  bool _isProcessing = false;

  static const Color _dangerRed = Color(0xFFFF4545);

  @override
  void initState() {
    super.initState();
    _doorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _doorAngle = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -0.30)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -0.30, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInBack)),
        weight: 60,
      ),
    ]).animate(_doorController);

    _shakeX = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -4.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: -3.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -3.0, end: 3.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 3.0, end: 0.0), weight: 30),
    ]).animate(_doorController);

    _glowOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.6), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 0.0), weight: 60),
    ]).animate(_doorController);
  }

  @override
  void dispose() {
    _doorController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isProcessing) return;

    if (!_isConfirming) {
      setState(() => _isConfirming = true);
      HapticFeedback.mediumImpact();
      await _doorController.forward(from: 0);
      return;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.heavyImpact();
    await _doorController.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 150));

    if (mounted) {
      await widget.onLogout(context);
    }
  }

  void _cancelConfirm() {
    setState(() => _isConfirming = false);
    _doorController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _isConfirming && !_isProcessing
              ? Padding(
                  key: const ValueKey('hint'),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 13,
                        color: _dangerRed.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tap again to confirm logout',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: _dangerRed.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _cancelConfirm,
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Colors.white38,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(key: ValueKey('empty')),
        ),

        AnimatedBuilder(
          animation: _doorController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeX.value, 0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isConfirming)
                    Positioned.fill(
                      child: Opacity(
                        opacity: _glowOpacity.value,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: _dangerRed.withValues(alpha: 0.5),
                                blurRadius: 40,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  GestureDetector(
                    onTap: _handleTap,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: _isConfirming
                            ? _dangerRed.withValues(alpha: 0.12)
                            : Colors.white.withValues(alpha: 0.03),
                        border: Border.all(
                          color: _isConfirming
                              ? _dangerRed.withValues(alpha: 0.45)
                              : Colors.white.withValues(alpha: 0.08),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _DoorIcon(
                                angle: _doorAngle.value,
                                isActive: _isConfirming,
                                color: _isConfirming
                                    ? _dangerRed
                                    : Colors.white54,
                              ),
                              const SizedBox(width: 12),
                              _isProcessing
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: _dangerRed,
                                      ),
                                    )
                                  : AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.0,
                                        color: _isConfirming
                                            ? _dangerRed
                                            : Colors.white54,
                                      ),
                                      child: Text(
                                        _isConfirming
                                            ? 'CONFIRM LOGOUT'
                                            : 'SIGN OUT',
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DoorIcon extends StatelessWidget {
  final double angle;
  final bool isActive;
  final Color color;

  const _DoorIcon({
    required this.angle,
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: _DoorPainter(angle: angle, color: color),
      ),
    );
  }
}

class _DoorPainter extends CustomPainter {
  final double angle;
  final Color color;

  _DoorPainter({required this.angle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final framePath = Path()
      ..moveTo(w * 0.15, h * 0.05)
      ..lineTo(w * 0.85, h * 0.05)
      ..lineTo(w * 0.85, h * 0.95)
      ..lineTo(w * 0.15, h * 0.95)
      ..close();
    canvas.drawPath(framePath, paint);

    final cosA = (1.0 - (angle * angle * 0.5)).clamp(0.0, 1.0);
    final panelRight = w * 0.15 + (w * 0.70) * cosA;
    final panelPath = Path()
      ..moveTo(w * 0.15, h * 0.08)
      ..lineTo(panelRight, h * 0.08)
      ..lineTo(panelRight, h * 0.92)
      ..lineTo(w * 0.15, h * 0.92)
      ..close();
    canvas.drawPath(panelPath, paint..style = PaintingStyle.stroke);

    final arrowPaint = Paint()
      ..color = color.withAlpha((color.a * 255 * 0.7).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final cx = w * 0.58;
    final cy = h * 0.50;
    canvas.drawLine(Offset(cx - 5, cy), Offset(cx + 5, cy), arrowPaint);
    canvas.drawLine(Offset(cx + 2, cy - 3), Offset(cx + 5, cy), arrowPaint);
    canvas.drawLine(Offset(cx + 2, cy + 3), Offset(cx + 5, cy), arrowPaint);
  }

  @override
  bool shouldRepaint(_DoorPainter old) =>
      old.angle != angle || old.color != color;
}
