class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    this.birthDate,
    this.age,
    required this.email,
  });

  final String id;
  final String name;
  final DateTime? birthDate;
  final int? age;
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birth_date': birthDate?.toIso8601String(),
      'age': age,
      'email': email,
    };
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final birthDateValue = json['birth_date'];
    final ageValue = json['age'];

    return AuthUser(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDate: birthDateValue is String && birthDateValue.isNotEmpty
          ? DateTime.tryParse(birthDateValue)
          : null,
      age: ageValue is int ? ageValue : null,
      email: json['email'] as String,
    );
  }
}
