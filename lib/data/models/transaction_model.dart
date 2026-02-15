import '../../core/utils/currency_converter.dart';

enum TransactionType { earn, expense, loan, savings }

enum LoanType { given, taken }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final Currency currency;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String? note;

  // Loan-specific fields
  final LoanType? loanType;
  final String? personName;
  final DateTime? dueDate;
  final bool? isPaid;

  // Savings-specific fields
  final double? goalAmount;
  final DateTime? targetDate;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.currency,
    required this.type,
    required this.category,
    required this.date,
    this.note,
    this.loanType,
    this.personName,
    this.dueDate,
    this.isPaid,
    this.goalAmount,
    this.targetDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'currency': currency.index,
      'type': type.index,
      'category': category,
      'date': date.millisecondsSinceEpoch,
      'note': note,
      'loanType': loanType?.index,
      'personName': personName,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'isPaid': isPaid == true ? 1 : 0,
      'goalAmount': goalAmount,
      'targetDate': targetDate?.millisecondsSinceEpoch,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: Currency.values[map['currency'] as int],
      type: TransactionType.values[map['type'] as int],
      category: map['category'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      note: map['note'] as String?,
      loanType: map['loanType'] != null
          ? LoanType.values[map['loanType'] as int]
          : null,
      personName: map['personName'] as String?,
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int)
          : null,
      isPaid: map['isPaid'] != null ? (map['isPaid'] as int) == 1 : null,
      goalAmount: map['goalAmount'] != null
          ? (map['goalAmount'] as num).toDouble()
          : null,
      targetDate: map['targetDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['targetDate'] as int)
          : null,
    );
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    Currency? currency,
    TransactionType? type,
    String? category,
    DateTime? date,
    String? note,
    LoanType? loanType,
    String? personName,
    DateTime? dueDate,
    bool? isPaid,
    double? goalAmount,
    DateTime? targetDate,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      loanType: loanType ?? this.loanType,
      personName: personName ?? this.personName,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
      goalAmount: goalAmount ?? this.goalAmount,
      targetDate: targetDate ?? this.targetDate,
    );
  }
}
