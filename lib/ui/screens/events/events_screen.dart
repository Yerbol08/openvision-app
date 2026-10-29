import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/live/live_connection.dart';
import '../../../data/models.dart';
import '../../../state/cameras_store.dart';
import '../../../state/events_feed.dart';
import '../../../theme/ov_theme.dart';
import '../../../theme/ov_tokens.dart';
import '../../strings.dart';
import '../../widgets/cards.dart';
import '../../widgets/chrome.dart';
import '../../widgets/controls.dart';
import '../../widgets/ov_icon.dart';
import '../../widgets/status.dart';
import 'filters_sheet.dart';

/// Экран 4 · События (`GET /events?cursor…` + live `event`).
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final feed = context.read<EventsFeed>();
    final p = _scroll.position;
    feed.setAtTop(p.pixels < 8);
    if (p.pixels > p.maxScrollExtent - 600) feed.loadMore();
  }

  void _showPending(EventsFeed feed) {
    feed.flushPending();
    if (_scroll.hasClients) _scroll.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ov = context.ov;
    final feed = context.watch<EventsFeed>();
    final live = context.watch<LiveConnection>();
    final showBanner = live.state != LiveState.idle && live.state != LiveState.forbidden;

    return Column(
      children: [
        OvAppBar(
          title: l.eventsTitle,
          large: true,
          actions: [OvAction(OvIcons.filter, l.filtersA11y, () => showFiltersSheet(context))],
        ),
        if (showBanner) ConnectionBanner(state: live.state, onRetry: live.retryNow),
        _Chips(feed: feed),
        Expanded(
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: feed.reload,
                color: ov.brand,
                child: _FeedList(feed: feed, controller: _scroll),
              ),
              if (feed.pending.isNotEmpty)
                Positioned(
                  top: OvSpace.space2,
                  left: 0,
                  right: 0,
                  child: Center(child: _NewPill(count: feed.pending.length, onTap: () => _showPending(feed))),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({required this.feed});
  final EventsFeed feed;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cams = context.watch<CamerasStore>();
    final f = feed.filters;

    final camLabel = switch (f.cameraIds.length) {
      0 => l.camerasAll,
      1 => cams.byId(f.cameraIds.first)?.name ?? l.camerasSelected(1),
      final n => l.camerasSelected(n),
    };

    return SizedBox(
      height: OvSize.controlHSm + OvSpace.space3 * 2,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: OvSpace.space4, vertical: OvSpace.space3),
        children: [
          if (f.personId != null) ...[
            OvFilterChip(
              label: l.filterPerson,
              selected: true,
              icon: OvIcons.close,
              onTap: () => feed.setFilters(f.copyWith(personId: () => null)),
            ),
            const SizedBox(width: OvSpace.space2),
          ],
          OvFilterChip(
            label: f.period == Period.any ? l.filterPeriod : periodLabel(context, f),
            selected: f.period != Period.any,
            menu: true,
            onTap: () => showFiltersSheet(context),
          ),
          const SizedBox(width: OvSpace.space2),
          OvFilterChip(
            label: camLabel,
            icon: OvIcons.camera,
            selected: f.cameraIds.isNotEmpty,
            menu: true,
            onTap: () => showFiltersSheet(context),
          ),
          const SizedBox(width: OvSpace.space2),
          OvFilterChip(
            label: l.peopleUnknown,
            selected: f.known == false,
            onTap: () => feed.setFilters(f.copyWith(known: () => f.known == false ? null : false)),
          ),
          const SizedBox(width: OvSpace.space2),
          OvFilterChip(
            label: l.peopleKnown,
            selected: f.known == true,
            onTap: () => feed.setFilters(f.copyWith(known: () => f.known == true ? null : true)),
          ),
        ],
      ),
    );
  }
}

String periodLabel(BuildContext context, EventFilters f) {
  final l = context.l10n;
  switch (f.period) {
    case Period.any:
      return l.periodAny;
    case Period.today:
      return l.periodToday;
    case Period.yesterday:
      return l.periodYesterday;
    case Period.week:
      return l.period7d;
    case Period.custom:
      final r = f.range;
      if (r == null) return l.periodDates;
      final fmt = DateFormat.MMMd(context.localeTag);
      return r.start == r.end ? fmt.format(r.start) : '${fmt.format(r.start)} – ${fmt.format(r.end)}';
  }
}

