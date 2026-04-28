import 'package:flutter/material.dart';

import '../../../../app/auth_scope.dart';
import '../../../../app/navigation/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/action_buttons.dart';
import '../../../../shared/widgets/forkscore_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.redirectAfterAuth});

  final String? redirectAfterAuth;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionController = SessionScope.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final useWideLayout = constraints.maxWidth >= 900;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            useWideLayout ? 56 : 24,
            useWideLayout ? 40 : 16,
            useWideLayout ? 56 : 24,
            28,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: useWideLayout
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _RegisterIntroPanel(onBack: _goToLogin),
                        ),
                        const SizedBox(width: 56),
                        Expanded(
                          child: _RegisterFormCard(
                            nameController: _nameController,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            confirmPasswordController:
                                _confirmPasswordController,
                            obscurePassword: _obscurePassword,
                            obscureConfirmPassword: _obscureConfirmPassword,
                            onTogglePassword: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                            onToggleConfirmPassword: () {
                              setState(
                                () => _obscureConfirmPassword =
                                    !_obscureConfirmPassword,
                              );
                            },
                            onSubmit: _submit,
                            onBack: _goToLogin,
                            isBusy: sessionController.isBusy,
                          ),
                        ),
                      ],
                    )
                  : _RegisterFormCard(
                      nameController: _nameController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      obscurePassword: _obscurePassword,
                      obscureConfirmPassword: _obscureConfirmPassword,
                      onTogglePassword: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      onToggleConfirmPassword: () {
                        setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        );
                      },
                      onSubmit: _submit,
                      onBack: _goToLogin,
                      isBusy: sessionController.isBusy,
                    ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatorios.')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas precisam ser iguais.')),
      );
      return;
    }

    final sessionController = SessionScope.of(context, listen: false);
    await sessionController.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (!sessionController.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sessionController.errorMessage ??
                'Nao foi possivel criar a conta agora.',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      widget.redirectAfterAuth ?? AppRoutes.home,
      (route) => false,
    );
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.login,
      arguments: LoginRouteArgs(redirectAfterLogin: widget.redirectAfterAuth),
    );
  }
}

class _RegisterIntroPanel extends StatelessWidget {
  const _RegisterIntroPanel({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.accentYellow.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            key: const Key('register-back-button'),
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Voltar ao login'),
          ),
          const SizedBox(height: 28),
          Text(
            'Crie sua conta e comece a recomendar lugares incriveis.',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontSize: 38, height: 1.1),
          ),
          const SizedBox(height: 18),
          Text(
            'A mesma identidade visual e os mesmos componentes continuam aqui, agora organizados para uma experiencia web mais ampla.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _RegisterFormCard extends StatelessWidget {
  const _RegisterFormCard({
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onSubmit,
    required this.onBack,
    required this.isBusy,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final Future<void> Function() onSubmit;
  final VoidCallback onBack;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final useCard = MediaQuery.sizeOf(context).width >= 900;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: DecoratedBox(
        decoration: useCard
            ? BoxDecoration(
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
              )
            : const BoxDecoration(),
        child: Padding(
          padding: EdgeInsets.all(useCard ? 36 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!useCard)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        key: const Key('register-back-button'),
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                    Text(
                      'Criar Conta',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                )
              else
                Text(
                  'Criar Conta',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              const SizedBox(height: 24),
              ForkScoreTextField(
                key: const Key('register-name-field'),
                controller: nameController,
                label: 'Nome Completo',
                hintText: 'Seu nome',
              ),
              const SizedBox(height: 14),
              ForkScoreTextField(
                key: const Key('register-email-field'),
                controller: emailController,
                label: 'Email',
                hintText: 'seunome@email.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              ForkScoreTextField(
                key: const Key('register-password-field'),
                controller: passwordController,
                label: 'Senha',
                hintText: 'Senha',
                obscureText: obscurePassword,
                suffixIcon: IconButton(
                  onPressed: onTogglePassword,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ForkScoreTextField(
                key: const Key('register-confirm-password-field'),
                controller: confirmPasswordController,
                label: 'Confirmar Senha',
                hintText: 'Confirmar Senha',
                obscureText: obscureConfirmPassword,
                suffixIcon: IconButton(
                  onPressed: onToggleConfirmPassword,
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SecondaryActionButton(
                label: isBusy ? 'Criando conta...' : 'Criar Conta',
                onPressed: isBusy ? null : () => onSubmit(),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                  const SizedBox(width: 3),
                  Text(
                    'Ja tem conta? ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    key: const Key('register-login-link'),
                    onPressed: onBack,
                    child: Text(
                      'Login',
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
            ],
          ),
        ),
      ),
    );
  }
}
