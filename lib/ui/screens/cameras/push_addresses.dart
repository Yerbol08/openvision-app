import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models.dart';
import '../../../state/cameras_store.dart';
import '../../../theme/ov_theme.dart';
import '../../../theme/ov_tokens.dart';
import '../../strings.dart';
import '../../widgets/chrome.dart';
import '../../widgets/controls.dart';
import '../../widgets/ov_icon.dart';
import '../../widgets/status.dart';
import '../../widgets/wizard.dart';

/// Экран 7 · Адреса для регистратора. Показываются один раз; экран остаётся
/// открытым и сам переключается на «В сети», когда пойдёт видео (§7.2).
class PushAddressesBody extends StatelessWidget {
  const PushAddressesBody({super.key, required this.cameraId, required this.push});

  final int cameraId;
  final PushCredentials push;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ov = context.ov;
    final camera = context.watch<CamerasStore>().byId(cameraId);
    final online = camera?.isOnline ?? false;

    return ListView(
      padding: const EdgeInsets.all(OvSpace.space4),
      children: [
        Text(l.pushIntro, style: OvText.body.copyWith(fontSize: 14, height: 20 / 14, color: ov.inkMuted)),
        const SizedBox(height: 14),
        CopyField(label: 'SRT', badge: l.pushRecommended, value: push.srtUrl),
        const SizedBox(height: 14),
        CopyField(label: l.pushRtspLabel, value: push.rtspUrl),
        const SizedBox(height: 14),
        WarnNote(l.pushKeyOnce),
        const SizedBox(height: 14),
        if (online)
          SuccessBox(title: l.pushOnlineTitle, text: l.pushOnlineText)
        else
          StatusReason(camera?.statusReason ?? 'waiting_for_video'),
      ],
    );
  }
}

String pushShareText(PushCredentials push) => 'SRT:\n${push.srtUrl}\n\nRTSP:\n${push.rtspUrl}';

/// «Отправить» + «Готово».
class PushAddressesBar extends StatelessWidget {
  const PushAddressesBar({super.key, required this.cameraName, required this.push, required this.onDone});

  final String cameraName;
  final PushCredentials push;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return OvBottomBar(children: [
      Builder(
        builder: (context) => OvButton(
          label: l.share,
          icon: OvIcons.share,
          variant: OvButtonVariant.secondary,
          onPressed: () => shareText(context, text: pushShareText(push), subject: l.pushShareSubject(cameraName)),
        ),
      ),
      Expanded(child: OvButton(label: l.done, block: true, onPressed: onDone)),
    ]);
  }
}

/// После `rotate-key`: новые адреса той же камеры.
class RotatedKeyScreen extends StatelessWidget {
  const RotatedKeyScreen({super.key, required this.camera, required this.push});

  final Camera camera;
  final PushCredentials push;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            OvAppBar(title: camera.name, back: true),
            Expanded(child: PushAddressesBody(cameraId: camera.id, push: push)),
            PushAddressesBar(cameraName: camera.name, push: push, onDone: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}
