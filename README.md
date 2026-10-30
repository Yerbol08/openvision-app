# OpenVision — мобильное приложение (Flutter)

Камеры и события компании. Дизайн — `openvision-design/`, API — `MOBILE_API_HANDOFF.md`.

## Запуск

```bash
flutter pub get
flutter run                                              # демо-бэкенд: 10.0.2.2:8000 (Android) / localhost:8000 (iOS)
flutter run --dart-define=OV_API_BASE=http://192.168.1.20:8000   # телефон в той же сети
```

Демо-учётка: `demo@openvision.dev` / `demo-password-1`.

Проверка на настоящем сервере — параметры в начале `test/live_server_test.dart`, без них она пропускается.

## Устройство

- `lib/theme/` — `ov_tokens.dart` (из дизайн-системы, не править вручную) и тема на его основе.
- `lib/l10n/` — строки `app_ru.arb` (шаблон) и `app_kk.arb`; классы генерируются в `lib/l10n/gen` (`flutter gen-l10n`).
- `lib/core/api/` — Dio-клиент: токены в Keychain/Keystore, одиночный refresh, ошибки по `code`.
- `lib/core/live/` — WebSocket `/live`: auth первым сообщением, бэкофф 1→30 с, сторож 60 с.
- `lib/state/` — сессия, камеры, обзор, лента событий (ChangeNotifier + provider).
- `lib/ui/widgets/` — компоненты дизайн-системы; `lib/ui/screens/` — экраны.
- Защита экранов с лицами — `PrivacyScope` → канал `openvision/privacy` (`MainActivity.kt`, `AppDelegate.swift`).
