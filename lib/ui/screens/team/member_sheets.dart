import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_exception.dart';
import '../../../data/models.dart';
import '../../../data/ov_api.dart';
import '../../../theme/ov_theme.dart';
import '../../../theme/ov_tokens.dart';
import '../../strings.dart';
import '../../widgets/chrome.dart';
import '../../widgets/controls.dart';
import '../../widgets/ov_icon.dart';
import '../../widgets/wizard.dart';
import '../auth/auth_common.dart' show FormErrorText;

/// Роли, которые можно назначить (`owner` — нельзя).
const assignableRoles = ['admin', 'operator', 'viewer'];

/// Карточка роли с радиокнопкой и тем, что роль открывает.
class RoleCard extends StatelessWidget {
  const RoleCard({super.key, required this.role, required this.selected, required this.onTap});
  final String role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    final l = context.l10n;
    final hint = switch (role) {
      'admin' => l.roleAdminHint,
      'operator' => l.roleOperatorHint,
      _ => l.roleViewerHint,
    };
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
            padding: EdgeInsets.symmetric(horizontal: selected ? 11 : 12, vertical: selected ? 7 : 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: const EdgeInsets.only(top: 2), child: OvRadio(selected: selected)),
                const SizedBox(width: OvSpace.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(roleLabel(l, role), style: OvText.bodyStrong.copyWith(fontWeight: FontWeight.w600, color: ov.ink)),
                      Text(hint, style: OvText.caption.copyWith(color: ov.inkMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Шапка шита: ручка, заголовок, «Закрыть».
class _SheetHeader extends StatelessWidget {
  const _SheetHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    final ov = context.ov;
    return Column(
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
              Expanded(child: Semantics(header: true, child: Text(title, style: OvText.title.copyWith(color: ov.ink)))),
              OvIconButton(icon: OvIcons.close, label: context.l10n.close, onTap: () => Navigator.pop(context)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Экран 16 · Новый участник (`POST /users`). Возвращает созданного пользователя.
Future<User?> showInviteSheet(BuildContext context) {
  final api = context.read<OvApi>();
  return showModalBottomSheet<User>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => Provider.value(value: api, child: const _InviteSheet()),
  );
}

class _InviteSheet extends StatefulWidget {
  const _InviteSheet();

  @override
  State<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<_InviteSheet> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _role = 'operator';
  bool _saving = false;
  Map<String, String> _errors = {};
  String? _formError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = context.l10n;
    final email = _email.text.trim();
    final pw = _password.text;
    setState(() {
      _errors = {
        if (_name.text.trim().isEmpty) 'full_name': l.errFieldRequired,
        if (email.isEmpty) 'email': l.errFieldRequired else if (!email.contains('@')) 'email': l.errEmailInvalid,
        if (pw.length < 10) 'password': l.errPasswordShort else if (pw.length > 128) 'password': l.errPasswordLong,
      };
      _formError = null;
    });
    if (_errors.isNotEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      final user = await context.read<OvApi>().createUser(email: email, fullName: _name.text.trim(), role: _role, password: pw);
      if (mounted) Navigator.pop(context, user);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.code == 'email_taken') {
          _errors = {'email': l.errEmailTaken};
        } else if (e.invalidFields.isNotEmpty) {
          _errors = {
            for (final f in e.invalidFields)
              f: switch (f) {
                'email' => l.errEmailInvalid,
                'password' => l.errPasswordShort,
                _ => l.errFieldInvalid,
              },
          };
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
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHeader(l.inviteTitle),
          Flexible(
            child: AutofillGroup(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(OvSpace.space5, 0, OvSpace.space5, OvSpace.space4),
                children: [
                  OvTextField(
                    label: l.fieldPersonName,
                    controller: _name,
                    error: _errors['full_name'],
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: OvSpace.space3),
                  OvTextField(
                    label: l.fieldEmail,
                    controller: _email,
                    error: _errors['email'],
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: OvSpace.space3),
                  Text(l.fieldRole, style: OvText.caption.copyWith(color: ov.ink, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  for (final r in assignableRoles) ...[
                    RoleCard(role: r, selected: _role == r, onTap: () => setState(() => _role = r)),
                    const SizedBox(height: OvSpace.space2),
                  ],
                  const SizedBox(height: OvSpace.space1),
                  OvTextField(
                    label: l.fieldInitialPassword,
                    controller: _password,
                    password: true,
                    error: _errors['password'],
                    hint: l.initialPasswordHint,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    onSubmitted: (_) => _submit(),
                  ),
                  if (_formError != null) ...[const SizedBox(height: OvSpace.space3), FormErrorText(_formError!)],
                ],
              ),
            ),
          ),
          OvBottomBar(children: [
            Expanded(child: OvButton(label: l.inviteButton, block: true, loading: _saving, onPressed: _submit)),
          ]),
        ],
      ),
    );
  }
}

/// Меню «⋮» участника: сменить роль, отключить/включить, удалить.
/// Возвращает true, если список нужно перечитать.
Future<bool> showMemberActions(BuildContext context, User user) async {
  final l = context.l10n;
  final ov = context.ov;
  final api = context.read<OvApi>();
  final messenger = ScaffoldMessenger.of(context);
  final name = user.fullName.isEmpty ? user.email : user.fullName;

  final action = await showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    builder: (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SheetHeader(name),
        OvList(children: [
          OvActionRow(icon: OvIcons.team, label: l.memberChangeRole, onTap: () => Navigator.pop(ctx, 'role')),
          OvActionRow(
            icon: OvIcons.lock,
            label: user.isActive ? l.memberDeactivate : l.memberActivate,
            onTap: () => Navigator.pop(ctx, 'active'),
          ),
          OvActionRow(icon: OvIcons.trash, label: l.memberRemove, danger: true, onTap: () => Navigator.pop(ctx, 'remove')),
        ]),
        const SizedBox(height: OvSpace.space4),
      ],
    ),
  );
  if (action == null || !context.mounted) return false;

  Future<bool> run(Future<void> Function() call) async {
    try {
      await call();
      return true;
    } on ApiException catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(errorText(l, e))));
      return e.code == 'not_found';
    }
  }

  switch (action) {
    case 'role':
      final role = await _pickRole(context, user.role);
      if (role == null || role == user.role) return false;
      return run(() => api.updateUser(user.id, role: role));
    case 'active':
      // Отключение сразу выходит из всех сессий пользователя; включить можно обратно.
      return run(() => api.updateUser(user.id, isActive: !user.isActive));
    case 'remove':
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.memberRemoveTitle(name)),
          content: Text(l.memberRemoveText),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              style: TextButton.styleFrom(foregroundColor: ov.ink),
              child: Text(l.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: ov.danger),
              child: Text(l.delete),
            ),
          ],
        ),
      );
      if (ok != true) return false;
      return run(() => api.deleteUser(user.id));
  }
  return false;
}

Future<String?> _pickRole(BuildContext context, String current) {
  return showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (ctx) {
      var selected = assignableRoles.contains(current) ? current : 'viewer';
      return StatefulBuilder(
        builder: (ctx, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetHeader(ctx.l10n.memberChangeRole),
            Padding(
              padding: const EdgeInsets.fromLTRB(OvSpace.space5, 0, OvSpace.space5, OvSpace.space4),
              child: Column(
                children: [
                  for (final r in assignableRoles) ...[
                    RoleCard(role: r, selected: selected == r, onTap: () => setState(() => selected = r)),
                    const SizedBox(height: OvSpace.space2),
                  ],
                ],
              ),
            ),
            OvBottomBar(children: [
              Expanded(child: OvButton(label: ctx.l10n.save, block: true, onPressed: () => Navigator.pop(ctx, selected))),
            ]),
          ],
        ),
      );
    },
  );
}
