enum AppRouteAccess { publicOnly, authenticated }

abstract final class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const profile = '/profile';
  static const places = '/places';
  static const reviews = '/reviews';

  static const publicRoutes = <String>{
    login,
    register,
  };

  static const protectedRoutes = <String>{
    home,
    profile,
    places,
    reviews,
  };

  static const all = <String>{
    ...publicRoutes,
    ...protectedRoutes,
  };
}

class LoginRouteArgs {
  const LoginRouteArgs({this.redirectAfterLogin});

  final String? redirectAfterLogin;
}

class RegisterRouteArgs {
  const RegisterRouteArgs({this.redirectAfterAuth});

  final String? redirectAfterAuth;
}
