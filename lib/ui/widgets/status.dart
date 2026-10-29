import 'package:flutter/material.dart';

import '../../core/live/live_connection.dart';
import '../../theme/ov_theme.dart';
import '../../theme/ov_tokens.dart';
import '../strings.dart';
import 'ov_icon.dart';

enum _Glyph { spin, dot, ring, alert, dash }

/// Бейдж статуса камеры: цвет + слово + форма значка.
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key, this.text});

  final String status;

  /// Своё слово вместо стандартного: «Не в сети · 2 дня».
  final String? text;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    final l = context.l10n;
    final (text, glyph, bg, fg) = switch (status) {
      'pending' => (l.statusPending, _Glyph.spin, ov.neutralSoft, ov.inkMuted),
      'connecting' => (l.statusConnecting, _Glyph.spin, ov.warnSoft, ov.warn),
      'online' => (l.statusOnline, _Glyph.dot, ov.onlineSoft, ov.online),
      'offline' => (l.statusOffline, _Glyph.ring, ov.dangerSoft, ov.danger),
      'error' => (l.statusError, _Glyph.alert, ov.dangerSoft, ov.danger),
      'disabled' => (l.statusDisabled, _Glyph.dash, ov.neutralSoft, ov.inkMuted),
      _ => (l.statusUnknown, _Glyph.ring, ov.neutralSoft, ov.inkMuted),
    };
    final Widget g = switch (glyph) {
      _Glyph.spin => OvSpinner(size: 12, color: fg),
      _Glyph.alert => OvIcon(OvIcons.alert, size: 14, strokeWidth: 2.25, color: fg),
      _Glyph.dot => Container(width: 8, height: 8, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
      _Glyph.ring => Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: fg, width: 2)),
        ),
      _Glyph.dash => Container(
          width: 9,
          height: 2,
          decoration: BoxDecoration(color: fg, borderRadius: BorderRadius.circular(1)),
        ),
    };
    return Container(
      constraints: const BoxConstraints(minHeight: 24),
      padding: const EdgeInsets.only(left: 8, right: 10, top: 2, bottom: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(OvRadius.radiusFull)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          g,
          const SizedBox(width: 6),
          Text(this.text ?? text, style: OvText.label.copyWith(color: fg)),
        ],
      ),
    );
  }
}

/// Объяснение `status_reason`. [compact] — одной строкой внутри CameraCard.
class StatusReason extends StatelessWidget {
  const StatusReason(this.reason, {super.key, this.compact = false, this.lastSeen, this.action});

  final String reason;
  final bool compact;

  /// «3 ч назад» — для `no_video`.
  final String? lastSeen;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    final l = context.l10n;
    final r = reasonText(l, reason);
    final (bg, iconColor, icon) = switch (r.tone) {
      ReasonTone.warn => (ov.warnSoft, ov.warn, OvIcons.clock),
      ReasonTone.danger => (ov.dangerSoft, ov.danger, OvIcons.alert),
      ReasonTone.info => (ov.neutralSoft, ov.inkMuted, OvIcons.info),
    };
    final textStyle = OvText.body.copyWith(fontSize: 14, height: 20 / 14, color: ov.ink);
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: OvSpace.space4, vertical: OvSpace.space3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(OvRadius.radiusMd)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.only(top: 1), child: OvIcon(icon, color: iconColor)),
            const SizedBox(width: OvSpace.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!compact) Text(r.title, style: OvText.bodyStrong.copyWith(fontWeight: FontWeight.w600, color: ov.ink)),
                  Text(compact ? '${r.title}. ${r.text}' : r.text, style: textStyle),
                  if (lastSeen != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(l.reasonLastSeen(lastSeen!), style: OvText.caption.copyWith(color: ov.inkMuted)),
                    ),
                  if (action != null) Padding(padding: const EdgeInsets.only(top: OvSpace.space2), child: action),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Полоска состояния live-соединения под шапкой ленты и обзора.
class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({super.key, required this.state, required this.onRetry});

  final LiveState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    final l = context.l10n;
    final (bg, fg, text) = switch (state) {
      LiveState.live => (ov.onlineSoft, ov.online, l.connLive),
      LiveState.offline => (ov.dangerSoft, ov.danger, l.connOffline),
      _ => (ov.warnSoft, ov.warn, l.connReconnecting),
    };
    final Widget glyph = switch (state) {
      LiveState.live => _PulsingDot(color: fg),
      LiveState.offline => OvIcon(OvIcons.offline, size: 16, color: fg),
      _ => OvSpinner(size: 14, color: fg),
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        color: bg,
        padding: const EdgeInsets.symmetric(horizontal: OvSpace.space4, vertical: OvSpace.space2),
        child: Row(
          children: [
            glyph,
            const SizedBox(width: OvSpace.space2),
            Expanded(child: Text(text, style: OvText.caption.copyWith(fontWeight: FontWeight.w500, color: ov.ink))),
            if (state == LiveState.offline)
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: ov.brand,
                  minimumSize: const Size(OvSize.tapMin, 32),
                  padding: const EdgeInsets.symmetric(horizontal: OvSpace.space2),
                  textStyle: OvText.caption.copyWith(fontWeight: FontWeight.w600),
                ),
                child: Text(l.retry),
              ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});
  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: .35).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: Container(width: 8, height: 8, decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle)),
    );
  }
}
