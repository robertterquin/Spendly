class TransactionModel {
  const TransactionModel({
    this.id = '',
    required this.userId,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    this.createdAt,
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
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'type': type,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String().split('T').first,
        'account_id': accountId,
        'notes': notes,
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        type: json['type'] as String,
        amount: (json['amount'] as num).toDouble(),
        category: json['category'] as String,
        date: DateTime.parse(json['date'] as String),
        accountId: json['account_id'] as String?,
        notes: json['notes'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
}
