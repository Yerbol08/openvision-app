import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'core/api/token_store.dart';
import 'core/live/live_connection.dart';
import 'data/ov_api.dart';
import 'l10n/gen/app_localizations.dart';
import 'router.dart';
import 'state/cameras_store.dart';
import 'state/dashboard_store.dart';
import 'state/events_feed.dart';
import 'state/session.dart';
import 'theme/ov_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  final client = ApiClient(TokenStore());
  final api = OvApi(client);
  final session = Session(api);
  final live = LiveConnection(client);
  final cameras = CamerasStore(api, live);
  final dashboard = DashboardStore(api, live);
  final feed = EventsFeed(api, live);

  // Вышли или сессию завершил сервер — закрываем сокет и забываем данные компании.
  session.addListener(() {
    if (session.status == SessionStatus.signedIn) return;
    live.stop();
    cameras.reset();
    dashboard.reset();
    feed.reset();
  });

  runApp(MultiProvider(
    providers: [
      Provider.value(value: client),
      Provider.value(value: api),
      ChangeNotifierProvider.value(value: session),
      ChangeNotifierProvider.value(value: live),
      ChangeNotifierProvider.value(value: cameras),
      ChangeNotifierProvider.value(value: dashboard),
      ChangeNotifierProvider.value(value: feed),
    ],
    child: OpenVisionApp(session: session),
  ));

  session.bootstrap();
}

class OpenVisionApp extends StatefulWidget {
  const OpenVisionApp({super.key, required this.session});
  final Session session;

  @override
  State<OpenVisionApp> createState() => _OpenVisionAppState();
}

class _OpenVisionAppState extends State<OpenVisionApp> {
  late final _router = buildRouter(widget.session);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      // Обе темы полные, приложение следует системной.
      theme: buildOvTheme(Brightness.light),
      darkTheme: buildOvTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Казахский — если он в системе, иначе русский.
      localeListResolutionCallback: (locales, supported) {
        for (final l in locales ?? const <Locale>[]) {
          if (l.languageCode == 'kk') return const Locale('kk');
          if (l.languageCode == 'ru') return const Locale('ru');
        }
        return const Locale('ru');
      },
      // Системный масштаб шрифта учитываем до 130 %.
      builder: (context, child) => MediaQuery.withClampedTextScaling(maxScaleFactor: 1.3, child: child!),
    );
  }
}
