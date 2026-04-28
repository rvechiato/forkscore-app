class ReviewAuthor {
  const ReviewAuthor({required this.id, required this.name});

  final String id;
  final String name;

  factory ReviewAuthor.fromJson(Map<String, dynamic> payload) {
    return ReviewAuthor(
      id: payload['id'] as String,
      name: payload['name'] as String,
    );
  }
}
