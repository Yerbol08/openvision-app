import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../theme/ov_theme.dart';
import '../../theme/ov_tokens.dart';
import '../strings.dart';
import 'ov_icon.dart';

/// Полоски шагов мастера под шапкой.
class OvSteps extends StatelessWidget {
  const OvSteps({super.key, required this.current, this.total = 3});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    return Padding(
      padding: const EdgeInsets.fromLTRB(OvSpace.space4, OvSpace.space1, OvSpace.space4, 0),
      child: Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 4,
                decoration: BoxDecoration(
                  color: i < current ? ov.brand : ov.line,
                  borderRadius: BorderRadius.circular(OvRadius.radiusFull),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Заголовок шага: вопрос `title` и пояснение.
class OvStepHeading extends StatelessWidget {
  const OvStepHeading({super.key, required this.title, this.text});
  final String title;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: OvText.title.copyWith(color: ov.ink)),
        ),
        if (text != null) ...[
          const SizedBox(height: 6),
          Text(
            text!,
            style: OvText.body.copyWith(fontSize: 14, height: 20 / 14, color: ov.inkMuted),
          ),
        ],
      ],
    );
  }
}

/// Нижняя панель с действиями экрана.
class OvBottomBar extends StatelessWidget {
  const OvBottomBar({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    return Container(
      decoration: BoxDecoration(
        color: ov.surface,
        border: Border(top: BorderSide(color: ov.line)),
      ),
      padding: const EdgeInsets.fromLTRB(OvSpace.space4, OvSpace.space4, OvSpace.space4, 0),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: OvSpace.space4),
        // Кнопки одной высоты, даже если подпись одной перенеслась на две строки.
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(width: OvSpace.space3),
                children[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Радиокнопка дизайн-системы.
class OvRadio extends StatelessWidget {
  const OvRadio({super.key, required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: selected ? ov.brand : ov.lineStrong, width: 2),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: ov.brand, shape: BoxShape.circle),
            )
          : null,
    );
  }
}

/// Вариант ответа «Как подключена камера?». Выбранный — `brand-soft`, рамка `brand`.
class ModeOption extends StatelessWidget {
  const ModeOption({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.description,
    this.tag,
  });

  final OvIcons icon;
  final String title;
  final String? description;
  final String? tag;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    final radius = BorderRadius.circular(OvRadius.radiusMd);
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      child: Material(
        color: selected ? ov.brandSoft : ov.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: selected ? ov.brand : ov.lineStrong, width: selected ? 2 : 1),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(selected ? OvSpace.space4 - 1 : OvSpace.space4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selected ? ov.surface : ov.surfaceSunken,
                    borderRadius: BorderRadius.circular(OvRadius.radiusSm),
                  ),
                  alignment: Alignment.center,
                  child: OvIcon(icon, size: 22, color: selected ? ov.brand : ov.ink),
                ),
                const SizedBox(width: OvSpace.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: OvText.headline.copyWith(color: ov.ink)),
                      if (description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          description!,
                          style: OvText.body.copyWith(fontSize: 14, height: 20 / 14, color: ov.inkMuted),
                        ),
                      ],
                      if (tag != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: OvSpace.space2, vertical: 3),
                          decoration: BoxDecoration(
                            color: ov.neutralSoft,
                            borderRadius: BorderRadius.circular(OvRadius.radiusFull),
                          ),
                          child: Text(tag!, style: OvText.label.copyWith(color: ov.inkMuted, letterSpacing: 0)),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: OvSpace.space3),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: OvRadio(selected: selected),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Значение, которое нельзя перепечатывать: адрес push, команда установки.
/// Моноширинный, перенос по любому символу, «Копировать» → «Скопировано» на 1,6 с.
/// Это пароль от чужого видеонаблюдения — значение нигде не логируется.
class CopyField extends StatefulWidget {
  const CopyField({super.key, required this.value, this.label, this.badge, this.hint});

  final String value;
  final String? label;
  final String? badge;
  final String? hint;

  @override
  State<CopyField> createState() => _CopyFieldState();
}

