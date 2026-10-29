# TextField

Поле ввода с подписью сверху и подсказкой или ошибкой снизу.

- Ошибки `validation_error` показывайте под полем, где `details[].field` совпадает с ключом поля; свой русский/казахский текст по `code`, не `message` сервера.
- `type="password"` добавляет кнопку «показать». Пароль — от 10 символов: пишите это в `hint` заранее, а не только в ошибке.
- `mono` — для RTSP-адресов и ключей (`mono`-стиль). Для URL: `type="url"`, `autoComplete="off"`.
- Фон `surface-sunken`, рамка `line-strong`, фокус — рамка `brand`; ошибка — рамка и текст `danger`.

Потребитель передаёт: `label`, `value/onChange` или `defaultValue`, `error`, `hint`.
