import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/design_tokens.dart';
import '../../../config/routes.dart';
import '../../../data/providers/providers.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../widgets/auth/auth_form_field.dart';
import '../../widgets/auth/glassmorphic_container.dart';
import '../../widgets/common/gradient_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _obscurePassword = true;

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
    _emailController.dispose();
    _passwordController.dispose();
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
        context.go(AppRoutes.dashboard);
      } else if (next.hasError) {
        _showErrorSnackBar(next.error!);
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                        // Logo and welcome text
                        _buildHeader(l10n, colorScheme),

                        const SizedBox(height: DesignTokens.spaceXXL),

                        // Login form
                        _buildLoginForm(l10n, authState),

                        const SizedBox(height: DesignTokens.spaceL),

                        // Sign up link
                        _buildSignUpLink(l10n, colorScheme),
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
        // Logo with glow effect
        Container(
          padding: const EdgeInsets.all(DesignTokens.spaceL),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                DesignTokens.accent.withValues(alpha: 0.3),
                DesignTokens.primary.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
          ),
          child: const Icon(
            Icons.psychology_rounded,
            size: 80,
            color: DesignTokens.accent,
          ),
        ),

        const SizedBox(height: DesignTokens.spaceL),

        // Welcome text
        Text(
          l10n.welcome,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: DesignTokens.spaceS),

        Text(
          l10n.personalAITutor,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(AppLocalizations l10n, AuthState authState) {
    return GlassmorphicContainer(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
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
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: DesignTokens.spaceL),

            // Login button
            GradientButton(
              onPressed: authState.isLoading ? null : _handleLogin,
              text: l10n.login,
              isLoading: authState.isLoading,
              width: double.infinity,
            ),

            const SizedBox(height: DesignTokens.spaceM),

            // Forgot password link
            TextButton(
              onPressed: () {
                // TODO: Implement forgot password
                _showComingSoonSnackBar();
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: DesignTokens.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpLink(AppLocalizations l10n, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        TextButton(
          onPressed: () {
            context.go(AppRoutes.register);
          },
          child: Text(
            l10n.register,
            style: const TextStyle(
              color: DesignTokens.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref
          .read(authProvider.notifier)
          .signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
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

  void _showComingSoonSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Coming soon!'),
        backgroundColor: DesignTokens.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        ),
      ),
    );
  }
}
