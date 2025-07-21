import 'package:flutter/material.dart';

class BudgetProvider extends ChangeNotifier {
  double _monthlyBudget = 0.0;
  double _totalExpenses = 0.0;
  double _totalWithdrawn = 0.0;

  double get monthlyBudget => _monthlyBudget;
  double get totalExpenses => _totalExpenses;
  double get totalWithdrawn => _totalWithdrawn;

  // Balance is budget minus withdrawn amount
  double get balance => _monthlyBudget - _totalWithdrawn;

  void setBudget(double amount) {
    _monthlyBudget = amount;
    notifyListeners();
  }

  void addExpense(double amount) {
    _totalExpenses += amount;
    notifyListeners();
  }

  void withdraw(double amount) {
    if (amount <= balance) {
      _totalWithdrawn += amount;
      notifyListeners();
    }
  }

  void reset() {
    _monthlyBudget = 0.0;
    _totalExpenses = 0.0;
    _totalWithdrawn = 0.0;
    notifyListeners();
  }
}
