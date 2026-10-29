# OpenVision — дизайн мобильного приложения

Передача дизайна для реализации во Flutter. Источник API — MOBILE_API_HANDOFF.md.

- `screens/` — 16 экранов MVP в светлой и тёмной теме (эталон того, как должно выглядеть).
- `design-system/README.md` — правила: тексты, цвета, типографика, структура приложения, приватность. Читать первым.
- `design-system/tokens.json` — все токены (цвета для двух тем, шрифты, отступы, радиусы, размеры).
- `design-system/components/<Имя>/README.md` — правила каждого компонента; `preview.html` и `bundle.js` / `bundle.css` — эталонная веб-реализация (React), по ней видны все состояния.
- `design-system/components/Screens*/preview.html` — разметка экранов 1–16.
- `flutter/ov_tokens.dart` — токены, уже переведённые в Dart: `OvColors` (ThemeExtension, light/dark), `OvSpace`, `OvRadius`, `OvSize`, `OvText`.

Шрифты: Golos Text и JetBrains Mono (Google Fonts, OFL) — положить файлы в assets/fonts и прописать в pubspec.yaml. Иконки: Lucide, обводка ~1.75.
