import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openvision/core/api/api_client.dart';
import 'package:openvision/core/api/api_exception.dart';
import 'package:openvision/core/api/token_store.dart';

class MemoryTokenStore extends TokenStore {
  TokenPair? pair;
  @override
  Future<TokenPair?> read() async => pair;
  @override
  Future<void> write(TokenPair p) async => pair = p;
  @override
  Future<void> clear() async => pair = null;
}

/// Сервер-заглушка: access-токен `a1` протух, refresh `r1` одноразовый.
class FakeServer implements HttpClientAdapter {
  int refreshCalls = 0;
  final usedRefresh = <String>{};
  String validAccess = 'a2';

  ResponseBody _json(int status, Object body) => ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
      );

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? body, Future<void>? cancel) async {
    await Future<void>.delayed(const Duration(milliseconds: 5));
    if (o.path == '/auth/refresh') {
      refreshCalls++;
      final token = (o.data as Map)['refresh_token'] as String;
      if (!usedRefresh.add(token)) {
        return _json(401, {'error': {'code': 'invalid_refresh_token', 'message': 'reused', 'details': null}});
      }
      return _json(200, {'access_token': validAccess, 'refresh_token': 'r-next', 'token_type': 'bearer', 'expires_in': 900});
    }
    if (o.headers['Authorization'] != 'Bearer $validAccess') {
      return _json(401, {'error': {'code': 'unauthorized', 'message': 'expired', 'details': null}});
    }
    return _json(200, {'ok': o.path});
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late MemoryTokenStore store;
  late FakeServer server;
  late ApiClient client;

  setUp(() async {
    store = MemoryTokenStore()
      ..pair = TokenPair(access: 'a1', refresh: 'r1', expiresAt: DateTime.now().add(const Duration(minutes: 10)));
    server = FakeServer();
    client = ApiClient(store);
    client.dio.httpClientAdapter = server;
    // Refresh идёт через отдельный Dio без перехватчиков — подменяем и его адаптер.
    client.bareForTest.httpClientAdapter = server;
    await client.restore();
  });

  test('три параллельных 401 обновляют токен ровно один раз', () async {
    final results = await Future.wait([
      client.get('/cameras', (d) => d),
      client.get('/events', (d) => d),
      client.get('/stats/summary', (d) => d),
    ]);
    expect(server.refreshCalls, 1);
    expect(results.length, 3);
    expect(store.pair!.access, 'a2');
    expect(store.pair!.refresh, 'r-next');
  });

  test('401 от /auth/refresh завершает сессию и чистит токены', () async {
    server.usedRefresh.add('r1'); // токен уже использован
    final ended = expectLater(client.sessionEnded, emits('invalid_refresh_token'));
    await expectLater(client.get('/cameras', (d) => d), throwsA(isA<ApiException>()));
    await ended;
    expect(store.pair, isNull);
    expect(client.hasTokens, isFalse);
  });

  test('токен, который вот-вот истечёт, обновляется до запроса', () async {
    store.pair = TokenPair(access: 'a1', refresh: 'r1', expiresAt: DateTime.now().add(const Duration(seconds: 30)));
    await client.restore();
    await client.get('/cameras', (d) => d);
    expect(server.refreshCalls, 1);
  });
}
