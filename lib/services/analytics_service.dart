import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get spending trends by month
  Future<Map<String, double>> getMonthlySpendingTrends(String userId, int months) async {
    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month - months, 1);
      
      QuerySnapshot snapshot = await _firestore
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .orderBy('date')
          .get();

      Map<String, double> monthlyTotals = {};
      
      for (var doc in snapshot.docs) {
        final expense = Expense.fromMap(doc.data() as Map<String, dynamic>);
        final monthKey = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
        monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + expense.amount;
      }

      return monthlyTotals;
    } catch (e) {
      throw Exception('Failed to get monthly trends: $e');
    }
  }

  // Get category spending analysis
  Future<Map<String, Map<String, dynamic>>> getCategoryAnalysis(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .get();

      Map<String, Map<String, dynamic>> categoryData = {};
      
      for (var doc in snapshot.docs) {
        final expense = Expense.fromMap(doc.data() as Map<String, dynamic>);
        
        if (!categoryData.containsKey(expense.category)) {
          categoryData[expense.category] = {
            'total': 0.0,
            'count': 0,
            'average': 0.0,
          };
        }
        
        categoryData[expense.category]!['total'] += expense.amount;
        categoryData[expense.category]!['count']++;
      }

      // Calculate averages
      categoryData.forEach((category, data) {
        data['average'] = data['total'] / data['count'];
      });

      return categoryData;
    } catch (e) {
      throw Exception('Failed to get category analysis: $e');
    }
  }

  // Get spending prediction for next month
  Future<double> getSpendingPrediction(String userId) async {
    try {
      final monthlyTrends = await getMonthlySpendingTrends(userId, 6);
      if (monthlyTrends.isEmpty) return 0.0;

      final values = monthlyTrends.values.toList();
      final average = values.reduce((a, b) => a + b) / values.length;
      
      // Simple trend analysis - you can make this more sophisticated
      if (values.length >= 2) {
        final recentTrend = values.last - values[values.length - 2];
        return average + (recentTrend * 0.5); // Weighted prediction
      }
      
      return average;
    } catch (e) {
      return 0.0;
    }
  }
}
