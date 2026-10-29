import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_exception.dart';
import '../../../data/models.dart';
import '../../../data/ov_api.dart';
import '../../../state/session.dart';
import '../../../theme/ov_theme.dart';
import '../../../theme/ov_tokens.dart';
import '../../strings.dart';
import '../../widgets/chrome.dart';
import '../../widgets/controls.dart';
import '../../widgets/ov_icon.dart';
import 'account_section.dart';
import 'member_sheets.dart';

/// Экран 8 · Команда (`GET /users`, только при `users.read`).
/// Приглашение и меню «⋮» — при `users.write`; у владельца и у себя меню нет.
class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  List<User>? _users;
  ApiException? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final users = await context.read<OvApi>().users();
      if (!mounted) return;
      setState(() {
        _users = users;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
      if (e.code == 'forbidden') context.read<Session>().reloadMe();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ov = context.ov;
    final session = context.watch<Session>();
    final me = session.me;
    final canWrite = session.can(Permissions.usersWrite);
    final users = _users;

    Future<void> invite() async {
      final user = await showInviteSheet(context);
      if (user == null || !context.mounted) return;
      showOvSnack(context, l.memberAdded);
      _load();
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: ov.brand,
      child: ListView(
        padding: const EdgeInsets.only(bottom: OvSpace.space6),
        children: [
          OvAppBar(
            title: l.teamTitle,
            large: true,
            actions: [if (canWrite) OvAction(OvIcons.plus, l.teamInviteA11y, invite)],
          ),
          if (users != null) OvSubtitle(l.teamMembers(users.length)),
          if (users == null && _error != null)
            OvEmpty(text: errorText(l, _error!), actionLabel: l.retry, onAction: _load)
          else if (users == null)
            const Padding(padding: EdgeInsets.all(OvSpace.space8), child: Center(child: CircularProgressIndicator()))
          else
            OvList(children: [
              for (final u in users)
                _MemberRow(
                  user: u,
                  isYou: u.id == me?.user.id,
                  onActions: canWrite && u.role != 'owner' && u.id != me?.user.id
                      ? () async {
                          if (await showMemberActions(context, u)) _load();
                        }
                      : null,
                ),
            ]),
          OvSection(l.accountSection),
          const AccountList(),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.user, required this.isYou, this.onActions});
  final User user;
  final bool isYou;

  /// Меню «⋮»; null — менять нельзя (владелец, вы сами или нет `users.write`).
  final VoidCallback? onActions;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ov = context.ov;
    final name = user.fullName.isEmpty ? user.email : user.fullName;
    final initials = name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).map((w) => w[0]).take(2).join().toUpperCase();
    final dim = user.isActive ? 1.0 : .55;
    final brand = user.role == 'owner' || user.role == 'admin';

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: EdgeInsets.only(
          left: OvSpace.space4,
          right: onActions != null ? OvSpace.space1 : OvSpace.space4,
          top: OvSpace.space3,
          bottom: OvSpace.space3,
        ),
        child: Row(
          children: [
            Opacity(
              opacity: dim,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: ov.neutralSoft, shape: BoxShape.circle),
                child: ExcludeSemantics(
                  child: Text(initials, style: OvText.bodyStrong.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: ov.ink)),
                ),
              ),
            ),
            const SizedBox(width: OvSpace.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Opacity(
                    opacity: dim,
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: name),
                        if (isYou) TextSpan(text: ' ${l.memberYou}', style: TextStyle(color: ov.inkMuted, fontWeight: FontWeight.w400)),
                      ]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OvText.bodyStrong.copyWith(color: ov.ink),
                    ),
                  ),
                  Text(
                    user.isActive ? user.email : l.memberInactive(user.email),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OvText.caption.copyWith(color: ov.inkMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: OvSpace.space2),
            OvTag(
              roleLabel(l, user.role),
              tone: brand ? OvTagTone.brand : OvTagTone.neutral,
              icon: user.role == 'owner' ? OvIcons.lock : null,
            ),
            if (onActions != null)
              OvIconButton(icon: OvIcons.more, size: 20, label: l.memberActions, onTap: onActions!, color: ov.inkMuted),
          ],
        ),
      ),
    );
  }
}
