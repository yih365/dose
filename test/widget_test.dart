import 'package:flutter_test/flutter_test.dart';
import 'package:dose/main.dart';

void main() {
  testWidgets('App renders home shell', (WidgetTester tester) async {
    await tester.pumpWidget(const DoseApp());
    await tester.pumpAndSettle();
    expect(find.byType(HomeShell), findsOneWidget);
  });
}
