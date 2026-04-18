import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/auth_provider.dart';
import 'supervisor_dashboard.dart';
import 'student_dashboard.dart';
import 'module_leader_dashboard.dart';
import 'supervisor_onboarding_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool adminOnly;
  const LoginScreen({super.key, this.adminOnly = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // View state
  late bool _isStaffView;
  String _staffRole = 'supervisor'; // 'supervisor' or 'module_leader'

  // Form states
  final GlobalKey<FormState> _studentLoginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _studentSignupFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _staffLoginFormKey = GlobalKey<FormState>();

  bool _showStudentLogin = true; // Toggle between login and signup for students
  bool _showPassword = false;
  bool _rememberMe = true;

  // Student Login Controllers
  final TextEditingController _studentEmailController = TextEditingController();
  final TextEditingController _studentPasswordController =
      TextEditingController();

  // Student Signup Controllers
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPasswordController =
      TextEditingController();
  final TextEditingController _signupFullNameController =
      TextEditingController();
  final TextEditingController _signupStudentIdController =
      TextEditingController();
  final TextEditingController _signupDegreeController = TextEditingController();

  // Staff Login Controllers
  final TextEditingController _staffEmailController = TextEditingController();
  final TextEditingController _staffPasswordController =
      TextEditingController();

  // Focus nodes
  late FocusNode _studentEmailFocus;
  late FocusNode _studentPasswordFocus;
  late FocusNode _signupEmailFocus;
  late FocusNode _signupPasswordFocus;
  late FocusNode _signupFullNameFocus;
  late FocusNode _signupStudentIdFocus;
  late FocusNode _signupDegreeFocus;
  late FocusNode _staffEmailFocus;
  late FocusNode _staffPasswordFocus;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _isStaffView = widget.adminOnly;
    _initializeFocusNodes();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  void _initializeFocusNodes() {
    _studentEmailFocus = FocusNode();
    _studentPasswordFocus = FocusNode();
    _signupEmailFocus = FocusNode();
    _signupPasswordFocus = FocusNode();
    _signupFullNameFocus = FocusNode();
    _signupStudentIdFocus = FocusNode();
    _signupDegreeFocus = FocusNode();
    _staffEmailFocus = FocusNode();
    _staffPasswordFocus = FocusNode();
  }

  @override
  void dispose() {
    _disposeControllers();
    _disposeFocusNodes();
    _slideController.dispose();
    super.dispose();
  }

  void _disposeControllers() {
    _studentEmailController.dispose();
    _studentPasswordController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupFullNameController.dispose();
    _signupStudentIdController.dispose();
    _signupDegreeController.dispose();
    _staffEmailController.dispose();
    _staffPasswordController.dispose();
  }

  void _disposeFocusNodes() {
    _studentEmailFocus.dispose();
    _studentPasswordFocus.dispose();
    _signupEmailFocus.dispose();
    _signupPasswordFocus.dispose();
    _signupFullNameFocus.dispose();
    _signupStudentIdFocus.dispose();
    _signupDegreeFocus.dispose();
    _staffEmailFocus.dispose();
    _staffPasswordFocus.dispose();
  }

  void _toggleStaffView() {
    setState(() {
      _isStaffView = !_isStaffView;
      if (_isStaffView) {
        _slideController.forward();
      } else {
        _slideController.reverse();
      }
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  void _toggleStudentForm() {
    setState(() {
      _showStudentLogin = !_showStudentLogin;
    });
  }

  Future<void> _handleStudentLogin(BuildContext context) async {
    if (!_studentLoginFormKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final success = await authProvider.studentLogin(
      _studentEmailController.text.trim(),
      _studentPasswordController.text,
    );

    if (success && context.mounted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Student login successful!')),
      );

      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const StudentDashboard()),
      );
    }
  }

  Future<void> _handleStudentSignup(BuildContext context) async {
    if (!_studentSignupFormKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await authProvider.registerStudent(
      email: _signupEmailController.text.trim(),
      password: _signupPasswordController.text,
      fullName: _signupFullNameController.text.trim(),
      studentId: _signupStudentIdController.text.trim(),
      degree: _signupDegreeController.text.trim(),
    );

    if (success && context.mounted) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please log in.'),
        ),
      );
      _toggleStudentForm();
      // Clear signup fields
      _signupEmailController.clear();
      _signupPasswordController.clear();
      _signupFullNameController.clear();
      _signupStudentIdController.clear();
      _signupDegreeController.clear();
    }
  }

  Future<void> _handleStaffLogin(BuildContext context) async {
    if (!_staffLoginFormKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final success = _staffRole == 'supervisor'
        ? await authProvider.supervisorLogin(
            _staffEmailController.text.trim(),
            _staffPasswordController.text,
          )
        : await authProvider.moduleLeaderLogin(
            _staffEmailController.text.trim(),
            _staffPasswordController.text,
          );

    if (success && context.mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${_staffRole == 'supervisor' ? 'Supervisor' : 'Module Leader'} login successful!',
          ),
        ),
      );

      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            if (_staffRole == 'supervisor') {
              return authProvider.isFirstLogin
                  ? const SupervisorOnboardingScreen()
                  : const SupervisorDashboard();
            } else {
              return const ModuleLeaderDashboard();
            }
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: AppTheme.premiumBlack,
        body: Stack(
          children: [
            // Ambient glows
            Positioned(
              top: -150,
              right: -100,
              child: _GlowOrb(color: AppTheme.forestEmerald, size: 400),
            ),
            Positioned(
              bottom: -100,
              left: -50,
              child: _GlowOrb(
                color: AppTheme.forestEmerald.withValues(alpha: 0.5),
                size: 300,
              ),
            ),

            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isDesktop = constraints.maxWidth > 800;
                  const double verticalPadding = 32.0;
                  final double horizontalPadding = isDesktop ? 0 : 24.0;
                  final double minScrollableHeight =
                      (constraints.maxHeight - (verticalPadding * 2))
                          .clamp(0.0, double.infinity)
                          .toDouble();

                  final authCard = Container(
                    width: isDesktop ? 480 : double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: isDesktop
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 50,
                                spreadRadius: 10,
                                offset: const Offset(0, 20),
                              ),
                            ]
                          : null,
                    ),
                    child: _GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 40,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildLogo(),
                            const SizedBox(height: 40),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              switchInCurve: Curves.easeOutQuart,
                              switchOutCurve: Curves.easeInQuart,
                              child: widget.adminOnly
                                  ? _buildStaffView()
                                  : (!_isStaffView
                                      ? _buildStudentView()
                                      : _buildStaffView()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );

                  final content = ScrollConfiguration(
                    behavior: const MaterialScrollBehavior().copyWith(
                      scrollbars: false,
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: verticalPadding,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: minScrollableHeight,
                        ),
                        child: Center(child: authCard),
                      ),
                    ),
                  );

                  return Stack(
                    children: [
                      content,
                      if (!widget.adminOnly)
                        Positioned(top: 20, right: 24, child: _buildLockButton()),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Widget Builders ====================

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.spa_rounded,
            color: AppTheme.forestEmerald,
            size: 40,
          ),
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 16),
        Text(
          'GreenMatch',
          style: GoogleFonts.montserrat(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -1.0,
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 6),
        Text(
          _isStaffView ? 'Staff Portal' : 'Student Portal',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white54,
            letterSpacing: 2.0,
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
      ],
    );
  }

  Widget _buildLockButton() {
    return Tooltip(
      message: _isStaffView ? 'Switch to Student' : 'Staff Access',
      child: GestureDetector(
        onTap: _toggleStaffView,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _isStaffView
                ? AppTheme.forestEmerald
                : Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: _isStaffView
                  ? AppTheme.forestEmerald
                  : Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              _isStaffView
                  ? Icons.lock_open_rounded
                  : Icons.admin_panel_settings_rounded,
              color: _isStaffView ? Colors.white : Colors.white60,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentView() {
    return Column(
      key: const ValueKey('student_view'),
      children: [
        if (_showStudentLogin)
          _buildStudentLoginForm()
        else
          _buildStudentSignupForm(),
        const SizedBox(height: 24),
        _buildAuthDivider(),
        const SizedBox(height: 24),
        _buildStudentToggleButton(),
      ],
    );
  }

  Widget _buildStudentLoginForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Form(
          key: _studentLoginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GlassTextField(
                label: 'Email Address',
                controller: _studentEmailController,
                focusNode: _studentEmailFocus,
                hintText: 'your.email@university.edu',
                keyboardType: TextInputType.emailAddress,
                icon: Icons.alternate_email_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Email is required';
                  if (!RegExp(r'^[\w-\.]+@[\w-\.]+\.\w+$').hasMatch(value))
                    return 'Enter a valid email address';
                  return null;
                },
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
              const SizedBox(height: 20),
              _GlassTextField(
                label: 'Password',
                controller: _studentPasswordController,
                focusNode: _studentPasswordFocus,
                hintText: 'Enter your password',
                obscureText: !_showPassword,
                icon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white38,
                    size: 20,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Password is required';
                  if (value.length < 6)
                    return 'Password must be at least 6 characters';
                  return null;
                },
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _rememberMe
                                  ? AppTheme.forestEmerald
                                  : Colors.white24,
                            ),
                            color: _rememberMe
                                ? AppTheme.forestEmerald
                                : Colors.transparent,
                          ),
                          child: _rememberMe
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Remember me',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: Colors.white60,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Forgot password?',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: AppTheme.forestEmerald,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 32),
              if (authProvider.errorMessage != null)
                _buildErrorBox(authProvider.errorMessage!),
              _buildSubmitButton(
                    label: 'Sign In',
                    isLoading: authProvider.isLoading,
                    onPressed: () => _handleStudentLogin(context),
                  )
                  .animate()
                  .fadeIn(delay: 500.ms)
                  .scale(begin: const Offset(0.95, 0.95)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentSignupForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Form(
          key: _studentSignupFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GlassTextField(
                label: 'Full Name',
                controller: _signupFullNameController,
                focusNode: _signupFullNameFocus,
                hintText: 'John Doe',
                icon: Icons.person_outline_rounded,
                validator: (value) => value == null || value.isEmpty
                    ? 'Full name is required'
                    : null,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              _GlassTextField(
                label: 'Student ID',
                controller: _signupStudentIdController,
                focusNode: _signupStudentIdFocus,
                hintText: 'e.g., STU-123456',
                icon: Icons.badge_outlined,
                validator: (value) => value == null || value.isEmpty
                    ? 'Student ID is required'
                    : null,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              _GlassTextField(
                label: 'Degree Programme',
                controller: _signupDegreeController,
                focusNode: _signupDegreeFocus,
                hintText: 'e.g., BSc Computer Science',
                icon: Icons.menu_book_outlined,
                validator: (value) => value == null || value.isEmpty
                    ? 'Degree programme is required'
                    : null,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              _GlassTextField(
                label: 'Email Address',
                controller: _signupEmailController,
                focusNode: _signupEmailFocus,
                hintText: 'your.email@university.edu',
                keyboardType: TextInputType.emailAddress,
                icon: Icons.alternate_email_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Email is required';
                  if (!RegExp(r'^[\w-\.]+@[\w-\.]+\.\w+$').hasMatch(value))
                    return 'Enter a valid email address';
                  return null;
                },
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              _GlassTextField(
                label: 'Password',
                controller: _signupPasswordController,
                focusNode: _signupPasswordFocus,
                hintText: 'Create a strong password',
                obscureText: !_showPassword,
                icon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white38,
                    size: 20,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Password is required';
                  if (value.length < 8)
                    return 'Password must be at least 8 characters';
                  return null;
                },
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
              const SizedBox(height: 32),
              if (authProvider.errorMessage != null)
                _buildErrorBox(authProvider.errorMessage!),
              _buildSubmitButton(
                    label: 'Create Account',
                    isLoading: authProvider.isLoading,
                    onPressed: () => _handleStudentSignup(context),
                  )
                  .animate()
                  .fadeIn(delay: 600.ms)
                  .scale(begin: const Offset(0.95, 0.95)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentToggleButton() {
    return Center(
      child: GestureDetector(
        onTap: _toggleStudentForm,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: _showStudentLogin
                    ? "Don't have an account? "
                    : 'Already have an account? ',
                style: GoogleFonts.montserrat(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: _showStudentLogin ? 'Create Account' : 'Sign In',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 700.ms);
  }

  Widget _buildStaffView() {
    return Column(
      key: const ValueKey('staff_view'),
      children: [
        _buildStaffRoleSelector()
            .animate()
            .fadeIn(delay: 100.ms)
            .slideY(begin: 0.1),
        const SizedBox(height: 32),
        _buildStaffLoginForm(),
      ],
    );
  }

  Widget _buildStaffRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRoleButton(
              label: 'Supervisor',
              isSelected: _staffRole == 'supervisor',
              onTap: () => setState(() => _staffRole = 'supervisor'),
            ),
          ),
          Expanded(
            child: _buildRoleButton(
              label: 'Module Leader',
              isSelected: _staffRole == 'module_leader',
              onTap: () => setState(() => _staffRole = 'module_leader'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: Colors.white.withValues(alpha: 0.2))
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            color: isSelected ? Colors.white : Colors.white54,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStaffLoginForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Form(
          key: _staffLoginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GlassTextField(
                label: 'Staff Email',
                controller: _staffEmailController,
                focusNode: _staffEmailFocus,
                hintText: 'staff.email@university.edu',
                keyboardType: TextInputType.emailAddress,
                icon: Icons.alternate_email_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Email is required';
                  if (!RegExp(r'^[\w-\.]+@[\w-\.]+\.\w+$').hasMatch(value))
                    return 'Enter a valid email address';
                  return null;
                },
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
              const SizedBox(height: 20),
              _GlassTextField(
                label: 'Password',
                controller: _staffPasswordController,
                focusNode: _staffPasswordFocus,
                hintText: 'Enter your password',
                obscureText: !_showPassword,
                icon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white38,
                    size: 20,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Password is required'
                    : null,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
              const SizedBox(height: 32),
              if (authProvider.errorMessage != null)
                _buildErrorBox(authProvider.errorMessage!),
              _buildSubmitButton(
                    label: 'Sign In',
                    isLoading: authProvider.isLoading,
                    onPressed: () => _handleStaffLogin(context),
                  )
                  .animate()
                  .fadeIn(delay: 400.ms)
                  .scale(begin: const Offset(0.95, 0.95)),
              const SizedBox(height: 24),
              _buildAuthDivider(),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Staff accounts must be provisioned by IT Support.',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.white38,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAuthDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.white.withValues(alpha: 0.1),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.white.withValues(alpha: 0.1),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.forestEmerald,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.forestEmerald.withValues(
            alpha: 0.5,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
      ),
    );
  }

  Widget _buildErrorBox(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.montserrat(
                color: Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().shake(duration: 400.ms, hz: 4);
  }
}

// ============================================================================
// PRIVATE COMPONENTS
// ============================================================================

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
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

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: size / 2,
            spreadRadius: size / 4,
          ),
        ],
      ),
    );
  }
}

class _GlassTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final bool obscureText;
  final IconData icon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _GlassTextField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.focusNode,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.montserrat(fontSize: 15, color: Colors.white),
          cursorColor: AppTheme.forestEmerald,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.montserrat(
              color: Colors.white24,
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, color: Colors.white38, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.2),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppTheme.forestEmerald,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            errorStyle: GoogleFonts.montserrat(
              color: Colors.redAccent,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
