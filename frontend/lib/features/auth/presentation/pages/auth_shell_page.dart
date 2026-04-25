import 'dart:math' as math;

import 'package:flutter/material.dart';

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
      body: Container(
        color: const Color(0xFFF6EBDC),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) {
                    return controller.isAuthenticated
                        ? _ProfileCard(controller: controller)
                        : _AuthLanding(controller: controller);
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

class _AuthLanding extends StatefulWidget {
  const _AuthLanding({required this.controller});

  final SessionController controller;

  @override
  State<_AuthLanding> createState() => _AuthLandingState();
}

class _AuthLandingState extends State<_AuthLanding> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(text: 'rafa@example.com');
  final _passwordController = TextEditingController(text: 'super-secret-123');

  _AuthMode _mode = _AuthMode.login;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busy = widget.controller.isBusy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        const Center(child: _ForkScoreLogo()),
        const SizedBox(height: 20),
        Text(
          'novo ForkScore',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: const Color(0xFF2F2218),
            fontWeight: FontWeight.w700,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: busy
                    ? null
                    : () {
                        widget.controller.clearError();
                        setState(() => _mode = _AuthMode.login);
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: _mode == _AuthMode.login
                      ? const Color(0xFF8E4B2A)
                      : const Color(0xFFB68962),
                ),
                child: const Text('Login'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: busy
                    ? null
                    : () {
                        widget.controller.clearError();
                        setState(() => _mode = _AuthMode.register);
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: _mode == _AuthMode.register
                      ? const Color(0xFF8E4B2A)
                      : const Color(0xFFB68962),
                ),
                child: const Text('Cadastro'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SurfaceCard(
          title: _mode == _AuthMode.login ? 'Entrar' : 'Criar conta',
          errorMessage: widget.controller.errorMessage,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_mode == _AuthMode.register) ...[
                  TextFormField(
                    key: const Key('register-name-field'),
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Seu nome'),
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
                        ? 'Aguarde...'
                        : _mode == _AuthMode.login
                        ? 'Entrar'
                        : 'Criar conta',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }
}

class _ForkScoreLogo extends StatelessWidget {
  const _ForkScoreLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFE8D4B8),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD3B38C),
                width: 2,
              ),
            ),
          ),
          Positioned(
            left: 28,
            top: 26,
            child: SizedBox(
              width: 64,
              height: 64,
              child: CustomPaint(painter: _GraphPainter()),
            ),
          ),
          Positioned(
            right: 30,
            top: 34,
            child: Transform.rotate(
              angle: math.pi / 14,
              child: const _KnifeShape(),
            ),
          ),
        ],
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF6F4B33)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final nodePaint = Paint()..color = const Color(0xFF8E4B2A);

    final points = <Offset>[
      Offset(size.width * 0.15, size.height * 0.7),
      Offset(size.width * 0.45, size.height * 0.28),
      Offset(size.width * 0.76, size.height * 0.58),
    ];

    canvas.drawLine(points[0], points[1], linePaint);
    canvas.drawLine(points[1], points[2], linePaint);
    canvas.drawLine(points[0], points[2], linePaint);

    for (final point in points) {
      canvas.drawCircle(point, 6, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _KnifeShape extends StatelessWidget {
  const _KnifeShape();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 70,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 10,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFF8F5EF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: 22,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFF6F4630),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
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
    _birthDateController = TextEditingController(
      text: user.birthDate == null ? '' : _apiDate(user.birthDate!),
    );
    _emailController = TextEditingController(text: user.email);
  }

  @override
  void didUpdateWidget(covariant _ProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final user = widget.controller.currentUser!;
    _nameController.text = user.name;
    _birthDateController.text =
        user.birthDate == null ? '' : _apiDate(user.birthDate!);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        const Center(child: _ForkScoreLogo()),
        const SizedBox(height: 20),
        Text(
          'Meu perfil',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: const Color(0xFF2F2218),
            fontWeight: FontWeight.w700,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 24),
        _SurfaceCard(
          title: user.name,
          errorMessage: widget.controller.errorMessage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                user.email,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6C5542),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ProfilePill(
                    label: user.age == null
                        ? 'Idade pendente'
                        : '${user.age} anos',
                  ),
                  _ProfilePill(
                    label: user.birthDate == null
                        ? 'Nascimento nao informado'
                        : _apiDate(user.birthDate!),
                  ),
                ],
              ),
              const SizedBox(height: 22),
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return null;
                        }
                        return DateTime.tryParse(value) == null
                            ? 'Use o formato AAAA-MM-DD.'
                            : null;
                      },
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
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton(
                          key: const Key('profile-save-button'),
                          onPressed: busy ? null : _save,
                          child: Text(busy ? 'Salvando...' : 'Salvar'),
                        ),
                        OutlinedButton(
                          key: const Key('profile-refresh-button'),
                          onPressed: busy
                              ? null
                              : widget.controller.refreshProfile,
                          child: const Text('Atualizar'),
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
        ),
      ],
    );
  }

  Future<void> _save() async {
    widget.controller.clearError();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await widget.controller.updateProfile(
      name: _nameController.text.trim(),
      birthDate: _birthDateController.text.trim().isEmpty
          ? null
          : DateTime.parse(_birthDateController.text.trim()),
      email: _emailController.text.trim(),
    );
  }

  String _apiDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }
}

class _ProfilePill extends StatelessWidget {
  const _ProfilePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2DBCF)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF5A4332),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.title,
    required this.child,
    this.errorMessage,
  });

  final String title;
  final Widget child;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: const Color(0xFFE4DDD0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF2E2118),
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBE8E2),
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
