import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/expense_model.dart';
import '../data/repositories/expense_repository.dart';
import '../core/constants/app_constants.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repository;

  String? _currentUid;
  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter states
  String? _selectedCategoryFilter;
  DateTime? _selectedDateFilter;
  String _searchQuery = '';

  // App Preference state
  ThemeMode _themeMode = ThemeMode.dark;
  String _selectedCurrency = AppConstants.defaultCurrency;

  StreamSubscription<List<ExpenseModel>>? _expensesSubscription;

  ExpenseProvider({ExpenseRepository? repository})
      : _repository = repository ?? ExpenseRepository();

  // Update authenticated user UID
  void setUserUid(String? uid) {
    if (_currentUid != uid) {
      _currentUid = uid;
      _expenses.clear();
      _initRealtimeStream();
    }
  }

  // Getters
  List<ExpenseModel> get expenses => List.unmodifiable(_expenses);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCategoryFilter => _selectedCategoryFilter;
  DateTime? get selectedDateFilter => _selectedDateFilter;
  String get searchQuery => _searchQuery;
  ThemeMode get themeMode => _themeMode;
  String get selectedCurrency => _selectedCurrency;

  /// Filtered expense list based on category, date, and search term
  List<ExpenseModel> get filteredExpenses {
    return _expenses.where((expense) {
      if (_selectedCategoryFilter != null && _selectedCategoryFilter!.isNotEmpty) {
        if (expense.category.toLowerCase() != _selectedCategoryFilter!.toLowerCase()) {
          return false;
        }
      }

      if (_selectedDateFilter != null) {
        final d1 = expense.date;
        final d2 = _selectedDateFilter!;
        if (d1.year != d2.year || d1.month != d2.month || d1.day != d2.day) {
          return false;
        }
      }

      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final matchesTitle = expense.title.toLowerCase().contains(q);
        final matchesCategory = expense.category.toLowerCase().contains(q);
        final matchesNote = (expense.note ?? '').toLowerCase().contains(q);
        if (!matchesTitle && !matchesCategory && !matchesNote) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Total amount of all loaded expenses
  double get totalExpenses {
    return _expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Total amount for the current month
  double get currentMonthTotal {
    final now = DateTime.now();
    return _expenses.where((e) {
      return e.date.year == now.year && e.date.month == now.month;
    }).fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Total expense count for current month
  int get currentMonthCount {
    final now = DateTime.now();
    return _expenses.where((e) => e.date.year == now.year && e.date.month == now.month).length;
  }

  /// Recent 5 expenses
  List<ExpenseModel> get recentExpenses {
    final sorted = List<ExpenseModel>.from(_expenses)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  /// Category breakdown: map of category name to total spent
  Map<String, double> get categoryBreakdown {
    final Map<String, double> breakdown = {};
    for (final expense in _expenses) {
      breakdown[expense.category] = (breakdown[expense.category] ?? 0.0) + expense.amount;
    }
    return breakdown;
  }

  /// Daily expenses summary for current month
  Map<int, double> get dailyTotalsForCurrentMonth {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final Map<int, double> totals = {for (int i = 1; i <= daysInMonth; i++) i: 0.0};

    for (final expense in _expenses) {
      if (expense.date.year == now.year && expense.date.month == now.month) {
        totals[expense.date.day] = (totals[expense.date.day] ?? 0.0) + expense.amount;
      }
    }
    return totals;
  }

  // Real-time stream initialization
  void _initRealtimeStream() {
    _expensesSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    try {
      _expensesSubscription = _repository.getExpensesStream(uid: _currentUid).listen(
        (data) {
          if (data.isEmpty && _expenses.isEmpty) {
            _populateInitialSeedDataIfEmpty();
          } else {
            _expenses = data;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          }
        },
        onError: (error) {
          _errorMessage = 'Failed to sync expenses: $error';
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      loadExpenses();
    }
  }

  /// Seed initial demo data if user has no expenses yet
  Future<void> _populateInitialSeedDataIfEmpty() async {
    final seedData = [
      ExpenseModel(
        id: '',
        title: 'Weekly Grocery Shopping',
        amount: 145.50,
        category: 'Food',
        date: DateTime.now().subtract(const Duration(hours: 14)),
        note: 'Supermarket essentials and fruits',
        createdAt: DateTime.now(),
      ),
      ExpenseModel(
        id: '',
        title: 'Monthly Electric Bill',
        amount: 82.30,
        category: 'Bills',
        date: DateTime.now().subtract(const Duration(days: 2)),
        note: 'Utility bill for current month',
        createdAt: DateTime.now(),
      ),
      ExpenseModel(
        id: '',
        title: 'Uber Ride to Office',
        amount: 24.00,
        category: 'Transport',
        date: DateTime.now().subtract(const Duration(days: 3)),
        note: 'Morning commute',
        createdAt: DateTime.now(),
      ),
      ExpenseModel(
        id: '',
        title: 'Cinema & Snacks',
        amount: 38.00,
        category: 'Entertainment',
        date: DateTime.now().subtract(const Duration(days: 5)),
        note: 'Weekend movie with friends',
        createdAt: DateTime.now(),
      ),
    ];

    for (final item in seedData) {
      await _repository.addExpense(item, uid: _currentUid);
    }
    loadExpenses();
  }

  /// Load expenses manually
  Future<void> loadExpenses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _expenses = await _repository.getExpenses(uid: _currentUid);
    } catch (e) {
      _errorMessage = 'Could not load expenses. Please check network connection.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add new expense
  Future<bool> addExpense({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newExpense = ExpenseModel(
        id: '',
        title: title.trim(),
        amount: amount,
        category: category,
        date: date,
        note: note?.trim(),
        createdAt: DateTime.now(),
      );

      final created = await _repository.addExpense(newExpense, uid: _currentUid);
      if (!_expenses.any((e) => e.id == created.id)) {
        _expenses.insert(0, created);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add expense: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update expense
  Future<bool> updateExpense(ExpenseModel updatedExpense) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateExpense(updatedExpense, uid: _currentUid);
      final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update expense: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete expense
  Future<bool> deleteExpense(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteExpense(id, uid: _currentUid);
      _expenses.removeWhere((e) => e.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete expense: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Filter methods
  void setCategoryFilter(String? category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  void setDateFilter(DateTime? date) {
    _selectedDateFilter = date;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategoryFilter = null;
    _selectedDateFilter = null;
    _searchQuery = '';
    notifyListeners();
  }

  // Settings preferences
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setCurrency(String currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  @override
  void dispose() {
    _expensesSubscription?.cancel();
    super.dispose();
  }
}
