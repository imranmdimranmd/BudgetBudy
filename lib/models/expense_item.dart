class ExpenseItem {
  final int? id;
  final int subcategoryId;
  final String name;
  final double amount;
  final DateTime date;
  final String? note;

  ExpenseItem({
    this.id,
    required this.subcategoryId,
    required this.name,
    required this.amount,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'subcategory_id': subcategoryId,
        'name': name,
        'amount': amount,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory ExpenseItem.fromMap(Map<String, dynamic> map) => ExpenseItem(
        id: map['id'] as int?,
        subcategoryId: map['subcategory_id'] as int,
        name: map['name'] as String,
        amount: (map['amount'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        note: map['note'] as String?,
      );
}
