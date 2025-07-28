// lib/screens/fund_wallet_screen.dart
import 'package:flutter/material.dart';

class FundWalletScreen extends StatefulWidget {
  const FundWalletScreen({super.key});

  @override
  State<FundWalletScreen> createState() => _FundWalletScreenState();
}

class _FundWalletScreenState extends State<FundWalletScreen> {
  final _amountController = TextEditingController();
  String? _selectedMethod;

  final List<String> _methods = ['MTN MoMo', 'Orange Money', 'Mock Wallet'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fund Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter amount (FCFA)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              items: _methods
                  .map((method) => DropdownMenuItem(
                value: method,
                child: Text(method),
              ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedMethod = value),
              decoration: const InputDecoration(
                labelText: 'Select Wallet',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _handleFundWallet,
              child: const Text('Proceed to Pay'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleFundWallet() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a payment method')),
      );
      return;
    }

    // Call MoMo API or your service here
    // For now, we just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Initiating $_selectedMethod payment of FCFA $amount')),
    );

    // TODO: call backend or payment API here
  }
}

