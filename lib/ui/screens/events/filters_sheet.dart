import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/cameras_store.dart';
import '../../../state/events_feed.dart';
import '../../../theme/ov_theme.dart';
import '../../../theme/ov_tokens.dart';
import '../../strings.dart';
import '../../widgets/controls.dart';
import '../../widgets/ov_icon.dart';
import '../../widgets/status.dart';
import 'events_screen.dart' show periodLabel;

/// Экран 15 · Фильтры событий: период, люди, камеры.
Future<void> showFiltersSheet(BuildContext context) {
  final feed = context.read<EventsFeed>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: feed),
        ChangeNotifierProvider.value(value: context.read<CamerasStore>()),
      ],
      child: _FiltersSheet(initial: feed.filters),
    ),
  );
}

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({required this.initial});
  final EventFilters initial;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late EventFilters _f = widget.initial;

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final r = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      initialDateRange: _f.range,
    );
    if (r != null) setState(() => _f = _f.copyWith(period: Period.custom, range: r));
  }

  void _setPeriod(Period p) {
    if (p == Period.custom) {
      _pickDates();
      return;
    }
    // Повторный тап по выбранному периоду снимает фильтр.
    setState(() => _f = _f.copyWith(period: _f.period == p ? Period.any : p));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ov = context.ov;
    final cams = context.watch<CamerasStore>().cameras;

    Widget label(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(OvSpace.space5, OvSpace.space3, OvSpace.space5, OvSpace.space2),
          child: Text(text, style: OvText.caption.copyWith(fontWeight: FontWeight.w600, color: ov.inkMuted)),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 4,
          margin: const EdgeInsets.only(top: OvSpace.space2, bottom: OvSpace.space1),
          decoration: BoxDecoration(color: ov.lineStrong, borderRadius: BorderRadius.circular(OvRadius.radiusFull)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(OvSpace.space5, OvSpace.space2, OvSpace.space2, OvSpace.space2),
          child: Row(
            children: [
              Expanded(child: Semantics(header: true, child: Text(l.filterTitle, style: OvText.title.copyWith(color: ov.ink)))),
              TextButton(
                onPressed: () => setState(() => _f = const EventFilters()),
                style: TextButton.styleFrom(foregroundColor: ov.brand, minimumSize: const Size(OvSize.tapMin, OvSize.tapMin)),
                child: Text(l.filterReset, style: OvText.bodyStrong.copyWith(color: ov.brand)),
              ),
            ],
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                label(l.filterPeriod),
                _Segmented<Period>(
                  value: _f.period,
                  onChanged: _setPeriod,
                  options: [
                    (Period.today, l.periodToday),
                    (Period.yesterday, l.periodYesterday),
                    (Period.week, l.period7d),
                    (Period.custom, _f.period == Period.custom ? periodLabel(context, _f) : l.periodDates),
                  ],
                ),
                label(l.filterPeople),
                _Segmented<bool?>(
                  value: _f.known,
                  onChanged: (v) => setState(() => _f = _f.copyWith(known: () => v)),
                  options: [(null, l.peopleAll), (true, l.peopleKnown), (false, l.peopleUnknown)],
                ),
                if (cams.isNotEmpty) ...[
                  label(l.filterCameras),
                  for (final c in cams)
                    _CameraCheck(
                      name: c.name,
                      status: c.displayStatus,
                      value: _f.cameraIds.contains(c.id),
                      onChanged: (v) => setState(() {
                        final ids = {..._f.cameraIds};
                        v ? ids.add(c.id) : ids.remove(c.id);
                        _f = _f.copyWith(cameraIds: ids);
                      }),
                    ),
                ],
                const SizedBox(height: OvSpace.space3),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(color: ov.surface, border: Border(top: BorderSide(color: ov.line))),
          padding: const EdgeInsets.all(OvSpace.space4),
          child: OvButton(
            label: l.filterShow,
            block: true,
            onPressed: () {
              context.read<EventsFeed>().setFilters(_f);
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}

/// Сегменты на подложке `surface-sunken`; подписи могут переноситься.
class _Segmented<T> extends StatelessWidget {
  const _Segmented({required this.value, required this.onChanged, required this.options});
  final T value;
  final ValueChanged<T> onChanged;
  final List<(T, String)> options;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: OvSpace.space5),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: ov.surfaceSunken, borderRadius: BorderRadius.circular(10)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (v, text) in options)
              Expanded(
                child: Semantics(
                  selected: v == value,
                  button: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(v),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      constraints: const BoxConstraints(minHeight: 40),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: OvSpace.space2),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: v == value ? ov.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(OvRadius.radiusSm),
                        border: Border.all(color: v == value ? ov.line : Colors.transparent),
                      ),
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        style: OvText.bodyStrong.copyWith(fontSize: 14, height: 1.3, color: v == value ? ov.ink : ov.inkMuted),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CameraCheck extends StatelessWidget {
  const _CameraCheck({required this.name, required this.status, required this.value, required this.onChanged});
  final String name;
  final String status;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    return Semantics(
      checked: value,
      label: name,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: OvSize.tapMin),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: OvSpace.space5, vertical: OvSpace.space1),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: value ? ov.brand : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: value ? ov.brand : ov.lineStrong, width: 2),
                  ),
                  child: value ? Center(child: OvIcon(OvIcons.check, size: 16, strokeWidth: 2.5, color: ov.onBrand)) : null,
                ),
                const SizedBox(width: OvSpace.space3),
                Expanded(child: Text(name, style: OvText.body.copyWith(color: ov.ink))),
                StatusBadge(status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
