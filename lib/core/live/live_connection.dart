import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../data/models.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../config.dart';

enum LiveState { idle, connecting, live, reconnecting, offline, forbidden }

/// WebSocket `/api/v1/live` (MOBILE_API_HANDOFF.md §8).
///
/// Токен — первым сообщением, не в URL. Переподключение с бэкоффом 1→30 с,
/// сброс после минуты стабильной связи; 60 с без кадров — соединение мёртвое.
/// Сообщения best effort: после каждого `ready` слушатели [onReady]
/// перезапрашивают REST и сливают по id.
class LiveConnection extends ChangeNotifier {
  LiveConnection(this._client);

  final ApiClient _client;

  LiveState _state = LiveState.idle;
  LiveState get state => _state;

  final _events = StreamController<OvEvent>.broadcast();
  final _cameras = StreamController<Camera>.broadcast();
  final _deleted = StreamController<int>.broadcast();
  final _ready = StreamController<void>.broadcast();

  Stream<OvEvent> get events => _events.stream;
  Stream<Camera> get cameraStatus => _cameras.stream;
  Stream<int> get cameraDeleted => _deleted.stream;
  Stream<void> get onReady => _ready.stream;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  StreamSubscription<String>? _tokenSub;
  Timer? _retryTimer, _watchdog, _stableTimer;
  bool _running = false;
  int _attempt = 0;
  int _networkFailures = 0;
  int _gen = 0;

  void start() {
    if (_running) return;
    _running = true;
    _attempt = 0;
    _networkFailures = 0;
    _tokenSub = _client.tokenRefreshed.listen(_sendAuth);
    _connect();
  }

  void stop() {
    _running = false;
    _retryTimer?.cancel();
    _stableTimer?.cancel();
    _tokenSub?.cancel();
    _tokenSub = null;
    _closeSocket();
    _setState(LiveState.idle);
  }

  /// Кнопка «Повторить» в баннере.
  void retryNow() {
    if (!_running) return;
    _retryTimer?.cancel();
    _closeSocket();
    _attempt = 0;
    _connect();
  }

  Future<void> _connect() async {
    final gen = ++_gen;
    if (_state != LiveState.offline) {
      _setState(_attempt == 0 ? LiveState.connecting : LiveState.reconnecting);
    }
    try {
      final token = await _client.accessToken();
      final channel = WebSocketChannel.connect(AppConfig.liveUri);
      await channel.ready;
      if (!_running || gen != _gen) {
        channel.sink.close();
        return;
      }
      _channel = channel;
      _sub = channel.stream.listen(
        _onMessage,
        onDone: () => _onClosed(channel.closeCode, gen),
        onError: (Object _) {},
      );
      channel.sink.add(jsonEncode({'type': 'auth', 'token': token}));
      _armWatchdog();
    } on ApiException catch (e) {
      if (gen != _gen || !_running) return;
      if (e.isNetwork) {
        _scheduleReconnect(network: true);
      } else {
        stop(); // токенов нет — сессия закончилась
      }
    } catch (_) {
      if (gen != _gen || !_running) return;
      _scheduleReconnect(network: true);
    }
  }

  void _onMessage(dynamic raw) {
    _armWatchdog();
    final Object? msg;
    try {
      msg = jsonDecode(raw as String);
    } catch (_) {
      return;
    }
    if (msg is! Map) return;
    final data = msg['data'];
    try {
      switch (msg['type']) {
        case 'ready':
          _networkFailures = 0;
          _setState(LiveState.live);
          _stableTimer?.cancel();
          _stableTimer = Timer(const Duration(minutes: 1), () => _attempt = 0);
          _ready.add(null);
        case 'event':
          _events.add(OvEvent.fromJson(data as Map<String, dynamic>));
        case 'camera_status':
          _cameras.add(Camera.fromJson(data as Map<String, dynamic>));
        case 'camera_deleted':
          _deleted.add(((data as Map)['id'] as num).toInt());
      }
    } catch (_) {
      // Сообщение незнакомого вида — пропускаем, не роняем соединение.
    }
  }

  Future<void> _onClosed(int? code, int gen) async {
    if (gen != _gen || !_running) return;
    _closeSocket();
    if (code == 4403) {
      _running = false;
      _setState(LiveState.forbidden);
      return;
    }
    if (code == 4401) {
      try {
        await _client.refresh();
      } on ApiException catch (e) {
        if (!e.isNetwork) return stop();
      }
    }
    _scheduleReconnect(network: false);
  }

  void _scheduleReconnect({required bool network}) {
    _stableTimer?.cancel();
    if (network) _networkFailures++;
    _setState(_networkFailures >= 2 ? LiveState.offline : LiveState.reconnecting);
    final delay = Duration(seconds: min(30, 1 << min(_attempt, 5)));
    _attempt++;
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, _connect);
  }

  void _armWatchdog() {
    _watchdog?.cancel();
    _watchdog = Timer(const Duration(seconds: 60), () {
      if (!_running) return;
      _closeSocket();
      _scheduleReconnect(network: false);
    });
  }

  void _sendAuth(String token) {
    _channel?.sink.add(jsonEncode({'type': 'auth', 'token': token}));
  }

  void _closeSocket() {
    _gen++;
    _watchdog?.cancel();
    _sub?.cancel();
    _sub = null;
    _channel?.sink.close();
    _channel = null;
  }

  void _setState(LiveState s) {
    if (_state == s) return;
    _state = s;
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
