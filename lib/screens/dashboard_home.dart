import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../models/transaction_model.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final List<Transaction> transactions = [
      Transaction(
        id: 't1',
        title: 'Coffee',
        amount: 300,
        category: 'Food',
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.expense,
      ),
      Transaction(
        id: 't2',
        title: 'Bus Ticket',
        amount: 200,
        category: 'Transport',
        date: DateTime.now().subtract(const Duration(days: 3)),
        type: TransactionType.expense,
      ),
    ];

    final totalExpenses = transactions.fold(0.0, (sum, t) => sum + t.amount);
    final lastTransaction = transactions.isNotEmpty ? transactions.first : null;
    final budgetUsed = totalExpenses;
    final budgetTotal = budgetProvider.monthlyBudget > 0 ? budgetProvider.monthlyBudget : 50000;
    final budgetPercent = budgetUsed / budgetTotal;
    final userName = "Deborah"; // replace with real user name if available

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back, $userName!', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Budget Summary
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Budget Summary', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summaryColumn('Current Budget', 'FCFA ${budgetTotal.toStringAsFixed(2)}', colorScheme.primary),
                        _summaryColumn('Available Balance', 'FCFA ${(budgetTotal - budgetUsed).toStringAsFixed(2)}', Colors.green.shade700),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: budgetPercent.clamp(0, 1),
                      backgroundColor: Colors.grey.shade300,
                      color: budgetPercent > 1 ? Colors.red : colorScheme.primary,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(budgetPercent * 100).clamp(0, 100).toStringAsFixed(1)}% of budget used',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Stats
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quick Stats', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Text('Total Expenses: FCFA ${totalExpenses.toStringAsFixed(2)}', style: textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Text(
                      lastTransaction != null
                          ? 'Last Transaction: ${lastTransaction.title} - FCFA ${lastTransaction.amount.toStringAsFixed(2)}'
                          : 'No recent transactions',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text('Quick Actions', style: textTheme.titleLarge),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3,
              children: [
                _navButton(
                  icon: Icons.add,
                  label: 'Add Expense',
                  onTap: () => Navigator.pushNamed(context, '/home'),
                  color: colorScheme.primary,
                ),
                _navButton(
                  icon: Icons.receipt_long,
                  label: 'Transactions',
                  onTap: () => Navigator.pushNamed(context, '/transactions'),
                  color: Colors.deepPurple,
                ),
                _navButton(
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                  color: Colors.grey.shade700,
                ),
                _navButton(
                  icon: Icons.account_circle,
                  label: 'Profile',
                  onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                  color: Colors.teal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  Widget _navButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
