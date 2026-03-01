class IncomeEntry {
  final int? id;
  final double amount;
  final String note;
  final DateTime date;
  final bool isPaid;

  IncomeEntry({
    this.id,
    required this.amount,
    required this.note,
    required this.date,
    this.isPaid = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'date': date.toIso8601String(),
      'isPaid': isPaid ? 1 : 0,
    };
  }

  factory IncomeEntry.fromMap(Map<String, dynamic> map) {
    return IncomeEntry(
      id: map['id'],
      amount: map['amount'],
      note: map['note'],
      date: DateTime.parse(map['date']),
      isPaid: map['isPaid'] == 1,
    );
  }

  IncomeEntry copyWith({
    int? id,
    double? amount,
    String? note,
    DateTime? date,
    bool? isPaid,
  }) {
    return IncomeEntry(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}
