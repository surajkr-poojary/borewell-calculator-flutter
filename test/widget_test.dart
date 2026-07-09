import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:borewell_bill_calculator/main.dart';

// Note: pumpAndSettle() is avoided here because the initial loading state
// briefly shows an indeterminate CircularProgressIndicator, whose repeating
// animation never lets pumpAndSettle's frame-scheduling check settle.
Future<void> _pumpUntilLoaded(WidgetTester tester) async {
  // Tall surface so the whole form (depth field + 4 slab cards + buttons)
  // renders without needing to scroll the lazy ListView.
  await tester.binding.setSurfaceSize(const Size(400, 2000));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(const BorewellBillCalculatorApp());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Home screen loads with title, depth field, and slabs',
      (WidgetTester tester) async {
    await _pumpUntilLoaded(tester);

    expect(find.text('Borewell Bill Calculator'), findsWidgets);
    expect(find.text('Total Depth (Feet)'), findsOneWidget);
    expect(find.text('0 - 200 ft'), findsOneWidget);
    expect(find.text('Calculate Bill'), findsOneWidget);
  });

  testWidgets('Calculating with an empty depth shows a validation error',
      (WidgetTester tester) async {
    await _pumpUntilLoaded(tester);

    await tester.tap(find.text('Calculate Bill'));
    await tester.pump();

    expect(find.text('Please enter borewell depth.'), findsOneWidget);
  });

  testWidgets('Calculating 450 ft produces the expected total',
      (WidgetTester tester) async {
    await _pumpUntilLoaded(tester);

    await tester.enterText(find.byType(TextField).first, '450');
    await tester.tap(find.text('Calculate Bill'));
    await tester.pump();

    expect(find.text('₹1,50,000'), findsOneWidget);
  });

  testWidgets('Calculating 680 ft matches the spec worked example',
      (WidgetTester tester) async {
    await _pumpUntilLoaded(tester);

    await tester.enterText(find.byType(TextField).first, '680');
    await tester.tap(find.text('Calculate Bill'));
    await tester.pump();

    expect(find.text('601 - 680 ft'), findsOneWidget);
    expect(find.text('₹2,46,000'), findsOneWidget);
  });

  testWidgets('Settings screen opens and saves new default rates',
      (WidgetTester tester) async {
    await _pumpUntilLoaded(tester);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Edit Default Rates'), findsOneWidget);

    // The old route stays mounted (offstage) during/after the push
    // transition, so scope the finder to the visible "0 - 200 ft" field
    // by its label instead of relying on tree order via `.first`.
    await tester.enterText(
        find.widgetWithText(TextField, '0 - 200 ft'), '320');
    await tester.tap(find.text('Save'));
    // Safe to settle here (unlike the initial load): no indeterminate
    // spinner remains, just the page-pop transition animation finishing.
    await tester.pumpAndSettle();

    // Back on the home screen, the new (non-preset) default rate should
    // now show as a custom amount on the first slab.
    expect(find.text('Edit Default Rates'), findsNothing);
    expect(find.text('Custom Rate'), findsOneWidget);
    expect(find.text('320'), findsOneWidget);
  });
}
