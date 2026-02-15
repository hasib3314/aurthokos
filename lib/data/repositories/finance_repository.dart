import '../database/app_database.dart';
import '../models/transaction_model.dart';
import '../../core/utils/currency_converter.dart';

class FinanceRepository {
  final AppDatabase _db = AppDatabase.instance;

  // === Transactions ===

  Future<void> addTransaction(TransactionModel transaction) async {
    await _db.insertTransaction(transaction);
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    return await _db.getAllTransactions();
  }

  Future<List<TransactionModel>> getTransactionsByType(
      TransactionType type) async {
    return await _db.getTransactionsByType(type);
  }

  Future<List<TransactionModel>> getRecentTransactions({int limit = 10}) async {
    return await _db.getRecentTransactions(limit: limit);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _db.updateTransaction(transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _db.deleteTransaction(id);
  }

  // === Balance Calculation ===

  Future<double> getTotalEarnings() async {
    return await _db.getTotalByType(TransactionType.earn);
  }

  Future<double> getTotalExpenses() async {
    return await _db.getTotalByType(TransactionType.expense);
  }

  Future<double> getTotalLoans() async {
    return await _db.getTotalByType(TransactionType.loan);
  }

  Future<double> getTotalSavings() async {
    return await _db.getTotalByType(TransactionType.savings);
  }

  Future<double> getBalance() async {
    return await _db.calculateBalance();
  }

  /// Get all amounts converted to a single target currency
  Future<Map<String, double>> getBalanceSummary(Currency targetCurrency) async {
    final allTransactions = await getAllTransactions();

    double totalEarn = 0;
    double totalExpense = 0;
    double totalLoan = 0;
    double totalSavings = 0;

    for (final t in allTransactions) {
      final amount = t.currency == targetCurrency
          ? t.amount
          : CurrencyConverter.convert(t.amount, t.currency, targetCurrency);

      switch (t.type) {
        case TransactionType.earn:
          totalEarn += amount;
          break;
        case TransactionType.expense:
          totalExpense += amount;
          break;
        case TransactionType.loan:
          totalLoan += amount;
          break;
        case TransactionType.savings:
          totalSavings += amount;
          break;
      }
    }

    return {
      'earn': totalEarn,
      'expense': totalExpense,
      'loan': totalLoan,
      'savings': totalSavings,
      'balance': (totalEarn + totalSavings) - (totalExpense + totalLoan),
    };
  }

  // === Settings ===

  Future<Map<String, dynamic>> getSettings() async {
    return await _db.getSettings();
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    await _db.updateSettings(settings);
  }

  Future<double> getLowBalanceThreshold() async {
    final settings = await getSettings();
    return (settings['lowBalanceThreshold'] as num).toDouble();
  }

  Future<bool> isBalanceBelowThreshold() async {
    final balance = await getBalance();
    final threshold = await getLowBalanceThreshold();
    return balance < threshold;
  }
}
