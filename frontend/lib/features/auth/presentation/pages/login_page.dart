import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/action_buttons.dart';
import '../../../../shared/widgets/forkscore_logo.dart';
import '../../../../shared/widgets/forkscore_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.onEnter,
    required this.onCreateAccount,
  });

  final VoidCallback onEnter;
  final VoidCallback onCreateAccount;

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final useWideLayout = constraints.maxWidth >= 900;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            useWideLayout ? 56 : 32,
            useWideLayout ? 48 : 56,
            useWideLayout ? 56 : 32,
            36,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: useWideLayout
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: _AuthBrandPanel(
                            title:
                                'Avalie experiencias que realmente valem a pena.',
                            description:
                                'Registre sabor, atendimento e custo-beneficio em uma experiencia visual coerente com o universo ForkScore.',
                          ),
                        ),
                        const SizedBox(width: 56),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _LoginFormCard(
                              emailController: _emailController,
                              passwordController: _passwordController,
                              obscure: _obscure,
                              onToggleObscure: () {
                                setState(() => _obscure = !_obscure);
                              },
                              onSubmit: _submit,
                              onCreateAccount: widget.onCreateAccount,
                            ),
                          ),
                        ),
                      ],
                    )
                  : _LoginFormCard(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      obscure: _obscure,
                      onToggleObscure: () {
                        setState(() => _obscure = !_obscure);
                      },
                      onSubmit: _submit,
                      onCreateAccount: widget.onCreateAccount,
                    ),
            ),
          ),
        );
      },
    );
  }

  void _submit() {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha email e senha para entrar.')),
      );
      return;
    }

    widget.onEnter();
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
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    final useCard = MediaQuery.sizeOf(context).width >= 900;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: DecoratedBox(
        decoration: useCard
            ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppTheme.inputBorder),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 22,
                    offset: Offset(0, 14),
                  ),
                ],
              )
            : const BoxDecoration(),
        child: Padding(
          padding: EdgeInsets.all(useCard ? 36 : 0),
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
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Entre para continuar suas avaliacoes gastronomicas.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
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
              PrimaryActionButton(label: 'Entrar', onPressed: onSubmit),
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
                    decorationThickness: 1,
                    color: AppTheme.charcoal,
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
                    decorationColor: AppTheme.charcoal,
                    color: AppTheme.charcoal,
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

class _AuthBrandPanel extends StatelessWidget {
  const _AuthBrandPanel({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFFF6E8E1), Color(0xFFE9EFE8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ForkScoreLogo(
            showWordmark: true,
            markWidth: 96,
            wordmarkSize: 36,
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontSize: 54, height: 0.95),
          ),
          const SizedBox(height: 18),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _BrandBadge(icon: Icons.restaurant_menu_rounded, label: 'Sabor'),
              _BrandBadge(
                icon: Icons.room_service_outlined,
                label: 'Atendimento',
              ),
              _BrandBadge(
                icon: Icons.thumb_up_alt_outlined,
                label: 'Recomendacao',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrandBadge extends StatelessWidget {
  const _BrandBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.terracotta),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
