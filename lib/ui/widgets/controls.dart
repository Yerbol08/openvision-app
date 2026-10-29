import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/ov_theme.dart';
import '../../theme/ov_tokens.dart';
import '../strings.dart';
import 'ov_icon.dart';

enum OvButtonVariant { primary, secondary, ghost, danger }

/// Кнопка: одна `primary` на экран; `danger` — только для необратимого.
/// Подпись может переноситься на вторую строку (казахский длиннее).
class OvButton extends StatelessWidget {
  const OvButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = OvButtonVariant.primary,
    this.loading = false,
    this.icon,
    this.small = false,
    this.block = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final OvButtonVariant variant;
  final bool loading;
  final OvIcons? icon;
  final bool small;
  final bool block;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    final (bg, fg, border) = switch (variant) {
      OvButtonVariant.primary => (ov.brand, ov.onBrand, Colors.transparent),
      OvButtonVariant.secondary => (ov.surface, ov.ink, ov.lineStrong),
      OvButtonVariant.ghost => (Colors.transparent, ov.brand, Colors.transparent),
      OvButtonVariant.danger => (ov.surface, ov.danger, ov.danger),
    };
    final disabled = onPressed == null && !loading;
    final radius = BorderRadius.circular(OvRadius.radiusSm);
    final lead = loading
        ? OvSpinner(size: 18, color: fg)
        : (icon != null ? OvIcon(icon!, size: 20, color: fg) : null);

    final content = Row(
      mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (lead != null) ...[lead, const SizedBox(width: OvSpace.space2)],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: OvText.bodyStrong.copyWith(color: fg, fontSize: small ? 14 : 15),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: !disabled,
      child: Opacity(
        opacity: disabled ? .45 : 1,
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: border)),
          child: InkWell(
            borderRadius: radius,
            onTap: loading ? null : onPressed,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: small ? OvSize.controlHSm : OvSize.controlH),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: small ? OvSpace.space3 : OvSpace.space5,
                  vertical: OvSpace.space1,
                ),
                child: Center(widthFactor: block ? null : 1, child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Поле ввода: подпись сверху, подсказка или ошибка снизу.
class OvTextField extends StatefulWidget {
  const OvTextField({
    super.key,
    required this.label,
    this.controller,
    this.error,
    this.hint,
    this.placeholder,
    this.password = false,
    this.mono = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
    this.onChanged,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController? controller;
  final String? error;
  final String? hint;
  final String? placeholder;
  final bool password;
  final bool mono;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final TextCapitalization textCapitalization;

  @override
  State<OvTextField> createState() => _OvTextFieldState();
}

class _OvTextFieldState extends State<OvTextField> {
  final _focus = FocusNode();
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    final l = context.l10n;
    final hasError = widget.error != null;
    final focused = _focus.hasFocus;
    final borderColor = hasError ? ov.danger : (focused ? ov.brand : ov.lineStrong);
    final textStyle = (widget.mono ? OvText.mono : OvText.body).copyWith(color: ov.ink);
    final below = widget.error ?? widget.hint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.label, style: OvText.caption.copyWith(color: ov.ink, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          constraints: const BoxConstraints(minHeight: OvSize.controlH),
          padding: const EdgeInsets.only(left: OvSpace.space3, right: OvSpace.space1),
          decoration: BoxDecoration(
            color: ov.surfaceSunken,
            borderRadius: BorderRadius.circular(OvRadius.radiusSm),
            border: Border.all(color: borderColor, width: focused && !hasError ? 2 : 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  enabled: widget.enabled,
                  obscureText: widget.password && _obscured,
                  enableSuggestions: !widget.password && !widget.mono,
                  autocorrect: !widget.password && !widget.mono,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  textCapitalization: widget.textCapitalization,
                  autofillHints: widget.autofillHints,
                  onSubmitted: widget.onSubmitted,
                  onChanged: widget.onChanged,
                  style: textStyle,
                  cursorColor: ov.brand,
                  decoration: InputDecoration.collapsed(
                    hintText: widget.placeholder,
                    hintStyle: textStyle.copyWith(color: ov.inkMuted),
                  ).copyWith(contentPadding: const EdgeInsets.symmetric(vertical: OvSpace.space3), isDense: true),
                ),
              ),
              if (widget.password)
                SizedBox(
                  width: 44,
                  height: 44,
                  child: IconButton(
                    onPressed: () => setState(() => _obscured = !_obscured),
                    tooltip: _obscured ? l.showPassword : l.hidePassword,
                    icon: OvIcon(OvIcons.eye, color: ov.inkMuted),
                  ),
                )
              else
                const SizedBox(width: OvSpace.space2),
            ],
          ),
        ),
        if (below != null) ...[
          const SizedBox(height: 6),
          Semantics(
            liveRegion: hasError,
            child: Text(below, style: OvText.caption.copyWith(color: hasError ? ov.danger : ov.inkMuted)),
          ),
        ],
      ],
    );
  }
}

