import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenPair {
  TokenPair({required this.access, required this.refresh, required this.expiresAt});

  factory TokenPair.fromJson(Map<String, dynamic> json) => TokenPair(
        access: json['access_token'] as String,
        refresh: json['refresh_token'] as String,
        expiresAt: DateTime.now().add(Duration(seconds: (json['expires_in'] as num?)?.toInt() ?? 900)),
      );

  final String access;
  final String refresh;
  final DateTime expiresAt;

  /// Обновляем заранее, когда до истечения осталось меньше минуты (§4).
  bool get expiresSoon => DateTime.now().isAfter(expiresAt.subtract(const Duration(seconds: 60)));
}

/// Токены — только в Keychain / Keystore, не в SharedPreferences.
class TokenStore {
  static const _storage = FlutterSecureStorage();
  static const _kAccess = 'ov_access_token';
  static const _kRefresh = 'ov_refresh_token';
  static const _kExpires = 'ov_access_expires_at';

  Future<TokenPair?> read() async {
    final values = await _storage.readAll();
    final access = values[_kAccess], refresh = values[_kRefresh];
    if (access == null || refresh == null) return null;
    final expires = int.tryParse(values[_kExpires] ?? '') ?? 0;
    return TokenPair(
      access: access,
      refresh: refresh,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(expires),
    );
  }

  Future<void> write(TokenPair pair) async {
    await _storage.write(key: _kAccess, value: pair.access);
    await _storage.write(key: _kRefresh, value: pair.refresh);
    await _storage.write(key: _kExpires, value: '${pair.expiresAt.millisecondsSinceEpoch}');
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kExpires);
  }
}
