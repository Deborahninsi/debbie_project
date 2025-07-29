class Expense {
  final String id;
  final String userId;
  final String category;
  final double amount;
  final String description;
  final DateTime date;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'category': category,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
