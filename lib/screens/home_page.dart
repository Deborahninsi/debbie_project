import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/budget_provider.dart';
import '../widgets/enhanced_refresh_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    return Consumer3<AuthProvider, ExpenseProvider, BudgetProvider>(
      builder: (context, authProvider, expenseProvider, budgetProvider, child) {
        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;

        // Reset inactivity timer on user interaction
        authProvider.resetInactivityTimer();

        final totalExpenses = expenseProvider.totalExpenses;
        final budgetTotal = authProvider.userData?['monthlyBudget']?.toDouble() ?? 50000;
        final availableBalance = budgetTotal - totalExpenses;

        return Scaffold(
          appBar: AppBar(
            title: const Text('XTrackr Home'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                onPressed: () => _showLogoutDialog(context, authProvider),
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
              ),
            ],
          ),
          body: EnhancedRefreshIndicator(
            onRefresh: _refreshData,
            refreshMessage: 'Home data updated successfully!',
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Header
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                            '${authProvider.getGreeting()}, ${authProvider.userData?['fullName'] ?? authProvider.displayName}!',
                            style: textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Welcome to XTrackr - Your Personal Finance Tracker',
                            style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Financial Overview
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.account_balance_wallet, color: colorScheme.primary),
                              const SizedBox(width: 8),
                              Text('Financial Overview', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _summaryRow('Monthly Budget', 'FCFA ${budgetTotal.toStringAsFixed(2)}', Colors.blue),
                          const SizedBox(height: 12),
                          _summaryRow('Total Expenses', 'FCFA ${totalExpenses.toStringAsFixed(2)}', Colors.red),
                          const SizedBox(height: 12),
                          _summaryRow('Available Balance', 'FCFA ${availableBalance.toStringAsFixed(2)}', 
                              availableBalance >= 0 ? Colors.green : Colors.red),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: budgetTotal > 0 ? (totalExpenses / budgetTotal).clamp(0, 1) : 0,
                            backgroundColor: Colors.grey.shade300,
                            color: totalExpenses > budgetTotal ? Colors.red : colorScheme.primary,
                            minHeight: 8,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${budgetTotal > 0 ? ((totalExpenses / budgetTotal) * 100).clamp(0, 100).toStringAsFixed(1) : "0"}% of budget used',
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
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quick Stats', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _statCard(
                                  'Transactions',
                                  '${expenseProvider.expenses.length}',
                                  Icons.receipt_long,
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _statCard(
                                  'Categories',
                                  '${expenseProvider.categoryTotals.length}',
                                  Icons.category,
                                  Colors.purple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _statCard(
                                  'Avg/Day',
                                  'FCFA ${expenseProvider.expenses.isNotEmpty ? (totalExpenses / 30).toStringAsFixed(0) : "0"}',
                                  Icons.calendar_today,
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _statCard(
                                  'This Month',
                                  'FCFA ${totalExpenses.toStringAsFixed(0)}',
                                  Icons.trending_up,
                                  Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recent Transactions
                  if (expenseProvider.expenses.isNotEmpty) ...[
                    Text('Recent Transactions', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: expenseProvider.expenses.take(5).map((expense) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getCategoryColor(expense.category),
                              child: Icon(
                                _getCategoryIcon(expense.category),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(expense.description),
                            subtitle: Text('${expense.category} • ${expense.date.day}/${expense.date.month}/${expense.date.year}'),
                            trailing: Text(
                              'FCFA ${expense.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ] else ...[
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'No transactions yet',
                                style: textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start tracking your expenses to see them here',
                                style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _summaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food & Drinks':
        return Colors.orange;
      case 'Transport':
        return Colors.blue;
      case 'Academics (Books, Fees)':
        return Colors.purple;
      case 'Utilities (Rent, Bills)':
        return Colors.green;
      case 'Personal Care':
        return Colors.pink;
      case 'Entertainment':
        return Colors.red;
      case 'Clothing':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food & Drinks':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_car;
      case 'Academics (Books, Fees)':
        return Icons.school;
      case 'Utilities (Rent, Bills)':
        return Icons.home;
      case 'Personal Care':
        return Icons.spa;
      case 'Entertainment':
        return Icons.movie;
      case 'Clothing':
        return Icons.shopping_bag;
      default:
        return Icons.category;
    }
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
