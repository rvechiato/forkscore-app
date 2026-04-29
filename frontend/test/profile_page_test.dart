import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forkscore_frontend/app/app.dart';
import 'package:forkscore_frontend/app/navigation/app_routes.dart';
import 'package:forkscore_frontend/features/auth/domain/auth_repository.dart';
import 'package:forkscore_frontend/features/auth/domain/models/auth_session.dart';
import 'package:forkscore_frontend/features/auth/domain/models/auth_user.dart';
import 'package:forkscore_frontend/features/auth/presentation/controllers/session_controller.dart';

void main() {
  group('ProfilePage', () {
    testWidgets('navega autenticado para /profile', (
      WidgetTester tester,
    ) async {
      final repository = _FakeAuthRepository(
        initialUser: _user(
          name: 'Gastronomo',
          email: 'chef@example.com',
          birthDate: DateTime(1994, 4, 12),
        ),
      );
      final sessionController = SessionController(repository: repository);
      await sessionController.login(
        email: 'chef@example.com',
        password: 'super-secret-123',
      );

      await tester.pumpWidget(
        ForkScoreApp(
          initialRoute: AppRoutes.home,
          sessionController: sessionController,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Perfil'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile-page')), findsOneWidget);
      expect(find.byKey(const Key('profile-name-field')), findsOneWidget);
      expect(repository.getMyProfileCallCount, greaterThanOrEqualTo(1));
    });

    testWidgets('exibe estado inicial carregado do perfil autenticado', (
      WidgetTester tester,
    ) async {
      final repository = _FakeAuthRepository(
        initialUser: _user(
          name: 'Nome Original',
          email: 'original@example.com',
          birthDate: DateTime(1990, 1, 20),
        ),
      );
      final sessionController = SessionController(repository: repository);
      await sessionController.login(
        email: 'original@example.com',
        password: 'super-secret-123',
      );

      await tester.pumpWidget(
        ForkScoreApp(
          initialRoute: AppRoutes.home,
          sessionController: sessionController,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Perfil'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile-page')), findsOneWidget);
      expect(_fieldText(tester, 'profile-name-field'), equals('Nome Original'));
      expect(
        _fieldText(tester, 'profile-email-field'),
        equals('original@example.com'),
      );
      expect(_fieldText(tester, 'profile-birth-date-field'), isNotEmpty);
      expect(find.byKey(const Key('profile-age-value')), findsNothing);
    });

    testWidgets('salva alteracoes e reflete novo nome e email na sessao', (
      WidgetTester tester,
    ) async {
      final repository = _FakeAuthRepository(
        initialUser: _user(
          name: 'Nome Antigo',
          email: 'old@example.com',
          birthDate: DateTime(1992, 6, 15),
        ),
      );
      final sessionController = SessionController(repository: repository);
      await sessionController.login(
        email: 'old@example.com',
        password: 'super-secret-123',
      );

      await tester.pumpWidget(
        ForkScoreApp(
          initialRoute: AppRoutes.home,
          sessionController: sessionController,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Perfil'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      await _enterFieldText(tester, 'profile-name-field', 'Nome Atualizado');
      await _enterFieldText(tester, 'profile-email-field', 'new@example.com');
      await tester.ensureVisible(find.byKey(const Key('profile-save-button')));
      await tester.tap(find.byKey(const Key('profile-save-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(repository.updateMyProfileCallCount, 1);
      expect(sessionController.currentUser?.name, 'Nome Atualizado');
      expect(sessionController.currentUser?.email, 'new@example.com');
      expect(_fieldText(tester, 'profile-name-field'), 'Nome Atualizado');
      expect(_fieldText(tester, 'profile-email-field'), 'new@example.com');
    });

    testWidgets('lida com birth_date vazia sem quebrar', (
      WidgetTester tester,
    ) async {
      final repository = _FakeAuthRepository(
        initialUser: _user(
          name: 'Sem Data',
          email: 'sem-data@example.com',
          birthDate: null,
        ),
      );
      final sessionController = SessionController(repository: repository);
      await sessionController.login(
        email: 'sem-data@example.com',
        password: 'super-secret-123',
      );

      await tester.pumpWidget(
        ForkScoreApp(
          initialRoute: AppRoutes.home,
          sessionController: sessionController,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Perfil'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile-page')), findsOneWidget);
      expect(_fieldText(tester, 'profile-birth-date-field'), isEmpty);
      expect(find.byKey(const Key('profile-age-value')), findsNothing);

      await tester.ensureVisible(find.byKey(const Key('profile-save-button')));
      await tester.tap(find.byKey(const Key('profile-save-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(repository.updateMyProfileCallCount, 1);
      expect(repository.lastUpdatedBirthDate, isNull);
      expect(sessionController.currentUser?.birthDate, isNull);
    });
  });
}

Future<void> _enterFieldText(
  WidgetTester tester,
  String key,
  String text,
) async {
  final fieldFinder = find.byKey(Key(key));
  final editableFinder = find.descendant(
    of: fieldFinder,
    matching: find.byType(EditableText),
  );

  if (editableFinder.evaluate().isNotEmpty) {
    await tester.enterText(editableFinder.first, text);
    return;
  }

  await tester.enterText(fieldFinder, text);
}

String _fieldText(WidgetTester tester, String key) {
  final fieldFinder = find.byKey(Key(key));
  final editableFinder = find.descendant(
    of: fieldFinder,
    matching: find.byType(EditableText),
  );

  final target = editableFinder.evaluate().isNotEmpty
      ? editableFinder.first
      : fieldFinder;

  final editable = tester.widget<EditableText>(target);
  return editable.controller.text;
}

AuthUser _user({
  required String name,
  required String email,
  required DateTime? birthDate,
}) {
  return AuthUser(
    id: 'user-1',
    name: name,
    email: email,
    birthDate: birthDate,
    age: birthDate == null ? null : _calculateAge(birthDate),
  );
}

int _calculateAge(DateTime birthDate) {
  final now = DateTime.now();
  var age = now.year - birthDate.year;
  final birthdayPassed =
      now.month > birthDate.month ||
      (now.month == birthDate.month && now.day >= birthDate.day);

  if (!birthdayPassed) {
    age -= 1;
  }

  return age;
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required AuthUser initialUser}) : _user = initialUser;

  AuthUser _user;

  int getMyProfileCallCount = 0;
  int updateMyProfileCallCount = 0;
  DateTime? lastUpdatedBirthDate;

  @override
  Future<AuthUser> getMyProfile({required String accessToken}) async {
    getMyProfileCallCount += 1;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return _user;
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    return AuthSession(accessToken: 'token-123', user: _user);
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> updateMyProfile({
    required String accessToken,
    required String name,
    required DateTime? birthDate,
    required String email,
  }) async {
    updateMyProfileCallCount += 1;
    lastUpdatedBirthDate = birthDate;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    _user = _user.copyWith(
      name: name,
      email: email,
      birthDate: birthDate,
      age: birthDate == null ? null : _calculateAge(birthDate),
    );
    return _user;
  }
}
