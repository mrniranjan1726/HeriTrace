import 'package:flutter_test/flutter_test.dart';
import 'package:heritrace/app.dart';

void main() {
  testWidgets('HeriTrace app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const HeriTraceApp());

    expect(find.byType(HeriTraceApp), findsOneWidget);
  });
}
