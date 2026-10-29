import 'package:dio/dio.dart';

/// Ошибка API в едином формате `{"error": {"code", "message", "details"}}`.
/// Ветвимся по [code], `message` сервера пользователю не показываем.
class ApiException implements Exception {
  ApiException(this.code, {this.status, this.details});

  /// Нет ответа от сервера: нет сети, таймаут, сервер недоступен.
  static const network = 'network_error';

  /// Ответ пришёл, но не в ожидаемом формате.
  static const unknown = 'unknown_error';

  final String code;
  final int? status;
  final Object? details;

  bool get isNetwork => code == network;

  /// `validation_error`: поле → список сообщений (используем только ключи полей).
  Set<String> get invalidFields {
    final d = details;
    if (code != 'validation_error' || d is! List) return const {};
    return {
      for (final item in d)
        if (item is Map && item['field'] is String) item['field'] as String,
    };
  }

  int? _intDetail(String key) {
    final d = details;
    if (d is Map && d[key] is num) return (d[key] as num).toInt();
    return null;
  }

  int? get retryAfter => _intDetail('retry_after');
  int? get limit => _intDetail('limit');

  factory ApiException.fromDio(DioException e) {
    final inner = e.error;
    if (inner is ApiException) return inner;
    final res = e.response;
    if (res == null) return ApiException(network);
    final data = res.data;
    if (data is Map && data['error'] is Map) {
      final err = data['error'] as Map;
      return ApiException(
        err['code'] as String? ?? unknown,
        status: res.statusCode,
        details: err['details'],
      );
    }
    return ApiException(unknown, status: res.statusCode);
  }

  @override
  String toString() => 'ApiException($code, status: $status)';
}
