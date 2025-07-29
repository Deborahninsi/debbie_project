import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../services/analytics_service.dart';

class RefreshService {
  static Future<void> refreshAllData(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    
    if (authProvider.user == null) return;

    try {
      // Refresh user data
      await authProvider.updateUserData({});
      
      // Refresh expenses
      await expenseProvider.loadUserExpenses(authProvider.user!.uid);
      
      // You can add more refresh operations here
      
    } catch (e) {
      throw Exception('Failed to refresh data: $e');
    }
  }

  static Future<void> refreshExpenseData(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    
    if (authProvider.user == null) return;

    await expenseProvider.loadUserExpenses(authProvider.user!.uid);
  }

  static Future<void> refreshUserProfile(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.user == null) return;

    await authProvider.updateUserData({});
  }
}
