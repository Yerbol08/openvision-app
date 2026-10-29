import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_exception.dart';
import '../../../state/session.dart';
import '../../../theme/ov_theme.dart';
import '../../../theme/ov_tokens.dart';
import '../../strings.dart';
import '../../widgets/chrome.dart';
import '../../widgets/controls.dart';
import '../../widgets/wizard.dart';
import '../auth/auth_common.dart' show FormErrorText;

/// Смена пароля (`PUT /auth/me/password`). Другие устройства после неё выходят.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  bool _saving = false;
  String? _currentError;
  String? _nextError;
  String? _formError;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = context.l10n;
    final next = _next.text;
    setState(() {
      _currentError = _current.text.isEmpty ? l.errFieldRequired : null;
      _nextError = next.length < 10 ? l.errPasswordShort : (next.length > 128 ? l.errPasswordLong : null);
      _formError = null;
    });
    if (_currentError != null || _nextError != null) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await context.read<Session>().changePassword(current: _current.text, next: next);
      if (!mounted) return;
      showOvSnack(context, l.passwordChanged);
      context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.code == 'wrong_password') {
          _currentError = l.errWrongPassword;
        } else if (e.invalidFields.contains('new_password')) {
          _nextError = next.length < 10 ? l.errPasswordShort : l.errPasswordLong;
        } else {
          _formError = errorText(l, e);
        }
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ov = context.ov;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            OvAppBar(title: l.changePassword, back: true),
            Expanded(
              child: AutofillGroup(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(OvSpace.space4, OvSpace.space2, OvSpace.space4, OvSpace.space6),
                  children: [
                    Text(l.changePasswordText, style: OvText.body.copyWith(fontSize: 14, height: 20 / 14, color: ov.inkMuted)),
                    const SizedBox(height: OvSpace.space4),
                    OvTextField(
                      label: l.fieldCurrentPassword,
                      controller: _current,
                      password: true,
                      error: _currentError,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.password],
                    ),
                    const SizedBox(height: 14),
                    OvTextField(
                      label: l.fieldNewPassword,
                      controller: _next,
                      password: true,
                      error: _nextError,
                      hint: l.passwordHint,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      onSubmitted: (_) => _save(),
                    ),
                    if (_formError != null) ...[const SizedBox(height: 14), FormErrorText(_formError!)],
                  ],
                ),
              ),
            ),
            OvBottomBar(children: [
              Expanded(child: OvButton(label: l.changePassword, block: true, loading: _saving, onPressed: _save)),
            ]),
          ],
        ),
      ),
    );
  }
}
