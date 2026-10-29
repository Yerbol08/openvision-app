import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../state/session.dart';
import '../../../theme/ov_tokens.dart';
import '../../strings.dart';
import '../../widgets/chrome.dart';

/// Тариф, хранение, смена пароля и выход.
class AccountList extends StatelessWidget {
  const AccountList({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final session = context.watch<Session>();
    final tenant = session.me?.tenant;
    final plan = tenant == null || tenant.plan.isEmpty
        ? ''
        : tenant.plan[0].toUpperCase() + tenant.plan.substring(1);
    return OvList(children: [
      if (tenant != null) ...[
        OvKeyValue(l.accountPlan, l.accountPlanValue(plan, tenant.maxCameras)),
        OvKeyValue(l.accountRetention, l.accountRetentionValue(tenant.retentionDays)),
      ],
      OvActionRow(label: l.changePassword, brand: true, onTap: () => context.push('/password')),
      OvActionRow(label: l.signOut, danger: true, onTap: session.logout),
    ]);
  }
}

/// Для ролей без вкладки «Команда».
Future<void> showAccountSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.only(bottom: OvSpace.space4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(OvSpace.space5, 0, OvSpace.space5, OvSpace.space3),
            child: Text(context.l10n.accountSection, style: OvText.title),
          ),
          const AccountList(),
        ],
      ),
    ),
  );
}
