import 'package:flutter/services.dart';

/// Защита экранов с лицами (MOBILE_API_HANDOFF.md §13): FLAG_SECURE на Android,
/// размытие снимка в переключателе приложений на iOS. Счётчик — экраны могут
/// накладываться (вкладка «События» и открытое поверх событие).
class Privacy {
  static const _channel = MethodChannel('openvision/privacy');
  static int _holders = 0;

  static void acquire() {
    if (_holders++ == 0) _set(true);
  }

  static void release() {
    if (_holders == 0) return;
    if (--_holders == 0) _set(false);
  }

  static void _set(bool secure) {
    _channel.invokeMethod<void>('setSecure', {'secure': secure}).catchError((Object _) {});
  }
}
