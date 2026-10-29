import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_exception.dart';
import '../../../data/models.dart';
import '../../../data/ov_api.dart';
import '../../../state/cameras_store.dart';
import '../../../state/events_feed.dart';
import '../../../state/session.dart';
import '../../../theme/ov_theme.dart';
import '../../../theme/ov_tokens.dart';
import '../../strings.dart';
import '../../widgets/cards.dart';
import '../../widgets/chrome.dart';
import '../../widgets/controls.dart';
import '../../widgets/ov_icon.dart';
import '../../widgets/privacy_scope.dart';
import '../../widgets/status.dart';
import 'push_addresses.dart';

/// Экран 10 · Камера (`GET /cameras/{id}` · `PATCH` · `DELETE` · `rotate-key`).
class CameraDetailScreen extends StatelessWidget {
  const CameraDetailScreen({super.key, required this.cameraId});

  final int cameraId;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = OvFormat(context);
    final session = context.watch<Session>();
    final store = context.watch<CamerasStore>();
    final camera = store.byId(cameraId);

    if (camera == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(children: [
            const OvAppBar(title: '', back: true),
            Expanded(
              child: store.loaded
                  ? OvEmpty(text: l.errNotFound)
                  : const Center(child: CircularProgressIndicator()),
            ),
          ]),
        ),
      );
    }

    final last = store.lastEvents[camera.id];
    final status = camera.displayStatus;
    final reason = camera.statusReason;
    final info = camera.streamInfo;
    final connection = switch (camera.mode) {
      'pull' => l.connectionPull,
      'push' => l.connectionPush,
      'edge' => l.connectionEdge,
      _ => null,
    };
    final frameSize = info?.width != null && info?.height != null
        ? Size(info!.width!.toDouble(), info.height!.toDouble())
        : const Size(1920, 1080);

    Future<void> toggle(bool value) async {
      final ok = await store.setEnabled(camera.id, value);
      if (!ok && context.mounted) showOvSnack(context, l.cameraToggleFailed);
    }

    return PrivacyScope(
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              OvAppBar(title: camera.name, back: true),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: OvSpace.space8),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: OvSpace.space4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FrameViewer(
                            url: last?.frameUrl,
                            cacheKey: last?.frameCacheKey,
                            fallbackSize: frameSize,
                            time: last != null ? l.cameraLastFrame(fmt.time(last.occurredAt)) : null,
                            onError: () => store.refreshThumb(camera.id),
                            semanticLabel: l.frameA11y,
                          ),
                          const SizedBox(height: OvSpace.space3),
                          Row(
                            children: [
                              StatusBadge(status),
                              const Spacer(),
                              if (session.can(Permissions.camerasControl))
                                OvSwitch(value: camera.enabled, onChanged: toggle, label: l.cameraEnabled),
                            ],
                          ),
                          if (reason != null && status != 'online' && status != 'disabled') ...[
                            const SizedBox(height: OvSpace.space3),
                            StatusReason(
                              reason,
                              lastSeen: reason == 'no_video' && camera.lastSeenAt != null ? fmt.ago(camera.lastSeenAt!) : null,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: OvSpace.space4),
                    OvList(children: [
                      if (camera.location?.isNotEmpty ?? false) OvKeyValue(l.cameraLocation, camera.location!),
                      if (connection != null) OvKeyValue(l.cameraConnection, connection),
                      if (streamText(l, info) case final video?) OvKeyValue(l.cameraVideo, video, tabular: true),
                    ]),
                    const SizedBox(height: OvSpace.space4),
                    OvList(children: [
                      OvActionRow(
                        icon: OvIcons.face,
                        label: l.cameraEvents,
                        chevron: true,
                        onTap: () {
                          final feed = context.read<EventsFeed>();
                          feed.setFilters(EventFilters(cameraIds: {camera.id}));
                          context.go('/events');
                        },
                      ),
                      if (session.can(Permissions.camerasWrite)) ...[
                        OvActionRow(
                          icon: OvIcons.settings,
                          label: l.cameraEdit,
                          chevron: true,
                          onTap: () => context.push('/cameras/${camera.id}/edit'),
                        ),
                        if (camera.mode == 'push')
                          OvActionRow(
                            icon: OvIcons.refresh,
                            label: l.cameraRotateKey,
                            chevron: true,
                            onTap: () => _rotateKey(context, camera),
                          ),
                      ],
                      if (session.can(Permissions.camerasWrite))
                        OvActionRow(
                          icon: OvIcons.trash,
                          label: l.cameraDelete,
                          danger: true,
                          onTap: () => _confirmDelete(context, camera),
                        ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Регистратор потерял ключ — выдаём новый; старый сразу перестаёт работать.
  Future<void> _rotateKey(BuildContext context, Camera camera) async {
    final l = context.l10n;
    final ov = context.ov;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.rotateTitle),
        content: Text(l.rotateText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(foregroundColor: ov.ink),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: ov.brand),
            child: Text(l.rotateConfirm),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      final push = await context.read<OvApi>().rotateKey(camera.id);
      if (!context.mounted) return;
      // Не через URL: адреса — секрет и не должны попадать в историю маршрутов.
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => RotatedKeyScreen(camera: camera, push: push),
      ));
    } on ApiException catch (e) {
      if (context.mounted) showOvSnack(context, errorText(l, e));
    }
  }

  Future<void> _confirmDelete(BuildContext context, Camera camera) async {
    final l = context.l10n;
    final ov = context.ov;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.cameraDeleteTitle(camera.name)),
        content: Text(l.cameraDeleteText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(foregroundColor: ov.ink),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: ov.danger),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await context.read<CamerasStore>().delete(camera.id);
      if (!context.mounted) return;
      showOvSnack(context, l.cameraDeleted);
      context.pop();
    } on ApiException catch (e) {
      if (context.mounted) showOvSnack(context, errorText(l, e));
    }
  }
}
