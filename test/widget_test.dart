// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'package:flutter_test/flutter_test.dart';
import 'package:nova_clock/main.dart';
import 'package:nova_clock/widgets/analog_clock.dart';
import 'package:nova_clock/widgets/digital_clock.dart';

void main() {
  testWidgets('Renders clocks on HomeScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the clocks are present.
    expect(find.byType(AnalogClock), findsOneWidget);
    expect(find.byType(DigitalClock), findsOneWidget);
  });
}