sealed class _Entry {}

class _Header extends _Entry {
  _Header(this.title);
  final String title;
}

class _Row extends _Entry {
  _Row(this.event, {required this.last});
  final OvEvent event;
  final bool last;
}

class _FeedList extends StatelessWidget {
  const _FeedList({required this.feed, required this.controller});
  final EventsFeed feed;
  final ScrollController controller;

  List<_Entry> _entries(BuildContext context) {
    final fmt = OvFormat(context);
    final out = <_Entry>[];
    String? day;
    final items = feed.items;
    for (var i = 0; i < items.length; i++) {
      final e = items[i];
      final d = fmt.dayHeader(e.occurredAt);
      if (d != day) out.add(_Header(d));
      day = d;
      final next = i + 1 < items.length ? fmt.dayHeader(items[i + 1].occurredAt) : null;
      out.add(_Row(e, last: next != d));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ov = context.ov;

    Widget fill(Widget child) => CustomScrollView(
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [SliverFillRemaining(hasScrollBody: false, child: child)],
        );

    if (!feed.loaded) {
      if (feed.error != null) {
        return fill(OvEmpty(text: errorText(l, feed.error!), actionLabel: l.retry, onAction: feed.reload));
      }
      return fill(const Center(child: CircularProgressIndicator()));
    }
    if (feed.items.isEmpty && !feed.loading) {
      final filtered = !feed.filters.isDefault;
      return fill(Align(
        alignment: const Alignment(0, -.4),
        child: OvEmpty(
          text: filtered ? l.eventsEmptyFiltered : l.eventsEmpty,
          actionLabel: filtered ? l.filterReset : null,
          onAction: filtered ? () => feed.setFilters(const EventFilters()) : null,
        ),
      ));
    }

    final entries = _entries(context);
    return CustomScrollView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (feed.loading) const SliverToBoxAdapter(child: LinearProgressIndicator(minHeight: 2)),
        SliverList.builder(
          itemCount: entries.length,
          itemBuilder: (context, i) => switch (entries[i]) {
            _Header(:final title) => Padding(
                padding: const EdgeInsets.fromLTRB(OvSpace.space4, OvSpace.space4, OvSpace.space4, OvSpace.space2),
                child: Semantics(
                  header: true,
                  child: Text(title, style: OvText.caption.copyWith(fontWeight: FontWeight.w600, color: ov.inkMuted)),
                ),
              ),
            _Row(:final event, :final last) => DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: ov.line),
                    bottom: last ? BorderSide(color: ov.line) : BorderSide.none,
                  ),
                ),
                child: EventRow(
                  key: ValueKey(event.id),
                  event: event,
                  isNew: feed.newIds.contains(event.id),
                  onCropError: () => feed.refreshMedia(event.id),
                  onTap: () => context.push('/events/${event.id}'),
                ),
              ),
          },
        ),
        SliverToBoxAdapter(child: _Footer(feed: feed)),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.feed});
  final EventsFeed feed;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (feed.loadingMore) {
      return const Padding(padding: EdgeInsets.all(OvSpace.space6), child: Center(child: CircularProgressIndicator()));
    }
    if (feed.moreError != null) {
      return OvEmpty(text: l.eventsLoadMoreFailed, actionLabel: l.retry, onAction: feed.loadMore);
    }
    return SizedBox(height: feed.hasMore ? OvSpace.space8 * 2 : OvSpace.space6);
  }
}

class _NewPill extends StatelessWidget {
  const _NewPill({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    final radius = BorderRadius.circular(OvRadius.radiusFull);
    return Material(
      color: ov.brand,
      borderRadius: radius,
      elevation: 0,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: OvSize.controlHSm),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(borderRadius: radius, boxShadow: ovSheetShadow),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              NewDot(label: context.l10n.eventNewA11y),
              const SizedBox(width: OvSpace.space2),
              Text(context.l10n.eventsNewPill(count), style: OvText.bodyStrong.copyWith(fontSize: 14, color: ov.onBrand)),
            ],
          ),
        ),
      ),
    );
  }
}
