import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import '../../theme/ov_theme.dart';

enum MediaKind { scene, face, empty }

/// Кадр или кроп лица с заглушкой (MediaPlaceholder).
///
/// Подписанные ссылки меняются при каждом запросе, поэтому кэш — по [cacheKey]
/// (id события). Ошибка загрузки (обычно 403 `media_link_expired`) вызывает
/// [onError], чтобы перезапросить событие, а не старый URL.
class OvMedia extends StatelessWidget {
  const OvMedia({
    super.key,
    this.kind = MediaKind.scene,
    this.url,
    this.cacheKey,
    this.onError,
    this.radius = 0,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.opacity = 1,
  });

  final MediaKind kind;
  final String? url;
  final String? cacheKey;
  final VoidCallback? onError;
  final double radius;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    final placeholder = CustomPaint(painter: _PlaceholderPainter(kind, ov.mediaLine), size: Size.infinite);
    Widget child = placeholder;
    final src = url;
    if (src != null) {
      child = CachedNetworkImage(
        imageUrl: src,
        cacheKey: cacheKey,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 150),
        placeholder: (_, _) => placeholder,
        errorWidget: (_, _, _) {
          final cb = onError;
          if (cb != null) WidgetsBinding.instance.addPostFrameCallback((_) => cb());
          return placeholder;
        },
      );
    }
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: ColoredBox(
          color: ov.media,
          child: SizedBox(
            width: width,
            height: height,
            child: Opacity(opacity: opacity, child: child),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderPainter extends CustomPainter {
  _PlaceholderPainter(this.kind, this.color);

  final MediaKind kind;
  final Color color;

  static final _sceneLines = parseSvgPathData('M0 760L700 560H1220L1920 760M700 560V120M1220 560V120M0 1080L520 760M1920 1080L1400 760');
  static final _sceneBody1 = parseSvgPathData('M580 760c6-200 50-330 108-330s102 130 108 330z');
  static final _sceneBody2 = parseSvgPathData('M1245 700c4-150 36-250 75-250s71 100 75 250z');
  static final _faceBody = parseSvgPathData('M8 56c2-12 10-18 20-18s18 6 20 18z');

  @override
  void paint(Canvas canvas, Size size) {
    final (vw, vh) = switch (kind) {
      MediaKind.scene => (1920.0, 1080.0),
      MediaKind.face => (56.0, 56.0),
      MediaKind.empty => (160.0, 100.0),
    };
    // preserveAspectRatio="xMidYMid slice"
    final s = math.max(size.width / vw, size.height / vh);
    canvas.clipRect(Offset.zero & size);
    canvas.translate((size.width - vw * s) / 2, (size.height - vh * s) / 2);
    canvas.scale(s);

    final fill = Paint()..color = color;
    final faded = Paint()..color = color.withValues(alpha: color.a * .7);
    Paint stroke(double w) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..color = color;

    switch (kind) {
      case MediaKind.face:
        canvas.drawCircle(const Offset(28, 23), 10, fill);
        canvas.drawPath(_faceBody, fill);
      case MediaKind.empty:
        canvas.drawLine(const Offset(70, 50), const Offset(90, 50), stroke(2));
        canvas.drawLine(const Offset(80, 40), const Offset(80, 60), stroke(2));
      case MediaKind.scene:
        canvas.drawPath(_sceneLines, stroke(6));
        canvas.drawRect(const Rect.fromLTWH(860, 200, 200, 360), stroke(6));
        canvas.drawCircle(const Offset(688, 300), 62, fill);
        canvas.drawPath(_sceneBody1, fill);
        canvas.drawCircle(const Offset(1320, 360), 44, faded);
        canvas.drawPath(_sceneBody2, faded);
    }
  }

  @override
  bool shouldRepaint(_PlaceholderPainter old) => old.kind != kind || old.color != color;
}
