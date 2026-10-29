import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

import '../config.dart';
import 'api_exception.dart';
import 'token_store.dart';

/// HTTP-клиент с авторизацией и ротацией refresh-токена (MOBILE_API_HANDOFF.md §4).
///
/// Refresh-токены одноразовые: повторное предъявление отзывает всю сессию.
/// Поэтому обновление идёт строго одно за раз — все 401 ждут общий [_refreshing].
class ApiClient {
  ApiClient(this._store) {
    final options = BaseOptions(
      baseUrl: AppConfig.apiV1,
      connectTimeout: const Duration(seconds: 10),
      // Проба камеры отвечает до ~12 с.
      receiveTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      listFormat: ListFormat.multi, // camera_id=17&camera_id=18
    );
    dio = Dio(options);
    _bare = Dio(options);
    dio.interceptors.add(InterceptorsWrapper(onRequest: _onRequest, onError: _onError));
  }

  final TokenStore _store;
  late final Dio dio;

  /// Без перехватчиков: refresh, вход, регистрация, выход.
  late final Dio _bare;

  @visibleForTesting
  Dio get bareForTest => _bare;

  TokenPair? _tokens;
  Future<TokenPair>? _refreshing;

  final _sessionEnded = StreamController<String>.broadcast();
  final _tokenRefreshed = StreamController<String>.broadcast();

  /// Сессия закончилась на стороне сервера (код ошибки): нужно выйти на экран входа.
  Stream<String> get sessionEnded => _sessionEnded.stream;

  /// Новый access-токен — WebSocket отправляет его повторным `auth`.
  Stream<String> get tokenRefreshed => _tokenRefreshed.stream;

  bool get hasTokens => _tokens != null;
  String? get refreshToken => _tokens?.refresh;

  Future<bool> restore() async {
    _tokens = await _store.read();
    return _tokens != null;
  }

  Future<void> setTokens(TokenPair pair) async {
    await _store.write(pair);
    _tokens = pair;
  }

  Future<void> clearTokens() async {
    _tokens = null;
    await _store.clear();
  }

  /// Действующий access-токен; если он вот-вот истечёт — сначала обновляет.
  Future<String> accessToken() async {
    final t = _tokens;
    if (t == null) throw ApiException('unauthorized', status: 401);
    if (t.expiresSoon) return (await refresh()).access;
    return t.access;
  }

  Future<TokenPair> refresh() => _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);

  Future<TokenPair> _doRefresh() async {
    final t = _tokens;
    if (t == null) throw ApiException('unauthorized', status: 401);
    try {
      final res = await _bare.post<Map<String, dynamic>>('/auth/refresh', data: {'refresh_token': t.refresh});
      final pair = TokenPair.fromJson(res.data!);
      // Сохраняем новую пару до любых повторов запросов.
      await setTokens(pair);
      _tokenRefreshed.add(pair.access);
      return pair;
    } on DioException catch (e) {
      final ex = ApiException.fromDio(e);
      // 401 от /auth/refresh — выход, без повторов. Сетевую ошибку выходом не считаем.
      if (ex.status == 401 || ex.code == 'account_suspended') await _endSession(ex.code);
      throw ex;
    }
  }

  Future<void> _endSession(String code) async {
    if (_tokens == null) return;
    await clearTokens();
    _sessionEnded.add(code);
  }

  Future<void> _onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra['auth'] == false) return handler.next(options);
    try {
      options.headers['Authorization'] = 'Bearer ${await accessToken()}';
      handler.next(options);
    } on ApiException catch (e) {
      handler.reject(DioException(requestOptions: options, error: e));
    }
  }

  Future<void> _onError(DioException err, ErrorInterceptorHandler handler) async {
    final opts = err.requestOptions;
    final ex = ApiException.fromDio(err);
    if (ex.code == 'account_suspended') {
      await _endSession(ex.code);
      return handler.next(err);
    }
    if (ex.status != 401 || opts.extra['auth'] == false || _tokens == null) return handler.next(err);
    if (opts.extra['retried'] == true) {
      // Повтор с новым токеном снова получил 401 — выходим (§11).
      await _endSession(ex.code);
      return handler.next(err);
    }
    try {
      final current = _tokens!;
      // Если токен уже обновил параллельный запрос, просто повторяем с новым.
      if (opts.headers['Authorization'] == 'Bearer ${current.access}') await refresh();
      opts.extra['retried'] = true;
      handler.resolve(await dio.fetch<dynamic>(opts));
    } on DioException catch (e) {
      handler.next(e);
    } on ApiException catch (e) {
      handler.next(DioException(requestOptions: opts, error: e));
    }
  }

  // ---- Вызовы ----

  Future<T> _call<T>(Future<Response<dynamic>> Function() run, T Function(dynamic data) parse) async {
    try {
      final res = await run();
      return parse(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<T> get<T>(String path, T Function(dynamic data) parse, {Map<String, dynamic>? query}) =>
      _call(() => dio.get<dynamic>(path, queryParameters: query), parse);

  Future<T> post<T>(String path, Object? body, T Function(dynamic data) parse) =>
      _call(() => dio.post<dynamic>(path, data: body), parse);

  Future<T> patch<T>(String path, Object? body, T Function(dynamic data) parse) =>
      _call(() => dio.patch<dynamic>(path, data: body), parse);

  Future<void> put(String path, Object? body) => _call(() => dio.put<dynamic>(path, data: body), (_) {});

  Future<void> delete(String path) => _call(() => dio.delete<dynamic>(path), (_) {});

  /// Вызовы без Bearer: вход, регистрация, выход.
  Future<T> postPublic<T>(String path, Object? body, T Function(dynamic data) parse) =>
      _call(() => _bare.post<dynamic>(path, data: body), parse);
}
