import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/auth_controller.dart';

/// Screen widget providing the user authentication login form interface.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthController _authController = Get.put(AuthController());

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Triggers user sign-in process via the authentication controller.
  Future<void> _handleSignIn() async {
    await _authController.login(
      email: _emailController.text,
      password: _passwordController.text,
      formKey: _formKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 28,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/gopang_logo.png',
                      height: 76,
                      width: 190,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.business_rounded,
                          size: 48,
                          color: AppTheme.primary,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.045),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppTheme.blueLight,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.lock_person_outlined,
                                color: AppTheme.primary,
                                size: 25,
                              ),
                            ),
                            const SizedBox(height: 22),
                            const Text(
                              'Welcome back',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Sign in to access your internship workspace.',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 28),
                            const _FieldLabel('Email address'),
                            const SizedBox(height: 9),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [
                                AutofillHints.username,
                                AutofillHints.email,
                              ],
                              autocorrect: false,
                              enableSuggestions: false,
                              decoration: const InputDecoration(
                                hintText: 'Enter your email address',
                                prefixIcon: Icon(
                                  Icons.mail_outline_rounded,
                                ),
                              ),
                              validator: (value) {
                                final email = value?.trim() ?? '';

                                if (email.isEmpty) {
                                  return 'Email address is required';
                                }

                                final emailPattern = RegExp(
                                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                );

                                if (!emailPattern.hasMatch(email)) {
                                  return 'Enter a valid email address';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 22),
                            const _FieldLabel('Password'),
                            const SizedBox(height: 9),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [
                                AutofillHints.password,
                              ],
                              onFieldSubmitted: (_) => _handleSignIn(),
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                ),
                                suffixIcon: IconButton(
                                  tooltip: _obscurePassword
                                      ? 'Show password'
                                      : 'Hide password',
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 28),
                            Obx(
                                  () => SizedBox(
                                height: 54,
                                child: FilledButton(
                                  onPressed: _authController.isLoading.value
                                      ? null
                                      : _handleSignIn,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                    AppTheme.primary.withValues(
                                      alpha: 0.65,
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                  ),
                                  child: _authController.isLoading.value
                                      ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                      : const Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Sign in',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 19,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 15,
                        color: AppTheme.textMuted,
                      ),
                      SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          'Gopang IT Solutions · Intern Access',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper label widget for form input field headers.
class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}