import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/api/api_exception.dart';
import '../core/live/live_connection.dart';
import '../data/models.dart';
import '../data/ov_api.dart';

/// Список камер: REST — источник истины, `camera_status` по сокету — свежесть.
class CamerasStore extends ChangeNotifier {
  CamerasStore(this.api, LiveConnection live) {
    _subs = [
      live.cameraStatus.listen(put),
      live.cameraDeleted.listen(_remove),
      live.events.listen(_onEvent),
      live.onReady.listen((_) => load()),
    ];
  }

  final OvApi api;
  late final List<StreamSubscription<dynamic>> _subs;

  List<Camera> cameras = [];
  bool loaded = false;
  bool loading = false;
  ApiException? error;

  /// Последнее событие камеры — его кадр служит превью, пока нет live-снимка (§10).
  final Map<int, OvEvent> lastEvents = {};
  final Set<int> _thumbRefreshed = {};

  Camera? byId(int id) {
    for (final c in cameras) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<Camera> get attention => [for (final c in cameras) if (c.needsAttention) c];
  int get brokenCount => cameras.where((c) => c.isBroken).length;

  Future<void> load() async {
    if (loading) return;
    loading = true;
    notifyListeners();
    try {
      cameras = await api.cameras();
      error = null;
      loaded = true;
      unawaited(_loadThumbs());
    } on ApiException catch (e) {
      error = e;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadThumbs() async {
    _thumbRefreshed.clear();
    await Future.wait([for (final c in cameras) _loadThumb(c.id)]);
    notifyListeners();
  }

  Future<void> _loadThumb(int cameraId) async {
    try {
      final page = await api.events(EventQuery(cameraIds: {cameraId}), limit: 1);
      if (page.items.isNotEmpty) lastEvents[cameraId] = page.items.first;
    } on ApiException catch (_) {}
  }

  /// Ссылка на кадр истекла (403) — берём свежую, один раз на событие.
  Future<void> refreshThumb(int cameraId) async {
    if (!_thumbRefreshed.add(cameraId)) return;
    await _loadThumb(cameraId);
    notifyListeners();
  }

  /// Оптимистично: сразу меняем вид, при ошибке откатываем. Возвращает успех.
  Future<bool> setEnabled(int id, bool enabled) async {
    final before = byId(id);
    if (before == null) return false;
    put(before.copyWith(enabled: enabled));
    try {
      put(await api.setCameraEnabled(id, enabled));
      return true;
    } on ApiException catch (_) {
      put(before);
      return false;
    }
  }

  Future<void> delete(int id) async {
    await api.deleteCamera(id);
    _remove(id);
  }

  /// Камера из ответа API или сокета: заменить по id или добавить.
  void put(Camera c) {
    final i = cameras.indexWhere((x) => x.id == c.id);
    cameras = [...cameras];
    if (i < 0) {
      cameras.add(c);
    } else {
      cameras[i] = c;
    }
    notifyListeners();
  }

  void _remove(int id) {
    cameras = [for (final c in cameras) if (c.id != id) c];
    lastEvents.remove(id);
    notifyListeners();
  }

  void _onEvent(OvEvent e) {
    lastEvents[e.cameraId] = e;
    final c = byId(e.cameraId);
    if (c != null) {
      put(c.copyWith(lastEventAt: e.occurredAt));
    } else {
      notifyListeners();
    }
  }

  /// Сброс при выходе — без уведомлений, дерево в этот момент разбирается.
  void reset() {
    cameras = [];
    loaded = false;
    error = null;
    lastEvents.clear();
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }
}
