import 'package:flutter/material.dart';
import 'package:debbie_project/models/transaction_model.dart';

// Screen Imports
import 'add_expense_screen.dart';
import 'set_budget_screen.dart';
import 'savings_feature_screen.dart';
import 'transactions_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;  // Initialize to 0 so it starts on AddExpenseScreen
  double _monthlyBudget = 50000;  // You can initialize to 0 or load from saved data
  List<Transaction> _transactions = [];

  Map<String, double> _currentExpensesPerCategory = {};
  double _totalExpensesFromCategories = 0.0;

  // Calculates total withdrawals by summing withdrawal type transactions
  double get _totalWithdrawals => _transactions
      .where((t) => t.type == TransactionType.withdrawal)
      .fold(0.0, (sum, item) => sum + item.amount);

  // Balance after withdrawals
  double get _currentBalanceAfterWithdrawals => _monthlyBudget - _totalWithdrawals;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Load initial example data:
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

    _initializePages();
  }

  // Initialize the pages with callbacks for communication
  void _initializePages() {
    _pages = [
      AddExpenseScreen(
        initialExpenses: _currentExpensesPerCategory,
        onExpensesSubmitted: (categorizedExpenses, total) {
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
            _initializePages();  // Refresh pages so values update properly
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Monthly budget updated to: ${_formatCurrency(newBudget)}'),
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
                content: Text('Exceeds available balance of ${_formatCurrency(_currentBalanceAfterWithdrawals)}.'),
              ),
            );
            return;
          }

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

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_formatCurrency(amountInputByUser)} withdrawn. New balance: ${_formatCurrency(_currentBalanceAfterWithdrawals)}'),
            ),
          );
        },
      ),
      TransactionsScreen(transactions: _transactions),
      SavingsFeatureScreen(
        availableBalanceForSavings: _currentBalanceAfterWithdrawals,
        onSaveAttempted: (amountToSave) {
          if (amountToSave > 0 && amountToSave <= _currentBalanceAfterWithdrawals) {
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
                content: Text('Congrats! ${_formatCurrency(amountToSave)} notionally saved!'),
              ),
            );
          } else if (amountToSave > _currentBalanceAfterWithdrawals) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cannot save more than available balance.')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Enter a valid amount to save.')),
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

  String _formatCurrency(double amount) => 'FCFA ${amount.toStringAsFixed(2)}';

  Widget _buildUniqueHomeContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              children: [
                Icon(Icons.account_balance_wallet_outlined, size: 80, color: colorScheme.primary),
                const SizedBox(height: 20),
                Text("Welcome to XTrackr!",
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _summaryRow("Monthly Budget", _formatCurrency(_monthlyBudget), color: Colors.blueAccent),
                  const Divider(height: 30),
                  _summaryRow("Available Balance", _formatCurrency(_currentBalanceAfterWithdrawals), color: Colors.green.shade700),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text("Quick Actions", style: textTheme.titleLarge),
          const SizedBox(height: 16),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            shrinkWrap: true,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _actionCard(icon: Icons.add, label: 'Add Expense', onTap: () => _onItemTapped(0), color: Colors.orange),
              _actionCard(icon: Icons.pie_chart, label: 'Manage Budget', onTap: () => _onItemTapped(1), color: Colors.blue),
              _actionCard(icon: Icons.receipt_long, label: 'Transactions', onTap: () => _onItemTapped(2), color: Colors.deepPurple),
              _actionCard(icon: Icons.savings, label: 'Savings', onTap: () => _onItemTapped(3), color: Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {required Color color}) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(value, style: textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _actionCard({required IconData icon, required String label, required VoidCallback onTap, required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        color: color.withOpacity(0.1),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle(_selectedIndex)),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        automaticallyImplyLeading: false,  // Remove back button on main screen
      ),
      body: _selectedIndex == 0
          ? _pages[0]
          : IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Expense'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Budget'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.savings), label: 'Savings'),
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
