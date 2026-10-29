import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/models.dart';
import '../../../state/cameras_store.dart';
import '../../../state/session.dart';
import '../../../theme/ov_theme.dart';
import '../../../theme/ov_tokens.dart';
import '../../strings.dart';
import '../../widgets/cards.dart';
import '../../widgets/chrome.dart';
import '../../widgets/ov_icon.dart';

/// Экран 3 · Камеры (`GET /cameras` + live `camera_status`).
class CamerasScreen extends StatelessWidget {
  const CamerasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ov = context.ov;
    final session = context.watch<Session>();
    final store = context.watch<CamerasStore>();
    final canControl = session.can(Permissions.camerasControl);
    final canWrite = session.can(Permissions.camerasWrite);
    final tenant = session.me?.tenant;

    // Лимит тарифа объясняем до мастера, а не ошибкой после него.
    void add() {
      final max = tenant?.maxCameras ?? 0;
      if (max > 0 && store.cameras.length >= max) {
        showOvSnack(context, l.errCameraLimit(max));
      } else {
        context.push('/cameras/new');
      }
    }

    Future<void> toggle(Camera c, bool value) async {
      final ok = await store.setEnabled(c.id, value);
      if (!ok && context.mounted) showOvSnack(context, l.cameraToggleFailed);
    }

    final list = RefreshIndicator(
      onRefresh: store.load,
      color: ov.brand,
      child: ListView(
        // Место под плавающую кнопку, чтобы она не закрывала последнюю карточку.
        padding: EdgeInsets.only(bottom: canWrite ? 88 : OvSpace.space6),
        children: [
          OvAppBar(
            title: l.tabCameras,
            large: true,
            actions: [if (canWrite) OvAction(OvIcons.plus, l.addCameraA11y, add)],
          ),
          if (tenant != null && store.loaded && tenant.maxCameras > 0)
            OvSubtitle(l.camerasPlanUsage(store.cameras.length, tenant.maxCameras)),
          if (!store.loaded && store.error != null)
            OvEmpty(text: errorText(l, store.error!), actionLabel: l.retry, onAction: store.load)
          else if (!store.loaded)
            const Padding(padding: EdgeInsets.all(OvSpace.space8), child: Center(child: CircularProgressIndicator()))
          else if (store.cameras.isEmpty)
            OvEmpty(text: l.camerasEmpty, actionLabel: canWrite ? l.addCameraA11y : null, onAction: canWrite ? add : null)
          else
            for (final c in store.cameras)
              Padding(
                padding: const EdgeInsets.fromLTRB(OvSpace.space4, 0, OvSpace.space4, OvSpace.space3),
                child: CameraCard(
                  camera: c,
                  thumbEvent: store.lastEvents[c.id],
                  onThumbError: () => store.refreshThumb(c.id),
                  onToggle: canControl ? (v) => toggle(c, v) : null,
                  onTap: () => context.push('/cameras/${c.id}'),
                ),
              ),
        ],
      ),
    );

    if (!canWrite || store.cameras.isEmpty) return list;
    return Stack(
      children: [
        list,
        Positioned(right: OvSpace.space4, bottom: OvSpace.space4, child: _AddFab(onTap: add)),
      ],
    );
  }
}

/// Плавающая кнопка «+ Камера» — с тенью `shadow-sheet`.
class _AddFab extends StatelessWidget {
  const _AddFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    final l = context.l10n;
    final radius = BorderRadius.circular(16);
    return Semantics(
      button: true,
      label: l.addCameraA11y,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(borderRadius: radius, boxShadow: ovSheetShadow),
        child: Material(
          color: ov.brand,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.only(left: OvSpace.space4, right: OvSpace.space5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OvIcon(OvIcons.plus, size: 22, color: ov.onBrand),
                  const SizedBox(width: OvSpace.space2),
                  Text(l.fabCamera, style: OvText.bodyStrong.copyWith(fontWeight: FontWeight.w600, color: ov.onBrand)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
