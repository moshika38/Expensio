import 'package:flutter_test/flutter_test.dart';
import 'package:expensio/data/models/expense_model.dart';

void main() {
  group('ExpenseModel Unit Tests', () {
    test('toMap and fromMap conversion works accurately', () {
      final now = DateTime.now();
      final expense = ExpenseModel(
        id: 'test_123',
        title: 'Dinner at Italian Restaurant',
        amount: 85.50,
        category: 'Food',
        date: now,
        note: 'Pasta and Wine',
        createdAt: now,
      );

      final map = expense.toMap();
      expect(map['title'], equals('Dinner at Italian Restaurant'));
      expect(map['amount'], equals(85.50));
      expect(map['category'], equals('Food'));
      expect(map['note'], equals('Pasta and Wine'));

      final restored = ExpenseModel.fromMap(map, 'test_123');
      expect(restored.id, equals('test_123'));
      expect(restored.title, equals('Dinner at Italian Restaurant'));
      expect(restored.amount, equals(85.50));
      expect(restored.category, equals('Food'));
    });

    test('copyWith produces updated instance correctly', () {
      final now = DateTime.now();
      final original = ExpenseModel(
        id: '1',
        title: 'Original Title',
        amount: 10.0,
        category: 'Shopping',
        date: now,
        createdAt: now,
      );

      final updated = original.copyWith(amount: 45.0, title: 'Updated Title');
      expect(updated.id, equals('1'));
      expect(updated.title, equals('Updated Title'));
      expect(updated.amount, equals(45.0));
      expect(updated.category, equals('Shopping'));
    });
  });
}
