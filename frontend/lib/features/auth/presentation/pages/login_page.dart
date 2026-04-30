import 'package:flutter/material.dart';

import '../../../../app/auth_scope.dart';
import '../../../../app/navigation/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/action_buttons.dart';
import '../../../../shared/widgets/forkscore_logo.dart';
import '../../../../shared/widgets/forkscore_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.redirectAfterLogin});

  final String? redirectAfterLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionController = SessionScope.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 72),
            child: Center(
              child: _LoginFormCard(
                emailController: _emailController,
                passwordController: _passwordController,
                obscure: _obscure,
                onToggleObscure: () {
                  setState(() => _obscure = !_obscure);
                },
                onSubmit: _submit,
                onCreateAccount: _goToRegister,
                isBusy: sessionController.isBusy,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha email e senha para entrar.')),
      );
      return;
    }

    final sessionController = SessionScope.of(context, listen: false);
    await sessionController.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    if (!sessionController.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sessionController.errorMessage ?? 'Nao foi possivel entrar agora.',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      widget.redirectAfterLogin ?? AppRoutes.home,
      (route) => false,
    );
  }

  void _goToRegister() {
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.register,
      arguments: RegisterRouteArgs(
        redirectAfterAuth: widget.redirectAfterLogin,
      ),
    );
  }
}

class _LoginFormCard extends StatelessWidget {
  const _LoginFormCard({
    required this.emailController,
    required this.passwordController,
    required this.obscure,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onCreateAccount,
    required this.isBusy,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final Future<void> Function() onSubmit;
  final VoidCallback onCreateAccount;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.inputBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: ForkScoreLogo(showWordmark: false, markWidth: 140),
              ),
              const SizedBox(height: 12),
              Text(
                'ForkScore',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.headlineLarge?.copyWith(letterSpacing: -0.3),
              ),
              const SizedBox(height: 2),
              Text(
                'the society',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Entre para continuar suas avaliacoes gastronomicas.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 40),
              ForkScoreTextField(
                key: const Key('login-email-field'),
                controller: emailController,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
              ),
              const SizedBox(height: 14),
              ForkScoreTextField(
                key: const Key('login-password-field'),
                controller: passwordController,
                hintText: 'Senha',
                obscureText: obscure,
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: IconButton(
                  onPressed: onToggleObscure,
                  icon: Icon(
                    obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              PrimaryActionButton(
                label: isBusy ? 'Entrando...' : 'Entrar',
                onPressed: isBusy ? null : () => onSubmit(),
              ),
              const SizedBox(height: 28),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Recuperacao de senha ainda esta em placeholder.',
                      ),
                    ),
                  );
                },
                child: Text(
                  'Esqueceu a senha?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: AppTheme.inputBorderDark,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                key: const Key('go-to-register-button'),
                onPressed: onCreateAccount,
                child: Text(
                  'Criar nova conta',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: AppTheme.textPrimary,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
