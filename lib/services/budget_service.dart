import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_model.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or update budget
  Future<void> setBudget(Budget budget) async {
    try {
      await _firestore
          .collection('budgets')
          .doc(budget.userId)
          .set(budget.toMap());
    } catch (e) {
      throw Exception('Failed to set budget: $e');
    }
  }

  // Get user budget
  Future<Budget?> getUserBudget(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('budgets')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        return Budget.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get budget: $e');
    }
  }

  // Update withdrawal amount
  Future<void> updateWithdrawal(String userId, double withdrawalAmount) async {
    try {
      DocumentReference budgetRef = _firestore.collection('budgets').doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(budgetRef);
        
        if (snapshot.exists) {
          Budget currentBudget = Budget.fromMap(snapshot.data() as Map<String, dynamic>);
          double newTotalWithdrawn = currentBudget.totalWithdrawn + withdrawalAmount;
          
          transaction.update(budgetRef, {
            'totalWithdrawn': newTotalWithdrawn,
            'updatedAt': DateTime.now().toIso8601String(),
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to update withdrawal: $e');
    }
  }
}
