import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pg_ecowaste/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pg_ecowaste/widgets/eco_bottom_nav.dart';
import 'package:pg_ecowaste/widgets/eco_responsive_body.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('EcoPlamo App responsiveness test - Normal Mobile', (
    tester,
  ) async {
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

  testWidgets('EcoPlamo App responsiveness test - Tablet / Desktop', (
    tester,
  ) async {
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

  testWidgets('EcoPlamo App responsiveness test - Landscape Mobile', (
    tester,
  ) async {
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

  testWidgets('Main navigation adapts to tablet layout', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var selectedIndex = -1;
    var scanTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EcoResponsiveBody(
            currentIndex: 0,
            onTap: (index) => selectedIndex = index,
            onScanTap: () => scanTapped = true,
            child: const Center(child: Text('Responsive content')),
          ),
          bottomNavigationBar: EcoBottomNavBar(
            currentIndex: 0,
            onTap: (index) => selectedIndex = index,
          ),
        ),
      ),
    );

    expect(find.text('Responsive content'), findsOneWidget);
    expect(find.byTooltip('Home'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    await tester.tap(find.byTooltip('Info'));
    expect(selectedIndex, 3);
    await tester.tap(find.byTooltip('Scan & QR'));
    expect(scanTapped, isTrue);
  });
}
