import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:openvision/core/api/api_client.dart';
import 'package:openvision/core/api/api_exception.dart';
import 'package:openvision/core/api/token_store.dart';
import 'package:openvision/core/live/live_connection.dart';
import 'package:openvision/data/models.dart';
import 'package:openvision/data/ov_api.dart';
import 'package:openvision/l10n/gen/app_localizations.dart';
import 'package:openvision/state/cameras_store.dart';
import 'package:openvision/state/session.dart';
import 'package:openvision/theme/ov_theme.dart';

Camera camera(int id, {String mode = 'pull', String status = 'online', String? reason}) => Camera.fromJson({
      'id': id,
      'name': 'Камера $id',
      'mode': mode,
      'enabled': true,
      'status': status,
      'status_reason': reason,
    });

/// API без сети: записывает вызовы и отвечает заготовками.
class FakeApi extends OvApi {
  FakeApi() : super(ApiClient(TokenStore()));

  final calls = <String, Map<String, Object?>>{};
  List<EdgeAgent> agents = [];
  ProbeResult probeResult = ProbeResult(
    ok: true,
    stream: StreamInfo(codec: 'h264', width: 1920, height: 1080, fps: 8),
    warnings: ['low_fps'],
  );
  ApiException? createError;

  @override
  Future<ProbeResult> probe(String url) async {
    calls['probe'] = {'url': url};
    return probeResult;
  }

  @override
  Future<CreatedCamera> createCamera({
    required String name,
    required String mode,
    String? location,
    String? sourceUrl,
    String? edgeAgentId,
  }) async {
    calls['createCamera'] = {'name': name, 'mode': mode, 'source_url': sourceUrl, 'edge_agent_id': edgeAgentId};
    if (createError != null) throw createError!;
    return CreatedCamera.fromJson({
      'id': 42,
      'name': name,
      'mode': mode,
      'enabled': true,
      'status': mode == 'push' ? 'connecting' : 'pending',
      'status_reason': mode == 'push' ? 'waiting_for_video' : null,
      if (mode == 'push')
        'push': {
          'srt_url': 'srt://ingest.openvision.kz:8890?streamid=publish:cam/42:push:ovk_7Hq2xQ&pkt_size=1316',
          'rtsp_url': 'rtsp://push:ovk_7Hq2xQ@ingest.openvision.kz:8554/cam/42',
          'stream_key': 'ovk_7Hq2xQ',
        },
    });
  }

  @override
  Future<List<EdgeAgent>> edgeAgents() async => agents;

  @override
  Future<EdgeAgent> createEdgeAgent(String name) async {
    calls['createEdgeAgent'] = {'name': name};
    final a = EdgeAgent.fromJson({
      'id': 'agent-new',
      'name': name,
      'online': false,
      'install_command': 'docker run -d --restart=always --name openvision-edge -e OV_TOKEN=ova_9fK3xQ openvision/edge:latest',
    });
    agents = [...agents, a];
    return a;
  }

  @override
  Future<User> createUser({required String email, required String fullName, required String role, required String password}) async {
    calls['createUser'] = {'email': email, 'role': role};
    return User.fromJson({'id': 'u-new', 'email': email, 'full_name': fullName, 'role': role, 'is_active': true});
  }

  @override
  Future<List<User>> users() async => [
        User.fromJson({'id': 'me', 'email': 'aida@acme.kz', 'full_name': 'Аида Серикова', 'role': 'owner', 'is_active': true}),
        User.fromJson({'id': 'u2', 'email': 'timur@acme.kz', 'full_name': 'Тимур Ахметов', 'role': 'operator', 'is_active': true}),
      ];

  @override
  Future<Me> me() async => Me.fromJson({
        'user': {'id': 'me', 'email': 'aida@acme.kz', 'full_name': 'Аида Серикова', 'role': 'owner'},
        'tenant': {'id': 't', 'name': 'Acme LLP', 'plan': 'face', 'max_cameras': 4, 'retention_days': 30},
        'permissions': ['cameras.read', 'cameras.write', 'cameras.control', 'events.read', 'users.read', 'users.write'],
      });
}

/// Шрифты дизайн-системы вместо тестового Ahem — для скриншотов.
Future<void> loadOvFonts() async {
  final golos = FontLoader('Golos Text');
  for (final w in ['Regular', 'Medium', 'SemiBold']) {
    golos.addFont(rootBundle.load('assets/fonts/GolosText-$w.ttf'));
  }
  await golos.load();
  final mono = FontLoader('JetBrains Mono')..addFont(rootBundle.load('assets/fonts/JetBrainsMono-Regular.ttf'));
  await mono.load();
}

/// Экран в окружении приложения: тема, строки, провайдеры, маршрутизатор.
Future<({CamerasStore cameras, Session session})> pumpScreen(
  WidgetTester tester,
  FakeApi api,
  Widget screen, {
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('ru'),
  List<Camera> cameras = const [],
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final live = LiveConnection(api.client);
  final store = CamerasStore(api, live);
  cameras.forEach(store.put);
  final session = Session(api);
  await session.reloadMe();
  final router = GoRouter(
    initialLocation: '/screen',
    routes: [
      GoRoute(path: '/', builder: (_, _) => const Scaffold(body: Text('home'))),
      GoRoute(path: '/screen', builder: (_, _) => screen),
      GoRoute(path: '/cameras/:id', builder: (_, s) => Scaffold(body: Text('camera ${s.pathParameters['id']}'))),
    ],
  );
  await tester.pumpWidget(MultiProvider(
    providers: [
      Provider<OvApi>.value(value: api),
      ChangeNotifierProvider.value(value: session),
      ChangeNotifierProvider.value(value: live),
      ChangeNotifierProvider.value(value: store),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      theme: buildOvTheme(brightness),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  ));
  await tester.pump();
  return (cameras: store, session: session);
}

/// Спиннеры крутятся бесконечно — pumpAndSettle не дождётся, крутим вручную.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}
