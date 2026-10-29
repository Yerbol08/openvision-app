# StatusBadge

Бейдж статуса камеры: цвет + слово + форма значка, чтобы не различать только по цвету.

| status | значок | цвет | слово |
|---|---|---|---|
| `pending` | спиннер | `neutral-soft` / `ink-muted` | Настройка |
| `connecting` | спиннер | `warn-soft` / `warn` | Подключение |
| `online` | сплошная точка | `online-soft` / `online` | В сети |
| `offline` | кольцо | `danger-soft` / `danger` | Не в сети |
| `error` | треугольник | `danger-soft` / `danger` | Ошибка |
| `disabled` | тире | `neutral-soft` / `ink-muted` | Выключена |

Неизвестный статус — «Неизвестно», кольцо, нейтральный цвет; код — в лог. Статус обновляется из WebSocket (`camera_status`), без обновления экрана.
