import 'package:flutter/widgets.dart';

import '../../core/privacy.dart';

/// Пока виджет на экране — запрет скриншотов и размытие в переключателе приложений.
class PrivacyScope extends StatefulWidget {
  const PrivacyScope({super.key, required this.child, this.active = true});

  final Widget child;
  final bool active;

  @override
  State<PrivacyScope> createState() => _PrivacyScopeState();
}

class _PrivacyScopeState extends State<PrivacyScope> {
  bool _held = false;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(PrivacyScope old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.active && !_held) {
      Privacy.acquire();
      _held = true;
    } else if (!widget.active && _held) {
      Privacy.release();
      _held = false;
    }
  }

  @override
  void dispose() {
    if (_held) Privacy.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
