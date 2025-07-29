class Budget {
  final String id;
  final String userId;
  final double monthlyAmount;
  final double totalWithdrawn;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    required this.id,
    required this.userId,
    required this.monthlyAmount,
    required this.totalWithdrawn,
    required this.createdAt,
    required this.updatedAt,
  });

  double get availableBalance => monthlyAmount - totalWithdrawn;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'monthlyAmount': monthlyAmount,
      'totalWithdrawn': totalWithdrawn,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      monthlyAmount: (map['monthlyAmount'] ?? 0.0).toDouble(),
      totalWithdrawn: (map['totalWithdrawn'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
