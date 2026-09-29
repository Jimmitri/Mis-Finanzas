class TransactionItem {
  int? id;
  int userId;
  String title;
  double amount;
  String type; // 'Gasto' o 'Ingreso'
  String category;
  String date; // 'YYYY-MM-DD'
  String description;

  TransactionItem({
    this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.description = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date,
      'description': description,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      category: map['category'] as String,
      date: map['date'] as String,
      description: (map['description'] as String?) ?? '',
    );
  }
}
