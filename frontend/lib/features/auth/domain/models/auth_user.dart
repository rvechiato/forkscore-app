class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.age,
    required this.email,
  });

  final String id;
  final String name;
  final DateTime birthDate;
  final int age;
  final String email;

  AuthUser copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    int? age,
    String? email,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      age: age ?? this.age,
      email: email ?? this.email,
    );
  }
}
