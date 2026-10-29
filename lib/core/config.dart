import 'dart:io' show Platform;

/// Адрес API. Задаётся при сборке: `--dart-define=OV_API_BASE=https://api.openvision.kz`.
/// По умолчанию — локальный демо-бэкенд (MOBILE_API_HANDOFF.md §2).
class AppConfig {
  static const _fromEnv = String.fromEnvironment('OV_API_BASE');

  static String get apiBase {
    if (_fromEnv.isNotEmpty) return _fromEnv.replaceAll(RegExp(r'/+$'), '');
    return Platform.isAndroid ? 'http://10.0.2.2:8000' : 'http://localhost:8000';
  }

  static String get apiV1 => '$apiBase/api/v1';

  static Uri get liveUri {
    final base = Uri.parse(apiBase);
    return base.replace(
      scheme: base.scheme == 'https' ? 'wss' : 'ws',
      path: '/api/v1/live',
    );
  }
}