/// Переключатель включения камеры. Всегда с подписью или [semanticLabel].
class OvSwitch extends StatelessWidget {
  const OvSwitch({super.key, required this.value, required this.onChanged, this.label, this.semanticLabel});

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    const dur = Duration(milliseconds: 150);
    final track = AnimatedContainer(
      duration: dur,
      width: 44,
      height: 26,
      decoration: BoxDecoration(
        color: value ? ov.brand : ov.surfaceSunken,
        borderRadius: BorderRadius.circular(OvRadius.radiusFull),
        border: Border.all(color: value ? ov.brand : ov.lineStrong, width: 1.5),
      ),
      child: AnimatedAlign(
        duration: dur,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.5),
          child: AnimatedContainer(
            duration: dur,
            width: 18,
            height: 18,
            decoration: BoxDecoration(color: value ? ov.onBrand : ov.lineStrong, shape: BoxShape.circle),
          ),
        ),
      ),
    );
    return Semantics(
      toggled: value,
      enabled: onChanged != null,
      label: label ?? semanticLabel,
      excludeSemantics: true,
      child: Opacity(
        opacity: onChanged == null ? .45 : 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(OvRadius.radiusSm),
          onTap: onChanged == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onChanged!(!value);
                },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: OvSize.tapMin, minWidth: OvSize.tapMin),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (label != null) ...[
                  Text(label!, style: OvText.body.copyWith(color: ov.ink)),
                  const SizedBox(width: OvSpace.space3),
                ],
                track,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Чип фильтра ленты. Выбранный — `brand-soft`, рамка и текст `brand`, галочка.
class OvFilterChip extends StatelessWidget {
  const OvFilterChip({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.icon,
    this.menu = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;
  final OvIcons? icon;
  final bool menu;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    final fg = selected ? ov.brand : ov.ink;
    final lead = icon ?? (selected ? OvIcons.check : null);
    final radius = BorderRadius.circular(OvRadius.radiusFull);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? ov.brandSoft : ov.surface,
        shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: selected ? ov.brand : ov.lineStrong)),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: OvSize.controlHSm),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (lead != null) ...[OvIcon(lead, size: 16, color: fg), const SizedBox(width: 6)],
                  Text(label, style: OvText.bodyStrong.copyWith(fontSize: 14, color: fg)),
                  if (menu) ...[const SizedBox(width: 6), OvIcon(OvIcons.chevronDown, size: 16, color: fg)],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum OvTagTone { brand, neutral }

/// Бейдж «Известный 87 %» / «Новый» / роль.
class OvTag extends StatelessWidget {
  const OvTag(this.label, {super.key, this.tone = OvTagTone.neutral, this.icon});

  final String label;
  final OvTagTone tone;
  final OvIcons? icon;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    final (bg, fg) = tone == OvTagTone.brand ? (ov.brandSoft, ov.brand) : (ov.neutralSoft, ov.inkMuted);
    return Container(
      constraints: const BoxConstraints(minHeight: 22),
      padding: const EdgeInsets.symmetric(horizontal: OvSpace.space2, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(OvRadius.radiusFull)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[OvIcon(icon!, size: 12, strokeWidth: 2.25, color: fg), const SizedBox(width: 4)],
          Text(label, style: OvText.label.copyWith(color: fg, letterSpacing: 0, fontFeatures: ovTabular)),
        ],
      ),
    );
  }
}
