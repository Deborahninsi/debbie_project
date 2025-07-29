class Savings {
  final String id;
  final String userId;
  final double totalSaved;
  final double availableForSpending;
  final DateTime createdAt;
  final DateTime updatedAt;

  Savings({
    required this.id,
    required this.userId,
    required this.totalSaved,
    required this.availableForSpending,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'totalSaved': totalSaved,
      'availableForSpending': availableForSpending,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Savings.fromMap(Map<String, dynamic> map) {
    return Savings(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      totalSaved: (map['totalSaved'] ?? 0.0).toDouble(),
      availableForSpending: (map['availableForSpending'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
