import 'package:flutter/material.dart';

import '../../theme/ov_theme.dart';
import '../../theme/ov_tokens.dart';
import '../strings.dart';
import 'ov_icon.dart';

class OvAction {
  const OvAction(this.icon, this.label, this.onTap);
  final OvIcons icon;
  final String label;
  final VoidCallback onTap;
}

/// Шапка: крупная (`display`) на вкладках, обычная (`title`) с «Назад» на вложенных.
/// До двух иконок-действий справа, каждая 48×48 с подписью для озвучки.
class OvAppBar extends StatelessWidget {
  const OvAppBar({super.key, required this.title, this.large = false, this.back = false, this.actions = const []});

  final String title;
  final bool large;
  final bool back;
  final List<OvAction> actions;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    return Container(
      color: ov.bg,
      constraints: const BoxConstraints(minHeight: 56),
      padding: EdgeInsets.only(
        left: back ? OvSpace.space1 : OvSpace.space4,
        right: OvSpace.space2,
        top: large ? OvSpace.space6 : OvSpace.space2,
        bottom: OvSpace.space2,
      ),
      child: Row(
        children: [
          if (back)
            OvIconButton(
              icon: OvIcons.chevronLeft,
              size: 24,
              label: context.l10n.back,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: (large ? OvText.display : OvText.title).copyWith(color: ov.ink),
              ),
            ),
          ),
          for (final a in actions) OvIconButton(icon: a.icon, label: a.label, onTap: a.onTap),
        ],
      ),
    );
  }
}

class OvIconButton extends StatelessWidget {
  const OvIconButton({super.key, required this.icon, required this.label, required this.onTap, this.size = 22, this.color});

  final OvIcons icon;
  final String label;
  final VoidCallback onTap;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: OvSize.tapMin,
      child: IconButton(
        onPressed: onTap,
        tooltip: label,
        icon: OvIcon(icon, size: size, color: color ?? context.ov.ink),
      ),
    );
  }
}

/// Подзаголовок под крупной шапкой: «3 из 4 по тарифу».
class OvSubtitle extends StatelessWidget {
  const OvSubtitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(OvSpace.space4, 0, OvSpace.space4, OvSpace.space3),
        child: Text(text, style: OvText.body.copyWith(fontSize: 14, height: 20 / 14, color: context.ov.inkMuted)),
      );
}

class OvTab {
  const OvTab({required this.label, required this.icon, required this.branch, this.badge = 0, this.badgeLabel});
  final String label;
  final OvIcons icon;
  final int branch;
  final int badge;
  final String? badgeLabel;
}

/// Нижняя навигация: активная вкладка — значок в пилюле `brand-soft`.
class OvTabBar extends StatelessWidget {
  const OvTabBar({super.key, required this.tabs, required this.current, required this.onSelect});

  final List<OvTab> tabs;
  final int current;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    return Container(
      decoration: BoxDecoration(color: ov.surface, border: Border(top: BorderSide(color: ov.line))),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: OvSize.tabbarH),
          child: Row(
            children: [
              for (final t in tabs) Expanded(child: _TabItem(tab: t, active: t.branch == current, onTap: () => onSelect(t.branch))),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({required this.tab, required this.active, required this.onTap});
  final OvTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    final color = active ? ov.brand : ov.inkMuted;
    return Semantics(
      selected: active,
      button: true,
      label: [tab.label, if (tab.badge > 0) tab.badgeLabel].whereType<String>().join(', '),
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        highlightShape: BoxShape.rectangle,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 56,
                    height: 28,
                    decoration: BoxDecoration(
                      color: active ? ov.brandSoft : Colors.transparent,
                      borderRadius: BorderRadius.circular(OvRadius.radiusFull),
                    ),
                    child: Center(child: OvIcon(tab.icon, size: 22, color: color)),
                  ),
                  if (tab.badge > 0)
                    Positioned(
                      left: 36,
                      top: -4,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 18),
                        height: 18,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(color: ov.danger, borderRadius: BorderRadius.circular(OvRadius.radiusFull)),
                        alignment: Alignment.center,
                        child: Text(
                          '${tab.badge}',
                          textScaler: TextScaler.noScaling,
                          style: OvText.label.copyWith(fontSize: 11, height: 1, color: ov.onDanger, fontFeatures: ovTabular),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                tab.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: OvText.label.copyWith(color: color, letterSpacing: 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Заголовок секции: «Требуют внимания», «Аккаунт».
class OvSection extends StatelessWidget {
  const OvSection(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(OvSpace.space4, OvSpace.space6, OvSpace.space4, OvSpace.space2),
        child: Semantics(header: true, child: Text(title, style: OvText.headline.copyWith(color: context.ov.ink))),
      );
}

/// Карточка: `surface` с рамкой `line`, без теней.
class OvCard extends StatelessWidget {
  const OvCard({super.key, required this.child, this.padding = const EdgeInsets.all(OvSpace.space4), this.onTap});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    final radius = BorderRadius.circular(OvRadius.radiusMd);
    return Material(
      color: ov.surface,
      shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: ov.line)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}

/// Список во всю ширину: `surface`, рамки сверху и снизу, разделители `line`.
class OvList extends StatelessWidget {
  const OvList({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    return Material(
      color: ov.surface,
      shape: Border.symmetric(horizontal: BorderSide(color: ov.line)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, color: ov.line),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Строка «ключ — значение».
class OvKeyValue extends StatelessWidget {
  const OvKeyValue(this.label, this.value, {super.key, this.tabular = false});
  final String label;
  final String value;
  final bool tabular;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: OvSpace.space4, vertical: OvSpace.space3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: OvText.body.copyWith(color: ov.inkMuted)),
          const SizedBox(width: OvSpace.space3),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: OvText.body.copyWith(color: ov.ink, fontFeatures: tabular ? ovTabular : null),
            ),
          ),
        ],
      ),
    );
  }
}

/// Строка-действие: «События этой камеры ›», «Выйти».
class OvActionRow extends StatelessWidget {
  const OvActionRow({super.key, required this.label, required this.onTap, this.icon, this.danger = false, this.brand = false, this.chevron = false});

  final String label;
  final VoidCallback onTap;
  final OvIcons? icon;
  final bool danger;
  final bool brand;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    final fg = danger ? ov.danger : (brand ? ov.brand : ov.ink);
    final iconColor = danger ? ov.danger : ov.inkMuted;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: OvSize.tapMin),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: OvSpace.space4, vertical: 14),
          child: Row(
            children: [
              if (icon != null) ...[OvIcon(icon!, color: iconColor), const SizedBox(width: OvSpace.space3)],
              Expanded(child: Text(label, style: OvText.body.copyWith(color: fg))),
              if (chevron) OvIcon(OvIcons.chevronRight, color: ov.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Пустое состояние или ошибка загрузки: одна строка и максимум одна кнопка.
class OvEmpty extends StatelessWidget {
  const OvEmpty({super.key, required this.text, this.actionLabel, this.onAction});
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: OvSpace.space6, vertical: OvSpace.space8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, textAlign: TextAlign.center, style: OvText.body.copyWith(color: ov.inkMuted)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: OvSpace.space4),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: ov.brand, minimumSize: const Size(OvSize.tapMin, OvSize.tapMin)),
              child: Text(actionLabel!, style: OvText.bodyStrong.copyWith(color: ov.brand)),
            ),
          ],
        ],
      ),
    );
  }
}

void showOvSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}
