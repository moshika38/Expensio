import 'package:flutter_test/flutter_test.dart';
import 'package:expensio/data/models/expense_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Sanity check widget binding', () {
    final expense = ExpenseModel(
      id: '1',
      title: 'Test',
      amount: 10.0,
      category: 'Food',
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );
    expect(expense.title, equals('Test'));
  });
}
