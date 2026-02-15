import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/currency_converter.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/finance_repository.dart';
import '../../services/balance_warning_service.dart';

class AddTransactionViewModel extends ChangeNotifier {
  final FinanceRepository _repository = FinanceRepository();
  final BalanceWarningService _warningService = BalanceWarningService();

  late TransactionType _type;
  Currency _currency = Currency.bdt;
  LoanType _loanType = LoanType.taken;
  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;
  DateTime? _targetDate;
  bool _isSaving = false;

  // Edit mode
  bool _isEditMode = false;
  String? _editingId;

  bool get isEditMode => _isEditMode;
  TransactionType get type => _type;
  Currency get currency => _currency;
  LoanType get loanType => _loanType;
  DateTime get selectedDate => _selectedDate;
  DateTime? get dueDate => _dueDate;
  DateTime? get targetDate => _targetDate;
  bool get isSaving => _isSaving;

  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final categoryController = TextEditingController();
  final personNameController = TextEditingController();
  final goalAmountController = TextEditingController();

  AddTransactionViewModel({
    TransactionType initialType = TransactionType.earn,
    TransactionModel? existingTransaction,
  }) {
    if (existingTransaction != null) {
      _isEditMode = true;
      _editingId = existingTransaction.id;
      _type = existingTransaction.type;
      _currency = existingTransaction.currency;
      _selectedDate = existingTransaction.date;
      _loanType = existingTransaction.loanType ?? LoanType.taken;
      _dueDate = existingTransaction.dueDate;
      _targetDate = existingTransaction.targetDate;

      titleController.text = existingTransaction.title;
      amountController.text = existingTransaction.amount.toString();
      categoryController.text = existingTransaction.category;
      noteController.text = existingTransaction.note ?? '';
      personNameController.text = existingTransaction.personName ?? '';
      goalAmountController.text =
          existingTransaction.goalAmount?.toString() ?? '';
    } else {
      _type = initialType;
    }
  }

  void setType(TransactionType type) {
    _type = type;
    notifyListeners();
  }

  void setCurrency(Currency currency) {
    _currency = currency;
    notifyListeners();
  }

  void setLoanType(LoanType loanType) {
    _loanType = loanType;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setDueDate(DateTime? date) {
    _dueDate = date;
    notifyListeners();
  }

  void setTargetDate(DateTime? date) {
    _targetDate = date;
    notifyListeners();
  }

  String? validate() {
    if (titleController.text.trim().isEmpty) return 'Please enter a title';
    if (amountController.text.trim().isEmpty) return 'Please enter an amount';
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) return 'Please enter a valid amount';
    if (categoryController.text.trim().isEmpty) {
      return 'Please enter a category';
    }
    if (_type == TransactionType.loan &&
        personNameController.text.trim().isEmpty) {
      return 'Please enter the person name for loan';
    }
    return null;
  }

  Future<bool> saveTransaction() async {
    _isSaving = true;
    notifyListeners();

    try {
      final transaction = TransactionModel(
        id: _isEditMode ? _editingId! : const Uuid().v4(),
        title: titleController.text.trim(),
        amount: double.parse(amountController.text.trim()),
        currency: _currency,
        type: _type,
        category: categoryController.text.trim(),
        date: _selectedDate,
        note: noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim(),
        loanType: _type == TransactionType.loan ? _loanType : null,
        personName: _type == TransactionType.loan
            ? personNameController.text.trim()
            : null,
        dueDate: _type == TransactionType.loan ? _dueDate : null,
        isPaid: _type == TransactionType.loan ? false : null,
        goalAmount: _type == TransactionType.savings
            ? double.tryParse(goalAmountController.text.trim())
            : null,
        targetDate: _type == TransactionType.savings ? _targetDate : null,
      );

      if (_isEditMode) {
        await _repository.updateTransaction(transaction);
      } else {
        await _repository.addTransaction(transaction);
      }

      // Check balance warning after adding expense/loan
      if (_type == TransactionType.expense || _type == TransactionType.loan) {
        await _warningService.checkAndNotify();
      }

      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error saving transaction: $e');
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
    categoryController.dispose();
    personNameController.dispose();
    goalAmountController.dispose();
    super.dispose();
  }
}
