import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../models/transaction_model.dart';
import 'dashboard_screen.dart';
import '../widgets/enhanced_refresh_indicator.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
      
      if (authProvider.user != null) {
        expenseProvider.loadUserExpenses(authProvider.user!.uid);
      }
    });
  }

  Future<void> _refreshData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      await expenseProvider.loadUserExpenses(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<BudgetProvider, AuthProvider, ExpenseProvider>(
      builder: (context, budgetProvider, authProvider, expenseProvider, child) {
        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;

        // Reset inactivity timer on user interaction
        authProvider.resetInactivityTimer();

        final totalExpenses = expenseProvider.totalExpenses;
        final budgetTotal = authProvider.userData?['monthlyBudget']?.toDouble() ?? 50000;
        final budgetPercent = totalExpenses / budgetTotal;

        return SafeArea(
          child: EnhancedRefreshIndicator(
            onRefresh: _refreshData,
            refreshMessage: 'Dashboard updated successfully!',
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with logout button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${authProvider.getGreeting()}, ${authProvider.userData?['fullName'] ?? authProvider.displayName}!',
                          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showLogoutDialog(context, authProvider),
                        icon: const Icon(Icons.logout),
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Greeting Card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to XTrackr!',
                            style: textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Track your expenses, manage your budget, and achieve your financial goals.',
                            style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                              _summaryColumn('Available Balance', 'FCFA ${(budgetTotal - totalExpenses).toStringAsFixed(2)}', Colors.green.shade700),
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
                  const SizedBox(height: 16),

                  // Quick Stats - Full Card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.analytics_outlined, color: colorScheme.secondary),
                              const SizedBox(width: 8),
                              Text('Quick Stats', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _statItem(
                                  'Total Expenses',
                                  'FCFA ${totalExpenses.toStringAsFixed(2)}',
                                  Icons.trending_down,
                                  Colors.red.shade600,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _statItem(
                                  'Transactions',
                                  '${expenseProvider.expenses.length}',
                                  Icons.receipt_long,
                                  Colors.blue.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _statItem(
                                  'Categories',
                                  '${expenseProvider.categoryTotals.length}',
                                  Icons.category,
                                  Colors.purple.shade600,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _statItem(
                                  'Avg/Day',
                                  'FCFA ${expenseProvider.expenses.isNotEmpty ? (totalExpenses / 30).toStringAsFixed(0) : "0"}',
                                  Icons.calendar_today,
                                  Colors.green.shade600,
                                ),
                              ),
                            ],
                          ),
                          if (expenseProvider.expenses.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 12),
                            Text(
                              'Last Transaction: ${expenseProvider.expenses.first.description} - FCFA ${expenseProvider.expenses.first.amount.toStringAsFixed(2)}',
                              style: textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
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
                        onTap: () => _navigateToScreen(1),
                        color: colorScheme.primary,
                      ),
                      _navButton(
                        icon: Icons.receipt_long,
                        label: 'Transactions',
                        onTap: () => _navigateToScreen(2),
                        color: Colors.deepPurple,
                      ),
                      _navButton(
                        icon: Icons.pie_chart,
                        label: 'Budget',
                        onTap: () => _navigateToScreen(3),
                        color: Colors.blue,
                      ),
                      _navButton(
                        icon: Icons.savings,
                        label: 'Savings',
                        onTap: () => _navigateToScreen(4),
                        color: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(int index) {
    final dashboardState = context.findAncestorStateOfType<DashboardScreenState>();
    dashboardState?.navigateToScreen(index);
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
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                authProvider.signOut();
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
