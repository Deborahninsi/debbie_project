import 'package:flutter/material.dart';

class BudgetProvider extends ChangeNotifier {
  double _monthlyBudget = 0.0;
  double _totalExpenses = 0.0;
  double _totalWithdrawn = 0.0;
  String? _lastTransactionDescription;

  double get monthlyBudget => _monthlyBudget;

  double get totalExpenses => _totalExpenses;

  double get totalWithdrawn => _totalWithdrawn;

  // Available balance = budget minus withdrawn amount
  double get availableBalance => _monthlyBudget - _totalWithdrawn;

  String? get lastTransaction => _lastTransactionDescription;

  void setBudget(double amount) {
    _monthlyBudget = amount;
    notifyListeners();
  }

  void addExpense(double amount, {String? description}) {
    _totalExpenses += amount;
    if (description != null && description.isNotEmpty) {
      _lastTransactionDescription = description;
    }
    notifyListeners();
  }

  void withdraw(double amount, {String? description}) {
    if (amount <= availableBalance) {
      _totalWithdrawn += amount;
      if (description != null && description.isNotEmpty) {
        _lastTransactionDescription = description;
      }
      notifyListeners();
    }
  }

  void reset() {
    _monthlyBudget = 0.0;
    _totalExpenses = 0.0;
    _totalWithdrawn = 0.0;
    _lastTransactionDescription = null;
    notifyListeners();
  }
}
