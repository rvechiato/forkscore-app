import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/action_buttons.dart';
import '../../../../shared/widgets/forkscore_text_field.dart';

enum _Screen { login, register, home }

class AuthShellPage extends StatefulWidget {
  const AuthShellPage({super.key});

  @override
  State<AuthShellPage> createState() => _AuthShellPageState();
}

class _AuthShellPageState extends State<AuthShellPage> {
  _Screen _screen = _Screen.login;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final useDeviceFrame = constraints.maxWidth >= 600;
          final showPreviewNav = useDeviceFrame && constraints.maxHeight >= 860;

          return ColoredBox(
            color: useDeviceFrame
                ? const Color(0xFFE6E1DA)
                : AppTheme.cream,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: useDeviceFrame ? 24 : 0,
                      vertical: useDeviceFrame ? 24 : 0,
                    ),
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxWidth: useDeviceFrame ? 390 : double.infinity,
                        maxHeight: useDeviceFrame ? 844 : double.infinity,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.cream,
                        borderRadius: BorderRadius.circular(
                          useDeviceFrame ? 40 : 0,
                        ),
                        border: useDeviceFrame
                            ? Border.all(
                                color: const Color(0xFF262322),
                                width: 8,
                              )
                            : null,
                        boxShadow: useDeviceFrame
                            ? const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 32,
                                  offset: Offset(0, 20),
                                ),
                              ]
                            : null,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          const _StatusBar(),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              child: switch (_screen) {
                                _Screen.login => _LoginPage(
                                    key: const ValueKey('login-page'),
                                    onEnter: _goHome,
                                    onCreateAccount: () {
                                      setState(
                                        () => _screen = _Screen.register,
                                      );
                                    },
                                  ),
                                _Screen.register => _RegisterPage(
                                    key: const ValueKey('register-page'),
                                    onBack: () {
                                      setState(
                                        () => _screen = _Screen.login,
                                      );
                                    },
                                    onSubmit: _goHome,
                                  ),
                                _Screen.home => _HomePage(
                                    key: const ValueKey('home-page'),
                                  ),
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (showPreviewNav)
                    Positioned(
                      bottom: 32,
                      child: _PreviewNavigator(
                        current: _screen,
                        onSelect: (screen) {
                          setState(() => _screen = screen);
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _goHome() {
    setState(() => _screen = _Screen.home);
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 8),
      child: Row(
        children: [
          Text(
            '9:41',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const Spacer(),
          const Icon(Icons.menu_rounded, size: 16),
          const SizedBox(width: 6),
          const Icon(Icons.public_rounded, size: 16),
          const SizedBox(width: 6),
          const Icon(Icons.battery_full_rounded, size: 18),
        ],
      ),
    );
  }
}

class _LoginPage extends StatefulWidget {
  const _LoginPage({
    super.key,
    required this.onEnter,
    required this.onCreateAccount,
  });

  final VoidCallback onEnter;
  final VoidCallback onCreateAccount;

  @override
  State<_LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<_LoginPage> {
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
      padding: const EdgeInsets.fromLTRB(32, 64, 32, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: _LogoMark()),
          const SizedBox(height: 14),
          Text(
            'ForkScore',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 31,
                  height: 1,
                  letterSpacing: -0.6,
                ),
          ),
          const SizedBox(height: 56),
          ForkScoreTextField(
            key: const Key('login-email-field'),
            controller: _emailController,
            label: '',
            hintText: 'Email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined, size: 20),
          ),
          const SizedBox(height: 14),
          ForkScoreTextField(
            key: const Key('login-password-field'),
            controller: _passwordController,
            label: '',
            hintText: 'Senha',
            obscureText: _obscure,
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
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
          const SizedBox(height: 18),
          PrimaryActionButton(
            label: 'Entrar',
            onPressed: _submit,
          ),
          const SizedBox(height: 30),
          Column(
            children: [
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fluxo de recuperacao ainda e visual.'),
                    ),
                  );
                },
                child: Text(
                  'Esqueceu a senha?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.charcoal,
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFFD7CEC2),
                        decorationThickness: 1,
                      ),
                ),
              ),
              const SizedBox(height: 18),
              TextButton(
                key: const Key('go-to-register-button'),
                onPressed: widget.onCreateAccount,
                child: Text(
                  'Criar nova conta',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.charcoal,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.charcoal,
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
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha email e senha para entrar.'),
        ),
      );
      return;
    }

    widget.onEnter();
  }
}

class _RegisterPage extends StatefulWidget {
  const _RegisterPage({
    super.key,
    required this.onBack,
    required this.onSubmit,
  });

  final VoidCallback onBack;
  final VoidCallback onSubmit;

