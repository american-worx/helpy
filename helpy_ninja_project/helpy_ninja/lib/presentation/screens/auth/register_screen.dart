import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/design_tokens.dart';
import '../../../config/routes.dart';
import '../../../data/providers/providers.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';
import '../../widgets/auth/auth_form_field.dart';
import '../../widgets/auth/glassmorphic_container.dart';
import '../../widgets/common/gradient_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: DesignTokens.animationNormal,
      vsync: this,
    );

    _slideController = AnimationController(
      duration: DesignTokens.animationNormal,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Listen to auth state changes
    ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        // New users go to onboarding first
        context.go(AppRoutes.welcome);
      } else if (next.hasError) {
        _showErrorSnackBar(next.error!);
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              DesignTokens.backgroundDark,
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(DesignTokens.spaceL),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Header
                        _buildHeader(l10n, colorScheme),

                        const SizedBox(height: DesignTokens.spaceXXL),

                        // Registration form
                        _buildRegistrationForm(l10n, authState),

                        const SizedBox(height: DesignTokens.spaceL),

                        // Login link
                        _buildLoginLink(l10n, colorScheme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, ColorScheme colorScheme) {
    return Column(
      children: [
        // Logo with different gradient for register
        Container(
          padding: const EdgeInsets.all(DesignTokens.spaceL),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                DesignTokens.primary.withValues(alpha: 0.3),
                DesignTokens.accent.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
          ),
          child: const Icon(
            Icons.person_add_rounded,
            size: 80,
            color: DesignTokens.primary,
          ),
        ),

        const SizedBox(height: DesignTokens.spaceL),

        Text(
          'Join Helpy Ninja',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: DesignTokens.spaceS),

        Text(
          'Start your AI-powered learning journey',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegistrationForm(AppLocalizations l10n, AuthState authState) {
    return GlassmorphicContainer(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Name field
            AuthFormField(
              controller: _nameController,
              label: 'Full Name',
              keyboardType: TextInputType.name,
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                if (value.length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: DesignTokens.spaceM),

            // Email field
            AuthFormField(
              controller: _emailController,
              label: l10n.email,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),

            const SizedBox(height: DesignTokens.spaceM),

            // Password field
            AuthFormField(
              controller: _passwordController,
              label: l10n.password,
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                if (!RegExp(
                  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)',
                ).hasMatch(value)) {
                  return 'Password must contain uppercase, lowercase, and number';
                }
                return null;
              },
            ),

            const SizedBox(height: DesignTokens.spaceM),

            // Confirm Password field
            AuthFormField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              obscureText: _obscureConfirmPassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),

            const SizedBox(height: DesignTokens.spaceM),

            // Terms and conditions checkbox
            _buildTermsCheckbox(),

            const SizedBox(height: DesignTokens.spaceL),

            // Register button
            GradientButton(
              onPressed: authState.isLoading || !_agreeToTerms
                  ? null
                  : _handleRegister,
              text: l10n.register,
              isLoading: authState.isLoading,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (value) {
            setState(() {
              _agreeToTerms = value ?? false;
            });
          },
          activeColor: DesignTokens.accent,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _agreeToTerms = !_agreeToTerms;
              });
            },
            child: Text(
              'I agree to the Terms of Service and Privacy Policy',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink(AppLocalizations l10n, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.alreadyHaveAccount + ' ',
          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        TextButton(
          onPressed: () {
            context.go(AppRoutes.login);
          },
          child: Text(
            l10n.login,
            style: const TextStyle(
              color: DesignTokens.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreeToTerms) {
        _showErrorSnackBar('Please agree to the terms and conditions');
        return;
      }

      await ref
          .read(authProvider.notifier)
          .signUpWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
          );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: DesignTokens.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        ),
      ),
    );
  }
}
