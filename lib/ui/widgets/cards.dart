import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../theme/ov_theme.dart';
import '../../theme/ov_tokens.dart';
import '../strings.dart';
import 'chrome.dart';
import 'controls.dart';
import 'media.dart';
import 'ov_icon.dart';
import 'status.dart';

/// Плитка показателя на «Обзоре».
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.label, required this.value, this.total, this.sub, this.subColor});

  final String label;
  final int value;
  final int? total;
  final String? sub;
  final Color? subColor;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    return OvCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: OvText.caption.copyWith(color: ov.inkMuted)),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(children: [
              TextSpan(text: '$value'),
              if (total != null)
                TextSpan(
                  text: ' / $total',
                  style: TextStyle(color: ov.inkMuted, fontWeight: FontWeight.w500, fontSize: 22),
                ),
            ]),
            style: OvText.metric.copyWith(color: ov.ink, fontFeatures: ovTabular),
          ),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub!, style: OvText.caption.copyWith(color: subColor ?? ov.inkMuted)),
          ],
        ],
      ),
    );
  }
}

/// Столбцы событий по 24 локальным часам. Текущий час обведён, будущие — `line`.
class HourlyChart extends StatelessWidget {
  const HourlyChart({super.key, required this.data, required this.nowHour});

  final List<int> data;
  final int nowHour;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    final l = context.l10n;
    final maxV = math.max(1, data.fold<int>(0, math.max));
    final peak = data.indexOf(data.fold<int>(0, math.max));
    String hh(int h) => '${h.toString().padLeft(2, '0')}:00';
    final peakCount = data.isEmpty ? 0 : data[peak];
    final axis = OvText.label.copyWith(fontWeight: FontWeight.w400, letterSpacing: 0, color: ov.inkMuted, fontFeatures: ovTabular);

    return OvCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: Text(l.chartTitle, style: OvText.headline.copyWith(color: ov.ink))),
              if (peakCount > 0)
                Text(l.chartPeak(hh(peak), peakCount), style: OvText.caption.copyWith(color: ov.inkMuted, fontFeatures: ovTabular)),
            ],
          ),
          const SizedBox(height: OvSpace.space3),
          Semantics(
            label: l.chartA11y(peakCount, hh(peak)),
            excludeSemantics: true,
            child: Container(
              height: 96,
              padding: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: ov.lineStrong))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < 24; i++) ...[
                    if (i > 0) const SizedBox(width: 3),
                    Expanded(child: _Bar(value: data[i], max: maxV, future: i > nowHour, now: i == nowHour)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [for (final t in const ['00', '06', '12', '18', '23']) Text(t, style: axis)],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.value, required this.max, required this.future, required this.now});
  final int value;
  final int max;
  final bool future;
  final bool now;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    final flat = future || value == 0;
    return LayoutBuilder(builder: (context, c) {
      final h = flat ? 2.0 : math.max(2.0, c.maxHeight * value / max);
      return Container(
        height: h,
        decoration: BoxDecoration(
          color: flat ? ov.line : (now ? ov.brand : ov.brand.withValues(alpha: .9)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          boxShadow: now && !flat
              // Как в CSS: зазор цвета фона, затем кольцо brand. Во Flutter первая тень — нижняя.
              ? [BoxShadow(color: ov.brand, spreadRadius: 3), BoxShadow(color: ov.surface, spreadRadius: 1.5)]
              : null,
        ),
      );
    });
  }
}

/// Карточка камеры: превью, имя, место, время события, статус и причина сбоя.
class CameraCard extends StatelessWidget {
  const CameraCard({
    super.key,
    required this.camera,
    required this.onTap,
    this.thumbEvent,
    this.onThumbError,
    this.onToggle,
  });

  final Camera camera;
  final VoidCallback onTap;

  /// Последнее событие камеры — его кадр вместо live-снимка.
  final OvEvent? thumbEvent;
  final VoidCallback? onThumbError;

  /// Есть `cameras.control` — переключатель вместо шеврона.
  final ValueChanged<bool>? onToggle;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    final l = context.l10n;
    final fmt = OvFormat(context);
    final status = camera.displayStatus;
    final reason = camera.statusReason;
    final showReason = reason != null && status != 'online' && status != 'disabled';
    final meta = [
      if (camera.location?.isNotEmpty ?? false) camera.location!,
      if (camera.lastEventAt != null) l.cameraLastEvent(fmt.ago(camera.lastEventAt!)),
    ].join(' · ');
    final frame = thumbEvent?.frameUrl;

