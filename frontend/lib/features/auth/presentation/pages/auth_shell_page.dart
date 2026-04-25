import 'package:flutter/material.dart';

import '../../domain/models/auth_user.dart';
import '../controllers/session_controller.dart';

enum _AuthMode { login, register }

class AuthShellPage extends StatelessWidget {
  const AuthShellPage({
    super.key,
    required this.controller,
  });

  final SessionController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F1E7), Color(0xFFE6D0B2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1024),
                child: ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) {
                    final vertical = MediaQuery.sizeOf(context).width < 840;
                    return vertical
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _HeroPanel(
                                currentUser: controller.currentUser,
                              ),
                              const SizedBox(height: 24),
                              controller.isAuthenticated
                                  ? _ProfileCard(controller: controller)
                                  : _AuthCard(controller: controller),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _HeroPanel(
                                  currentUser: controller.currentUser,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: controller.isAuthenticated
                                    ? _ProfileCard(controller: controller)
                                    : _AuthCard(controller: controller),
                              ),
                            ],
                          );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.currentUser});

  final AuthUser? currentUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF2B1D15),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFDEA55E),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'auth-profile-mvp',
                style: TextStyle(
                  color: Color(0xFF2B1D15),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              currentUser == null ? 'ForkScore' : 'Bem-vinda, ${currentUser!.name}',
              style: theme.textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              currentUser == null
                  ? 'Crie sua conta, entre com email e senha e mantenha seu '
                        'perfil basico sincronizado com a API.'
                  : 'Seu email continua sendo o atributo canonico, e a idade '
                        'mostrada abaixo vem de `birth_date` em tempo de consulta.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFFF3E6D6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _InfoChip(
                  label: currentUser == null
                      ? 'JWT + FastAPI'
                      : '${currentUser!.age} anos',
                ),
                _InfoChip(
                  label: currentUser == null
                      ? 'Perfil autenticado'
                      : currentUser!.email,
                ),
                _InfoChip(
                  label: currentUser == null
                      ? 'Flutter web/mobile'
                      : _prettyDate(currentUser!.birthDate),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _prettyDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AuthCard extends StatefulWidget {
  const _AuthCard({required this.controller});

  final SessionController controller;

  @override
  State<_AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<_AuthCard> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController(text: '1991-03-05');
  final _emailController = TextEditingController(text: 'rafa@example.com');
  final _passwordController = TextEditingController(text: 'super-secret-123');
  _AuthMode _mode = _AuthMode.login;

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busy = widget.controller.isBusy;

    return _SurfaceCard(
      title: _mode == _AuthMode.login ? 'Entrar' : 'Criar conta',
      subtitle: _mode == _AuthMode.login
          ? 'Use seu email e senha para entrar no MVP.'
          : 'Crie a identidade basica que vai sustentar o restante do produto.',
      errorMessage: widget.controller.errorMessage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<_AuthMode>(
            segments: const [
              ButtonSegment<_AuthMode>(
                value: _AuthMode.login,
                label: Text('Login'),
              ),
              ButtonSegment<_AuthMode>(
                value: _AuthMode.register,
                label: Text('Cadastro'),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (value) {
              widget.controller.clearError();
              setState(() {
                _mode = value.first;
              });
            },
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                if (_mode == _AuthMode.register) ...[
                  TextFormField(
                    key: const Key('register-name-field'),
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (value) {
                      if (_mode == _AuthMode.login) {
                        return null;
                      }
                      if (value == null || value.trim().length < 2) {
                        return 'Informe um nome valido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('register-birth-date-field'),
                    controller: _birthDateController,
                    decoration: const InputDecoration(
                      labelText: 'Data de nascimento (AAAA-MM-DD)',
                    ),
                    validator: (value) =>
                        _parseDate(value) == null ? 'Use o formato AAAA-MM-DD.' : null,
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  key: const Key('auth-email-field'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Informe um email valido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('auth-password-field'),
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  validator: (value) {
                    if (value == null || value.length < 8) {
                      return 'Use ao menos 8 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('auth-submit-button'),
                  onPressed: busy ? null : _submit,
                  child: Text(
                    busy
                        ? 'Enviando...'
                        : _mode == _AuthMode.login
                        ? 'Entrar'
                        : 'Criar conta',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    widget.controller.clearError();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_mode == _AuthMode.login) {
      await widget.controller.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      return;
    }

    await widget.controller.register(
      name: _nameController.text.trim(),
      birthDate: _parseDate(_birthDateController.text)!,
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  DateTime? _parseDate(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) {
      return null;
    }

    return DateTime.tryParse(rawValue.trim());
  }
}

class _ProfileCard extends StatefulWidget {
  const _ProfileCard({required this.controller});

  final SessionController controller;

  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user = widget.controller.currentUser!;
    _nameController = TextEditingController(text: user.name);
    _birthDateController = TextEditingController(text: _apiDate(user.birthDate));
    _emailController = TextEditingController(text: user.email);
  }

  @override
  void didUpdateWidget(covariant _ProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final user = widget.controller.currentUser!;
    _nameController.text = user.name;
    _birthDateController.text = _apiDate(user.birthDate);
    _emailController.text = user.email;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.controller.currentUser!;
    final busy = widget.controller.isBusy;

    return _SurfaceCard(
      title: 'Meu perfil',
      subtitle: 'Consulte e atualize apenas os dados do usuario autenticado.',
      errorMessage: widget.controller.errorMessage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F1E8),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Email canonico: ${user.email}'),
                const SizedBox(height: 4),
                Text('Idade derivada: ${user.age} anos'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  key: const Key('profile-name-field'),
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) {
                    if (value == null || value.trim().length < 2) {
                      return 'Informe um nome valido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('profile-birth-date-field'),
                  controller: _birthDateController,
                  decoration: const InputDecoration(
                    labelText: 'Data de nascimento (AAAA-MM-DD)',
                  ),
                  validator: (value) =>
                      DateTime.tryParse(value ?? '') == null ? 'Use o formato AAAA-MM-DD.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('profile-email-field'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Informe um email valido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton(
                      key: const Key('profile-save-button'),
                      onPressed: busy ? null : _save,
                      child: Text(busy ? 'Salvando...' : 'Salvar perfil'),
                    ),
                    OutlinedButton(
                      key: const Key('profile-refresh-button'),
                      onPressed: busy ? null : widget.controller.refreshProfile,
                      child: const Text('Recarregar'),
                    ),
                    TextButton(
                      key: const Key('logout-button'),
                      onPressed: busy ? null : widget.controller.logout,
                      child: const Text('Sair'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    widget.controller.clearError();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await widget.controller.updateProfile(
      name: _nameController.text.trim(),
      birthDate: DateTime.parse(_birthDateController.text.trim()),
      email: _emailController.text.trim(),
    );
  }

  String _apiDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.errorMessage,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 30,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF2E2118),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF665343),
                height: 1.5,
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8E2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Color(0xFF8A2E1D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}
