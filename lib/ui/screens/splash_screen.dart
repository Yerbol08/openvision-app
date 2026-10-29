import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/session.dart';
import '../../theme/ov_theme.dart';
import '../../theme/ov_tokens.dart';
import '../strings.dart';
import '../widgets/controls.dart';

/// Проверка сохранённой сессии при запуске (`GET /auth/me`).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ov = context.ov;
    final session = context.watch<Session>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(OvSpace.space6),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.appName, style: OvText.display.copyWith(color: ov.ink)),
                const SizedBox(height: OvSpace.space6),
                if (session.bootstrapFailed) ...[
                  Text(l.splashOffline, textAlign: TextAlign.center, style: OvText.body.copyWith(color: ov.inkMuted)),
                  const SizedBox(height: OvSpace.space4),
                  OvButton(label: l.retry, variant: OvButtonVariant.secondary, onPressed: session.bootstrap),
                ] else
                  const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
