class TransactionModel {
  final String id;
  final String userId;
  final String type;
  final double amount;
  final String? toId;
  final String? toName;
  final String? fromName;
  final String description;
  final DateTime timestamp;

  TransactionModel({
    required this.id, required this.userId, required this.type,
    required this.amount, this.toId, this.toName, this.fromName,
    required this.description, required this.timestamp,
  });

  String get icon {
    switch (type) {
      case 'load_sc': return '💰';
      case 'transfer_out': return '💸';
      case 'transfer_in': return '📥';
      case 'loan': return '🏦';
      case 'loan_payment': return '💳';
      case 'save': return '📈';
      case 'withdraw': return '📤';
      case 'bonus': return '🎁';
      case 'box_purchase': return '📦';
      case 'prize_purchase': return '🏆';
      default: return '💫';
    }
  }

  bool get isPositive => amount > 0;

  Map<String, dynamic> toMap() => {
    'userId': userId, 'type': type, 'amount': amount,
    'toId': toId, 'toName': toName, 'fromName': fromName,
    'description': description, 'timestamp': timestamp.toIso8601String(),
  };

  factory TransactionModel.fromMap(String id, Map<String, dynamic> d) =>
      TransactionModel(
        id: id, userId: d['userId'] ?? '', type: d['type'] ?? '',
        amount: (d['amount'] ?? 0).toDouble(),
        toId: d['toId'], toName: d['toName'], fromName: d['fromName'],
        description: d['description'] ?? '',
        timestamp: d['timestamp'] != null
            ? DateTime.tryParse(d['timestamp']) ?? DateTime.now()
            : DateTime.now(),
      );
}
