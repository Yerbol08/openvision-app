import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/live/live_connection.dart';
import '../../data/models.dart';
import '../../state/cameras_store.dart';
import '../../state/dashboard_store.dart';
import '../../state/events_feed.dart';
import '../../state/session.dart';
import '../strings.dart';
import '../widgets/chrome.dart';
import '../widgets/ov_icon.dart';
import '../widgets/privacy_scope.dart';

/// Вкладки: Обзор, Камеры, События, Команда (только при `users.read`).
///
/// Живёт, пока пользователь вошёл: держит сокет открытым только на переднем плане
/// и при возвращении в приложение заранее обновляет токен (§4, §8).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  static const overview = 0, cameras = 1, events = 2, team = 3;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onShow: _resume, onHide: () => context.read<LiveConnection>().stop());
    // Не уведомляем слушателей во время построения дерева.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LiveConnection>().start();
      context.read<CamerasStore>().load();
      context.read<DashboardStore>().load();
      context.read<EventsFeed>().reload();
    });
  }

  Future<void> _resume() async {
    final client = context.read<ApiClient>();
    final live = context.read<LiveConnection>();
    final cams = context.read<CamerasStore>();
    final dash = context.read<DashboardStore>();
    try {
      await client.accessToken(); // обновит, если вот-вот истечёт
    } catch (_) {}
    if (!mounted || !client.hasTokens) return;
    live.start();
    unawaited(cams.load());
    unawaited(dash.load());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final session = context.watch<Session>();
    final broken = context.select<CamerasStore, int>((s) => s.brokenCount);
    final shell = widget.shell;

    final tabs = [
      OvTab(label: l.tabOverview, icon: OvIcons.dashboard, branch: HomeShell.overview),
      OvTab(
        label: l.tabCameras,
        icon: OvIcons.camera,
        branch: HomeShell.cameras,
        badge: broken,
        badgeLabel: l.tabBadgeA11y(broken),
      ),
      OvTab(label: l.tabEvents, icon: OvIcons.face, branch: HomeShell.events),
      if (session.can(Permissions.usersRead)) OvTab(label: l.tabTeam, icon: OvIcons.team, branch: HomeShell.team),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: PrivacyScope(active: shell.currentIndex == HomeShell.events, child: shell),
      ),
      bottomNavigationBar: OvTabBar(
        tabs: tabs,
        current: shell.currentIndex,
        onSelect: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
      ),
    );
  }
}
