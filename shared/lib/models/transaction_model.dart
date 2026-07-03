enum TransactionType { Withdrawal, Upgrade, DirectCommission, IndirectCommission }

enum TransactionStatus { Pending, Approved, Rejected, Success }

class TransactionModel {
  final String id;
  final String agentCode;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final String description;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.agentCode,
    required this.amount,
    required this.type,
    required this.status,
    required this.description,
    required this.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // agentCode may come from included agent relation
    final agentCode = (json['agent'] != null
        ? json['agent']['agentCode'] as String?
        : null) ?? json['agentCode'] as String? ?? '';

    return TransactionModel(
      id: json['id'] as String,
      agentCode: agentCode,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: TransactionType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'Withdrawal'),
        orElse: () => TransactionType.Withdrawal,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'Pending'),
        orElse: () => TransactionStatus.Pending,
      ),
      description: json['description'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agentCode': agentCode,
      'amount': amount,
      'type': type.name,
      'status': status.name,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  TransactionModel copyWith({
    String? id,
    String? agentCode,
    double? amount,
    TransactionType? type,
    TransactionStatus? status,
    String? description,
    DateTime? date,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      agentCode: agentCode ?? this.agentCode,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }
}
