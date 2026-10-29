import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_exception.dart';
import '../../../data/models.dart';
import '../../../data/ov_api.dart';
import '../../../state/cameras_store.dart';
import '../../../state/events_feed.dart';
import '../../../theme/ov_theme.dart';
import '../../../theme/ov_tokens.dart';
import '../../strings.dart';
import '../../widgets/cards.dart';
import '../../widgets/chrome.dart';
import '../../widgets/controls.dart';
import '../../widgets/media.dart';
import '../../widgets/ov_icon.dart';
import '../../widgets/privacy_scope.dart';

/// Экран 5 · Событие (`GET /events/{id}`): кадр с рамкой, кроп, камера, время.
class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key, required this.eventId});
  final String eventId;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  OvEvent? _event;
  ApiException? _error;
  bool _mediaRetried = false;

  /// «Сегодня 4 раза · первый раз в 09:12» по `person_id`.
  int? _todayCount;
  DateTime? _firstToday;

  @override
  void initState() {
    super.initState();
    _event = context.read<EventsFeed>().byId(widget.eventId);
    _fetch();
  }

  /// Всегда перечитываем: в ленте ссылки на изображения могли истечь.
  Future<void> _fetch() async {
    final api = context.read<OvApi>();
    final feed = context.read<EventsFeed>();
    try {
      final e = await api.event(widget.eventId);
      if (!mounted) return;
      setState(() {
        _event = e;
        _error = null;
      });
      feed.put(e);
      _loadPersonToday(e);
    } on ApiException catch (err) {
      if (mounted) setState(() => _error = err);
    }
  }

  Future<void> _loadPersonToday(OvEvent e) async {
    final personId = e.personId;
    if (personId == null) return;
    final now = DateTime.now();
    try {
      final page = await context.read<OvApi>().events(
            EventQuery(personId: personId, since: DateTime(now.year, now.month, now.day)),
            limit: 200,
          );
      if (!mounted || page.items.isEmpty) return;
      setState(() {
        _todayCount = page.items.length;
        _firstToday = page.items.last.occurredAt;
      });
    } on ApiException catch (_) {}
  }

  void _onMediaError() {
    if (_mediaRetried) return;
    _mediaRetried = true;
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ov = context.ov;
    final fmt = OvFormat(context);
    final e = _event;

    if (e == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(children: [
            const OvAppBar(title: '', back: true),
            Expanded(
              child: _error != null
                  ? OvEmpty(text: errorText(l, _error!), actionLabel: l.retry, onAction: _fetch)
                  : const Center(child: CircularProgressIndicator()),
            ),
          ]),
        ),
      );
    }

    final title = e.isKnown ? l.eventTitleKnown : l.eventTitleUnknown;
    final info = context.watch<CamerasStore>().byId(e.cameraId)?.streamInfo;
    final frameSize = info?.width != null && info?.height != null
        ? Size(info!.width!.toDouble(), info.height!.toDouble())
        : const Size(1920, 1080);
    final conf = e.confidence;
    final personLine = e.isKnown && conf != null ? '${l.eventKnown} · ${(conf * 100).round()}%' : (e.isKnown ? l.eventKnown : l.eventPersonUnknown);

    return PrivacyScope(
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              OvAppBar(title: title, back: true),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: OvSpace.space8),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: OvSpace.space4),
                      child: FrameViewer(
                        url: e.frameUrl,
                        cacheKey: e.frameCacheKey,
                        bbox: e.bbox,
                        label: title,
                        time: fmt.timecode(e.occurredAt),
                        fallbackSize: frameSize,
                        onError: _onMediaError,
                        semanticLabel: l.frameA11y,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(OvSpace.space4),
                      child: Row(
                        children: [
                          OvMedia(
                            kind: MediaKind.face,
                            url: e.cropUrl,
                            cacheKey: e.cropCacheKey,
                            onError: _onMediaError,
                            width: 72,
                            height: 72,
                            radius: OvRadius.radiusXs,
                          ),
                          const SizedBox(width: OvSpace.space3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(personLine, style: OvText.headline.copyWith(color: ov.ink)),
                                if (_todayCount != null && _firstToday != null)
                                  Text(
                                    l.eventSeenToday(_todayCount!, fmt.time(_firstToday!)),
                                    style: OvText.body.copyWith(fontSize: 14, height: 20 / 14, color: ov.inkMuted, fontFeatures: ovTabular),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    OvList(children: [
                      OvKeyValue(l.eventCamera, e.cameraName),
                      OvKeyValue(l.eventTime, fmt.full(e.occurredAt), tabular: true),
                      OvKeyValue(l.eventKind, e.kind == 'face' ? l.kindFace : l.kindOther),
                    ]),
                    if (e.personId != null)
                      Padding(
                        padding: const EdgeInsets.all(OvSpace.space4),
                        child: OvButton(
                          label: l.eventAllAppearances,
                          variant: OvButtonVariant.secondary,
                          icon: OvIcons.face,
                          block: true,
                          onPressed: () {
                            context.read<EventsFeed>().setFilters(EventFilters(personId: e.personId));
                            context.go('/events');
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
