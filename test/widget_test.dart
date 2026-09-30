import 'package:flutter_test/flutter_test.dart';
import 'package:expensio/app/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ExpensioApp builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpensioApp());
    expect(find.byType(ExpensioApp), findsOneWidget);
  });
}
