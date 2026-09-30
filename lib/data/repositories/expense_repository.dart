import '../models/expense_model.dart';
import '../services/expense_service.dart';

class ExpenseRepository {
  final ExpenseService _expenseService;
  final List<ExpenseModel> _localCache = [];

  ExpenseRepository({ExpenseService? expenseService})
      : _expenseService = expenseService ?? ExpenseService();

  Future<List<ExpenseModel>> getExpenses({String? uid}) async {
    try {
      final items = await _expenseService.fetchExpenses(uid: uid);
      _localCache.clear();
      _localCache.addAll(items);
      return items;
    } catch (e) {
      if (_localCache.isNotEmpty) {
        return List.unmodifiable(_localCache);
      }
      rethrow;
    }
  }

  Stream<List<ExpenseModel>> getExpensesStream({String? uid}) {
    return _expenseService.streamExpenses(uid: uid);
  }

  Future<ExpenseModel> addExpense(ExpenseModel expense, {String? uid}) async {
    try {
      final id = await _expenseService.addExpense(expense, uid: uid);
      final newExpense = expense.copyWith(id: id);
      _localCache.insert(0, newExpense);
      return newExpense;
    } catch (e) {
      final localId = 'local_${DateTime.now().millisecondsSinceEpoch}';
      final newExpense = expense.copyWith(id: localId);
      _localCache.insert(0, newExpense);
      return newExpense;
    }
  }

  Future<void> updateExpense(ExpenseModel expense, {String? uid}) async {
    try {
      await _expenseService.updateExpense(expense, uid: uid);
      final index = _localCache.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _localCache[index] = expense;
      }
    } catch (e) {
      final index = _localCache.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _localCache[index] = expense;
      }
    }
  }

  Future<void> deleteExpense(String id, {String? uid}) async {
    try {
      await _expenseService.deleteExpense(id, uid: uid);
      _localCache.removeWhere((e) => e.id == id);
    } catch (e) {
      _localCache.removeWhere((e) => e.id == id);
    }
  }
}
