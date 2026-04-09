class AccountModel {
  const AccountModel({
    this.id = '',
    required this.userId,
    required this.name,
    required this.balance,
    required this.type,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String name;
  final double balance;
  final String type; // 'bank' | 'digital' | 'cash'
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        'balance': balance,
        'type': type,
      };

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        name: json['name'] as String,
        balance: (json['balance'] as num).toDouble(),
        type: json['type'] as String,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );

  AccountModel copyWith({
    String? name,
    double? balance,
    String? type,
  }) {
    return AccountModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      type: type ?? this.type,
      createdAt: createdAt,
    );
  }
}
