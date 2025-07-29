import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../services/budget_service.dart';
import '../models/budget_model.dart';

class SetBudgetScreen extends StatefulWidget {
  const SetBudgetScreen({super.key});

  @override
  State<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends State<SetBudgetScreen> {
  final _budgetController = TextEditingController();
  final _withdrawAmountController = TextEditingController();
  final BudgetService _budgetService = BudgetService();
  
  Budget? _currentBudget;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBudget();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _withdrawAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadBudget() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      try {
        final budget = await _budgetService.getUserBudget(authProvider.user!.uid);
        setState(() {
          _currentBudget = budget;
          if (budget != null) {
            _budgetController.text = budget.monthlyAmount.toStringAsFixed(0);
          }
        });
      } catch (e) {
        print('Error loading budget: $e');
      }
    }
  }

  Future<void> _setBudget() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final amount = double.tryParse(_budgetController.text);
    
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget amount')),
      );
      return;
    }

    if (authProvider.user == null) return;

    setState(() => _isLoading = true);

    try {
      final budget = Budget(
        id: authProvider.user!.uid,
        userId: authProvider.user!.uid,
        monthlyAmount: amount,
        totalWithdrawn: _currentBudget?.totalWithdrawn ?? 0.0,
        createdAt: _currentBudget?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _budgetService.setBudget(budget);
      
      // Update user data
      await authProvider.updateUserData({'monthlyBudget': amount});
      
      setState(() {
        _currentBudget = budget;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Budget set to FCFA ${amount.toStringAsFixed(2)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error setting budget: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _withdrawFromBudget() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final amount = double.tryParse(_withdrawAmountController.text);
    
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid withdrawal amount')),
      );
      return;
    }

    if (_currentBudget == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set a budget first')),
      );
      return;
    }

    if (amount > _currentBudget!.availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient balance. Available: FCFA ${_currentBudget!.availableBalance.toStringAsFixed(2)}'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _budgetService.updateWithdrawal(authProvider.user!.uid, amount);
      await _loadBudget(); // Reload budget data
      
      _withdrawAmountController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Withdrawn FCFA ${amount.toStringAsFixed(2)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing withdrawal: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    await _loadBudget();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      await expenseProvider.loadUserExpenses(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Budget'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          return RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Budget Overview Card
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.account_balance_wallet, color: colorScheme.primary),
                              const SizedBox(width: 8),
                              Text('Budget Overview', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_currentBudget != null) ...[
                            _budgetSummaryRow('Monthly Budget', _currentBudget!.monthlyAmount, Colors.blue),
                            const SizedBox(height: 12),
                            _budgetSummaryRow('Total Withdrawn', _currentBudget!.totalWithdrawn, Colors.orange),
                            const SizedBox(height: 12),
                            _budgetSummaryRow('Available Balance', _currentBudget!.availableBalance, Colors.green),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: (_currentBudget!.totalWithdrawn / _currentBudget!.monthlyAmount).clamp(0, 1),
                              backgroundColor: Colors.grey.shade300,
                              color: _currentBudget!.totalWithdrawn > _currentBudget!.monthlyAmount 
                                  ? Colors.red 
                                  : colorScheme.primary,
                              minHeight: 8,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${((_currentBudget!.totalWithdrawn / _currentBudget!.monthlyAmount) * 100).clamp(0, 100).toStringAsFixed(1)}% used',
                              style: textTheme.bodySmall,
                            ),
                          ] else ...[
                            Text(
                              'No budget set yet',
                              style: textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Set Budget Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Set Monthly Budget', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _budgetController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Monthly Budget Amount',
                              hintText: 'e.g., 50000',
                              prefixText: 'FCFA ',
                              prefixIcon: const Icon(Icons.attach_money),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _setBudget,
                            icon: _isLoading 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.save),
                            label: Text(_isLoading ? 'Saving...' : 'Set Budget'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Withdraw Section
                  if (_currentBudget != null && _currentBudget!.availableBalance > 0) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Withdraw from Budget', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                              'Available: FCFA ${_currentBudget!.availableBalance.toStringAsFixed(2)}',
                              style: textTheme.bodyMedium?.copyWith(color: Colors.green.shade700),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _withdrawAmountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Withdrawal Amount',
                                hintText: 'e.g., 5000',
                                prefixText: 'FCFA ',
                                prefixIcon: const Icon(Icons.money_off),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _withdrawFromBudget,
                              icon: const Icon(Icons.arrow_downward),
                              label: const Text('Withdraw'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.secondary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Expense Summary
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Expense Summary', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          _budgetSummaryRow('Total Expenses', expenseProvider.totalExpenses, Colors.red),
                          const SizedBox(height: 8),
                          _budgetSummaryRow('Number of Transactions', expenseProvider.expenses.length.toDouble(), Colors.blue),
                          if (_currentBudget != null) ...[
                            const SizedBox(height: 8),
                            _budgetSummaryRow(
                              'Budget vs Expenses', 
                              _currentBudget!.monthlyAmount - expenseProvider.totalExpenses, 
                              _currentBudget!.monthlyAmount >= expenseProvider.totalExpenses ? Colors.green : Colors.red,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _budgetSummaryRow(String label, double value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(
          label.contains('Number') ? value.toInt().toString() : 'FCFA ${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
