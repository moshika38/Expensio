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

  // Month Selection State
  DateTime _selectedMonth = DateTime.now();
  bool _isAllTimeFilter = false;
  int _selectedTabIndex = 0;

  // App Preference state
  ThemeMode _themeMode = ThemeMode.dark;
  String _selectedCurrency = AppConstants.defaultCurrency;

  bool _hasAttemptedSeed = false;
  StreamSubscription<List<ExpenseModel>>? _expensesSubscription;

  ExpenseProvider({ExpenseRepository? repository})
      : _repository = repository ?? ExpenseRepository();

  // Update authenticated user UID
  void setUserUid(String? uid) {
    if (_currentUid != uid) {
      _currentUid = uid;
      _expenses.clear();
      _hasAttemptedSeed = false;
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
  DateTime get selectedMonth => _selectedMonth;
  bool get isAllTimeFilter => _isAllTimeFilter;
  int get selectedTabIndex => _selectedTabIndex;

  void setSelectedTabIndex(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month, 1);
    _isAllTimeFilter = false;
    notifyListeners();
  }

  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    _isAllTimeFilter = false;
    notifyListeners();
  }

  void nextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    _isAllTimeFilter = false;
    notifyListeners();
  }

  void toggleAllTime() {
    _isAllTimeFilter = !_isAllTimeFilter;
    notifyListeners();
  }

  /// Filtered expense list based on selected month, category, date, and search term
  List<ExpenseModel> get filteredExpenses {
    return _expenses.where((expense) {
      if (!_isAllTimeFilter) {
        if (expense.date.year != _selectedMonth.year ||
            expense.date.month != _selectedMonth.month) {
          return false;
        }
      }

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

  /// Total amount for the selected month (or overall if all-time)
  double get currentMonthTotal {
    if (_isAllTimeFilter) return totalExpenses;
    return _expenses.where((e) {
      return e.date.year == _selectedMonth.year && e.date.month == _selectedMonth.month;
    }).fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Total expense count for selected month
  int get currentMonthCount {
    if (_isAllTimeFilter) return _expenses.length;
    return _expenses.where((e) => e.date.year == _selectedMonth.year && e.date.month == _selectedMonth.month).length;
  }

  /// Recent 5 expenses (respecting active month selection if not all-time)
  List<ExpenseModel> get recentExpenses {
    final sourceList = _isAllTimeFilter
        ? _expenses
        : _expenses.where((e) => e.date.year == _selectedMonth.year && e.date.month == _selectedMonth.month).toList();
    final sorted = List<ExpenseModel>.from(sourceList)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  /// Category breakdown: map of category name to total spent for selected month
  Map<String, double> get categoryBreakdown {
    final Map<String, double> breakdown = {};
    final targetList = _isAllTimeFilter
        ? _expenses
        : _expenses.where((e) => e.date.year == _selectedMonth.year && e.date.month == _selectedMonth.month);
    for (final expense in targetList) {
      breakdown[expense.category] = (breakdown[expense.category] ?? 0.0) + expense.amount;
    }
    return breakdown;
  }

  /// Daily expenses summary for selected month
  Map<int, double> get dailyTotalsForCurrentMonth {
    final daysInMonth = DateUtils.getDaysInMonth(_selectedMonth.year, _selectedMonth.month);
    final Map<int, double> totals = {for (int i = 1; i <= daysInMonth; i++) i: 0.0};

    for (final expense in _expenses) {
      if (expense.date.year == _selectedMonth.year && expense.date.month == _selectedMonth.month) {
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
          if (data.isEmpty && _expenses.isEmpty && !_hasAttemptedSeed) {
            _hasAttemptedSeed = true;
            _populateInitialSeedDataIfEmpty();
          } else {
            _expenses = List<ExpenseModel>.from(data);
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          }
        },
        onError: (error) async {
          debugPrint('Firestore stream error (falling back to local cache): $error');
          await loadExpenses();
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
      final fetched = await _repository.getExpenses(uid: _currentUid);
      _expenses = List<ExpenseModel>.from(fetched);
    } catch (e) {
      debugPrint('Expense load note: $e');
      if (_expenses.isEmpty && !_hasAttemptedSeed) {
        _hasAttemptedSeed = true;
        _populateInitialSeedDataIfEmpty();
      }
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
      final updatedList = List<ExpenseModel>.from(_expenses);
      if (!updatedList.any((e) => e.id == created.id)) {
        updatedList.insert(0, created);
      }
      _expenses = updatedList;
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
      final updatedList = List<ExpenseModel>.from(_expenses);
      if (index != -1) {
        updatedList[index] = updatedExpense;
      }
      _expenses = updatedList;
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
      final updatedList = List<ExpenseModel>.from(_expenses)..removeWhere((e) => e.id == id);
      _expenses = updatedList;
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
