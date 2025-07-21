import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter

// Assuming Transaction and ExpenseCategoryTotal models are accessible
// (either defined in a common models.dart or passed around)
// For simplicity, let's redefine a simple category structure here if needed
// or assume it's globally available.

class AddExpenseScreen extends StatefulWidget {
  final Map<String, double> initialExpenses; // Pre-fill if editing
  final Function(Map<String, double> categorizedExpenses, double total) onExpensesSubmitted;

  const AddExpenseScreen({
    super.key,
    this.initialExpenses = const {}, // Default to empty map
    required this.onExpensesSubmitted,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  // Define your expense categories
  final List<String> _expenseCategories = [
    'Food & Drinks',
    'Transport',
    'Academics (Books, Fees)',
    'Utilities (Rent, Bills)',
    'Personal Care',
    'Entertainment',
    'Clothing',
    'Others',
  ];

  late Map<String, TextEditingController> _controllers;
  double _totalCalculatedAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (var category in _expenseCategories)
        category: TextEditingController(
          text: widget.initialExpenses[category]?.toStringAsFixed(0) ?? '',
        ),
    };
  }

  void _calculateTotal() {
    double currentTotal = 0.0;
    _controllers.forEach((category, controller) {
      currentTotal += double.tryParse(controller.text) ?? 0.0;
    });
    setState(() {
      _totalCalculatedAmount = currentTotal;
    });
  }

  void _submitExpenses() {
    _calculateTotal(); // Ensure total is up-to-date before submitting

    final Map<String, double> categorizedExpenses = {};
    _controllers.forEach((category, controller) {
      final amount = double.tryParse(controller.text) ?? 0.0;
      if (amount > 0) { // Only include categories with actual expenses
        categorizedExpenses[category] = amount;
      }
    });

    widget.onExpensesSubmitted(categorizedExpenses, _totalCalculatedAmount);

    // Optionally clear fields after submission if desired, or let HomePage handle it
    // _clearAllFields();
    // setState(() {
    //   _totalCalculatedAmount = 0.0;
    // });
  }

  void _clearAllFields() {
    for (var controller in _controllers.values) {
      controller.clear();
    }
    setState(() {
      _totalCalculatedAmount = 0.0;
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Helper to format currency (consistent with HomePage)
  String _formatCurrency(double amount) {
    return 'FCFA ${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // AppBar might be part of HomePage, but if standalone, add one:
      // appBar: AppBar(title: const Text("Add Expenses by Category")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Enter amounts for each category:",
              style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            ..._expenseCategories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextField(
                  controller: _controllers[category],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    labelText: category,
                    hintText: "0.00",
                    prefixText: "FCFA ",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (_) => _calculateTotal(), // Recalculate on any change
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total:",
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatCurrency(_totalCalculatedAmount),
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("Confirm & Calculate Expenses"),
              onPressed: _submitExpenses,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.clear_all, size: 20),
              label: const Text("Clear All Fields"),
              onPressed: _clearAllFields,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