    return OvCard(
      onTap: onTap,
      padding: const EdgeInsets.all(OvSpace.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              OvMedia(
                kind: frame == null && status != 'online' ? MediaKind.empty : MediaKind.scene,
                url: frame,
                cacheKey: thumbEvent?.frameCacheKey,
                onError: onThumbError,
                width: OvSize.thumbCamera,
                height: 55,
                radius: OvRadius.radiusSm,
                opacity: status == 'disabled' ? .4 : 1,
              ),
              const SizedBox(width: OvSpace.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(camera.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: OvText.headline.copyWith(color: ov.ink)),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(meta, maxLines: 1, overflow: TextOverflow.ellipsis, style: OvText.caption.copyWith(color: ov.inkMuted)),
                    ],
                    const SizedBox(height: 4),
                    StatusBadge(status),
                  ],
                ),
              ),
              if (onToggle != null)
                OvSwitch(value: camera.enabled, onChanged: onToggle, semanticLabel: l.cameraEnabledA11y)
              else
                OvIcon(OvIcons.chevronRight, color: ov.inkMuted),
            ],
          ),
          if (showReason) ...[
            const SizedBox(height: OvSpace.space3),
            StatusReason(
              reason,
              compact: true,
              lastSeen: reason == 'no_video' && camera.lastSeenAt != null ? fmt.ago(camera.lastSeenAt!) : null,
            ),
          ],
        ],
      ),
    );
  }
}

/// Строка ленты: кроп лица, известный/неизвестный, камера, время, уверенность.
class EventRow extends StatelessWidget {
  const EventRow({super.key, required this.event, required this.onTap, this.isNew = false, this.onCropError});

  final OvEvent event;
  final VoidCallback onTap;
  final bool isNew;
  final VoidCallback? onCropError;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    final l = context.l10n;
    final fmt = OvFormat(context);
    final conf = event.confidence;
    final tag = event.isKnown
        ? OvTag(conf != null ? '${(conf * 100).round()}%' : l.eventTagKnown, tone: OvTagTone.brand)
        : OvTag(l.eventTagNew);

    return Material(
      color: ov.surface,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: OvSpace.space4, vertical: OvSpace.space3),
            child: Row(
              children: [
                OvMedia(
                  kind: MediaKind.face,
                  url: event.cropUrl,
                  cacheKey: event.cropCacheKey,
                  onError: onCropError,
                  width: OvSize.thumbFace,
                  height: OvSize.thumbFace,
                  radius: OvRadius.radiusXs,
                ),
                const SizedBox(width: OvSpace.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              event.isKnown ? l.eventKnown : l.eventUnknown,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: OvText.bodyStrong.copyWith(color: ov.ink),
                            ),
                          ),
                          if (isNew) ...[const SizedBox(width: OvSpace.space2), NewDot(label: l.eventNewA11y)],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(event.cameraName, maxLines: 1, overflow: TextOverflow.ellipsis, style: OvText.caption.copyWith(color: ov.inkMuted)),
                    ],
                  ),
                ),
                const SizedBox(width: OvSpace.space2),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(fmt.time(event.occurredAt), style: OvText.caption.copyWith(color: ov.inkMuted, fontFeatures: ovTabular)),
                    const SizedBox(height: 4),
                    tag,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Точка `scan` у событий, пришедших по сокету.
class NewDot extends StatelessWidget {
  const NewDot({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    return Semantics(
      label: label,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: ov.scan,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: ov.onScan, spreadRadius: 1.5)],
        ),
      ),
    );
  }
}

/// Полный кадр с рамкой лица. `bbox` — в пикселях исходного кадра, поэтому
/// масштабируем по фактическому размеру изображения. Двойной тап — увеличение.
class FrameViewer extends StatefulWidget {
  const FrameViewer({
    super.key,
    this.url,
    this.cacheKey,
    this.bbox,
    this.label,
    this.time,
    this.fallbackSize = const Size(1920, 1080),
    this.onError,
    this.semanticLabel,
  });

