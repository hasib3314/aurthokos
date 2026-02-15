import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/finance_repository.dart';
import '../../core/utils/currency_converter.dart';
import '../../services/balance_warning_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final FinanceRepository _repository = FinanceRepository();
  final BalanceWarningService _warningService = BalanceWarningService();

  List<TransactionModel> _recentTransactions = [];
  double _totalBalance = 0;
  double _totalEarnings = 0;
  double _totalExpenses = 0;
  double _totalLoans = 0;
  double _totalSavings = 0;
  Currency _selectedCurrency = Currency.bdt;
  bool _isLoading = true;
  bool _isLowBalance = false;

  List<TransactionModel> get recentTransactions => _recentTransactions;
  double get totalBalance => _totalBalance;
  double get totalEarnings => _totalEarnings;
  double get totalExpenses => _totalExpenses;
  double get totalLoans => _totalLoans;
  double get totalSavings => _totalSavings;
  Currency get selectedCurrency => _selectedCurrency;
  bool get isLoading => _isLoading;
  bool get isLowBalance => _isLowBalance;

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      final summary =
          await _repository.getBalanceSummary(_selectedCurrency);
      _totalEarnings = summary['earn']!;
      _totalExpenses = summary['expense']!;
      _totalLoans = summary['loan']!;
      _totalSavings = summary['savings']!;
      _totalBalance = summary['balance']!;

      _recentTransactions = await _repository.getRecentTransactions(limit: 10);

      // Check low balance warning
      final status = await _warningService.getBalanceStatus();
      _isLowBalance = status['isBelowThreshold'] as bool;

      if (_isLowBalance) {
        await _warningService.checkAndNotify();
      }
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleCurrency() {
    _selectedCurrency =
        _selectedCurrency == Currency.bdt ? Currency.usd : Currency.bdt;
    loadDashboard();
  }

  Future<void> deleteTransaction(String id) async {
    await _repository.deleteTransaction(id);
    await loadDashboard();
  }
}
