import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/savings_model.dart';

class SavingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or update savings
  Future<void> updateSavings(Savings savings) async {
    try {
      await _firestore
          .collection('savings')
          .doc(savings.userId)
          .set(savings.toMap());
    } catch (e) {
      throw Exception('Failed to update savings: $e');
    }
  }

  // Get user savings
  Future<Savings?> getUserSavings(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('savings')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        return Savings.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get savings: $e');
    }
  }

  // Add to savings
  Future<void> addToSavings(String userId, double amount) async {
    try {
      DocumentReference savingsRef = _firestore.collection('savings').doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(savingsRef);
        
        if (snapshot.exists) {
          Savings currentSavings = Savings.fromMap(snapshot.data() as Map<String, dynamic>);
          double newTotalSaved = currentSavings.totalSaved + amount;
          double newAvailableForSpending = currentSavings.availableForSpending + amount;
          
          transaction.update(savingsRef, {
            'totalSaved': newTotalSaved,
            'availableForSpending': newAvailableForSpending,
            'updatedAt': DateTime.now().toIso8601String(),
          });
        } else {
          // Create new savings record
          Savings newSavings = Savings(
            id: userId,
            userId: userId,
            totalSaved: amount,
            availableForSpending: amount,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          transaction.set(savingsRef, newSavings.toMap());
        }
      });
    } catch (e) {
      throw Exception('Failed to add to savings: $e');
    }
  }

  // Spend from savings
  Future<void> spendFromSavings(String userId, double amount) async {
    try {
      DocumentReference savingsRef = _firestore.collection('savings').doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(savingsRef);
        
        if (snapshot.exists) {
          Savings currentSavings = Savings.fromMap(snapshot.data() as Map<String, dynamic>);
          
          if (currentSavings.availableForSpending >= amount) {
            double newAvailableForSpending = currentSavings.availableForSpending - amount;
            
            transaction.update(savingsRef, {
              'availableForSpending': newAvailableForSpending,
              'updatedAt': DateTime.now().toIso8601String(),
            });
          } else {
            throw Exception('Insufficient savings balance');
          }
        }
      });
    } catch (e) {
      throw Exception('Failed to spend from savings: $e');
    }
  }
}
