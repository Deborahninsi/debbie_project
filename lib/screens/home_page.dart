import 'package:debbie_project/screens/transactions_screen.dart';
import 'package:flutter/material.dart';
import 'package:debbie_project/models/transaction_model.dart';

// Screen Imports
import 'add_expense_screen.dart';
import 'set_budget_screen.dart';
import 'savings_feature_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _selectedIndex;
  double _monthlyBudget = 0.0;
  List<Transaction> _transactions = [];
  Map<String, double> _currentExpensesPerCategory = {};
  double _totalExpensesFromCategories = 0.0;

  double get _totalWithdrawals => _transactions
      .where((t) => t.type == TransactionType.withdrawal)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get _currentBalanceAfterWithdrawals =>
      _monthlyBudget - _totalWithdrawals;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _initializePages();
  }

  void _loadInitialData() {
    setState(() {
      _monthlyBudget = 50000;
      _transactions = [
        Transaction(
          id: '1',
          title: 'Groceries',
          category: 'Food',
          amount: 5000,
          date: DateTime.now().subtract(const Duration(days: 2)),
          type: TransactionType.expense,
        ),
        Transaction(
          id: '2',
          title: 'Bus Fare',
          category: 'Transport',
          amount: 500,
          date: DateTime.now().subtract(const Duration(days: 1)),
          type: TransactionType.expense,
        ),
      ];
    });
  }

  void _initializePages() {
    _pages = [
      AddExpenseScreen(
        initialExpenses: _currentExpensesPerCategory,
        onExpensesSubmitted:
            (Map<String, double> categorizedExpenses, double total) {
          setState(() {
            _currentExpensesPerCategory = categorizedExpenses;
            _totalExpensesFromCategories = total;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Total for categories: ${_formatCurrency(total)} calculated. Go to "Budget" to withdraw.'),
            ),
          );
        },
      ),
      SetBudgetScreen(
        currentMonthlyBudget: _monthlyBudget,
        calculatedExpensesFromAddTab: _totalExpensesFromCategories,
        currentAvailableBalance: _currentBalanceAfterWithdrawals,
        onBudgetSet: (newBudget) {
          setState(() {
            _monthlyBudget = newBudget;
            _initializePages();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Monthly budget updated to: ${_formatCurrency(newBudget)}'),
            ),
          );
        },
        onWithdrawFromBudget: (amountInputByUser) {
          if (amountInputByUser <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Amount must be positive.')),
            );
            return;
          }
          if (amountInputByUser > _currentBalanceAfterWithdrawals) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Exceeds available balance of ${_formatCurrency(_currentBalanceAfterWithdrawals)}.'),
              ),
            );
            return;
          }

          setState(() {
            _addTransaction(
              Transaction(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Withdrawal from Budget',
                category: 'Budget Withdrawal',
                amount: amountInputByUser,
                date: DateTime.now(),
                type: TransactionType.withdrawal,
              ),
            );
            _initializePages();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${_formatCurrency(amountInputByUser)} withdrawn. New balance: ${_formatCurrency(_currentBalanceAfterWithdrawals)}'),
            ),
          );
        },
      ),
      TransactionsScreen(transactions: _transactions),
      SavingsFeatureScreen(
        availableBalanceForSavings: _currentBalanceAfterWithdrawals,
        onSaveAttempted: (amountToSave) {
          if (amountToSave > 0 &&
              amountToSave <= _currentBalanceAfterWithdrawals) {
            _addTransaction(
              Transaction(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: "Moved to Savings",
                category: "Savings",
                amount: amountToSave,
                date: DateTime.now(),
                type: TransactionType.withdrawal,
              ),
            );
            setState(() => _initializePages());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Congrats! ${_formatCurrency(amountToSave)} notionally saved!'),
              ),
            );
          } else if (amountToSave > _currentBalanceAfterWithdrawals) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cannot save more than available balance.'),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Enter a valid amount to save.'),
              ),
            );
          }
        },
      ),
    ];
  }

  void _addTransaction(Transaction transaction) {
    setState(() {
      _transactions.add(transaction);
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _formatCurrency(double amount) {
    return 'FCFA ${amount.toStringAsFixed(2)}';
  }

  Widget _buildUniqueHomeContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 80, color: colorScheme.primary),
            const SizedBox(height: 20),
            Text("Welcome to XTrackr!",
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                )),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              color: colorScheme.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text("Monthly Budget",
                        style: textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_formatCurrency(_monthlyBudget),
                        style: textTheme.headlineSmall?.copyWith(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w700)),
                    const Divider(height: 32),
                    Text("Available Balance",
                        style: textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_formatCurrency(_currentBalanceAfterWithdrawals),
                        style: textTheme.headlineSmall?.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text("Choose an option to proceed:",
                style: textTheme.titleMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Add Expense"),
                    onPressed: () => _onItemTapped(0)),
                ElevatedButton.icon(
                    icon: const Icon(Icons.pie_chart),
                    label: const Text("Manage Budget"),
                    onPressed: () => _onItemTapped(1)),
                ElevatedButton.icon(
                    icon: const Icon(Icons.receipt_long),
                    label: const Text("Transaction History"),
                    onPressed: () => _onItemTapped(2)),
                ElevatedButton.icon(
                    icon: const Icon(Icons.savings),
                    label: const Text("Savings"),
                    onPressed: () => _onItemTapped(3)),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == null
            ? "XTrackr Home"
            : _getPageTitle(_selectedIndex!)),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Go back to login/signup
        ),
      ),
      body: _selectedIndex == null
          ? _buildUniqueHomeContent(context)
          : IndexedStack(index: _selectedIndex!, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex ?? 0,
        onTap: _onItemTapped,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.add), label: 'Add Expense'),
          BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart), label: 'Budget'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt), label: 'Transactions'),
          BottomNavigationBarItem(
              icon: Icon(Icons.savings), label: 'Savings'),
        ],
      ),
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Add New Expense';
      case 1:
        return 'Manage Budget';
      case 2:
        return 'Transaction History';
      case 3:
        return 'Savings';
      default:
        return 'XTrackr';
    }
  }
}
