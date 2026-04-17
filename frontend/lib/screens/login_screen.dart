import 'package:flutter/material.dart';
import '../theme/login_design.dart';
import '../widgets/academic_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _showPassword = false;
  bool _rememberMe = true;
  bool _submitted = false;

  late final AnimationController _logoTransitionController;

  @override
  void initState() {
    super.initState();
    _logoTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
  }

  @override
  void dispose() {
    _logoTransitionController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address.';
    }
    const emailPattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}";
    if (!RegExp(emailPattern).hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your password.';
    }
    if (value.trim().length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }

  void _submit() {
    setState(() {
      _submitted = true;
    });

    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      debugPrint('Login submitted: email=$email, password=${'*' * password.length}, remember=$_rememberMe');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credentials captured. Redirecting to dashboard...'),
          duration: Duration(milliseconds: 1600),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 860;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: LoginColors.background,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: isWide ? _buildWideLayout() : _buildCompactLayout(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: AnimatedBuilder(
            animation: _logoTransitionController,
            builder: (context, child) {
              return Opacity(
                opacity: _logoTransitionController.value,
                child: Transform.translate(
                  offset: Offset(-24 * (1 - _logoTransitionController.value), 0),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: LoginColors.panel,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  bottomLeft: Radius.circular(28),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: LoginColors.shadow,
                    blurRadius: 28,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Academic Access', style: LoginTypography.headline.copyWith(fontSize: 38)),
                  const SizedBox(height: LoginSpacing.small),
                  Text(
                    'A calm, structured login experience designed for modern institutions. Clear hierarchy, generous white space, and subtle monochrome refinement.',
                    style: LoginTypography.subheadline,
                  ),
                  const SizedBox(height: LoginSpacing.large),
                  _buildFeatureItem('Minimalist visual system'),
                  const SizedBox(height: LoginSpacing.small),
                  _buildFeatureItem('Access for students, staff, and faculty'),
                  const SizedBox(height: LoginSpacing.small),
                  _buildFeatureItem('Professional contrast and clean forms'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(flex: 6, child: _buildFormPanel()),
      ],
    );
  }

  Widget _buildCompactLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: LoginColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: LoginColors.shadow,
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Academic Access', style: LoginTypography.headline),
              const SizedBox(height: LoginSpacing.small),
              Text(
                'Login to your institutional workspace with a design that feels polished, calm, and easy to scan.',
                style: LoginTypography.subheadline,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _buildFormPanel(),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: LoginColors.accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: LoginSpacing.small),
        Expanded(child: Text(text, style: LoginTypography.body)),
      ],
    );
  }

  Widget _buildFormPanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: LoginColors.shadow,
            blurRadius: 32,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: _submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Welcome back', style: LoginTypography.headline),
            const SizedBox(height: LoginSpacing.small),
            Text(
              'Enter your details to continue with your academic portal.',
              style: LoginTypography.subheadline,
            ),
            const SizedBox(height: LoginSpacing.large),
            AcademicTextField(
              label: 'Email address',
              hintText: 'example@institution.edu',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              focusNode: _emailFocus,
              errorText: _submitted ? _validateEmail(_emailController.text) : null,
              validator: _validateEmail,
              autofillHints: const [AutofillHints.email],
              onChanged: (_) {
                if (_submitted) setState(() {});
              },
            ),
            const SizedBox(height: LoginSpacing.medium),
            AcademicTextField(
              label: 'Password',
              hintText: 'Enter your password',
              controller: _passwordController,
              obscureText: !_showPassword,
              focusNode: _passwordFocus,
              errorText: _submitted ? _validatePassword(_passwordController.text) : null,
              validator: _validatePassword,
              autofillHints: const [AutofillHints.password],
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _showPassword = !_showPassword),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                    color: LoginColors.accentSoft,
                    size: 22,
                  ),
                ),
              ),
              onChanged: (_) {
                if (_submitted) setState(() {});
              },
            ),
            const SizedBox(height: LoginSpacing.small),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => setState(() => _rememberMe = !_rememberMe),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) => setState(() => _rememberMe = value ?? true),
                          activeColor: LoginColors.accent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        const SizedBox(width: 8),
                        Text('Remember me', style: LoginTypography.body.copyWith(color: LoginColors.textPrimary)),
                      ],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: LoginColors.accent,
                    textStyle: LoginTypography.link,
                  ),
                  child: const Text('Forgot password?'),
                ),
              ],
            ),
            const SizedBox(height: LoginSpacing.medium),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: LoginColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text('Sign in', style: LoginTypography.button),
            ),
            const SizedBox(height: LoginSpacing.large),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('New to the portal?', style: LoginTypography.body),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    foregroundColor: LoginColors.accent,
                    textStyle: LoginTypography.link,
                  ),
                  child: const Text('Create account'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
