import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateTimeRange;

import '../core/api/api_exception.dart';
import '../core/live/live_connection.dart';
import '../data/models.dart';
import '../data/ov_api.dart';

enum Period { any, today, yesterday, week, custom }

@immutable
class EventFilters {
  const EventFilters({
    this.period = Period.any,
    this.range,
    this.known,
    this.cameraIds = const {},
    this.personId,
  });

  final Period period;

  /// Для [Period.custom]: локальные даты, конец включительно.
  final DateTimeRange? range;
  final bool? known;
  final Set<int> cameraIds;
  final String? personId;

  bool get isDefault => period == Period.any && known == null && cameraIds.isEmpty && personId == null;

  EventFilters copyWith({
    Period? period,
    DateTimeRange? range,
    bool? Function()? known,
    Set<int>? cameraIds,
    String? Function()? personId,
  }) =>
      EventFilters(
        period: period ?? this.period,
        range: range ?? this.range,
        known: known != null ? known() : this.known,
        cameraIds: cameraIds ?? this.cameraIds,
        personId: personId != null ? personId() : this.personId,
      );

  /// Границы периода считаются в момент запроса — «сегодня» сдвигается после полуночи.
  EventQuery toQuery() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime? since, until;
    switch (period) {
      case Period.any:
        break;
      case Period.today:
        since = today;
      case Period.yesterday:
        since = today.subtract(const Duration(days: 1));
        until = today;
      case Period.week:
        since = today.subtract(const Duration(days: 6));
      case Period.custom:
        final r = range;
        if (r != null) {
          since = DateTime(r.start.year, r.start.month, r.start.day);
          until = DateTime(r.end.year, r.end.month, r.end.day + 1);
        }
    }
    return EventQuery(cameraIds: cameraIds, known: known, personId: personId, since: since, until: until);
  }
}

/// Лента событий: курсорная подгрузка, фильтры, live-события сверху.
///
/// Чтобы список не прыгал, новые события вставляются сразу, только когда
/// лента прокручена к началу; иначе копятся в [pending] до возврата наверх.
class EventsFeed extends ChangeNotifier {
  EventsFeed(this.api, LiveConnection live) {
    _subs = [
      live.events.listen(_onLive),
      live.onReady.listen((_) => _resync()),
    ];
  }

  static const _pageSize = 50;

  final OvApi api;
  late final List<StreamSubscription<dynamic>> _subs;

  EventFilters filters = const EventFilters();
  List<OvEvent> items = [];
  String? _cursor;
  bool hasMore = false;
  bool loaded = false;
  bool loading = false;
  bool loadingMore = false;
  ApiException? error;
  ApiException? moreError;

  /// События, пришедшие по сокету, пока экран открыт — точка `scan`.
  final Set<String> newIds = {};
  List<OvEvent> pending = [];
  bool _atTop = true;
  int _gen = 0;
  final Set<String> _mediaRefreshed = {};

  OvEvent? byId(String id) {
    for (final e in items) {
      if (e.id == id) return e;
    }
    return null;
  }

  void setFilters(EventFilters f) {
    filters = f;
    reload();
  }

  Future<void> reload() async {
    final gen = ++_gen;
    loading = true;
    error = null;
    moreError = null;
    pending = [];
    notifyListeners();
    try {
      final page = await api.events(filters.toQuery(), limit: _pageSize);
      if (gen != _gen) return;
      items = page.items;
      _cursor = page.nextCursor;
      hasMore = _cursor != null;
      loaded = true;
    } on ApiException catch (e) {
      if (gen != _gen) return;
      error = e;
    } finally {
      if (gen == _gen) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMore() async {
    if (loading || loadingMore || !hasMore || _cursor == null) return;
    final gen = _gen;
    loadingMore = true;
    moreError = null;
    notifyListeners();
    try {
      final page = await api.events(filters.toQuery(), cursor: _cursor, limit: _pageSize);
      if (gen != _gen) return;
      final known = {for (final e in items) e.id};
      items = [...items, ...page.items.where((e) => !known.contains(e.id))];
      _cursor = page.nextCursor;
      hasMore = _cursor != null;
    } on ApiException catch (e) {
      if (gen != _gen) return;
      if (e.code == 'invalid_cursor') {
        loadingMore = false;
        return reload();
      }
      moreError = e;
    } finally {
      if (gen == _gen) {
        loadingMore = false;
        notifyListeners();
      }
    }
  }

  /// Лента у верхнего края: можно вставлять новые события без сдвига.
  void setAtTop(bool atTop) {
    if (_atTop == atTop) return;
    _atTop = atTop;
    if (atTop && pending.isNotEmpty) flushPending();
  }

  void flushPending() {
    if (pending.isEmpty) return;
    _mergeOnTop(pending);
    pending = [];
    notifyListeners();
  }

  void _onLive(OvEvent e) {
    if (!loaded || !filters.toQuery().matches(e)) return;
    if (byId(e.id) != null || pending.any((p) => p.id == e.id)) return;
    newIds.add(e.id);
    if (_atTop) {
      _mergeOnTop([e]);
    } else {
      pending = [e, ...pending];
    }
    notifyListeners();
  }

  /// После (пере)подключения сокета: первая страница REST, слияние по id.
  Future<void> _resync() async {
    if (!loaded || loading) return;
    final gen = _gen;
    try {
      final page = await api.events(filters.toQuery(), limit: _pageSize);
      if (gen != _gen) return;
      final fresh = page.items.where((e) => byId(e.id) == null).toList();
      if (fresh.isEmpty) return;
      if (_atTop) {
        _mergeOnTop(fresh);
      } else {
        final ids = {for (final p in pending) p.id};
        pending = [...pending, ...fresh.where((e) => !ids.contains(e.id))];
      }
      notifyListeners();
    } on ApiException catch (_) {}
  }

  void _mergeOnTop(List<OvEvent> fresh) {
    final ids = {for (final e in items) e.id};
    items = [...fresh.where((e) => !ids.contains(e.id)), ...items]
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }

  /// Подписанные ссылки истекли (403) — перезапрашиваем событие, один раз.
  Future<OvEvent?> refreshMedia(String id) async {
    if (!_mediaRefreshed.add(id)) return null;
    try {
      final fresh = await api.event(id);
      put(fresh);
      return fresh;
    } on ApiException catch (_) {
      return null;
    }
  }

  void put(OvEvent e) {
    final i = items.indexWhere((x) => x.id == e.id);
    if (i < 0) return;
    items = [...items]..[i] = e;
    notifyListeners();
  }

  void reset() {
    _gen++;
    filters = const EventFilters();
    items = [];
    pending = [];
    newIds.clear();
    _mediaRefreshed.clear();
    _cursor = null;
    hasMore = false;
    loaded = false;
    error = null;
    moreError = null;
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }
}