  @override
  State<_RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<_RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 28,
                      height: 1,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _FieldLabel(
            text: 'Nome Completo',
            child: ForkScoreTextField(
              key: const Key('register-name-field'),
              controller: _nameController,
              label: '',
              hintText: '',
            ),
          ),
          const SizedBox(height: 12),
          _FieldLabel(
            text: 'Email',
            child: ForkScoreTextField(
              key: const Key('register-email-field'),
              controller: _emailController,
              label: '',
              hintText: '',
            ),
          ),
          const SizedBox(height: 12),
          _FieldLabel(
            text: 'Data de Nascimento',
            child: ForkScoreTextField(
              key: const Key('register-birth-date-field'),
              controller: _birthDateController,
              label: '',
              hintText: '',
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
            ),
          ),
          const SizedBox(height: 12),
          _FieldLabel(
            text: 'Senha',
            child: ForkScoreTextField(
              key: const Key('register-password-field'),
              controller: _passwordController,
              label: '',
              hintText: 'Senha',
              obscureText: true,
            ),
          ),
          const SizedBox(height: 12),
          ForkScoreTextField(
            key: const Key('register-confirm-password-field'),
            controller: _confirmPasswordController,
            label: '',
            hintText: 'Confirmar Senha',
            obscureText: true,
          ),
          const SizedBox(height: 28),
          SecondaryActionButton(
            label: 'Criar Conta',
            onPressed: _submit,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
              const SizedBox(width: 2),
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
                        color: AppTheme.charcoal,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.charcoal,
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
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos obrigatorios.'),
        ),
      );
      return;
    }

    widget.onSubmit();
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ForkScore',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: 22,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ola, Gastronomo!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const _AvatarBadge(),
            ],
          ),
          const SizedBox(height: 18),
          _HeroCard(),
          const SizedBox(height: 14),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppTheme.terracotta,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(width: 6),
                ...List.generate(
                  2,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD5CEC5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Acoes Rapidas',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 20,
                ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.02,
            children: const [
              _QuickActionCard(
                color: Color(0xFF4A6B53),
                icon: Icons.search_rounded,
                label: 'Buscar\nLocais',
              ),
              _QuickActionCard(
                color: Color(0xFFC05D43),
                icon: Icons.favorite_border_rounded,
                label: 'Meus\nFavoritos',
              ),
              _QuickActionCard(
                color: Color(0xFF5C82A6),
                icon: Icons.map_outlined,
                label: 'Mapa',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Explorar Categorias',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 20,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _CategoryCard(
                  emoji: '☕',
                  colors: [Color(0xFF6F5240), Color(0xFFB48D74)],
                  label: 'Cafeterias\nAcolhedoras',
                ),
                SizedBox(width: 12),
                _CategoryCard(
                  emoji: '🍽️',
                  colors: [Color(0xFFC05D43), Color(0xFFD79578)],
                  label: 'Restaurantes\nLocais',
                ),
                SizedBox(width: 12),
                _CategoryCard(
                  emoji: '🍣',
                  colors: [Color(0xFF5C82A6), Color(0xFF8EB3CF)],
                  label: 'Restaurantes\nOrientais',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/icon_forkscore.png',
      width: 150,
      height: 108,
      fit: BoxFit.contain,
    );
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.terracotta,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 18,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore & Avalie',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                        height: 1.02,
                      ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('new-review-button'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Iniciando fluxo de avaliacao...'),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.terracotta,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Nova Avaliacao'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const _HeroGraphic(),
        ],
      ),
    );
  }
}

class _HeroGraphic extends StatelessWidget {
  const _HeroGraphic();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.18,
      child: Container(
        width: 98,
        height: 98,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 16,
              top: 18,
              child: Container(
                width: 42,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFD5E8D4),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF2CC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.place_rounded,
                  color: AppTheme.terracotta,
                  size: 22,
                ),
              ),
            ),
            const Center(
              child: Icon(
                Icons.restaurant_menu_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(label.replaceAll('\n', ' '))),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      height: 1.2,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.emoji,
    required this.colors,
    required this.label,
  });

  final String emoji;
  final List<Color> colors;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 130,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.72),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFF1E0D3), Color(0xFFD9E5D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppTheme.cream, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        'RV',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.text,
    required this.child,
  });

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
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        child,
      ],
    );
  }
}

class _PreviewNavigator extends StatelessWidget {
  const _PreviewNavigator({
    required this.current,
    required this.onSelect,
  });

  final _Screen current;
  final ValueChanged<_Screen> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PreviewNavButton(
            label: 'Login',
            active: current == _Screen.login,
            onTap: () => onSelect(_Screen.login),
          ),
          _PreviewNavButton(
            label: 'Cadastro',
            active: current == _Screen.register,
            onTap: () => onSelect(_Screen.register),
          ),
          _PreviewNavButton(
            label: 'Home',
            active: current == _Screen.home,
            onTap: () => onSelect(_Screen.home),
          ),
        ],
      ),
    );
  }
}

class _PreviewNavButton extends StatelessWidget {
  const _PreviewNavButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: active ? AppTheme.terracotta : AppTheme.charcoal,
          textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        child: Text(label),
      ),
    );
  }
}
