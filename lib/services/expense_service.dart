import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add expense
  Future<void> addExpense(Expense expense) async {
    try {
      await _firestore
          .collection('expenses')
          .doc(expense.id)
          .set(expense.toMap());
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
  }

  // Get user expenses
  Future<List<Expense>> getUserExpenses(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Expense.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get expenses: $e');
    }
  }

  // Get expenses by category
  Future<Map<String, double>> getExpensesByCategory(String userId) async {
    try {
      List<Expense> expenses = await getUserExpenses(userId);
      Map<String, double> categoryTotals = {};

      for (var expense in expenses) {
        categoryTotals[expense.category] = 
            (categoryTotals[expense.category] ?? 0) + expense.amount;
      }

      return categoryTotals;
    } catch (e) {
      throw Exception('Failed to get expenses by category: $e');
    }
  }

  // Delete expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _firestore.collection('expenses').doc(expenseId).delete();
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }
}
