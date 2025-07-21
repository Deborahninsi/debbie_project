import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter

class SetBudgetScreen extends StatefulWidget {
  final double currentMonthlyBudget;
  // This is still useful to show the user what was calculated on the other tab
  final double calculatedExpensesFromAddTab;
  final double currentAvailableBalance; // Pass this from HomePage
  final Function(double) onBudgetSet;
  final Function(double) onWithdrawFromBudget; // This will now take the user-inputted amount

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

  @override
  void initState() {
    super.initState();
    _budgetController = TextEditingController(
      text: widget.currentMonthlyBudget > 0 ? widget.currentMonthlyBudget.toStringAsFixed(0) : '',
    );
    _withdrawAmountController = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant SetBudgetScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentMonthlyBudget != oldWidget.currentMonthlyBudget) {
      if (_budgetController.text != widget.currentMonthlyBudget.toStringAsFixed(0) &&
          widget.currentMonthlyBudget > 0) {
        _budgetController.text = widget.currentMonthlyBudget.toStringAsFixed(0);
        // It's generally good practice to also clear dependent fields or re-evaluate
        // if a core value like budget changes significantly.
        // For now, we'll let the user manage the withdrawal amount independently.
      }
    }
  }

  void _handleSetBudget() {
    final newBudgetString = _budgetController.text;
    final newBudget = double.tryParse(newBudgetString) ?? 0.0;
    if (newBudget > 0) {
      widget.onBudgetSet(newBudget); // Callback to HomePage
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget amount.')),
      );
    }
  }

  void _handleWithdraw() {
    final withdrawString = _withdrawAmountController.text;
    final amountToWithdraw = double.tryParse(withdrawString) ?? 0.0;

    if (amountToWithdraw <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount to withdraw.')),
      );
      return;
    }
    if (amountToWithdraw > widget.currentAvailableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Withdrawal amount exceeds available balance of ${_formatCurrency(widget.currentAvailableBalance)}.')),
      );
      return;
    }

    widget.onWithdrawFromBudget(amountToWithdraw); // Callback to HomePage
    _withdrawAmountController.clear(); // Clear field after successful attempt
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _withdrawAmountController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return 'FCFA ${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // --- Section: Display Current Budget & Balance ---
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
                        Text("Set Monthly Budget:", style: textTheme.titleSmall),
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
                          _formatCurrency(widget.currentAvailableBalance), // Display the passed available balance
                          style: textTheme.titleMedium?.copyWith(
                            color: widget.currentAvailableBalance >= 0 ? Colors.green.shade700 : colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- Section: Set or Update Budget ---
            Text(
              "Set or Update Your Monthly Budget:",
              style: textTheme.titleMedium,
            ),
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

            // --- Section: Withdraw from Budget ---
            Text(
              "Withdraw from Budget:",
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (widget.calculatedExpensesFromAddTab > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "(Tip: Expenses calculated from 'Add Expense' tab: ${_formatCurrency(widget.calculatedExpensesFromAddTab)})",
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary, fontStyle: FontStyle.italic),
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
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_downward_rounded),
              label: const Text('Confirm Withdrawal'),
              onPressed: _handleWithdraw,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
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
