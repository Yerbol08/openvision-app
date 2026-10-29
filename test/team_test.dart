import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openvision/ui/screens/team/team_screen.dart';

import 'support.dart';

void main() {
  testWidgets('приглашение: короткий пароль не уходит на сервер, верная форма — уходит с ролью', (tester) async {
    final api = FakeApi();
    await pumpScreen(tester, api, const Scaffold(body: TeamScreen()));
    await settle(tester);

    // У владельца нет «⋮», у оператора — есть.
    expect(find.byTooltip('Действия'), findsOneWidget);

    await tester.tap(find.byTooltip('Пригласить'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).at(0), 'Тимур Ахметов');
    await tester.enterText(find.byType(TextField).at(1), 'timur@acme.kz');
    await tester.enterText(find.byType(TextField).at(2), 'short');
    await tester.tap(find.text('Наблюдатель'));
    await tester.tap(find.text('Добавить в команду'));
    await settle(tester);
    expect(find.text('Не меньше 10 символов'), findsOneWidget);
    expect(api.calls.containsKey('createUser'), isFalse);

    await tester.enterText(find.byType(TextField).at(2), 'temp-pass-2026');
    await tester.tap(find.text('Добавить в команду'));
    await settle(tester);
    expect(api.calls['createUser'], {'email': 'timur@acme.kz', 'role': 'viewer'});
    expect(find.text('Участник добавлен'), findsOneWidget);
  });
}
