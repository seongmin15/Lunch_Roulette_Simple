import 'package:flutter_test/flutter_test.dart';
import 'package:lunch_roulette_app/app/app.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('점심 룰렛'), findsOneWidget);
  });
}
