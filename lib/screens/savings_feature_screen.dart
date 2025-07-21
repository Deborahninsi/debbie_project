import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter

class SavingsFeatureScreen extends StatefulWidget {
  final double availableBalanceForSavings;
  final Function(double) onSaveAttempted;

  const SavingsFeatureScreen({
    super.key,
    required this.availableBalanceForSavings,
    required this.onSaveAttempted,
  });

  @override
  State<SavingsFeatureScreen> createState() => _SavingsFeatureScreenState();
}

class _SavingsFeatureScreenState extends State<SavingsFeatureScreen> {
  late TextEditingController _saveAmountController;

  @override
  void initState() {
    super.initState();
    _saveAmountController = TextEditingController();
  }

  void _handleTrySaving() {
    final amountString = _saveAmountController.text;
    final amountToSave = double.tryParse(amountString) ?? 0.0;

    if (amountToSave <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount to save.')),
      );
      return;
    }
    if (amountToSave > widget.availableBalanceForSavings) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot save more than your available balance of ${_formatCurrency(widget.availableBalanceForSavings)}.')),
      );
      return;
    }
    widget.onSaveAttempted(amountToSave);
    _saveAmountController.clear(); // Clear after attempt
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _saveAmountController.dispose();
    super.dispose();
  }

  // Helper to format currency
  String _formatCurrency(double amount) {
    return 'FCFA ${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.1), // Push content down a bit
            Icon(
              Icons.savings_rounded,
              size: 100,
              color: colorScheme.secondary.withOpacity(0.8),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Grow Your Savings!',
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              'Available to Save: ${_formatCurrency(widget.availableBalanceForSavings)}',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8.0),
            Text(
              "Enter an amount from your available balance to notionally set aside for savings.",
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32.0),
            TextField(
              controller: _saveAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Amount to Save',
                hintText: 'e.g., 1000',
                prefixText: "FCFA ",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton.icon(
              icon: const Icon(Icons.volunteer_activism_outlined),
              label: const Text('Try Saving This Amount'),
              onPressed: _handleTrySaving,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            if (widget.availableBalanceForSavings <= 0)
              Text(
                "You currently have no available balance to save from. Try setting a budget and managing expenses first!",
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
              )
          ],
        ),
      ),
    );
  }
}
