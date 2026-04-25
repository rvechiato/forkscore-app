import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forkscore_frontend/app/app.dart';
import 'package:forkscore_frontend/features/auth/domain/auth_repository.dart';
import 'package:forkscore_frontend/features/auth/domain/models/auth_session.dart';
import 'package:forkscore_frontend/features/auth/domain/models/auth_user.dart';

void main() {
  testWidgets('renderiza o fluxo inicial de autenticacao', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ForkScoreApp(repository: FakeAuthRepository()),
    );

    expect(find.text('novo ForkScore'), findsOneWidget);
    expect(find.text('Entrar'), findsWidgets);
    expect(find.text('Cadastro'), findsOneWidget);
  });

  testWidgets('transiciona para o perfil ao criar conta', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ForkScoreApp(repository: FakeAuthRepository()),
    );

    await tester.ensureVisible(find.text('Cadastro'));
    await tester.tap(find.text('Cadastro'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('register-name-field')),
      'Rafa Vecchiato',
    );
    await tester.enterText(
      find.byKey(const Key('auth-email-field')),
      'rafa@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('auth-password-field')),
      'super-secret-123',
    );

    await tester.ensureVisible(find.byKey(const Key('auth-submit-button')));
    await tester.tap(find.byKey(const Key('auth-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Meu perfil'), findsOneWidget);
    expect(find.text('Rafa Vecchiato'), findsWidgets);
    expect(find.text('rafa@example.com'), findsWidgets);
  });
}

class FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthUser> getMyProfile({
    required String accessToken,
  }) async {
    return _user;
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    return AuthSession(accessToken: 'token', user: _user);
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _user = AuthUser(
      id: 'user-1',
      name: name,
      email: email,
    );

    return AuthSession(accessToken: 'token', user: _user);
  }

  @override
  Future<AuthUser> updateMyProfile({
    required String accessToken,
    required String name,
    required DateTime? birthDate,
    required String email,
  }) async {
    _user = AuthUser(
      id: _user.id,
      name: name,
      birthDate: birthDate,
      age: birthDate == null ? null : 34,
      email: email,
    );

    return _user;
  }

  AuthUser _user = AuthUser(
    id: 'user-1',
    name: 'Rafa Vecchiato',
    email: 'rafa@example.com',
  );
}
