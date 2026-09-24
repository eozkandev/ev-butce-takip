import 'package:flutter/foundation.dart';
import '../models/transaction_item.dart';
import '../models/category_item.dart';
import '../models/budget_goal.dart';
import '../services/storage_service.dart';

class BudgetProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<TransactionItem> _transactions = [];
  List<CategoryItem> _categories = [];
  List<BudgetGoal> _budgetGoals = [];
  bool _isLoading = true;

  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  List<TransactionItem> get transactions => _transactions;
  List<CategoryItem> get categories => _categories;
  List<BudgetGoal> get budgetGoals => _budgetGoals;
  bool get isLoading => _isLoading;
  DateTime get selectedMonth => _selectedMonth;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _categories = await _storageService.loadCategories();
    _transactions = await _storageService.loadTransactions();
    _budgetGoals = await _storageService.loadBudgetGoals();

    // If transactions are empty, add friendly welcome demo data so user immediately sees charts
    if (_transactions.isEmpty) {
      _initDemoData();
      await _storageService.saveTransactions(_transactions);
      await _storageService.saveBudgetGoals(_budgetGoals);
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  List<TransactionItem> get currentMonthTransactions {
    return _transactions.where((t) {
      return t.date.year == _selectedMonth.year &&
          t.date.month == _selectedMonth.month;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double get totalIncome {
    return currentMonthTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return currentMonthTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get netBalance => totalIncome - totalExpense;

  double get totalLifetimeBalance {
    final inc = _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final exp = _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    return inc - exp;
  }

  Map<String, double> get categoryExpenseMap {
    final map = <String, double>{};
    for (final t in currentMonthTransactions) {
      if (t.type == TransactionType.expense) {
        map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
      }
    }
    return map;
  }

  CategoryItem? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  BudgetGoal? getGoalForCategory(String categoryId) {
    try {
      return _budgetGoals.firstWhere((g) => g.categoryId == categoryId);
    } catch (_) {
      return null;
    }
  }

  Future<void> addTransaction(TransactionItem transaction) async {
    _transactions.insert(0, transaction);
    await _storageService.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _storageService.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionItem updated) async {
    final index = _transactions.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _transactions[index] = updated;
      await _storageService.saveTransactions(_transactions);
      notifyListeners();
    }
  }

  Future<void> setBudgetGoal(String categoryId, double limit) async {
    _budgetGoals.removeWhere((g) => g.categoryId == categoryId);
    if (limit > 0) {
      _budgetGoals.add(BudgetGoal(categoryId: categoryId, monthlyLimit: limit));
    }
    await _storageService.saveBudgetGoals(_budgetGoals);
    notifyListeners();
  }

  Future<void> clearAll() async {
    _transactions.clear();
    _budgetGoals.clear();
    await _storageService.clearAllData();
    notifyListeners();
  }

  void _initDemoData() {
    final now = DateTime.now();
    _transactions = [
      TransactionItem(
        id: '1',
        title: 'Aylık Maaş',
        amount: 45000,
        date: DateTime(now.year, now.month, 1),
        type: TransactionType.income,
        categoryId: 'inc_salary',
        paymentMethod: PaymentMethod.bankTransfer,
        note: 'Eylül Ayı Maaşı',
      ),
      TransactionItem(
        id: '2',
        title: 'Ev Kirası',
        amount: 15000,
        date: DateTime(now.year, now.month, 2),
        type: TransactionType.expense,
        categoryId: 'exp_rent',
        paymentMethod: PaymentMethod.bankTransfer,
        note: 'Eylül Kira Bedeli',
      ),
      TransactionItem(
        id: '3',
        title: 'Haftalık Market Alışverişi',
        amount: 3250,
        date: DateTime(now.year, now.month, 5),
        type: TransactionType.expense,
        categoryId: 'exp_market',
        paymentMethod: PaymentMethod.creditCard,
      ),
      TransactionItem(
        id: '4',
        title: 'Elektrik & Su Faturası',
        amount: 1120,
        date: DateTime(now.year, now.month, 8),
        type: TransactionType.expense,
        categoryId: 'exp_bills',
        paymentMethod: PaymentMethod.creditCard,
      ),
      TransactionItem(
        id: '5',
        title: 'Araç Yakıt Dolumu',
        amount: 1800,
        date: DateTime(now.year, now.month, 12),
        type: TransactionType.expense,
        categoryId: 'exp_transport',
        paymentMethod: PaymentMethod.creditCard,
      ),
      TransactionItem(
        id: '6',
        title: 'Serbest Proje Geliri',
        amount: 8500,
        date: DateTime(now.year, now.month, 15),
        type: TransactionType.income,
        categoryId: 'inc_freelance',
        paymentMethod: PaymentMethod.bankTransfer,
        note: 'Logo & UI Tasarım Teslimi',
      ),
    ];

    _budgetGoals = [
      BudgetGoal(categoryId: 'exp_market', monthlyLimit: 12000),
      BudgetGoal(categoryId: 'exp_transport', monthlyLimit: 5000),
      BudgetGoal(categoryId: 'exp_bills', monthlyLimit: 3000),
      BudgetGoal(categoryId: 'exp_entertainment', monthlyLimit: 4000),
    ];
  }
}
