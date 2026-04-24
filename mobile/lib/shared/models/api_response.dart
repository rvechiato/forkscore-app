class ApiResponse<T> {
  final String status;
  final T? data;
  final String? code;
  final String? message;
  final DateTime timestamp;

  ApiResponse({
    required this.status,
    this.data,
    this.code,
    this.message,
    required this.timestamp,
  });

  bool get isSuccess => status == 'success';
  bool get isError => status == 'error';

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse(
      status: json['status'] as String,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      code: json['code'] as String?,
      message: json['message'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
