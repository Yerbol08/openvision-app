import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openvision/data/models.dart';
import 'package:openvision/ui/screens/cameras/add_camera_screen.dart';

import 'support.dart';

Future<void> chooseMode(WidgetTester tester, String title) async {
  await tester.tap(find.text(title));
  await tester.pump();
  await tester.tap(find.text('Далее'));
  await settle(tester);
}

void main() {
  testWidgets('«Далее» неактивна, пока не выбран способ подключения', (tester) async {
    final api = FakeApi();
    await pumpScreen(tester, api, const AddCameraScreen());
    expect(find.text('Как камера подключена к интернету?'), findsOneWidget);
    await tester.tap(find.text('Далее'));
    await settle(tester);
    expect(find.text('Как камера подключена к интернету?'), findsOneWidget);
  });

  testWidgets('адрес в интернете: проверка показывает поток и предупреждение, затем сохранение', (tester) async {
    final api = FakeApi();
    await pumpScreen(tester, api, const AddCameraScreen());
    await chooseMode(tester, 'У камеры есть адрес в интернете');

    await tester.enterText(find.byType(TextField).at(0), 'Вход');
    await tester.enterText(find.byType(TextField).at(2), 'rtsp://admin:pass@203.0.113.5:554/101');
    await tester.tap(find.text('Проверить подключение'));
    await settle(tester);

    expect(api.calls['probe']!['url'], 'rtsp://admin:pass@203.0.113.5:554/101');
    expect(find.text('Камера отвечает'), findsOneWidget);
    expect(find.text('1920×1080 · 8 fps · H.264'), findsOneWidget);
    expect(find.textContaining('Меньше 10 кадров'), findsOneWidget);

    await tester.tap(find.text('Сохранить камеру'));
    await settle(tester);
    expect(api.calls['createCamera']!['mode'], 'pull');
    expect(find.text('camera 42'), findsOneWidget);
  });

  testWidgets('локальный адрес не проверяем, а предлагаем блок и переносим адрес', (tester) async {
    final api = FakeApi()..agents = [EdgeAgent.fromJson({'id': 'a1', 'name': 'ПК охраны', 'online': true})];
    await pumpScreen(tester, api, const AddCameraScreen());
    await chooseMode(tester, 'У камеры есть адрес в интернете');

    await tester.enterText(find.byType(TextField).at(0), 'Склад');
    await tester.enterText(find.byType(TextField).at(2), 'rtsp://admin:pass@192.168.1.64/s');
    await tester.tap(find.text('Проверить подключение'));
    await settle(tester);

    expect(api.calls.containsKey('probe'), isFalse);
    expect(find.text('Это адрес локальной сети'), findsOneWidget);

    await tester.tap(find.text('Подключить через блок'));
    await settle(tester);
    expect(find.text('Какой блок читает камеру?'), findsOneWidget);
    expect(find.text('rtsp://admin:pass@192.168.1.64/s'), findsOneWidget);

    await tester.tap(find.text('Сохранить камеру'));
    await settle(tester);
    expect(api.calls['createCamera'], {'name': 'Склад', 'mode': 'edge', 'source_url': 'rtsp://admin:pass@192.168.1.64/s', 'edge_agent_id': 'a1'});
  });

  testWidgets('регистратор: после создания адреса показаны один раз, назад к форме нельзя', (tester) async {
    final api = FakeApi();
    await pumpScreen(tester, api, const AddCameraScreen());
    await chooseMode(tester, 'Регистратор отправляет поток');

    await tester.enterText(find.byType(TextField).first, 'Касса');
    await tester.tap(find.text('Получить адрес'));
    await settle(tester);

    expect(api.calls['createCamera']!['mode'], 'push');
    expect(find.text('Рекомендуем'), findsOneWidget);
    expect(find.textContaining('Ключ показываем только один раз'), findsOneWidget);
    expect(find.text('Ждём видео'), findsOneWidget);
    expect(find.text('Как назвать камеру?'), findsNothing);
  });

  testWidgets('нет блоков — сначала установка блока с командой', (tester) async {
    final api = FakeApi();
    await pumpScreen(tester, api, const AddCameraScreen());
    await chooseMode(tester, 'Камеры только в нашей сети');

    expect(find.text('Установите блок в вашей сети'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Склад — ПК охраны');
    await tester.tap(find.text('Получить команду'));
    await settle(tester);

    expect(api.calls['createEdgeAgent']!['name'], 'Склад — ПК охраны');
    expect(find.text('Команда установки'), findsOneWidget);
    expect(find.text('Ждём, когда блок выйдет на связь'), findsOneWidget);
    // Пока блок не на связи, «Далее» не ведёт дальше.
    await tester.tap(find.text('Далее'));
    await settle(tester);
    expect(find.text('Установите блок в вашей сети'), findsOneWidget);
  });
}
