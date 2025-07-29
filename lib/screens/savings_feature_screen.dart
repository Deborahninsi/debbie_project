import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/savings_service.dart';
import '../services/budget_service.dart';
import '../models/savings_model.dart';
import '../models/budget_model.dart';

class SavingsFeatureScreen extends StatefulWidget {
  const SavingsFeatureScreen({super.key});

  @override
  State<SavingsFeatureScreen> createState() => _SavingsFeatureScreenState();
}

class _SavingsFeatureScreenState extends State<SavingsFeatureScreen> {
  final _saveAmountController = TextEditingController();
  final _spendAmountController = TextEditingController();
  final SavingsService _savingsService = SavingsService();
  final BudgetService _budgetService = BudgetService();
  
  Savings? _currentSavings;
  Budget? _currentBudget;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _saveAmountController.dispose();
    _spendAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      try {
        final savings = await _savingsService.getUserSavings(authProvider.user!.uid);
        final budget = await _budgetService.getUserBudget(authProvider.user!.uid);
        setState(() {
          _currentSavings = savings;
          _currentBudget = budget;
        });
      } catch (e) {
        print('Error loading data: $e');
      }
    }
  }

  Future<void> _addToSavings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final amount = double.tryParse(_saveAmountController.text);
    
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount to save')),
      );
      return;
    }

    if (_currentBudget == null || amount > _currentBudget!.availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient budget balance. Available: FCFA ${_currentBudget?.availableBalance.toStringAsFixed(2) ?? "0.00"}'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Add to savings
      await _savingsService.addToSavings(authProvider.user!.uid, amount);
      
      // Update budget withdrawal
      await _budgetService.updateWithdrawal(authProvider.user!.uid, amount);
      
      await _loadData(); // Reload data
      _saveAmountController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('FCFA ${amount.toStringAsFixed(2)} added to savings!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding to savings: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _spendFromSavings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final amount = double.tryParse(_spendAmountController.text);
    
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount to spend')),
      );
      return;
    }

    if (_currentSavings == null || amount > _currentSavings!.availableForSpending) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient savings balance. Available: FCFA ${_currentSavings?.availableForSpending.toStringAsFixed(2) ?? "0.00"}'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _savingsService.spendFromSavings(authProvider.user!.uid, amount);
      await _loadData(); // Reload data
      _spendAmountController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('FCFA ${amount.toStringAsFixed(2)} spent from savings'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error spending from savings: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Savings Overview
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.savings, color: colorScheme.primary, size: 32),
                          const SizedBox(width: 12),
                          Text('Savings Overview', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_currentSavings != null) ...[
                        _savingsRow('Total Saved', _currentSavings!.totalSaved, Colors.green),
                        const SizedBox(height: 12),
                        _savingsRow('Available to Spend', _currentSavings!.availableForSpending, Colors.blue),
                        const SizedBox(height: 12),
                        _savingsRow('Already Spent', _currentSavings!.totalSaved - _currentSavings!.availableForSpending, Colors.orange),
                      ] else ...[
                        Text(
                          'No savings yet. Start saving today!',
                          style: textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Add to Savings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add to Savings', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (_currentBudget != null)
                        Text(
                          'Available from budget: FCFA ${_currentBudget!.availableBalance.toStringAsFixed(2)}',
                          style: textTheme.bodyMedium?.copyWith(color: Colors.green.shade700),
                        ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _saveAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Amount to Save',
                          hintText: 'e.g., 1000',
                          prefixText: 'FCFA ',
                          prefixIcon: const Icon(Icons.add_circle_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _addToSavings,
                        icon: _isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.savings),
                        label: Text(_isLoading ? 'Saving...' : 'Add to Savings'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Spend from Savings
              if (_currentSavings != null && _currentSavings!.availableForSpending > 0) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Spend from Savings', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          'Available to spend: FCFA ${_currentSavings!.availableForSpending.toStringAsFixed(2)}',
                          style: textTheme.bodyMedium?.copyWith(color: Colors.blue.shade700),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _spendAmountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Amount to Spend',
                            hintText: 'e.g., 500',
                            prefixText: 'FCFA ',
                            prefixIcon: const Icon(Icons.remove_circle_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _spendFromSavings,
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('Spend from Savings'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Savings Tips
              const SizedBox(height: 24),
              Card(
                color: colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, color: colorScheme.onPrimaryContainer),
                          const SizedBox(width: 8),
                          Text(
                            'Savings Tips',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Set aside a fixed amount each month\n'
                        '• Save before you spend\n'
                        '• Track your progress regularly\n'
                        '• Use savings for emergencies or goals\n'
                        '• Start small and increase gradually',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _savingsRow(String label, double value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(
          'FCFA ${value.toStringAsFixed(2)}',
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
