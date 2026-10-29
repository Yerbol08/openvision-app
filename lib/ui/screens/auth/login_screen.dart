import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_exception.dart';
import '../../../state/session.dart';
import '../../../theme/ov_theme.dart';
import '../../../theme/ov_tokens.dart';
import '../../strings.dart';
import '../../widgets/controls.dart';
import 'auth_common.dart';

/// Экран 1 · Вход (`POST /auth/login`).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _emailError;
  String? _passwordError;
  String? _formError;

  @override
  void initState() {
    super.initState();
    // Сервер завершил сессию — объясняем, почему снова экран входа.
    final ended = context.read<Session>().endedReason;
    if (ended != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _formError = errorText(context.l10n, ApiException(ended)));
      });
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = context.l10n;
    final email = _email.text.trim();
    final password = _password.text;
    setState(() {
      _emailError = email.isEmpty ? l.errFieldRequired : (!email.contains('@') ? l.errEmailInvalid : null);
      _passwordError = password.isEmpty ? l.errFieldRequired : null;
      _formError = null;
    });
    if (_emailError != null || _passwordError != null) return;

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await context.read<Session>().login(email, password);
      // Дальше маршрутизатор сам уведёт на «Обзор».
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.code == 'invalid_credentials') {
          _passwordError = l.errInvalidCredentials;
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
        child: FillScrollView(
          padding: const EdgeInsets.fromLTRB(OvSpace.space5, 48, OvSpace.space5, OvSpace.space5),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.appName, style: OvText.title.copyWith(color: ov.ink, letterSpacing: -0.2)),
                const SizedBox(height: OvSpace.space6),
                AuthHeading(title: l.loginTitle, subtitle: l.loginSubtitle),
                const SizedBox(height: OvSpace.space6),
                OvTextField(
                  label: l.fieldEmail,
                  controller: _email,
                  error: _emailError,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email, AutofillHints.username],
                ),
                const SizedBox(height: OvSpace.space4),
                OvTextField(
                  label: l.fieldPassword,
                  controller: _password,
                  password: true,
                  error: _passwordError,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => _submit(),
                ),
                if (_formError != null) ...[
                  const SizedBox(height: OvSpace.space4),
                  FormErrorText(_formError!),
                ],
                const SizedBox(height: OvSpace.space6),
                OvButton(label: l.loginButton, onPressed: _submit, loading: _loading, block: true),
                const Spacer(),
                const SizedBox(height: OvSpace.space6),
                AuthSwitchLink(
                  question: l.loginNoAccount,
                  action: l.loginRegisterLink,
                  onTap: () => context.push('/register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
