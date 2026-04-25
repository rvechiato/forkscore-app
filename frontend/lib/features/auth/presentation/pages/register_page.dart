import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/action_buttons.dart';
import '../../../../shared/widgets/forkscore_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.onBack, required this.onSubmit});

  final VoidCallback onBack;
  final VoidCallback onSubmit;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  key: const Key('register-back-button'),
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              Text(
                'Criar Conta',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _FieldLabel(
            text: 'Nome Completo',
            child: ForkScoreTextField(
              key: const Key('register-name-field'),
              controller: _nameController,
              hintText: 'Seu nome',
            ),
          ),
          const SizedBox(height: 14),
          _FieldLabel(
            text: 'Email',
            child: ForkScoreTextField(
              key: const Key('register-email-field'),
              controller: _emailController,
              hintText: 'seunome@email.com',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          const SizedBox(height: 14),
          _FieldLabel(
            text: 'Data de Nascimento',
            child: ForkScoreTextField(
              key: const Key('register-birth-date-field'),
              controller: _birthDateController,
              hintText: 'dd/mm/aaaa',
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
              keyboardType: TextInputType.datetime,
            ),
          ),
          const SizedBox(height: 14),
          _FieldLabel(
            text: 'Senha',
            child: ForkScoreTextField(
              key: const Key('register-password-field'),
              controller: _passwordController,
              hintText: 'Senha',
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          ForkScoreTextField(
            key: const Key('register-confirm-password-field'),
            controller: _confirmPasswordController,
            hintText: 'Confirmar Senha',
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              onPressed: () {
                setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                );
              },
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 28),
          SecondaryActionButton(label: 'Criar Conta', onPressed: _submit),
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
                onPressed: widget.onBack,
                child: Text(
                  'Login',
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
        ],
      ),
    );
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _birthDateController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatorios.')),
      );
      return;
    }

    widget.onSubmit();
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, required this.child});

  final String text;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        child,
      ],
    );
  }
}
