import 'package:flutter_test/flutter_test.dart';
import 'package:expensio/data/models/expense_model.dart';
import 'package:expensio/data/services/expense_service.dart';
import 'package:expensio/data/repositories/expense_repository.dart';
import 'package:expensio/providers/expense_provider.dart';

class MockExpenseService extends ExpenseService {
  final List<ExpenseModel> _storage = [];

  @override
  Future<List<ExpenseModel>> fetchExpenses({String? uid}) async {
    return List.from(_storage);
  }

  @override
  Stream<List<ExpenseModel>> streamExpenses({String? uid}) async* {
    yield List.from(_storage);
  }

  @override
  Future<String> addExpense(ExpenseModel expense, {String? uid}) async {
    final id = 'test_${_storage.length + 1}';
    final saved = expense.copyWith(id: id);
    _storage.insert(0, saved);
    return id;
  }

  @override
  Future<void> updateExpense(ExpenseModel expense, {String? uid}) async {
    final index = _storage.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _storage[index] = expense;
    }
  }

  @override
  Future<void> deleteExpense(String id, {String? uid}) async {
    _storage.removeWhere((e) => e.id == id);
  }
}

void main() {
  group('ExpenseProvider State Management Tests', () {
    late ExpenseProvider provider;

    setUp(() {
      final repository = ExpenseRepository(expenseService: MockExpenseService());
      provider = ExpenseProvider(repository: repository);
    });

    test('addExpense updates list immediately and triggers listener', () async {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      final success = await provider.addExpense(
        title: 'New Lunch',
        amount: 25.0,
        category: 'Food',
        date: DateTime.now(),
      );

      expect(success, isTrue);
      expect(provider.expenses.length, equals(1));
      expect(provider.expenses.first.title, equals('New Lunch'));
      expect(notifyCount, greaterThan(0));
    });

    test('updateExpense modifies existing item immediately', () async {
      await provider.addExpense(
        title: 'Old Title',
        amount: 50.0,
        category: 'Bills',
        date: DateTime.now(),
      );

      final original = provider.expenses.first;
      final updatedItem = original.copyWith(title: 'Updated Title', amount: 75.0);

      final success = await provider.updateExpense(updatedItem);

      expect(success, isTrue);
      expect(provider.expenses.first.title, equals('Updated Title'));
      expect(provider.expenses.first.amount, equals(75.0));
    });

    test('deleteExpense removes item immediately', () async {
      await provider.addExpense(
        title: 'To Delete',
        amount: 100.0,
        category: 'Shopping',
        date: DateTime.now(),
      );

      final targetId = provider.expenses.first.id;
      expect(provider.expenses.any((e) => e.id == targetId), isTrue);

      final success = await provider.deleteExpense(targetId);

      expect(success, isTrue);
      expect(provider.expenses.any((e) => e.id == targetId), isFalse);
    });
  });
}
