import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forkscore_frontend/app/app.dart';

void main() {
  testWidgets('renderiza a tela de login inicial', (WidgetTester tester) async {
    await tester.pumpWidget(const ForkScoreApp());
    await tester.pumpAndSettle();

    expect(find.text('ForkScore'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar nova conta'), findsOneWidget);
  });

  testWidgets('navega para cadastro e entra na home apos criar conta', (
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

    expect(find.text('Ola, Gastronomo!'), findsOneWidget);
    expect(find.text('Explore & Avalie'), findsOneWidget);
    expect(find.text('Acoes Rapidas'), findsOneWidget);
    expect(find.text('Explorar Categorias'), findsOneWidget);
  });

  testWidgets('mostra snackbar ao tentar login vazio e ao tocar em nova avaliacao', (
    WidgetTester tester,
  ) async {
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

    await tester.ensureVisible(find.byKey(const Key('new-review-button')));
    await tester.tap(find.byKey(const Key('new-review-button')));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Iniciando fluxo de avaliacao...'), findsOneWidget);
  });
}
