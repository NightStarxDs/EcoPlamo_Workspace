import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pg_ecowaste/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('EcoPlamo App responsiveness test - Normal Mobile', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EcoPlamoApp(initialRoute: '/login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Eco Plamo'), findsWidgets);
    expect(find.text('Masuk'), findsWidgets);
    expect(find.text('Nomor WhatsApp / Username'), findsOneWidget);
  });


  testWidgets('EcoPlamo App responsiveness test - Tablet / Desktop', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EcoPlamoApp(initialRoute: '/login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Eco Plamo'), findsWidgets);
    expect(find.text('Masuk'), findsWidgets);
    expect(find.text('Nomor WhatsApp / Username'), findsOneWidget);
  });

  testWidgets('EcoPlamo App responsiveness test - Small Phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EcoPlamoApp(initialRoute: '/login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Eco Plamo'), findsWidgets);
    expect(find.text('Masuk'), findsWidgets);
  });

  testWidgets('EcoPlamo App responsiveness test - Landscape Mobile', (tester) async {
    tester.view.physicalSize = const Size(800, 400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EcoPlamoApp(initialRoute: '/login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Eco Plamo'), findsWidgets);
    expect(find.text('Masuk'), findsWidgets);
  });
}
