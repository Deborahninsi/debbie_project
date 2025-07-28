import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SetBudgetScreen extends StatefulWidget {
  final double currentMonthlyBudget;
  final double calculatedExpensesFromAddTab;
  final double currentAvailableBalance;
  final Function(double) onBudgetSet;
  final Function(double) onWithdrawFromBudget;

  const SetBudgetScreen({
    super.key,
    required this.currentMonthlyBudget,
    required this.calculatedExpensesFromAddTab,
    required this.currentAvailableBalance,
    required this.onBudgetSet,
    required this.onWithdrawFromBudget,
  });

  @override
  State<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends State<SetBudgetScreen> {
  late TextEditingController _budgetController;
  late TextEditingController _withdrawAmountController;
  double _availableBalance = 0.0;
  double _lastWithdrawalAmount = 0.0;
  bool _withdrawalConfirmed = false;

  @override
  void initState() {
    super.initState();
    _budgetController = TextEditingController(
      text: widget.currentMonthlyBudget > 0 ? widget.currentMonthlyBudget.toStringAsFixed(0) : '',
    );
    _withdrawAmountController = TextEditingController();
    _availableBalance = widget.currentAvailableBalance;
  }

  @override
  void didUpdateWidget(covariant SetBudgetScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentMonthlyBudget != oldWidget.currentMonthlyBudget) {
      _budgetController.text = widget.currentMonthlyBudget.toStringAsFixed(0);
    }
    if (widget.currentAvailableBalance != oldWidget.currentAvailableBalance) {
      setState(() {
        _availableBalance = widget.currentAvailableBalance;
      });
    }
  }

  void _handleSetBudget() {
    final newBudget = double.tryParse(_budgetController.text) ?? 0.0;
    if (newBudget > 0) {
      widget.onBudgetSet(newBudget);
      setState(() {
        _availableBalance = newBudget;
        _withdrawalConfirmed = false;
      });
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Budget of ${_formatCurrency(newBudget)} saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget amount.')),
      );
    }
  }

  void _handleWithdraw() {
    final amountToWithdraw = double.tryParse(_withdrawAmountController.text) ?? 0.0;

    if (amountToWithdraw <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount to withdraw.')),
      );
      return;
    }

    if (amountToWithdraw > _availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ Withdrawal failed: Exceeds available balance of ${_formatCurrency(_availableBalance)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    widget.onWithdrawFromBudget(amountToWithdraw);
    setState(() {
      _lastWithdrawalAmount = amountToWithdraw;
      _availableBalance -= amountToWithdraw;
      _withdrawalConfirmed = true;
    });
    FocusScope.of(context).unfocus();
  }

  String _formatCurrency(double amount) {
    return 'FCFA ${amount.toStringAsFixed(2)}';
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _withdrawAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Budget Overview
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Budget Overview", style: textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Monthly Budget:", style: textTheme.titleSmall),
                        Text(
                          _formatCurrency(widget.currentMonthlyBudget),
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Available Balance:", style: textTheme.titleSmall),
                        Text(
                          _formatCurrency(_availableBalance),
                          style: textTheme.titleMedium?.copyWith(
                            color: _availableBalance >= 0
                                ? Colors.green.shade700
                                : colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (_withdrawalConfirmed) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Last Withdrawal:", style: textTheme.titleSmall),
                          Text(
                            _formatCurrency(_lastWithdrawalAmount),
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Set Budget
            Text("Set Your Monthly Budget:", style: textTheme.titleMedium),
            const SizedBox(height: 8.0),
            TextField(
              controller: _budgetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Enter Monthly Budget',
                hintText: 'e.g., 50000',
                prefixText: "FCFA ",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              icon: const Icon(Icons.save_alt_outlined),
              label: const Text('Save Budget'),
              onPressed: _handleSetBudget,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 30),
            const Divider(height: 30),

            // Withdraw Section
            Text("Withdraw from Budget:", style: textTheme.titleMedium),
            const SizedBox(height: 12),
            if (widget.calculatedExpensesFromAddTab > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "(Tip: Expenses calculated from 'Add Expense' tab: ${_formatCurrency(widget.calculatedExpensesFromAddTab)})",
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.secondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            TextField(
              controller: _withdrawAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Amount to Withdraw',
                hintText: 'e.g., 2500',
                prefixText: "FCFA ",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              onChanged: (_) => setState(() => _withdrawalConfirmed = false),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_downward_rounded),
              label: const Text('Confirm Withdrawal'),
              onPressed: (_withdrawAmountController.text.isEmpty || _availableBalance <= 0)
                  ? null
                  : _handleWithdraw,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),

            if (_withdrawalConfirmed) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text(
                        "Withdrawal Successful!",
                        style: textTheme.titleMedium?.copyWith(color: Colors.green),
                      ),
                      const SizedBox(height: 8),
                      Text("Withdrawn: ${_formatCurrency(_lastWithdrawalAmount)}"),
                      Text(
                        "New Balance: ${_formatCurrency(_availableBalance)}",
                        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              "Ensure the amount is within your available balance.",
              style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
