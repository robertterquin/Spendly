class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    required this.createdAt,
    this.accountId,
    this.notes,
  });

  final String id;
  final String userId;
  final String type; // 'income' | 'expense'
  final double amount;
  final String category;
  final DateTime date;
  final String? accountId;
  final String? notes;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String(),
        'accountId': accountId,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        type: json['type'] as String,
        amount: (json['amount'] as num).toDouble(),
        category: json['category'] as String,
        date: DateTime.parse(json['date'] as String),
        accountId: json['accountId'] as String?,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
}
