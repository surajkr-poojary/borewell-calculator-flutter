import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:borewell_bill_calculator/main.dart';
import 'package:borewell_bill_calculator/widgets/rate_picker_field.dart';

// Note: pumpAndSettle() is avoided throughout this file because the app
// bar's wave animation (WaveAppBarBottom) repeats indefinitely on every
// screen, so pumpAndSettle's frame-scheduling check never converges.
// Fixed-duration pumps are used instead.
//
// A realistic (not artificially tall) surface size is used, and elements
// are explicitly scrolled into view before tapping — modal bottom sheets
// anchor to the bottom of the actual viewport, and an oversized surface
// was pushing their content past the sheet's own bounds.
Future<void> _pumpUntilLoaded(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(400, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(const BorewellBillCalculatorApp());
  await tester.pump();
  // App starts on SplashScreen, which holds for a minimum 1400ms before
  // fading into HomeScreen over another 500ms transition.
  await tester.pump(const Duration(milliseconds: 1500));
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump(const Duration(milliseconds: 300));
}

/// Scrolls [finder] into view. Results render below the fold and a plain
/// ListView only builds what's within the visible + cache extent, so the
/// widget may not even exist yet — `scrollUntilVisible` drags the
/// Scrollable step by step until it does, unlike `ensureVisible` which
/// requires the element to already be built. `scrollUntilVisible` only
/// drags in one fixed direction though, so a prior call that scrolled
/// forward (e.g. down to the Calculate button) would strand a target that
/// sits earlier in the list (e.g. a field's error text) — resetting to the
/// top first makes every call search forward from the same starting point.
///
/// Each TextField has its own internal Scrollable too (for cursor
/// visibility), so a plain `find.byType(Scrollable)` is ambiguous once any
/// TextField is on screen — `.first` picks out the outer list's Scrollable,
/// which is built (and thus found) before the nested per-field ones.
Future<void> _scrollIntoView(WidgetTester tester, Finder finder) async {
  final scrollable = find.byType(Scrollable).first;
  await tester.drag(scrollable, const Offset(0, 5000));
  await tester.pump();
  await tester.scrollUntilVisible(finder, 200, scrollable: scrollable);
  await tester.pump();
}

/// Scrolls [finder] into view and taps it.
Future<void> _tap(WidgetTester tester, Finder finder) async {
  await _scrollIntoView(tester, finder);
  await tester.tap(finder);
}

/// Scrolls [finder] into view and enters [text] into it.
Future<void> _enterText(WidgetTester tester, Finder finder, String text) async {
  await _scrollIntoView(tester, finder);
  await tester.enterText(finder, text);
}

/// Scrolls [finder] into view and asserts exactly one match.
Future<void> _expectVisible(WidgetTester tester, Finder finder) async {
  await _scrollIntoView(tester, finder);
  expect(finder, findsOneWidget);
}

/// Opens the bottom sheet for the [fieldFinder] rate picker (tapped via its
/// widget, not its floating label text — the label's shrink transform can
/// throw off tap-offset hit-testing), taps the option matching
/// [optionText], then pumps past the sheet's open/close animations.
Future<void> _pickRate(WidgetTester tester, Finder fieldFinder, String optionText) async {
  await _tap(tester, fieldFinder);

  // Poll until the option's on-screen position stops moving (rather than
  // guessing a fixed delay) — tapping while the sheet's open animation is
  // still sliding computes a coordinate that's stale by the time the tap
  // actually lands, which can hit the wrong (adjacent) list tile.
  final optionFinder = find.text(optionText);
  Rect? previousRect;
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    final rect = tester.getRect(optionFinder);
    if (previousRect == rect) break;
    previousRect = rect;
  }

  await tester.tap(optionFinder);
  // Let the sheet's close animation fully finish before the caller does
  // anything else — a still-closing sheet's barrier can eat the next tap.
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
      'Home screen loads with title, depth field, drilling and casing sections',
      (WidgetTester tester) async {
    await _pumpUntilLoaded(tester);

    expect(find.text('Borewell Bill Calculator'), findsWidgets);
    expect(find.text('TOTAL DEPTH'), findsOneWidget);
    expect(find.text('Drilling Rate'), findsOneWidget);
    expect(find.text('Casing'), findsOneWidget);

    final calculateButton = find.text('Calculate Bill');
    await _scrollIntoView(tester, calculateButton);
    expect(calculateButton, findsOneWidget);
  });

  testWidgets('Calculating with an empty depth shows a validation error',
      (WidgetTester tester) async {
    await _pumpUntilLoaded(tester);

    await _tap(tester, find.text('Calculate Bill'));
    await tester.pump();

    expect(find.text('Please enter borewell depth.'), findsOneWidget);
  });

  testWidgets(
      'Calculating 450 ft at the default base rate produces the expected total',
      (WidgetTester tester) async {
    await _pumpUntilLoaded(tester);

    // 0-300ft: 300x100=30000, 300-350: 50x105=5250, 350-400: 50x110=5500,
    // 400-450: 50x115=5750 => drilling 46500 + fixed charges 1400 = 47900.
    await _enterText(tester, find.byType(TextField).first, '450');
    await _tap(tester, find.text('Calculate Bill'));
    await tester.pump();

    await _expectVisible(tester, find.text('COLLAR'));
    await _expectVisible(tester, find.text('₹47,900'));
  });

  testWidgets('Calculating 850 ft continues past 700ft at the capped rate',
      (WidgetTester tester) async {
    await _pumpUntilLoaded(tester);

    await _enterText(tester, find.byType(TextField).first, '850');
    await _tap(tester, find.text('Calculate Bill'));
    await tester.pump();

    await _expectVisible(tester, find.text('701 ft and above'));
    await _expectVisible(tester, find.text('₹1,07,900'));
  });

  testWidgets('Selecting a different base drilling rate changes the total',
      (WidgetTester tester) async {
    await _pumpUntilLoaded(tester);

    await _pickRate(tester, find.byType(RatePickerField).first, '₹120 / ft');

    // 0-300ft billed entirely in the base band: 300 x 120 = 36000,
    // + fixed charges 1400 = 37400.
    await _enterText(tester, find.byType(TextField).first, '300');
    await _tap(tester, find.text('Calculate Bill'));
    await tester.pump();

    await _expectVisible(tester, find.text('₹37,400'));
  });

  testWidgets(
      'Casing feet without a selected casing rate is rejected, then succeeds once picked',
      (WidgetTester tester) async {
    await _pumpUntilLoaded(tester);

    await _enterText(tester, find.byType(TextField).first, '300');
    await _enterText(tester, find.byType(TextField).at(1), '50');
    await _tap(tester, find.text('Calculate Bill'));
    await tester.pump();

    await _expectVisible(tester, find.text('Please select a casing rate.'));

    await _pickRate(tester, find.byType(RatePickerField).at(1), '₹500 / ft');
    await _tap(tester, find.text('Calculate Bill'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Drilling 300x100=30000 + casing 50x500=25000 + fixed 1400 = 56400.
    await _expectVisible(tester, find.text('Casing (GI)'));
    await _expectVisible(tester, find.text('₹56,400'));
  });

  testWidgets('Settings screen edits a fixed charge and it reflects on the next bill',
      (WidgetTester tester) async {
    await _pumpUntilLoaded(tester);

    await _tap(tester, find.byIcon(Icons.settings_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Edit Fixed Charges'), findsOneWidget);

    await _enterText(tester, find.widgetWithText(TextField, 'Collar'), '700');
    await _tap(tester, find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Edit Fixed Charges'), findsNothing);

    await _enterText(tester, find.byType(TextField).first, '10');
    await _tap(tester, find.text('Calculate Bill'));
    await tester.pump();

    // Drilling 10x100=1000 + collar 700 + welding/cutting/cap 300 each = 2600.
    await _expectVisible(tester, find.text('₹700'));
    await _expectVisible(tester, find.text('₹2,600'));
  });
}
