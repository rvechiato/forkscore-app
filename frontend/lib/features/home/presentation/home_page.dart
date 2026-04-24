import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F2E7), Color(0xFFE8D6BD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A2618),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'MVP em construcao',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'ForkScore',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2D1B10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Avalie restaurantes, cafeterias e locais especiais '
                      'com uma recomendacao simples, honesta e util.',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF4C3728),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'A base do produto ja esta preparada para receber '
                      'autenticacao, cadastro de locais e o fluxo de avaliacao '
                      'gastronomica.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF5C4634),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: const [
                        _FeatureChip(label: 'Backend FastAPI'),
                        _FeatureChip(label: 'Arquitetura Hexagonal'),
                        _FeatureChip(label: 'JWT + SQLite'),
                        _FeatureChip(label: 'Flutter Web/Mobile'),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD1B58F)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF3B2A1E),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
