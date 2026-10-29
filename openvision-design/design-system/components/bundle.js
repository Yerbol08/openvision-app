/* @ds-bundle: {"format":4,"namespace":"OpenVision","components":[{"name":"Button"},{"name":"TextField"},{"name":"Switch"},{"name":"FilterChip"},{"name":"StatusBadge"},{"name":"StatusReason"},{"name":"ConnectionBanner"},{"name":"CameraCard"},{"name":"EventRow"},{"name":"FrameViewer"},{"name":"StatTile"},{"name":"HourlyChart"},{"name":"ModeOption"},{"name":"CopyField"},{"name":"MemberRow"},{"name":"TabBar"},{"name":"AppBar"},{"name":"Icon"},{"name":"MediaPlaceholder"}]} */
(function () {
  var R = window.React, h = R.createElement, useState = R.useState;
  function cx() { return Array.prototype.filter.call(arguments, Boolean).join(' '); }
  function omit(o, keys) { var r = {}; for (var k in o) if (keys.indexOf(k) < 0) r[k] = o[k]; return r; }

  /* ---------- Icons: 24px grid, 1.75 stroke, round caps ---------- */
  var P = {
    dashboard: ['M4 4h7v7H4z', 'M13 4h7v4h-7z', 'M13 10h7v10h-7z', 'M4 13h7v7H4z'],
    camera: ['M4 7h10a2 2 0 0 1 2 2v6a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V9a2 2 0 0 1 2-2z', 'M16 10.5l6-3.5v10l-6-3.5'],
    face: ['M4 8V6a2 2 0 0 1 2-2h2', 'M16 4h2a2 2 0 0 1 2 2v2', 'M20 16v2a2 2 0 0 1-2 2h-2', 'M8 20H6a2 2 0 0 1-2-2v-2', 'M9 10h.01', 'M15 10h.01', 'M9.5 14.5a3.5 3.5 0 0 0 5 0'],
    team: ['M15 20v-1.5a3.5 3.5 0 0 0-3.5-3.5h-5A3.5 3.5 0 0 0 3 18.5V20', 'M9 11.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7z', 'M21 20v-1.5a3.5 3.5 0 0 0-2.6-3.4', 'M15.5 4.6a3.5 3.5 0 0 1 0 6.8'],
    user: ['M19 20v-1.5a3.5 3.5 0 0 0-3.5-3.5h-7A3.5 3.5 0 0 0 5 18.5V20', 'M12 11.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7z'],
    plus: ['M12 5v14', 'M5 12h14'],
    copy: ['M9 9h10a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1H9a1 1 0 0 1-1-1V10a1 1 0 0 1 1-1z', 'M5 15H4a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1h10a1 1 0 0 1 1 1v1'],
    check: ['M5 12.5l4.5 4.5L19 7.5'],
    alert: ['M10.3 4.2L2.6 18a2 2 0 0 0 1.7 3h15.4a2 2 0 0 0 1.7-3L13.7 4.2a2 2 0 0 0-3.4 0z', 'M12 9v4', 'M12 17h.01'],
    info: ['M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18z', 'M12 11v5', 'M12 8h.01'],
    clock: ['M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18z', 'M12 7v5l3 2'],
    offline: ['M3 3l18 18', 'M8.5 16.5a5 5 0 0 1 6-.8', 'M5 12.9a10 10 0 0 1 4-2.5', 'M19 12.9a10 10 0 0 0-3-2', 'M2 8.8a15 15 0 0 1 3.5-2.4', 'M22 8.8A15 15 0 0 0 11 5', 'M12 20h.01'],
    box: ['M21 8l-9-5-9 5v8l9 5 9-5z', 'M3 8l9 5 9-5', 'M12 13v8'],
    link: ['M10 14a4 4 0 0 0 5.7 0l3-3a4 4 0 0 0-5.7-5.7l-1 1', 'M14 10a4 4 0 0 0-5.7 0l-3 3a4 4 0 0 0 5.7 5.7l1-1'],
    send: ['M12 16V4', 'M7 9l5-5 5 5', 'M5 20h14'],
    share: ['M12 3v12', 'M8 7l4-4 4 4', 'M5 12v7a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-7'],
    'chevron-right': ['M9 6l6 6-6 6'],
    'chevron-left': ['M15 6l-6 6 6 6'],
    'chevron-down': ['M6 9l6 6 6-6'],
    filter: ['M4 5h16l-6 7.5V19l-4 2v-8.5z'],
    lock: ['M7 11h10a1 1 0 0 1 1 1v8a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1v-8a1 1 0 0 1 1-1z', 'M8 11V8a4 4 0 0 1 8 0v3'],
    eye: ['M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z', 'M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z'],
    more: ['M12 6h.01', 'M12 12h.01', 'M12 18h.01'],
    close: ['M6 6l12 12', 'M18 6L6 18'],
    refresh: ['M20 11a8 8 0 0 0-14.9-3', 'M4 4v4h4', 'M4 13a8 8 0 0 0 14.9 3', 'M20 20v-4h-4'],
    bell: ['M6 9a6 6 0 0 1 12 0c0 6 2.5 7.5 2.5 7.5h-17S6 15 6 9z', 'M10 20a2 2 0 0 0 4 0'],
    settings: ['M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z', 'M19 12a7 7 0 0 0-.1-1.2l2-1.6-2-3.4-2.4 1a7 7 0 0 0-2-1.2L14 3h-4l-.5 2.6a7 7 0 0 0-2 1.2l-2.4-1-2 3.4 2 1.6a7 7 0 0 0 0 2.4l-2 1.6 2 3.4 2.4-1a7 7 0 0 0 2 1.2L10 21h4l.5-2.6a7 7 0 0 0 2-1.2l2.4 1 2-3.4-2-1.6c.1-.4.1-.8.1-1.2z'],
    trash: ['M4 7h16', 'M10 11v6', 'M14 11v6', 'M6 7l1 13h10l1-13', 'M9 7V4h6v3']
  };
  function Icon(p) {
    var size = p.size || 20, d = P[p.name] || P.info;
    return h('svg', { className: cx('ov-icon', p.spin && 'ov-spin', p.className), width: size, height: size, viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth: p.strokeWidth || 1.75, strokeLinecap: 'round', strokeLinejoin: 'round', 'aria-hidden': p.label ? undefined : true, role: p.label ? 'img' : undefined, 'aria-label': p.label },
      d.map(function (x, i) { return h('path', { key: i, d: x }); }));
  }
  Icon.names = Object.keys(P);
  function Spinner(p) {
    var s = p.size || 16;
    return h('svg', { className: 'ov-icon ov-spin', width: s, height: s, viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth: 3, strokeLinecap: 'round', 'aria-hidden': true },
      h('path', { d: 'M12 3a9 9 0 1 1-9 9', opacity: 1 }));
  }

  /* ---------- Media placeholder: stands in for a CCTV frame or a face crop ---------- */
  function MediaPlaceholder(p) {
    var kind = p.kind || 'scene', src = p.src;
    var art = kind === 'face'
      ? h('svg', { viewBox: '0 0 56 56', preserveAspectRatio: 'xMidYMid slice', 'aria-hidden': true },
          h('circle', { className: 'ov-scene-fill', cx: 28, cy: 23, r: 10 }),
          h('path', { className: 'ov-scene-fill', d: 'M8 56c2-12 10-18 20-18s18 6 20 18z' }))
      : kind === 'empty'
        ? h('svg', { viewBox: '0 0 160 100', preserveAspectRatio: 'xMidYMid slice', 'aria-hidden': true },
            h('path', { className: 'ov-scene-line', d: 'M70 50h20M80 40v20', strokeWidth: 2, fill: 'none' }))
        : h('svg', { viewBox: '0 0 1920 1080', preserveAspectRatio: 'xMidYMid slice', 'aria-hidden': true },
            h('path', { className: 'ov-scene-line', fill: 'none', strokeWidth: 6, d: 'M0 760L700 560H1220L1920 760M700 560V120M1220 560V120M0 1080L520 760M1920 1080L1400 760' }),
            h('rect', { className: 'ov-scene-line', fill: 'none', strokeWidth: 6, x: 860, y: 200, width: 200, height: 360 }),
            h('circle', { className: 'ov-scene-fill', cx: 688, cy: 300, r: 62 }),
            h('path', { className: 'ov-scene-fill', d: 'M580 760c6-200 50-330 108-330s102 130 108 330z' }),
            h('circle', { className: 'ov-scene-fill', cx: 1320, cy: 360, r: 44, opacity: .7 }),
            h('path', { className: 'ov-scene-fill', opacity: .7, d: 'M1245 700c4-150 36-250 75-250s71 100 75 250z' }));
    return h('div', { className: cx('ov-media', p.className), style: p.style },
      src ? h('img', { src: src, alt: p.alt || '', loading: 'lazy' }) : art);
  }

  /* ---------- Button ---------- */
  function Button(p) {
    var v = p.variant || 'primary';
    var rest = omit(p, ['variant', 'size', 'block', 'loading', 'icon', 'className', 'children']);
    return h('button', Object.assign({ type: 'button' }, rest, {
      className: cx('ov-btn', 'ov-btn-' + v, p.size === 'sm' && 'ov-btn-sm', p.block && 'ov-btn-block', p.loading && 'ov-btn-loading', p.className),
      'aria-busy': p.loading || undefined, disabled: p.disabled
    }), p.loading ? h(Spinner, { size: 18 }) : (p.icon ? h(Icon, { name: p.icon, size: 20 }) : null), p.children);
  }

  /* ---------- TextField ---------- */
  function TextField(p) {
    var st = useState(false), show = st[0], setShow = st[1];
    var isPw = p.type === 'password';
    var id = p.id || ('f' + Math.random().toString(36).slice(2, 8));
    return h('div', { className: cx('ov-field', p.error && 'ov-field-error', p.mono && 'ov-field-mono', p.className) },
      p.label ? h('label', { className: 'ov-field-label', htmlFor: id }, p.label) : null,
      h('div', { className: 'ov-field-box' },
        p.icon ? h(Icon, { name: p.icon, size: 20 }) : null,
        h('input', { id: id, type: isPw && !show ? 'password' : (isPw ? 'text' : (p.type || 'text')), placeholder: p.placeholder, defaultValue: p.defaultValue, value: p.value, onChange: p.onChange, autoComplete: p.autoComplete, inputMode: p.inputMode, 'aria-invalid': !!p.error || undefined, readOnly: p.readOnly }),
        isPw ? h('button', { type: 'button', className: 'ov-iconbtn', style: { width: 36, height: 36, marginRight: -6, color: 'var(--ink-muted)' }, onClick: function () { setShow(!show); }, 'aria-label': show ? 'Скрыть пароль' : 'Показать пароль' }, h(Icon, { name: 'eye', size: 20 })) : null),
      (p.error || p.hint) ? h('div', { className: 'ov-field-hint', role: p.error ? 'alert' : undefined }, p.error || p.hint) : null);
  }

  /* ---------- Switch ---------- */
  function Switch(p) {
    var st = useState(!!p.defaultChecked), inner = st[0], setInner = st[1];
    var on = p.checked != null ? p.checked : inner;
    return h('button', { type: 'button', role: 'switch', 'aria-checked': on ? 'true' : 'false', 'aria-label': p.label ? undefined : p['aria-label'], className: cx('ov-switch', p.className), disabled: p.disabled,
      onClick: function () { if (p.checked == null) setInner(!on); if (p.onChange) p.onChange(!on); } },
      p.label ? h('span', null, p.label) : null,
      h('span', { className: 'ov-switch-track' }, h('span', { className: 'ov-switch-thumb' })));
  }

  /* ---------- FilterChip ---------- */
  function FilterChip(p) {
    return h('button', { type: 'button', className: 'ov-chip', 'aria-pressed': p.selected ? 'true' : 'false', onClick: p.onClick },
      p.selected && !p.icon ? h(Icon, { name: 'check', size: 16 }) : (p.icon ? h(Icon, { name: p.icon, size: 16 }) : null),
      p.children, p.count != null ? h('span', { className: 'ov-chip-count' }, p.count) : null,
      p.menu ? h(Icon, { name: 'chevron-down', size: 16 }) : null);
  }

  /* ---------- Camera status ---------- */
  var STATUS = {
    pending: { text: 'Настройка', glyph: 'spin' },
    connecting: { text: 'Подключение', glyph: 'spin' },
    online: { text: 'В сети', glyph: 'dot' },
    offline: { text: 'Не в сети', glyph: 'ring' },
    error: { text: 'Ошибка', glyph: 'alert' },
    disabled: { text: 'Выключена', glyph: 'dash' }
  };
  function StatusBadge(p) {
    var s = STATUS[p.status] || { text: 'Неизвестно', glyph: 'ring' };
    var key = STATUS[p.status] ? p.status : 'unknown';
    var g = s.glyph === 'spin' ? h(Spinner, { size: 12 })
      : s.glyph === 'alert' ? h(Icon, { name: 'alert', size: 14, strokeWidth: 2.25 })
      : h('span', { className: cx('ov-dot', s.glyph === 'ring' && 'ov-dot-ring', s.glyph === 'dash' && 'ov-dot-dash') });
    return h('span', { className: cx('ov-badge', 'ov-badge-' + key, p.className) }, g, p.children || s.text);
  }
  var REASONS = {
    waiting_for_video: ['warn', 'Ждём видео', 'Проверьте, что регистратор отправляет поток на адрес, который мы выдали.'],
    edge_agent_offline: ['warn', 'Блок OpenVision не в сети', 'Проверьте, что блок на объекте включён и подключён к интернету.'],
    no_video: ['danger', 'Видео не поступает', 'Проверьте питание и сеть камеры.'],
    waiting_for_gpu: ['info', 'Ожидание мощностей анализа', 'Видео в порядке, анализ скоро начнётся. Ничего делать не нужно.'],
    source_unreachable: ['danger', 'Камера недоступна', 'Проверьте адрес и что камера доступна из интернета.'],
    source_auth_failed: ['danger', 'Неверный логин или пароль', 'Камера отклонила имя пользователя или пароль.'],
    source_not_found: ['danger', 'Поток не найден', 'По этому пути у камеры нет потока. Проверьте URL.'],
    unsupported_codec: ['danger', 'Неподдерживаемый формат', 'Нужен H.264 или H.265. Смените кодек в настройках камеры.'],
    no_video_track: ['danger', 'В потоке нет видео', 'Поток подключился, но видеодорожки в нём нет.'],
    private_address_refused: ['danger', 'Это адрес локальной сети', 'Из облака его не видно. Подключите камеру через блок OpenVision.'],
    ingest_error: ['info', 'Сбой на нашей стороне', 'Мы уже получили уведомление и разбираемся.']
  };
  function StatusReason(p) {
    if (!p.reason) return null;
    var r = REASONS[p.reason] || ['danger', 'Камера не работает', 'Обратитесь в поддержку.'];
    var icon = r[0] === 'info' ? 'info' : r[0] === 'warn' ? 'clock' : 'alert';
    return h('div', { className: cx('ov-reason', 'ov-reason-' + r[0], p.className), role: 'status' },
      h('span', { className: 'ov-reason-icon' }, h(Icon, { name: icon, size: 20 })),
      h('div', { style: { flex: 1, minWidth: 0 } },
        p.compact ? null : h('div', { className: 'ov-reason-title' }, r[1]),
        h('div', { className: 'ov-reason-text' }, p.compact ? r[1] + '. ' + r[2] : r[2]),
        p.lastSeen ? h('div', { className: 'ov-reason-meta' }, 'Последний сигнал ' + p.lastSeen) : null,
        p.action ? h('div', { style: { marginTop: 8 } }, p.action) : null));
  }
  StatusReason.reasons = REASONS;

  /* ---------- ConnectionBanner (live socket) ---------- */
  function ConnectionBanner(p) {
    var s = p.state || 'live';
    var text = s === 'live' ? 'Онлайн — события приходят сразу' : s === 'reconnecting' ? 'Переподключаемся…' : 'Нет интернета. Показаны сохранённые данные';
    var g = s === 'live' ? h('span', { className: 'ov-dot' }) : s === 'reconnecting' ? h(Spinner, { size: 14 }) : h(Icon, { name: 'offline', size: 16 });
    return h('div', { className: cx('ov-conn', 'ov-conn-' + s), role: 'status' }, g, h('span', { className: 'ov-conn-text' }, p.children || text),
      s === 'offline' && p.onRetry !== false ? h('button', { type: 'button', className: 'ov-conn-action', onClick: p.onRetry }, 'Повторить') : null);
  }

  /* ---------- CameraCard ---------- */
  function CameraCard(p) {
    var status = p.enabled === false ? 'disabled' : p.status;
    var showReason = p.reason && status !== 'online' && status !== 'disabled';
    var meta = [p.location, p.lastEventAt ? 'событие ' + p.lastEventAt : null].filter(Boolean).join(' · ');
    return h('div', { className: cx('ov-card ov-cam', status === 'disabled' && 'ov-cam-off', p.className) },
      h('div', { className: 'ov-cam-main' },
        h(MediaPlaceholder, { className: 'ov-cam-thumb', src: p.thumb, kind: p.thumb === null && status !== 'online' ? 'empty' : 'scene' }),
        h('div', { className: 'ov-cam-body' },
          h('div', { className: 'ov-cam-name' }, p.name),
          meta ? h('div', { className: 'ov-cam-meta' }, meta) : null,
          h('div', null, h(StatusBadge, { status: status }))),
        p.canControl ? h(Switch, { defaultChecked: p.enabled !== false, 'aria-label': 'Камера включена', onChange: p.onToggle }) : h('span', { className: 'ov-chev' }, h(Icon, { name: 'chevron-right' }))),
      showReason ? h(StatusReason, { reason: p.reason, compact: true, lastSeen: p.lastSeen }) : null);
  }

  /* ---------- EventRow ---------- */
  function EventRow(p) {
    var known = !!p.known;
    var title = p.personName || (known ? 'Известный человек' : 'Неизвестный');
    return h('div', { className: cx('ov-event', p.className), role: 'button', tabIndex: 0, onClick: p.onClick },
      h(MediaPlaceholder, { className: 'ov-event-crop', src: p.crop, kind: 'face' }),
      h('div', { className: 'ov-event-body' },
        h('div', { className: 'ov-event-title' }, title, p.isNew ? h('span', { className: 'ov-new', 'aria-label': 'Новое' }) : null),
        h('div', { className: 'ov-event-meta' }, [p.cameraName, p.seenToday ? 'сегодня ' + p.seenToday + ' раз' : null].filter(Boolean).join(' · '))),
      h('div', { className: 'ov-event-side' },
        h('span', { className: 'ov-num' }, p.time),
        h('span', { className: cx('ov-tag', known ? 'ov-tag-brand' : 'ov-tag-neutral') }, known ? (p.confidence != null ? Math.round(p.confidence * 100) + '%' : 'Известный') : 'Новый')));
  }

  /* ---------- FrameViewer: draws bbox [x,y,w,h] in frame pixels ---------- */
  function FrameViewer(p) {
    var W = p.naturalWidth || 1920, H = p.naturalHeight || 1080, b = p.bbox;
    var box = b ? { left: (b[0] / W * 100) + '%', top: (b[1] / H * 100) + '%', width: (b[2] / W * 100) + '%', height: (b[3] / H * 100) + '%' } : null;
    return h('div', { className: cx('ov-frame', p.className), style: { aspectRatio: W + ' / ' + H } },
      h(MediaPlaceholder, { className: 'ov-frame-img', src: p.src, alt: p.alt || 'Кадр события' }),
      box ? h('div', { className: 'ov-bbox', style: box }, p.label ? h('span', { className: 'ov-bbox-label' }, p.label) : null) : null,
      p.time ? h('span', { className: 'ov-frame-time' }, p.time) : null);
  }

  /* ---------- StatTile ---------- */
  function StatTile(p) {
    return h('div', { className: cx('ov-card ov-stat', p.className) },
      h('div', { className: 'ov-stat-label' }, p.label),
      h('div', { className: 'ov-stat-value' }, p.value, p.total != null ? h('span', { style: { color: 'var(--ink-muted)', fontWeight: 500, fontSize: 22 } }, ' / ' + p.total) : null),
      p.sub ? h('div', { className: 'ov-stat-sub', style: p.subTone ? { color: 'var(--' + p.subTone + ')' } : null }, p.sub) : null);
  }

  /* ---------- HourlyChart: 24 local hours, gaps already zero-filled ---------- */
  function HourlyChart(p) {
    var data = p.data || [], now = p.nowHour != null ? p.nowHour : 23;
    var max = Math.max.apply(null, data.concat([1])), peak = data.indexOf(max);
    var pad = function (n) { return (n < 10 ? '0' : '') + n; };
    return h('div', { className: cx('ov-card ov-chart', p.className) },
      h('div', { className: 'ov-chart-head' },
        h('span', { className: 'ov-chart-title' }, p.title || 'События по часам'),
        h('span', { className: 'ov-chart-peak ov-num' }, 'пик ' + pad(peak) + ':00 — ' + max)),
      h('div', { className: 'ov-bars', role: 'img', 'aria-label': 'Событий по часам, максимум ' + max + ' в ' + pad(peak) + ':00' },
        Array.from({ length: 24 }, function (_, i) {
          var v = data[i] || 0, fut = i > now;
          return h('div', { key: i, title: pad(i) + ':00 — ' + v, className: cx('ov-bar', fut ? 'ov-bar-future' : (v === 0 && 'ov-bar-zero'), i === now && 'ov-bar-now'), style: { height: fut ? '2px' : (v / max * 100) + '%' } });
        })),
      h('div', { className: 'ov-axis' }, h('span', null, '00'), h('span', null, '06'), h('span', null, '12'), h('span', null, '18'), h('span', null, '23')));
  }

  /* ---------- ModeOption (Add camera questionnaire) ---------- */
  function ModeOption(p) {
    return h('button', { type: 'button', role: 'radio', 'aria-checked': p.selected ? 'true' : 'false', className: 'ov-mode', onClick: p.onClick },
      h('span', { className: 'ov-mode-icon' }, h(Icon, { name: p.icon || 'camera', size: 22 })),
      h('span', { className: 'ov-mode-body' },
        h('span', { className: 'ov-mode-title' }, p.title),
        p.description ? h('span', { className: 'ov-mode-text' }, p.description) : null,
        p.tag ? h('span', { className: 'ov-mode-tag' }, h('span', { className: 'ov-tag ov-tag-neutral' }, p.tag)) : null),
      h('span', { className: 'ov-radio' }));
  }

  /* ---------- CopyField (push URLs, agent command) ---------- */
  function CopyField(p) {
    var st = useState(false), done = st[0], setDone = st[1];
    function copy() {
      try { if (navigator.clipboard) navigator.clipboard.writeText(p.value).catch(function () {}); } catch (e) {}
      setDone(true); setTimeout(function () { setDone(false); }, 1600);
      if (p.onCopy) p.onCopy();
    }
    return h('div', { className: cx('ov-copy', p.className) },
      p.label ? h('div', { className: 'ov-copy-head' }, h('span', { className: 'ov-copy-label' }, p.label), p.badge ? h('span', { className: 'ov-tag ov-tag-brand' }, p.badge) : null) : null,
      h('div', { className: 'ov-copy-box' },
        h('span', { className: 'ov-copy-value' }, p.value),
        h('button', { type: 'button', className: cx('ov-copy-btn', done && 'ov-copy-done'), onClick: copy, 'aria-live': 'polite' },
          h(Icon, { name: done ? 'check' : 'copy', size: 16 }), done ? 'Скопировано' : 'Копировать')),
      p.hint ? h('div', { className: 'ov-copy-hint' }, p.hint) : null);
  }

  /* ---------- MemberRow (Team) ---------- */
  var ROLES = { owner: 'Владелец', admin: 'Администратор', operator: 'Оператор', viewer: 'Наблюдатель' };
  function MemberRow(p) {
    var initials = (p.name || '?').split(/\s+/).map(function (w) { return w.charAt(0); }).join('').slice(0, 2).toUpperCase();
    return h('div', { className: cx('ov-member', p.active === false && 'ov-member-inactive') },
      h('span', { className: 'ov-avatar', 'aria-hidden': true }, initials),
      h('div', { className: 'ov-member-body' },
        h('div', { className: 'ov-member-name' }, p.name, p.isYou ? h('span', { style: { color: 'var(--ink-muted)', fontWeight: 400 } }, ' (вы)') : null),
        h('div', { className: 'ov-member-mail' }, p.active === false ? 'Отключён · ' + p.email : p.email)),
      h('span', { className: cx('ov-tag', p.role === 'owner' || p.role === 'admin' ? 'ov-tag-brand' : 'ov-tag-neutral') }, p.role === 'owner' ? h(Icon, { name: 'lock', size: 12, strokeWidth: 2.25 }) : null, ROLES[p.role] || p.role),
      p.editable ? h('button', { type: 'button', className: 'ov-iconbtn', 'aria-label': 'Действия' }, h(Icon, { name: 'more' })) : null);
  }

  /* ---------- TabBar ---------- */
  var TABS = [{ id: 'dashboard', label: 'Обзор', icon: 'dashboard' }, { id: 'cameras', label: 'Камеры', icon: 'camera' }, { id: 'events', label: 'События', icon: 'face' }, { id: 'team', label: 'Команда', icon: 'team' }];
  function TabBar(p) {
    var items = p.items || TABS;
    if (p.hideTeam) items = items.filter(function (t) { return t.id !== 'team'; });
    return h('nav', { className: cx('ov-tabbar', p.className) }, items.map(function (t) {
      var b = p.badges && p.badges[t.id];
      return h('button', { key: t.id, type: 'button', className: 'ov-tab', 'aria-current': p.active === t.id ? 'page' : undefined },
        h('span', { className: 'ov-tab-pill' }, h(Icon, { name: t.icon, size: 22 })), t.label,
        b ? h('span', { className: 'ov-tab-badge' }, b) : null);
    }));
  }

  /* ---------- AppBar ---------- */
  function AppBar(p) {
    return h('header', { className: cx('ov-appbar', p.large && 'ov-appbar-large') },
      p.back ? h('button', { type: 'button', className: 'ov-iconbtn', style: { marginLeft: -12 }, 'aria-label': 'Назад' }, h(Icon, { name: 'chevron-left', size: 24 })) : null,
      h('div', { className: 'ov-appbar-title' }, p.title),
      (p.actions || []).map(function (a, i) { return h('button', { key: i, type: 'button', className: 'ov-iconbtn', 'aria-label': a.label }, h(Icon, { name: a.icon, size: 22 })); }));
  }

  window.OpenVision = Object.assign(window.OpenVision || {}, {
    Button: Button, TextField: TextField, Switch: Switch, FilterChip: FilterChip, StatusBadge: StatusBadge, StatusReason: StatusReason,
    ConnectionBanner: ConnectionBanner, CameraCard: CameraCard, EventRow: EventRow, FrameViewer: FrameViewer, StatTile: StatTile,
    HourlyChart: HourlyChart, ModeOption: ModeOption, CopyField: CopyField, MemberRow: MemberRow, TabBar: TabBar, AppBar: AppBar,
    Icon: Icon, MediaPlaceholder: MediaPlaceholder
  });
})();
