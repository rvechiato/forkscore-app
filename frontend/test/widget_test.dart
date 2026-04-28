import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forkscore_frontend/app/app.dart';
import 'package:forkscore_frontend/app/navigation/app_routes.dart';

void main() {
  testWidgets('renderiza a tela de login inicial', (WidgetTester tester) async {
    await tester.pumpWidget(const ForkScoreApp());
    await tester.pumpAndSettle();

    expect(find.text('ForkScore'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar nova conta'), findsOneWidget);
  });

  testWidgets(
    'redireciona rota protegida para login e volta ao destino apos autenticar',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ForkScoreApp(initialRoute: AppRoutes.places),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('login-email-field')), findsOneWidget);
      expect(find.text('Locais'), findsNothing);

      await tester.enterText(
        find.byKey(const Key('login-email-field')),
        'chef@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('login-password-field')),
        'super-secret-123',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Pesquisa de Lugares'), findsOneWidget);
      expect(find.byKey(const Key('places-search-field')), findsOneWidget);
      expect(find.byKey(const Key('new-establishment-button')), findsOneWidget);
    },
  );

  testWidgets('navega para cadastro, autentica e faz logout', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ForkScoreApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('go-to-register-button')));
    await tester.tap(find.byKey(const Key('go-to-register-button')));
    await tester.pumpAndSettle();

    expect(find.text('Criar Conta'), findsWidgets);

    await tester.enterText(
      find.byKey(const Key('register-name-field')),
      'Rafa Vecchiato',
    );
    await tester.enterText(
      find.byKey(const Key('register-email-field')),
      'rafa@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('register-password-field')),
      'super-secret-123',
    );
    await tester.enterText(
      find.byKey(const Key('register-confirm-password-field')),
      'super-secret-123',
    );

    await tester.ensureVisible(find.text('Criar Conta').last);
    await tester.tap(find.text('Criar Conta').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('Rafa Vecchiato'), findsWidgets);
    expect(find.text('Sair'), findsOneWidget);

    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login-email-field')), findsOneWidget);
    expect(find.textContaining('Rafa Vecchiato'), findsNothing);
  });

  testWidgets('usuario autenticado navega para outra rota interna protegida', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ForkScoreApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('login-email-field')),
      'chef@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('login-password-field')),
      'super-secret-123',
    );
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Perfil'), findsWidgets);
    expect(find.textContaining('Area protegida'), findsOneWidget);
  });

  testWidgets(
    'navega da home para a pesquisa de lugares ao tocar em nova avaliacao',
    (WidgetTester tester) async {
      await tester.pumpWidget(const ForkScoreApp());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Entrar').first);
      await tester.tap(find.text('Entrar').first);
      await tester.pumpAndSettle();

      expect(find.text('Preencha email e senha para entrar.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('login-email-field')),
        'chef@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('login-password-field')),
        'super-secret-123',
      );
      await tester.ensureVisible(find.text('Entrar').first);
      await tester.tap(find.text('Entrar').first);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Buscar Locais'));
      await tester.tap(find.text('Buscar Locais'));
      await tester.pumpAndSettle();

      expect(find.text('Pesquisa de Lugares'), findsOneWidget);
      expect(find.byKey(const Key('places-search-field')), findsOneWidget);
      expect(find.byKey(const Key('new-establishment-button')), findsOneWidget);
      expect(find.text('Cafe do Centro'), findsWidgets);
    },
  );

  testWidgets('abre o cadastro de lugar a partir da tela de pesquisa', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ForkScoreApp(initialRoute: AppRoutes.places));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('login-email-field')),
      'chef@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('login-password-field')),
      'super-secret-123',
    );
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('new-establishment-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('place-create-page')), findsOneWidget);
    expect(find.byKey(const Key('create-place-name-field')), findsOneWidget);
    expect(find.byKey(const Key('submit-new-establishment')), findsOneWidget);
  });

  testWidgets('atalho buscar locais em acoes rapidas abre a rota de pesquisa', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ForkScoreApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('login-email-field')),
      'chef@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('login-password-field')),
      'super-secret-123',
    );
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Buscar Locais'));
    await tester.tap(find.text('Buscar Locais'));
    await tester.pumpAndSettle();

    expect(find.text('Pesquisa de Lugares'), findsOneWidget);
    expect(find.byKey(const Key('places-search-field')), findsOneWidget);
  });
}
