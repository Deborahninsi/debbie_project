import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import '../providers/expense_provider.dart';
import '../providers/auth_provider.dart';
import '../models/expense_model.dart';
import '../widgets/enhanced_refresh_indicator.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedCategory = 'All';
  DateTimeRange? _selectedDateRange;

  final List<String> _categories = [
    'All',
    'Food & Drinks',
    'Transport',
    'Academics (Books, Fees)',
    'Utilities (Rent, Bills)',
    'Personal Care',
    'Entertainment',
    'Clothing',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);

      if (authProvider.user != null) {
        expenseProvider.loadUserExpenses(authProvider.user!.uid);
      }
    });
  }

  List<Expense> _getFilteredExpenses(List<Expense> expenses) {
    List<Expense> filtered = expenses;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((expense) => expense.category == _selectedCategory)
          .toList();
    }

    // Filter by date range
    if (_selectedDateRange != null) {
      filtered = filtered.where((expense) {
        return expense.date.isAfter(
                _selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            expense.date
                .isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  Future<void> _exportToPDF(List<Expense> expenses) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userName =
          authProvider.userData?['fullName'] ?? authProvider.displayName;

      // Create PDF document
      final pdf = pw.Document();

      // Calculate totals
      final totalAmount =
          expenses.fold(0.0, (sum, expense) => sum + expense.amount);
      final categoryTotals = <String, double>{};

      for (var expense in expenses) {
        categoryTotals[expense.category] =
            (categoryTotals[expense.category] ?? 0) + expense.amount;
      }

      // Add pages to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'XTrackr - Expense Report',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text('Generated for: $userName'),
                        pw.Text(
                            'Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
                      ],
                    ),
                    pw.Container(
                      width: 80,
                      height: 80,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.green300,
                        borderRadius: pw.BorderRadius.circular(40),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'XT',
                          style: pw.TextStyle(
                            fontSize: 32,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Summary Section
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Summary',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Transactions:'),
                        pw.Text('${expenses.length}'),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Amount:'),
                        pw.Text(
                          'FCFA ${totalAmount.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                    if (_selectedCategory != 'All') ...[
                      pw.SizedBox(height: 4),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Category Filter:'),
                          pw.Text(_selectedCategory),
                        ],
                      ),
                    ],
                    if (_selectedDateRange != null) ...[
                      pw.SizedBox(height: 4),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Date Range:'),
                          pw.Text(
                            '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}',
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Category Breakdown
              if (categoryTotals.isNotEmpty) ...[
                pw.Text(
                  'Category Breakdown',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Category',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Amount (FCFA)',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Percentage',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    ...categoryTotals.entries.map((entry) {
                      final percentage = (entry.value / totalAmount) * 100;
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(entry.key),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              entry.value.toStringAsFixed(2),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              '${percentage.toStringAsFixed(1)}%',
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 20),
              ],

              // Transactions Table
              pw.Text(
                'Transaction Details',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),

              if (expenses.isEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Center(
                    child: pw.Text(
                        'No transactions found for the selected criteria.'),
                  ),
                )
              else
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(3),
                    3: const pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    // Table Header
                    pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Date',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Category',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Description',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Amount (FCFA)',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    // Table Rows
                    ...expenses.map((expense) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(expense.category),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(expense.description),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              expense.amount.toStringAsFixed(2),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
            ];
          },
        ),
      );

      // Show print/save dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'XTrackr_Expenses_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('PDF export completed successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Export failed: $e')),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadAnalytics() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);

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
        title: const Text('Transactions'),
        automaticallyImplyLeading: false,
        actions: [
          Consumer<ExpenseProvider>(
            builder: (context, expenseProvider, child) {
              final filteredExpenses =
                  _getFilteredExpenses(expenseProvider.expenses);
              return IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: filteredExpenses.isNotEmpty
                    ? () => _exportToPDF(filteredExpenses)
                    : null,
                tooltip: 'Export to PDF',
              );
            },
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          if (expenseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredExpenses =
              _getFilteredExpenses(expenseProvider.expenses);
          final totalFiltered = filteredExpenses.fold(
              0.0, (sum, expense) => sum + expense.amount);

          return RefreshIndicator(
            onRefresh: _loadAnalytics,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Filters
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Category Filter
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: _categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(
                                category,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        // Date Range Filter
                        InkWell(
                          onTap: _selectDateRange,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date Range',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.date_range,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedDateRange == null
                                        ? 'All dates'
                                        : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}',
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Summary and Actions Row
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Total: FCFA ${totalFiltered.toStringAsFixed(2)}',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (filteredExpenses.isNotEmpty)
                                  ElevatedButton.icon(
                                    onPressed: () => _exportToPDF(filteredExpenses),
                                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                                    label: const Text('PDF', style: TextStyle(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade600,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      minimumSize: const Size(60, 32),
                                    ),
                                  ),
                              ],
                            ),
                            if (_selectedDateRange != null || _selectedCategory != 'All')
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedCategory = 'All';
                                        _selectedDateRange = null;
                                      });
                                    },
                                    child: const Text('Clear Filters'),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Transactions List
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 300,
                    child: filteredExpenses.isEmpty
                        ? EnhancedRefreshIndicator(
                            onRefresh: _loadAnalytics,
                            refreshMessage: 'Transactions refreshed!',
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.receipt_long_outlined,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No transactions found',
                                        style: textTheme.titleMedium?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Pull down to refresh or add some expenses',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : EnhancedRefreshIndicator(
                            onRefresh: _loadAnalytics,
                            refreshMessage: 'Transactions refreshed!',
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredExpenses.length,
                              itemBuilder: (context, index) {
                                final expense = filteredExpenses[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          _getCategoryColor(expense.category),
                                      child: Icon(
                                        _getCategoryIcon(expense.category),
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      expense.description,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(expense.category),
                                        Text(
                                          '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'FCFA ${expense.amount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red.shade600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onLongPress: () =>
                                        _showDeleteDialog(expense),
                                  ),
                                );
                              },
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

  void _showDeleteDialog(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content:
            Text('Are you sure you want to delete "${expense.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              final expenseProvider =
                  Provider.of<ExpenseProvider>(context, listen: false);

              try {
                await expenseProvider.deleteExpense(
                    expense.id, authProvider.user!.uid);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Expense deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting expense: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
