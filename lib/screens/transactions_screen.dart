
// lib/screens/transactions_screen.dart
import 'package:flutter/material.dart';
import 'package:debbie_project/models/transaction_model.dart';
import 'package:debbie_project/models/transaction_model.dart' hide Transaction, TransactionType; // ✅ correct


class TransactionsScreen extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionsScreen({Key? key, required this.transactions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions yet.'));
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return ListTile(
          leading: Icon(
            tx.type == TransactionType.income
                ? Icons.arrow_downward
                : tx.type == TransactionType.expense
                ? Icons.arrow_upward
                : Icons.money_off,
            color: tx.type == TransactionType.income
                ? Colors.green
                : Colors.red,
          ),
          title: Text(tx.title),
          subtitle: Text('${tx.category} • ${tx.date.toLocal().toString().split(' ')[0]}'),
          trailing: Text(
            'FCFA ${tx.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}
// TODO Implement this library.