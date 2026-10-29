import 'package:flutter/material.dart';

import '../../../theme/ov_theme.dart';
import '../../../theme/ov_tokens.dart';

/// Прокрутка, в которой [Spacer] прижимает низ к краю, пока хватает высоты.
class FillScrollView extends StatelessWidget {
  const FillScrollView({super.key, required this.child, this.padding = EdgeInsets.zero});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight - padding.vertical),
          child: IntrinsicHeight(child: child),
        ),
      ),
    );
  }
}

class AuthHeading extends StatelessWidget {
  const AuthHeading({super.key, required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(header: true, child: Text(title, style: OvText.display.copyWith(color: ov.ink))),
        const SizedBox(height: 6),
        Text(subtitle, style: OvText.body.copyWith(fontSize: 14, height: 20 / 14, color: ov.inkMuted)),
      ],
    );
  }
}

class FormErrorText extends StatelessWidget {
  const FormErrorText(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        child: Text(text, style: OvText.caption.copyWith(color: context.ov.danger)),
      );
}

/// «Нет аккаунта? Зарегистрировать компанию».
class AuthSwitchLink extends StatelessWidget {
  const AuthSwitchLink({super.key, required this.question, required this.action, required this.onTap});
  final String question;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(OvRadius.radiusSm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: OvSize.tapMin),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: OvSpace.space2),
            child: Center(
              widthFactor: 1,
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: '$question ', style: TextStyle(color: ov.inkMuted)),
                  TextSpan(text: action, style: TextStyle(color: ov.brand, fontWeight: FontWeight.w600)),
                ]),
                textAlign: TextAlign.center,
                style: OvText.body.copyWith(fontSize: 14, height: 20 / 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
