import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();
  
  List<Expense> _expenses = [];
  Map<String, double> _categoryTotals = {};
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  Map<String, double> get categoryTotals => _categoryTotals;
  bool get isLoading => _isLoading;
  
  double get totalExpenses => _expenses.fold(0.0, (sum, expense) => sum + expense.amount);

  // Add expense
  Future<void> addExpense({
    required String userId,
    required String category,
    required double amount,
    required String description,
    required DateTime date,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        category: category,
        amount: amount,
        description: description,
        date: date,
        createdAt: DateTime.now(),
      );

      await _expenseService.addExpense(expense);
      await loadUserExpenses(userId);
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user expenses
  Future<void> loadUserExpenses(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _expenses = await _expenseService.getUserExpenses(userId);
      _categoryTotals = await _expenseService.getExpensesByCategory(userId);
    } catch (e) {
      print('Error loading expenses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete expense
  Future<void> deleteExpense(String expenseId, String userId) async {
    try {
      await _expenseService.deleteExpense(expenseId);
      await loadUserExpenses(userId);
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }
}
