import 'package:flutter/material.dart';
import 'package:debbie_project/models/transaction_model.dart';

class TransactionsScreen extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionsScreen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: transactions.isEmpty
          ? const Center(child: Text('No transactions yet.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(
                tx.type == TransactionType.expense
                    ? Icons.remove_circle_outline
                    : Icons.arrow_downward,
                color: tx.type == TransactionType.expense
                    ? Colors.red
                    : Colors.green,
              ),
              title: Text(tx.title),
              subtitle: Text(
                  '${tx.category} • ${_formatDate(tx.date)}'),
              trailing: Text(
                '- FCFA ${tx.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
