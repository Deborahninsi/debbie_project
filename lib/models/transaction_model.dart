enum TransactionType {
  income,
  expense,
  withdrawal,
}

class Transaction {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final TransactionType type;

  Transaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
  });
}

// TODO Implement this library.