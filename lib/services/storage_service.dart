import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_item.dart';
import '../models/category_item.dart';
import '../models/budget_goal.dart';

class StorageService {
  static const _transactionsKey = 'app_transactions_data';
  static const _categoriesKey = 'app_categories_data';
  static const _budgetGoalsKey = 'app_budget_goals_data';

  Future<List<TransactionItem>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_transactionsKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list
          .map((item) => TransactionItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTransactions(List<TransactionItem> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final list = transactions.map((t) => t.toJson()).toList();
    await prefs.setString(_transactionsKey, jsonEncode(list));
  }

  Future<List<CategoryItem>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_categoriesKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      // Return defaults
      return [
        ...CategoryItem.defaultExpenseCategories,
        ...CategoryItem.defaultIncomeCategories,
      ];
    }

    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list
          .map((item) => CategoryItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [
        ...CategoryItem.defaultExpenseCategories,
        ...CategoryItem.defaultIncomeCategories,
      ];
    }
  }

  Future<void> saveCategories(List<CategoryItem> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final list = categories.map((c) => c.toJson()).toList();
    await prefs.setString(_categoriesKey, jsonEncode(list));
  }

  Future<List<BudgetGoal>> loadBudgetGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_budgetGoalsKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list
          .map((item) => BudgetGoal.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveBudgetGoals(List<BudgetGoal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final list = goals.map((g) => g.toJson()).toList();
    await prefs.setString(_budgetGoalsKey, jsonEncode(list));
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_transactionsKey);
    await prefs.remove(_categoriesKey);
    await prefs.remove(_budgetGoalsKey);
  }
}
