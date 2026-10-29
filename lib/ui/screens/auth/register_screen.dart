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
import 'auth_common.dart';

/// Экран 9 · Регистрация компании (`POST /auth/register`).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _company = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  Map<String, String> _errors = {};
  String? _formError;

  @override
  void dispose() {
    for (final c in [_company, _name, _email, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, String> _validate() {
    final l = context.l10n;
    final email = _email.text.trim();
    final pw = _password.text;
    return {
      if (_company.text.trim().isEmpty) 'company_name': l.errFieldRequired,
      if (_name.text.trim().isEmpty) 'full_name': l.errFieldRequired,
      if (email.isEmpty) 'email': l.errFieldRequired else if (!email.contains('@')) 'email': l.errEmailInvalid,
      if (pw.length < 10) 'password': l.errPasswordShort else if (pw.length > 128) 'password': l.errPasswordLong,
    };
  }

  /// `validation_error`: свой текст под полем по ключу `field`, не `message` сервера.
  String _serverFieldText(String field) {
    final l = context.l10n;
    return switch (field) {
      'email' => l.errEmailInvalid,
      'password' => _password.text.length < 10 ? l.errPasswordShort : l.errPasswordLong,
      _ => l.errFieldInvalid,
    };
  }

  Future<void> _submit() async {
    final l = context.l10n;
    setState(() {
      _errors = _validate();
      _formError = null;
    });
    if (_errors.isNotEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await context.read<Session>().register(
            companyName: _company.text.trim(),
            fullName: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
          );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.code == 'email_taken') {
          _errors = {'email': l.errEmailTaken};
        } else if (e.invalidFields.isNotEmpty) {
          _errors = {for (final f in e.invalidFields) f: _serverFieldText(f)};
          final known = {'company_name', 'full_name', 'email', 'password'};
          if (!e.invalidFields.any(known.contains)) _formError = l.errGeneric;
        } else {
          _formError = errorText(l, e);
        }
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const OvAppBar(title: '', back: true),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(OvSpace.space4, 0, OvSpace.space4, OvSpace.space6),
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthHeading(title: l.registerTitle, subtitle: l.registerSubtitle),
                      const SizedBox(height: 14),
                      OvTextField(
                        label: l.fieldCompany,
                        controller: _company,
                        error: _errors['company_name'],
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.sentences,
                        autofillHints: const [AutofillHints.organizationName],
                      ),
                      const SizedBox(height: 14),
                      OvTextField(
                        label: l.fieldFullName,
                        controller: _name,
                        error: _errors['full_name'],
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        autofillHints: const [AutofillHints.name],
                      ),
                      const SizedBox(height: 14),
                      OvTextField(
                        label: l.fieldEmail,
                        controller: _email,
                        error: _errors['email'],
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: 14),
                      OvTextField(
                        label: l.fieldPassword,
                        controller: _password,
                        password: true,
                        error: _errors['password'],
                        hint: l.passwordHint,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        onSubmitted: (_) => _submit(),
                      ),
                      if (_formError != null) ...[
                        const SizedBox(height: OvSpace.space4),
                        FormErrorText(_formError!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(color: ov.surface, border: Border(top: BorderSide(color: ov.line))),
              padding: const EdgeInsets.fromLTRB(OvSpace.space4, OvSpace.space4, OvSpace.space4, 0),
              child: SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OvButton(label: l.registerButton, onPressed: _submit, loading: _loading, block: true),
                    AuthSwitchLink(
                      question: l.registerHaveAccount,
                      action: l.registerLoginLink,
                      onTap: () => context.canPop() ? context.pop() : context.go('/login'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
