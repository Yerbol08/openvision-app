import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/live/live_connection.dart';
import '../../../data/models.dart';
import '../../../state/cameras_store.dart';
import '../../../state/dashboard_store.dart';
import '../../../state/session.dart';
import '../../../theme/ov_theme.dart';
import '../../../theme/ov_tokens.dart';
import '../../strings.dart';
import '../../widgets/cards.dart';
import '../../widgets/chrome.dart';
import '../../widgets/ov_icon.dart';
import '../../widgets/status.dart';
import '../team/account_section.dart';

/// Экран 2 · Обзор (`GET /stats/summary`): плитки 2×2, график, «Требуют внимания».
class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ov = context.ov;
    final session = context.watch<Session>();
    final dash = context.watch<DashboardStore>();
    final cams = context.watch<CamerasStore>();
    final live = context.watch<LiveConnection>();
    final me = session.me;
    final s = dash.summary;

    Future<void> refresh() => Future.wait([dash.load(), cams.load()]);

    final banner = live.state == LiveState.reconnecting || live.state == LiveState.offline;

    return RefreshIndicator(
      onRefresh: refresh,
      color: ov.brand,
      child: ListView(
        padding: const EdgeInsets.only(bottom: OvSpace.space6),
        children: [
          OvAppBar(
            title: l.tabOverview,
            large: true,
            actions: [
              // У кого нет вкладки «Команда», аккаунт и выход — здесь.
              if (!session.can(Permissions.usersRead))
                OvAction(OvIcons.user, l.accountA11y, () => showAccountSheet(context)),
            ],
          ),
          if (me != null) OvSubtitle(l.overviewSubtitle(OvFormat(context).dayMonth(DateTime.now()), me.tenant.name)),
          if (banner) ConnectionBanner(state: live.state, onRetry: live.retryNow),
          if (s == null && dash.error != null)
            OvEmpty(text: errorText(l, dash.error!), actionLabel: l.retry, onAction: dash.load)
          else if (s == null)
            const Padding(padding: EdgeInsets.all(OvSpace.space8), child: Center(child: CircularProgressIndicator()))
          else ...[
            if (banner) const SizedBox(height: OvSpace.space3),
            _Tiles(summary: s),
            Padding(
              padding: const EdgeInsets.fromLTRB(OvSpace.space4, OvSpace.space3, OvSpace.space4, 0),
              child: HourlyChart(data: dash.hourly, nowHour: DateTime.now().hour),
            ),
          ],
          if (cams.loaded) ...[
            OvSection(l.attentionTitle),
            if (cams.cameras.isEmpty)
              OvEmpty(text: l.camerasEmpty)
            else if (cams.attention.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: OvSpace.space4),
                child: OvCard(child: Text(l.attentionNone, style: OvText.body.copyWith(color: ov.inkMuted))),
              )
            else
              for (final c in cams.attention)
                Padding(
                  padding: const EdgeInsets.fromLTRB(OvSpace.space4, 0, OvSpace.space4, OvSpace.space3),
                  child: CameraCard(
                    camera: c,
                    thumbEvent: cams.lastEvents[c.id],
                    onThumbError: () => cams.refreshThumb(c.id),
                    onTap: () => context.push('/cameras/${c.id}'),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _Tiles extends StatelessWidget {
  const _Tiles({required this.summary});
  final StatsSummary summary;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ov = context.ov;
    final s = summary;
    final offline = s.camerasTotal - s.camerasOnline;
    final knownShare = s.totalEvents == 0 ? 0 : (s.knownEvents * 100 / s.totalEvents).round();

    Widget row(Widget a, Widget b) => IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [Expanded(child: a), const SizedBox(width: OvSpace.space3), Expanded(child: b)],
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: OvSpace.space4),
      child: Column(
        children: [
          row(
            StatTile(label: l.statEvents, value: s.totalEvents),
            StatTile(
              label: l.statCamerasOnline,
              value: s.camerasOnline,
              total: s.camerasTotal,
              sub: offline > 0 ? l.statCamerasOffline(offline) : null,
              subColor: ov.danger,
            ),
          ),
          const SizedBox(height: OvSpace.space3),
          row(
            StatTile(label: l.statUniquePeople, value: s.uniquePeople),
            StatTile(label: l.statKnown, value: s.knownEvents, sub: s.totalEvents > 0 ? l.statKnownShare(knownShare) : null),
          ),
        ],
      ),
    );
  }
}
