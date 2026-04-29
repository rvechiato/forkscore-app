import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'features/auth/data/shared_preferences_auth_session_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final sessionStorage = SharedPreferencesAuthSessionStorage(
    preferences: preferences,
  );

  runApp(ForkScoreApp(sessionStorage: sessionStorage));
}
