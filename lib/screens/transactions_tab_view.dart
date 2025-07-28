import 'package:flutter/material.dart';

class TransactionsTabView extends StatelessWidget {
  const TransactionsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text('Transactions List', style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}