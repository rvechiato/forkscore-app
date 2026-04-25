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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 56, 32, 36),
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
          const SizedBox(height: 52),
          ForkScoreTextField(
            key: const Key('login-email-field'),
            controller: _emailController,
            hintText: 'Email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined, size: 20),
          ),
          const SizedBox(height: 14),
          ForkScoreTextField(
            key: const Key('login-password-field'),
            controller: _passwordController,
            hintText: 'Senha',
            obscureText: _obscure,
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryActionButton(label: 'Entrar', onPressed: _submit),
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
            onPressed: widget.onCreateAccount,
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
