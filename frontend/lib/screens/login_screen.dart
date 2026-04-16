import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/login_design.dart';
import '../services/auth_provider.dart';
import '../widgets/academic_text_field.dart';
import 'supervisor_dashboard.dart';
import 'student_dashboard.dart';
import 'module_leader_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // View state
  bool _isStaffView = false;
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
        const SnackBar(content: Text('Login successful!')),
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
          builder: (context) => _staffRole == 'supervisor'
              ? const SupervisorDashboard()
              : const ModuleLeaderDashboard(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LoginSpacing.large,
                  vertical: LoginSpacing.medium,
                ),
                child: Column(
                  children: [
                    // Top spacing
                    const SizedBox(height: LoginSpacing.medium),

                    // Logo/Branding
                    _buildLogo(),

                    const SizedBox(height: LoginSpacing.xlarge),

                    // Student or Staff View
                    if (!_isStaffView)
                      _buildStudentView()
                    else
                      _buildStaffView(),

                    const SizedBox(height: LoginSpacing.large),
                  ],
                ),
              ),
            ),

            // Hidden Lock Icon
            Positioned(
              top: LoginSpacing.medium,
              right: LoginSpacing.medium,
              child: _buildLockButton(),
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
        Text(
          'GreenMatch',
          style: LoginTypography.headline.copyWith(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: LoginSpacing.xsmall),
        Text(
          _isStaffView ? 'Staff Access' : 'Student Portal',
          style: LoginTypography.subheadline.copyWith(
            fontSize: 14,
            color: LoginColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
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
            color: _isStaffView ? LoginColors.accent : LoginColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: LoginColors.border, width: 0.5),
          ),
          child: Center(
            child: Icon(
              _isStaffView ? Icons.lock_open : Icons.lock,
              color: _isStaffView ? LoginColors.surface : LoginColors.accent,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentView() {
    return Column(
      children: [
        if (_showStudentLogin)
          _buildStudentLoginForm()
        else
          _buildStudentSignupForm(),
        const SizedBox(height: LoginSpacing.medium),
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
              // Email Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email Address', style: LoginTypography.label),
                  const SizedBox(height: LoginSpacing.small),
                  AcademicTextField(
                    controller: _studentEmailController,
                    focusNode: _studentEmailFocus,
                    hintText: 'your.email@university.edu',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@[\w-\.]+\.\w+$',
                      ).hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: LoginSpacing.large),

              // Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Password', style: LoginTypography.label),
                  const SizedBox(height: LoginSpacing.small),
                  AcademicTextField(
                    controller: _studentPasswordController,
                    focusNode: _studentPasswordFocus,
                    hintText: 'Enter your password',
                    obscureText: !_showPassword,
                    onSuffixIconTap: _togglePasswordVisibility,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: LoginSpacing.medium),

              // Remember Me & Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _rememberMe = !_rememberMe;
                      });
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: LoginSpacing.small),
                        Text('Remember me', style: LoginTypography.body),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Implement forgot password
                    },
                    child: Text(
                      'Forgot password?',
                      style: LoginTypography.link.copyWith(
                        color: LoginColors.link,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: LoginSpacing.xlarge),

              // Error Message
              if (authProvider.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(LoginSpacing.medium),
                  decoration: BoxDecoration(
                    color: LoginColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: LoginColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: LoginColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: LoginSpacing.small),
                      Expanded(
                        child: Text(
                          authProvider.errorMessage!,
                          style: LoginTypography.body.copyWith(
                            color: LoginColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (authProvider.errorMessage != null)
                const SizedBox(height: LoginSpacing.large),

              // Sign In Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () => _handleStudentLogin(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LoginColors.accent,
                    disabledBackgroundColor: LoginColors.accentSoft,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: authProvider.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              LoginColors.surface,
                            ),
                          ),
                        )
                      : Text('Sign In', style: LoginTypography.button),
                ),
              ),
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
              // Full Name Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Full Name', style: LoginTypography.label),
                  const SizedBox(height: LoginSpacing.small),
                  AcademicTextField(
                    controller: _signupFullNameController,
                    focusNode: _signupFullNameFocus,
                    hintText: 'John Doe',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Full name is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: LoginSpacing.large),

              // Student ID Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Student ID', style: LoginTypography.label),
                  const SizedBox(height: LoginSpacing.small),
                  AcademicTextField(
                    controller: _signupStudentIdController,
                    focusNode: _signupStudentIdFocus,
                    hintText: 'e.g., STU-123456',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Student ID is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: LoginSpacing.large),

              // Degree Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Degree Programme', style: LoginTypography.label),
                  const SizedBox(height: LoginSpacing.small),
                  AcademicTextField(
                    controller: _signupDegreeController,
                    focusNode: _signupDegreeFocus,
                    hintText: 'e.g., BSc Computer Science',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Degree programme is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: LoginSpacing.large),

              // Email Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email Address', style: LoginTypography.label),
                  const SizedBox(height: LoginSpacing.small),
                  AcademicTextField(
                    controller: _signupEmailController,
                    focusNode: _signupEmailFocus,
                    hintText: 'your.email@university.edu',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@[\w-\.]+\.\w+$',
                      ).hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: LoginSpacing.large),

              // Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Password', style: LoginTypography.label),
                  const SizedBox(height: LoginSpacing.small),
                  AcademicTextField(
                    controller: _signupPasswordController,
                    focusNode: _signupPasswordFocus,
                    hintText: 'Create a strong password',
                    obscureText: !_showPassword,
                    onSuffixIconTap: _togglePasswordVisibility,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: LoginSpacing.xlarge),

              // Error Message
              if (authProvider.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(LoginSpacing.medium),
                  decoration: BoxDecoration(
                    color: LoginColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: LoginColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: LoginColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: LoginSpacing.small),
                      Expanded(
                        child: Text(
                          authProvider.errorMessage!,
                          style: LoginTypography.body.copyWith(
                            color: LoginColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (authProvider.errorMessage != null)
                const SizedBox(height: LoginSpacing.large),

              // Create Account Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () => _handleStudentSignup(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LoginColors.accent,
                    disabledBackgroundColor: LoginColors.accentSoft,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: authProvider.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              LoginColors.surface,
                            ),
                          ),
                        )
                      : Text('Create Account', style: LoginTypography.button),
                ),
              ),
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
                style: LoginTypography.body,
              ),
              TextSpan(
                text: _showStudentLogin ? 'Create Account' : 'Sign In',
                style: LoginTypography.link.copyWith(
                  color: LoginColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaffView() {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          // Staff Role Selector
          _buildStaffRoleSelector(),
          const SizedBox(height: LoginSpacing.xlarge),

          // Staff Login Form
          _buildStaffLoginForm(),
        ],
      ),
    );
  }

  Widget _buildStaffRoleSelector() {
    return Container(
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRoleButton(
              label: 'Supervisor',
              value: 'supervisor',
              isSelected: _staffRole == 'supervisor',
              onTap: () {
                setState(() {
                  _staffRole = 'supervisor';
                });
              },
            ),
          ),
          Expanded(
            child: _buildRoleButton(
              label: 'Module Leader',
              value: 'module_leader',
              isSelected: _staffRole == 'module_leader',
              onTap: () {
                setState(() {
                  _staffRole = 'module_leader';
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton({
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: LoginSpacing.medium,
          vertical: LoginSpacing.medium,
        ),
        decoration: BoxDecoration(
          color: isSelected ? LoginColors.accent : LoginColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: LoginTypography.label.copyWith(
            color: isSelected ? LoginColors.surface : LoginColors.textPrimary,
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
              // Email Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email Address', style: LoginTypography.label),
                  const SizedBox(height: LoginSpacing.small),
                  AcademicTextField(
                    controller: _staffEmailController,
                    focusNode: _staffEmailFocus,
                    hintText: 'staff.email@university.edu',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@[\w-\.]+\.\w+$',
                      ).hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: LoginSpacing.large),

              // Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Password', style: LoginTypography.label),
                  const SizedBox(height: LoginSpacing.small),
                  AcademicTextField(
                    controller: _staffPasswordController,
                    focusNode: _staffPasswordFocus,
                    hintText: 'Enter your password',
                    obscureText: !_showPassword,
                    onSuffixIconTap: _togglePasswordVisibility,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: LoginSpacing.xlarge),

              // Error Message
              if (authProvider.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(LoginSpacing.medium),
                  decoration: BoxDecoration(
                    color: LoginColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: LoginColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: LoginColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: LoginSpacing.small),
                      Expanded(
                        child: Text(
                          authProvider.errorMessage!,
                          style: LoginTypography.body.copyWith(
                            color: LoginColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (authProvider.errorMessage != null)
                const SizedBox(height: LoginSpacing.large),

              // Sign In Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () => _handleStaffLogin(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LoginColors.accent,
                    disabledBackgroundColor: LoginColors.accentSoft,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: authProvider.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              LoginColors.surface,
                            ),
                          ),
                        )
                      : Text('Sign In', style: LoginTypography.button),
                ),
              ),

              const SizedBox(height: LoginSpacing.medium),

              // Info note
              Container(
                padding: const EdgeInsets.all(LoginSpacing.medium),
                decoration: BoxDecoration(
                  color: LoginColors.panel,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: LoginColors.border),
                ),
                child: Text(
                  'Staff accounts are created by administrators only.',
                  style: LoginTypography.body.copyWith(
                    fontSize: 13,
                    color: LoginColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
