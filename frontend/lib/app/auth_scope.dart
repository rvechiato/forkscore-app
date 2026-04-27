import 'package:flutter/widgets.dart';

import '../features/auth/presentation/controllers/session_controller.dart';

class SessionScope extends InheritedNotifier<SessionController> {
  const SessionScope({
    super.key,
    required SessionController controller,
    required super.child,
  }) : super(notifier: controller);

  static SessionController of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<SessionScope>()
        : context.getInheritedWidgetOfExactType<SessionScope>();

    if (scope?.notifier case final controller?) {
      return controller;
    }

    throw StateError('SessionScope nao encontrado na arvore do app.');
  }
}