  final String? url;
  final String? cacheKey;
  final List<double>? bbox;
  final String? label;
  final String? time;

  /// Размер кадра до загрузки (из `stream_info` камеры, если есть).
  final Size fallbackSize;
  final VoidCallback? onError;
  final String? semanticLabel;

  @override
  State<FrameViewer> createState() => _FrameViewerState();
}

class _FrameViewerState extends State<FrameViewer> {
  final _zoom = TransformationController();
  Size? _natural;
  ImageStream? _stream;
  ImageStreamListener? _listener;
  TapDownDetails? _tap;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(FrameViewer old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) _resolve();
  }

  void _resolve() {
    _unlisten();
    final url = widget.url;
    if (url == null) return;
    final stream = CachedNetworkImageProvider(url, cacheKey: widget.cacheKey).resolve(createLocalImageConfiguration(context));
    final listener = ImageStreamListener((info, _) {
      if (!mounted) return;
      final s = Size(info.image.width.toDouble(), info.image.height.toDouble());
      if (s != _natural) setState(() => _natural = s);
    }, onError: (_, _) {});
    stream.addListener(listener);
    _stream = stream;
    _listener = listener;
  }

  void _unlisten() {
    if (_stream != null && _listener != null) _stream!.removeListener(_listener!);
    _stream = null;
    _listener = null;
  }

  @override
  void dispose() {
    _unlisten();
    _zoom.dispose();
    super.dispose();
  }

  void _toggleZoom() {
    if (_zoom.value.getMaxScaleOnAxis() > 1.01) {
      _zoom.value = Matrix4.identity();
      return;
    }
    final p = _tap?.localPosition ?? Offset.zero;
    const s = 2.5;
    _zoom.value = Matrix4.identity()
      ..translateByDouble(-p.dx * (s - 1), -p.dy * (s - 1), 0, 1)
      ..scaleByDouble(s, s, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    final natural = _natural ?? widget.fallbackSize;
    final b = widget.bbox;

    return Semantics(
      image: true,
      label: widget.semanticLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(OvRadius.radiusMd),
        child: AspectRatio(
          aspectRatio: natural.width / natural.height,
          child: LayoutBuilder(builder: (context, c) {
            final k = c.maxWidth / natural.width;
            return Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  onDoubleTapDown: (d) => _tap = d,
                  onDoubleTap: _toggleZoom,
                  child: InteractiveViewer(
                    transformationController: _zoom,
                    maxScale: 4,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        OvMedia(url: widget.url, cacheKey: widget.cacheKey, onError: widget.onError, fit: BoxFit.fill),
                        if (b != null)
                          Positioned(
                            left: b[0] * k,
                            top: b[1] * k,
                            width: b[2] * k,
                            height: b[3] * k,
                            child: _BBox(label: widget.label),
                          ),
                      ],
                    ),
                  ),
                ),
                if (widget.time != null)
                  Positioned(
                    right: OvSpace.space2,
                    bottom: OvSpace.space2,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(color: ov.scrim, borderRadius: BorderRadius.circular(OvRadius.radiusXs)),
                        child: Text(widget.time!, style: OvText.timecode.copyWith(color: ov.onMedia)),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _BBox extends StatelessWidget {
  const _BBox({this.label});
  final String? label;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Рамка `scan` 2px с тёмной окантовкой `scrim` 1px; центр прозрачный
        // (BoxShadow залил бы его, поэтому окантовка — отдельной рамкой).
        Positioned(
          left: -1,
          top: -1,
          right: -1,
          bottom: -1,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: ov.scrim),
              borderRadius: BorderRadius.circular(OvRadius.radiusXs + 1),
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: ov.scan, width: 2),
                borderRadius: BorderRadius.circular(OvRadius.radiusXs),
              ),
            ),
          ),
        ),
        if (label != null)
          Positioned(
            left: -2,
            top: -26,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: ov.scan, borderRadius: BorderRadius.circular(OvRadius.radiusXs)),
              child: Text(
                label!,
                maxLines: 1,
                softWrap: false,
                textScaler: TextScaler.noScaling,
                style: OvText.label.copyWith(color: ov.onScan, letterSpacing: 0),
              ),
            ),
          ),
      ],
    );
  }
}