class _CopyFieldState extends State<CopyField> {
  bool _done = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    if (!mounted) return;
    setState(() => _done = true);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _done = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    final l = context.l10n;
    final fg = _done ? ov.online : ov.ink;
    // Перенос по любому символу: вставляем нулевые пробелы между символами.
    final breakable = widget.value.split('').join('​');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.label!,
                  style: OvText.caption.copyWith(fontWeight: FontWeight.w600, color: ov.ink),
                ),
              ),
              if (widget.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: OvSpace.space2, vertical: 3),
                  decoration: BoxDecoration(
                    color: ov.brandSoft,
                    borderRadius: BorderRadius.circular(OvRadius.radiusFull),
                  ),
                  child: Text(widget.badge!, style: OvText.label.copyWith(color: ov.brand, letterSpacing: 0)),
                ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        Container(
          padding: const EdgeInsets.all(OvSpace.space3),
          decoration: BoxDecoration(
            color: ov.surfaceSunken,
            border: Border.all(color: ov.line),
            borderRadius: BorderRadius.circular(OvRadius.radiusSm),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  breakable,
                  style: OvText.mono.copyWith(color: ov.ink, height: 20 / 13),
                ),
              ),
              const SizedBox(width: OvSpace.space2),
              Transform.translate(
                offset: const Offset(4, -4),
                child: Semantics(
                  liveRegion: true,
                  child: OutlinedButton.icon(
                    onPressed: _copy,
                    icon: OvIcon(_done ? OvIcons.check : OvIcons.copy, size: 16, color: fg),
                    label: Text(_done ? l.copied : l.copy),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: fg,
                      backgroundColor: ov.surface,
                      side: BorderSide(color: _done ? ov.online : ov.lineStrong),
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      tapTargetSize: MaterialTapTargetSize.padded,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OvRadius.radiusSm)),
                      textStyle: OvText.caption.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.hint != null) ...[
          const SizedBox(height: 6),
          Text(widget.hint!, style: OvText.caption.copyWith(color: ov.inkMuted)),
        ],
      ],
    );
  }
}

/// Системный шит «Поделиться». Позиция нужна iPad для поповера.
Future<void> shareText(BuildContext context, {required String text, required String subject}) {
  final box = context.findRenderObject() as RenderBox?;
  return SharePlus.instance.share(
    ShareParams(
      text: text,
      subject: subject,
      sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    ),
  );
}

/// Карточка ожидания со спиннером: «Подключаемся к камере…», «Ждём блок…».
class WaitingBox extends StatelessWidget {
  const WaitingBox({super.key, required this.title, this.text});
  final String title;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: OvSpace.space4, vertical: 14),
        decoration: BoxDecoration(
          color: ov.surface,
          border: Border.all(color: ov.line),
          borderRadius: BorderRadius.circular(OvRadius.radiusMd),
        ),
        child: Row(
          children: [
            OvSpinner(size: 20, color: ov.brand),
            const SizedBox(width: OvSpace.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: OvText.body.copyWith(color: ov.ink)),
                  if (text != null) Text(text!, style: OvText.caption.copyWith(color: ov.inkMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Успех в `online-soft`: «Подключение работает · 1920×1080, 25 fps, H.264».
class SuccessBox extends StatelessWidget {
  const SuccessBox({super.key, required this.title, this.text});
  final String title;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: OvSpace.space4, vertical: OvSpace.space3),
        decoration: BoxDecoration(color: ov.onlineSoft, borderRadius: BorderRadius.circular(OvRadius.radiusMd)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OvIcon(OvIcons.check, size: 22, color: ov.online),
            const SizedBox(width: OvSpace.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: OvText.bodyStrong.copyWith(fontWeight: FontWeight.w600, color: ov.ink),
                  ),
                  if (text != null)
                    Text(
                      text!,
                      style: OvText.body.copyWith(
                        fontSize: 14,
                        height: 20 / 14,
                        color: ov.ink,
                        fontFeatures: ovTabular,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Короткое предупреждение в `warn-soft`: «Ключ показываем только один раз».
class WarnNote extends StatelessWidget {
  const WarnNote(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: OvSpace.space3, vertical: 10),
      decoration: BoxDecoration(color: ov.warnSoft, borderRadius: BorderRadius.circular(OvRadius.radiusSm)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OvIcon(OvIcons.alert, size: 18, color: ov.warn),
          const SizedBox(width: OvSpace.space2),
          Expanded(
            child: Text(text, style: OvText.caption.copyWith(color: ov.ink)),
          ),
        ],
      ),
    );
  }
}
