import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openvision/core/api/api_exception.dart';
import 'package:openvision/data/models.dart';

void main() {
  test('ошибка API разбирается по code и details', () {
    final e = ApiException.fromDio(DioException(
      requestOptions: RequestOptions(),
      response: Response(
        requestOptions: RequestOptions(),
        statusCode: 429,
        data: {'error': {'code': 'rate_limited', 'message': 'slow down', 'details': {'retry_after': 42}}},
      ),
    ));
    expect(e.code, 'rate_limited');
    expect(e.retryAfter, 42);
  });

  test('validation_error отдаёт ключи полей', () {
    final e = ApiException('validation_error', status: 422, details: [
      {'field': 'password', 'message': 'too short'},
    ]);
    expect(e.invalidFields, {'password'});
  });

  test('нет ответа — сетевая ошибка', () {
    final e = ApiException.fromDio(DioException(requestOptions: RequestOptions(), type: DioExceptionType.connectionError));
    expect(e.isNetwork, isTrue);
  });

  test('by_hour заполняется нулями до 24 локальных часов', () {
    final dayStart = DateTime(2026, 10, 29);
    final s = StatsSummary.fromJson({
      'total_events': 50,
      'by_hour': [
        {'start': dayStart.add(const Duration(hours: 9)).toUtc().toIso8601String(), 'events': 41},
        {'start': dayStart.add(const Duration(hours: 15)).toUtc().toIso8601String(), 'events': 9},
        {'start': dayStart.subtract(const Duration(hours: 1)).toUtc().toIso8601String(), 'events': 99},
      ],
    });
    final h = s.hourlyFrom(dayStart);
    expect(h.length, 24);
    expect(h[9], 41);
    expect(h[15], 9);
    expect(h.fold<int>(0, (a, b) => a + b), 50);
  });

  test('live-событие проверяется по фильтрам ленты', () {
    final e = OvEvent.fromJson({
      'id': 'e1',
      'camera_id': 17,
      'camera_name': 'Вход',
      'kind': 'face',
      'occurred_at': '2026-10-29T08:15:30Z',
      'is_known': false,
      'bbox': [640, 220, 96, 120],
      'future_field': 'игнорируем',
    });
    expect(const EventQuery().matches(e), isTrue);
    expect(const EventQuery(cameraIds: {18}).matches(e), isFalse);
    expect(const EventQuery(known: true).matches(e), isFalse);
    expect(EventQuery(until: DateTime.utc(2026, 10, 29, 8)).matches(e), isFalse);
    expect(e.bbox, [640, 220, 96, 120]);
  });

  test('выключенная камера показывается как disabled и не требует внимания', () {
    final c = Camera.fromJson({'id': 3, 'name': 'Склад', 'mode': 'edge', 'enabled': false, 'status': 'offline'});
    expect(c.displayStatus, 'disabled');
    expect(c.needsAttention, isFalse);
    expect(c.isBroken, isFalse);
  });
}
