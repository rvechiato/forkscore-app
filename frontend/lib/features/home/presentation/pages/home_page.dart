import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/forkscore_logo.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useWideLayout = constraints.maxWidth >= 1000;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            useWideLayout ? 40 : 24,
            24,
            useWideLayout ? 40 : 24,
            32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const ForkScoreLogo(
                        showWordmark: true,
                        compact: true,
                        markWidth: 34,
                        wordmarkSize: 22,
                      ),
                      const Spacer(),
                      _AvatarBadge(initials: _initialsFromName(userName)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ola, $userName!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Seu painel inicial para descobrir, avaliar e recomendar.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 24),
                  if (useWideLayout)
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 8, child: _HeroCard()),
                        SizedBox(width: 20),
                        Expanded(flex: 4, child: _QuickActionsPanel()),
                      ],
                    )
                  else ...[
                    const _HeroCard(),
                    const SizedBox(height: 14),
                    const _HeroIndicator(),
                    const SizedBox(height: 18),
                    Text(
                      'Acoes Rapidas',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 12),
                    const _QuickActionGrid(),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Explorar Categorias',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 130, child: _CategoryScroller()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String _initialsFromName(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    final initials = parts.take(2).map((part) => part[0]).join();
    return initials.isEmpty ? 'FS' : initials.toUpperCase();
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 420;

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
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _HeroTextContent(),
                    SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _HeroIllustration(),
                    ),
                  ],
                )
              : const Row(
                  children: [
                    Expanded(child: _HeroTextContent()),
                    SizedBox(width: 12),
                    _HeroIllustration(),
                  ],
                ),
        );
      },
    );
  }
}

class _HeroTextContent extends StatelessWidget {
  const _HeroTextContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore\n& Avalie',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontSize: 30,
            height: 0.98,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Descubra novos lugares e registre sua recomendacao logo apos a visita.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('new-review-button'),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Iniciando fluxo de avaliacao...')),
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.terracotta,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text('Nova Avaliacao'),
        ),
      ],
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.18,
      child: SizedBox(
        width: 108,
        height: 108,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDEAD9),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const Positioned(
              left: 18,
              top: 18,
              child: ForkScoreLogo(showWordmark: false, markWidth: 62),
            ),
            Positioned(
              right: 14,
              bottom: 16,
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE8D7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.place_rounded,
                  color: AppTheme.charcoal,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroIndicator extends StatelessWidget {
  const _HeroIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}

class _QuickActionsPanel extends StatelessWidget {
  const _QuickActionsPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acoes Rapidas',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 12),
          const _QuickActionGrid(),
        ],
      ),
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.02,
      children: const [
        _QuickActionTile(
          color: AppTheme.moss,
          icon: Icons.search_rounded,
          label: 'Buscar\nLocais',
        ),
        _QuickActionTile(
          color: AppTheme.terracotta,
          icon: Icons.favorite_border_rounded,
          label: 'Meus\nFavoritos',
        ),
        _QuickActionTile(
          color: AppTheme.softBlue,
          icon: Icons.map_outlined,
          label: 'Mapa',
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(label.replaceAll('\n', ' '))));
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

class _CategoryScroller extends StatelessWidget {
  const _CategoryScroller();

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: const [
        _CategoryCard(
          label: 'Cafeterias\nAcolhedoras',
          icon: Icons.local_cafe_rounded,
          colors: [Color(0xFF6F5240), Color(0xFFB48D74)],
        ),
        SizedBox(width: 12),
        _CategoryCard(
          label: 'Restaurantes\nLocais',
          icon: Icons.restaurant_rounded,
          colors: [Color(0xFFC05D43), Color(0xFFD79578)],
        ),
        SizedBox(width: 12),
        _CategoryCard(
          label: 'Restaurantes\nOrientais',
          icon: Icons.ramen_dining_rounded,
          colors: [Color(0xFF5C82A6), Color(0xFF8EB3CF)],
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.label,
    required this.icon,
    required this.colors,
  });

  final String label;
  final IconData icon;
  final List<Color> colors;

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
            Positioned(
              right: -8,
              top: -8,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
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
                    Colors.black.withValues(alpha: 0.76),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Icon(icon, color: Colors.white, size: 28),
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
  const _AvatarBadge({required this.initials});

  final String initials;

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
        initials,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
