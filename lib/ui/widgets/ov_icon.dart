import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

/// Линейные иконки 24×24, обводка 1.75, скруглённые концы (компонент Icon).
///
/// Контуры взяты из эталонной реализации дизайн-системы (стиль Lucide),
/// чтобы толщина и форма совпадали с макетами точно.
enum OvIcons {
  dashboard(['M4 4h7v7H4z', 'M13 4h7v4h-7z', 'M13 10h7v10h-7z', 'M4 13h7v7H4z']),
  camera(['M4 7h10a2 2 0 0 1 2 2v6a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V9a2 2 0 0 1 2-2z', 'M16 10.5l6-3.5v10l-6-3.5']),
  face([
    'M4 8V6a2 2 0 0 1 2-2h2', 'M16 4h2a2 2 0 0 1 2 2v2', 'M20 16v2a2 2 0 0 1-2 2h-2', 'M8 20H6a2 2 0 0 1-2-2v-2',
    'M9 10h.01', 'M15 10h.01', 'M9.5 14.5a3.5 3.5 0 0 0 5 0',
  ]),
  team([
    'M15 20v-1.5a3.5 3.5 0 0 0-3.5-3.5h-5A3.5 3.5 0 0 0 3 18.5V20', 'M9 11.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7z',
    'M21 20v-1.5a3.5 3.5 0 0 0-2.6-3.4', 'M15.5 4.6a3.5 3.5 0 0 1 0 6.8',
  ]),
  user(['M19 20v-1.5a3.5 3.5 0 0 0-3.5-3.5h-7A3.5 3.5 0 0 0 5 18.5V20', 'M12 11.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7z']),
  plus(['M12 5v14', 'M5 12h14']),
  copy([
    'M9 9h10a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1H9a1 1 0 0 1-1-1V10a1 1 0 0 1 1-1z',
    'M5 15H4a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1h10a1 1 0 0 1 1 1v1',
  ]),
  check(['M5 12.5l4.5 4.5L19 7.5']),
  alert(['M10.3 4.2L2.6 18a2 2 0 0 0 1.7 3h15.4a2 2 0 0 0 1.7-3L13.7 4.2a2 2 0 0 0-3.4 0z', 'M12 9v4', 'M12 17h.01']),
  info(['M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18z', 'M12 11v5', 'M12 8h.01']),
  clock(['M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18z', 'M12 7v5l3 2']),
  offline([
    'M3 3l18 18', 'M8.5 16.5a5 5 0 0 1 6-.8', 'M5 12.9a10 10 0 0 1 4-2.5', 'M19 12.9a10 10 0 0 0-3-2',
    'M2 8.8a15 15 0 0 1 3.5-2.4', 'M22 8.8A15 15 0 0 0 11 5', 'M12 20h.01',
  ]),
  box(['M21 8l-9-5-9 5v8l9 5 9-5z', 'M3 8l9 5 9-5', 'M12 13v8']),
  link([
    'M10 14a4 4 0 0 0 5.7 0l3-3a4 4 0 0 0-5.7-5.7l-1 1',
    'M14 10a4 4 0 0 0-5.7 0l-3 3a4 4 0 0 0 5.7 5.7l1-1',
  ]),
  send(['M12 16V4', 'M7 9l5-5 5 5', 'M5 20h14']),
  share(['M12 3v12', 'M8 7l4-4 4 4', 'M5 12v7a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-7']),
  chevronRight(['M9 6l6 6-6 6']),
  chevronLeft(['M15 6l-6 6 6 6']),
  chevronDown(['M6 9l6 6 6-6']),
  filter(['M4 5h16l-6 7.5V19l-4 2v-8.5z']),
  lock([
    'M7 11h10a1 1 0 0 1 1 1v8a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1v-8a1 1 0 0 1 1-1z',
    'M8 11V8a4 4 0 0 1 8 0v3',
  ]),
  eye(['M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z', 'M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z']),
  more(['M12 6h.01', 'M12 12h.01', 'M12 18h.01']),
  close(['M6 6l12 12', 'M18 6L6 18']),
  refresh(['M20 11a8 8 0 0 0-14.9-3', 'M4 4v4h4', 'M4 13a8 8 0 0 0 14.9 3', 'M20 20v-4h-4']),
  bell(['M6 9a6 6 0 0 1 12 0c0 6 2.5 7.5 2.5 7.5h-17S6 15 6 9z', 'M10 20a2 2 0 0 0 4 0']),
  settings([
    'M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z',
    'M19 12a7 7 0 0 0-.1-1.2l2-1.6-2-3.4-2.4 1a7 7 0 0 0-2-1.2L14 3h-4l-.5 2.6a7 7 0 0 0-2 1.2l-2.4-1-2 3.4 2 1.6a7 7 0 0 0 0 2.4l-2 1.6 2 3.4 2.4-1a7 7 0 0 0 2 1.2L10 21h4l.5-2.6a7 7 0 0 0 2-1.2l2.4 1 2-3.4-2-1.6c.1-.4.1-.8.1-1.2z',
  ]),
  trash(['M4 7h16', 'M10 11v6', 'M14 11v6', 'M6 7l1 13h10l1-13', 'M9 7V4h6v3']);

  const OvIcons(this.paths);
  final List<String> paths;

  static final Map<OvIcons, Path> _cache = {};
  Path get path => _cache.putIfAbsent(this, () {
        final p = Path();
        for (final d in paths) {
          p.addPath(parseSvgPathData(d), Offset.zero);
        }
        return p;
      });
}

/// Размеры: 20 в строках и полях, 22 в навигации и шапке, 16 в чипах и бейджах.
class OvIcon extends StatelessWidget {
  const OvIcon(this.icon, {super.key, this.size = 20, this.color, this.strokeWidth = 1.75, this.semanticLabel});

  final OvIcons icon;
  final double size;
  final Color? color;
  final double strokeWidth;

  /// Иконка без подписи рядом обязана иметь текст для TalkBack/VoiceOver.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? DefaultTextStyle.of(context).style.color!;
    final paint = CustomPaint(size: Size.square(size), painter: _StrokePainter(icon.path, c, strokeWidth));
    if (semanticLabel == null) return ExcludeSemantics(child: paint);
    return Semantics(label: semanticLabel, image: true, child: paint);
  }
}

class _StrokePainter extends CustomPainter {
  _StrokePainter(this.path, this.color, this.strokeWidth);

  final Path path;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.scale(s);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_StrokePainter old) => old.path != path || old.color != color || old.strokeWidth != strokeWidth;
}

/// Спиннер дизайн-системы: дуга 270°, обводка 3 на сетке 24.
class OvSpinner extends StatefulWidget {
  const OvSpinner({super.key, this.size = 16, this.color});

  final double size;
  final Color? color;

  @override
  State<OvSpinner> createState() => _OvSpinnerState();
}

class _OvSpinnerState extends State<OvSpinner> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? IconTheme.of(context).color ?? DefaultTextStyle.of(context).style.color!;
    return ExcludeSemantics(
      child: RotationTransition(
        turns: _c,
        child: CustomPaint(size: Size.square(widget.size), painter: _ArcPainter(color)),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.scale(s);
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(12, 12), radius: 9),
      -math.pi / 2,
      math.pi * 1.5,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.color != color;
}
