import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/api/api_exception.dart';
import '../core/live/live_connection.dart';
import '../data/models.dart';
import '../data/ov_api.dart';

/// Показатели «Обзора» за сегодняшние локальные сутки (`GET /stats/summary`).
class DashboardStore extends ChangeNotifier {
  DashboardStore(this.api, LiveConnection live) {
    _subs = [
      // Сводку по сокету не присылают: после новых событий перечитываем, не чаще раза в 10 с.
      live.events.listen((_) => _scheduleReload()),
      live.onReady.listen((_) => load()),
    ];
  }

  final OvApi api;
  late final List<StreamSubscription<dynamic>> _subs;
  Timer? _reloadTimer;

  StatsSummary? summary;
  List<int> hourly = List.filled(24, 0);
  DateTime dayStart = _today();
  bool loading = false;
  ApiException? error;

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> load() async {
    _reloadTimer?.cancel();
    _reloadTimer = null;
    loading = true;
    notifyListeners();
    try {
      final start = _today();
      final s = await api.statsSummary(since: start, until: start.add(const Duration(days: 1)));
      dayStart = start;
      summary = s;
      hourly = s.hourlyFrom(start);
      error = null;
    } on ApiException catch (e) {
      error = e;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _scheduleReload() {
    _reloadTimer ??= Timer(const Duration(seconds: 10), load);
  }

  void reset() {
    _reloadTimer?.cancel();
    _reloadTimer = null;
    summary = null;
    error = null;
    hourly = List.filled(24, 0);
  }

  @override
  void dispose() {
    _reloadTimer?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }
}
