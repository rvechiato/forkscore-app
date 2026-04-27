import 'package:flutter/material.dart';

import '../../../../app/auth_scope.dart';
import '../../../../app/navigation/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/action_buttons.dart';
import '../../../../shared/widgets/forkscore_logo.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionController = SessionScope.of(context);
    final userName = sessionController.currentUser?.name ?? 'Gastronomo';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final useWideLayout = constraints.maxWidth >= 900;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              useWideLayout ? 56 : 24,
              40,
              useWideLayout ? 56 : 24,
              60,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopNav(
                      userName: userName,
                      onLogout: () {
                        sessionController.logout();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.login,
                          (route) => false,
                        );
                      },
                    ),
                    const SizedBox(height: 64),

                    // Hero — limpo e tipográfico
                    Text(
                      'Bem-vindo, $userName.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Descubra o\nextraordinario.',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Registre sabor, atendimento e custo-beneficio\ndos melhores lugares da cidade.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 220,
                      child: PrimaryActionButton(
                        label: 'Nova Avaliacao',
                        onPressed: () =>
                            Navigator.of(context).pushNamed(AppRoutes.places),
                      ),
                    ),

                    const SizedBox(height: 64),
                    const Divider(),
                    const SizedBox(height: 40),

                    // Acesso Rápido — tiles horizontais, limpos
                    _SectionTitle(title: 'Acesso Rapido'),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAccessTile(
                            icon: Icons.search_rounded,
                            label: 'Buscar Locais',
                            subtitle: 'Encontre e avalie',
                            onTap: () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.places),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _QuickAccessTile(
                            icon: Icons.rate_review_outlined,
                            label: 'Minhas Avaliacoes',
                            subtitle: 'Historico completo',
                            onTap: () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.reviews),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _QuickAccessTile(
                            icon: Icons.bookmark_border_rounded,
                            label: 'Favoritos',
                            subtitle: 'Lugares salvos',
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 56),

                    // Categorias em Destaque
                    _SectionTitle(title: 'Categorias em Destaque'),
                    const SizedBox(height: 20),
                    const _CategoryRow(
                      label: 'Alta Gastronomia',
                      count: '142 locais',
                    ),
                    const _CategoryRow(
                      label: 'Cafeterias Acolhedoras',
                      count: '85 locais',
                    ),
                    const _CategoryRow(
                      label: 'Cozinha Internacional',
                      count: '64 locais',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopNav extends StatelessWidget {
  const _TopNav({required this.userName, required this.onLogout});

  final String userName;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const ForkScoreLogo(
          showWordmark: true,
          compact: true,
          markWidth: 28,
          wordmarkSize: 18,
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profile),
          child: const Text('Perfil'),
        ),
        const SizedBox(width: 8),
        TextButton(onPressed: onLogout, child: const Text('Sair')),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: AppTheme.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _QuickAccessTile extends StatelessWidget {
  const _QuickAccessTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.inputBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: AppTheme.primaryBrand),
            const SizedBox(height: 16),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.label, required this.count});

  final String label;
  final String count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text(
                count,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppTheme.inputBorderDark,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
