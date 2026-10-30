// Проверка на настоящем сервере. Без параметров пропускается:
//
// flutter test test/live_server_test.dart \
//   --dart-define=OV_API_BASE=http://10.8.0.53:8000 \
//   --dart-define=OV_LIVE_EMAIL=demo@openvision.dev \
//   --dart-define=OV_LIVE_PASSWORD=...
//
// Создаёт и сразу удаляет одну временную push-камеру. В вывод не попадают токены и адреса.
// ignore_for_file: avoid_print
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openvision/core/api/api_client.dart';
import 'package:openvision/core/api/api_exception.dart';
import 'package:openvision/core/api/token_store.dart';
import 'package:openvision/core/config.dart';
import 'package:openvision/core/live/live_connection.dart';
import 'package:openvision/data/models.dart';
import 'package:openvision/data/ov_api.dart';

const _email = String.fromEnvironment('OV_LIVE_EMAIL');
const _password = String.fromEnvironment('OV_LIVE_PASSWORD');
const _viewerEmail = String.fromEnvironment('OV_LIVE_VIEWER_EMAIL');

class _MemoryStore extends TokenStore {
  TokenPair? pair;

  @override
  Future<TokenPair?> read() async => pair;

  @override
  Future<void> write(TokenPair pair) async => this.pair = pair;

  @override
  Future<void> clear() async => pair = null;
}

OvApi _newApi() => OvApi(ApiClient(_MemoryStore()));

Future<void> _signIn(OvApi api, String email) async =>
    api.client.setTokens(await api.login(email: email, password: _password, deviceName: 'live_server_test'));

void main() {
  final skip = _email.isEmpty || _password.isEmpty ? 'нужны OV_LIVE_EMAIL и OV_LIVE_PASSWORD' : null;

  test('авторизация: /me и три одновременных refresh', skip: skip, () async {
    final api = _newApi();
    await _signIn(api, _email);
    final me = await api.me();
    print('me: role=${me.user.role} plan=${me.tenant.plan} max_cameras=${me.tenant.maxCameras} '
        'permissions=${me.permissions.toList()..sort()}');
    expect(me.can(Permissions.camerasRead), isTrue);

    final before = api.client.refreshToken;
    final pairs = await Future.wait([api.client.refresh(), api.client.refresh(), api.client.refresh()]);
    expect(pairs.map((p) => p.refresh).toSet(), hasLength(1), reason: 'refresh должен идти один');
    expect(api.client.refreshToken, isNot(before));
    await api.me();

    await api.logout(api.client.refreshToken!);
    print('refresh и logout: ok');
  });

  test('чтение: камеры, события, статистика, картинки, команда', skip: skip, () async {
    final api = _newApi();
    await _signIn(api, _email);

    final cameras = await api.cameras();
    print('cameras: ${cameras.length}; status/reason: ${cameras.map((c) => '${c.status}/${c.statusReason}').toList()}');
    if (cameras.isNotEmpty) expect((await api.camera(cameras.first.id)).id, cameras.first.id);

    final now = DateTime.now();
    final stats = await api.statsSummary(since: now.subtract(const Duration(hours: 24)), until: now);
    print('stats: total=${stats.totalEvents} known=${stats.knownEvents} people=${stats.uniquePeople} '
        'online=${stats.camerasOnline}/${stats.camerasTotal} hours=${stats.byHour.length}');

    final first = await api.events(const EventQuery(), limit: 2);
    print('events: first page=${first.items.length}, next_cursor=${first.nextCursor != null}');
    if (first.nextCursor != null) {
      final second = await api.events(const EventQuery(), cursor: first.nextCursor, limit: 2);
      final ids = first.items.map((e) => e.id).toSet();
      expect(second.items.where((e) => ids.contains(e.id)), isEmpty, reason: 'страницы не должны пересекаться');
    }

    final known = await api.events(const EventQuery(known: true), limit: 5);
    expect(known.items.every((e) => e.isKnown), isTrue);
    if (cameras.isNotEmpty) {
      final one = await api.events(EventQuery(cameraIds: {cameras.first.id}), limit: 5);
      expect(one.items.every((e) => e.cameraId == cameras.first.id), isTrue);
    }

    if (first.items.isEmpty) {
      print('media: событий нет, картинки не проверены');
    } else {
      final event = await api.event(first.items.first.id);
      print('event: kind=${event.kind} bbox=${event.bbox != null} crop=${event.cropUrl != null} frame=${event.frameUrl != null}');
      for (final url in [event.cropUrl, event.frameUrl]) {
        if (url == null) continue;
        final uri = Uri.parse(url);
        final res = await Dio().getUri<List<int>>(
          uri,
          options: Options(responseType: ResponseType.bytes, validateStatus: (_) => true),
        );
        print('media: host=${uri.host}:${uri.port} (api=${Uri.parse(AppConfig.apiBase).host}) '
            'status=${res.statusCode} type=${res.headers.value('content-type')} bytes=${res.data?.length}');
      }
    }

    print('users: ${(await api.users()).length}; edge agents: ${(await api.edgeAgents()).length}');
    await api.logout(api.client.refreshToken!);
  });

  test('запись и WebSocket: временная push-камера', skip: skip, () async {
    final api = _newApi();
    await _signIn(api, _email);

    final live = LiveConnection(api.client);
    final ready = Completer<void>();
    final statuses = <int>[];
    final deleted = <int>[];
    final events = <String>[];
    final subs = [
      live.onReady.listen((_) => ready.isCompleted ? null : ready.complete()),
      live.cameraStatus.listen((c) => statuses.add(c.id)),
      live.cameraDeleted.listen(deleted.add),
      live.events.listen((e) => events.add(e.id)),
    ];
    live.start();
    await ready.future.timeout(const Duration(seconds: 15));
    print('live: ready');

    final created = await api.createCamera(name: 'live_server_test', mode: 'push');
    final id = created.camera.id;
    try {
      expect(created.push, isNotNull);
      expect(created.push!.srtUrl, isNotEmpty);
      print('camera created: status=${created.camera.status}/${created.camera.statusReason}');

      expect((await api.updateCamera(id, name: 'live_server_test_2')).name, 'live_server_test_2');
      expect((await api.setCameraEnabled(id, false)).enabled, isFalse);
      expect((await api.rotateKey(id)).rtspUrl, isNotEmpty);
    } finally {
      await api.deleteCamera(id);
    }
    expect(
      () => api.camera(id),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'not_found')),
    );
    print('camera edit, rotate-key, delete: ok');

    await Future<void>.delayed(const Duration(seconds: 20));
    print('live: camera_status(своя)=${statuses.where((c) => c == id).length} '
        'camera_deleted(своя)=${deleted.where((c) => c == id).length} events=${events.length}');
    expect(statuses, contains(id));
    expect(deleted, contains(id));

    live.stop();
    for (final s in subs) {
      await s.cancel();
    }
    await api.logout(api.client.refreshToken!);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('права: viewer не может менять данные', skip: skip ?? (_viewerEmail.isEmpty ? 'нужен OV_LIVE_VIEWER_EMAIL' : null), () async {
    final api = _newApi();
    await _signIn(api, _viewerEmail);
    final me = await api.me();
    print('viewer permissions: ${me.permissions.toList()..sort()}');
    expect(me.can(Permissions.camerasWrite), isFalse);
    await expectLater(
      api.users(),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'forbidden')),
    );
    await api.logout(api.client.refreshToken!);
  });
}
