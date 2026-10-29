import 'dart:async';
import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../core/api/token_store.dart';
import '../data/models.dart';
import '../data/ov_api.dart';

enum SessionStatus { unknown, signedOut, signedIn }

/// Вход, регистрация, выход и `/auth/me`. Маршрутизатор слушает [status].
class Session extends ChangeNotifier {
  Session(this.api) {
    _endedSub = api.client.sessionEnded.listen((code) {
      endedReason = code;
      _setSignedOut();
    });
  }

  final OvApi api;
  late final StreamSubscription<String> _endedSub;

  SessionStatus status = SessionStatus.unknown;
  Me? me;

  /// Не удалось проверить сохранённую сессию из-за сети — экран-заставка с «Повторить».
  bool bootstrapFailed = false;

  /// Код, по которому сервер завершил сессию (для сообщения на экране входа).
  String? endedReason;

  ApiClient get client => api.client;

  bool can(String permission) => me?.can(permission) ?? false;

  Future<void> bootstrap() async {
    bootstrapFailed = false;
    notifyListeners();
    if (!await client.restore()) return _setSignedOut();
    try {
      await _loadMe();
    } on ApiException catch (e) {
      if (e.isNetwork || (e.status ?? 0) >= 500) {
        bootstrapFailed = true;
        notifyListeners();
      } else {
        await client.clearTokens();
        _setSignedOut();
      }
    }
  }

  Future<void> login(String email, String password) async {
    final pair = await api.login(email: email, password: password, deviceName: await _deviceName());
    await _signedIn(pair);
  }

  Future<void> register({
    required String companyName,
    required String fullName,
    required String email,
    required String password,
  }) async {
    final pair = await api.register(
      companyName: companyName,
      fullName: fullName,
      email: email,
      password: password,
      deviceName: await _deviceName(),
    );
    await _signedIn(pair);
  }

  /// Смена пароля завершает все сессии, включая сохранённый refresh-токен этой (§4),
  /// поэтому сразу входим заново с новым паролем. Не вышло — выходим.
  Future<void> changePassword({required String current, required String next}) async {
    final email = me?.user.email;
    await api.changePassword(current: current, next: next);
    if (email == null) return logout();
    try {
      await login(email, next);
    } on ApiException catch (_) {
      await logout();
    }
  }

  /// Локальные токены чистим при любом ответе сервера.
  Future<void> logout() async {
    final refresh = client.refreshToken;
    await client.clearTokens();
    _setSignedOut();
    if (refresh != null) unawaited(api.logout(refresh).catchError((Object _) {}));
  }

  /// Перечитать права — после неожиданного 403 (§4).
  Future<void> reloadMe() async {
    try {
      await _loadMe();
    } on ApiException catch (_) {}
  }

  Future<void> _signedIn(TokenPair pair) async {
    await client.setTokens(pair);
    endedReason = null;
    await _loadMe();
  }

  Future<void> _loadMe() async {
    me = await api.me();
    status = SessionStatus.signedIn;
    notifyListeners();
  }

  void _setSignedOut() {
    me = null;
    status = SessionStatus.signedOut;
    notifyListeners();
  }

  static Future<String?> _deviceName() async {
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final a = await info.androidInfo;
        return '${a.manufacturer} ${a.model}';
      }
      if (Platform.isIOS) return (await info.iosInfo).name;
    } catch (_) {}
    return null;
  }

  @override
  void dispose() {
    _endedSub.cancel();
    super.dispose();
  }
}
