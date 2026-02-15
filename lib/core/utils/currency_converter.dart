import 'package:intl/intl.dart';

enum Currency { bdt, usd }

class CurrencyConverter {
  CurrencyConverter._();

  // Approximate exchange rate (can be updated dynamically later)
  static const double _bdtToUsd = 0.0091; // 1 BDT = ~0.0091 USD
  static const double _usdToBdt = 110.0; // 1 USD = ~110 BDT

  static double convert(double amount, Currency from, Currency to) {
    if (from == to) return amount;
    if (from == Currency.bdt && to == Currency.usd) {
      return amount * _bdtToUsd;
    }
    return amount * _usdToBdt;
  }

  static String format(double amount, Currency currency) {
    final formatter = NumberFormat('#,##0.00');
    final symbol = currency == Currency.bdt ? '৳' : '\$';
    return '$symbol${formatter.format(amount)}';
  }

  static String formatCompact(double amount, Currency currency) {
    final symbol = currency == Currency.bdt ? '৳' : '\$';
    if (amount >= 10000000) {
      return '$symbol${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '$symbol${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static String currencySymbol(Currency currency) {
    return currency == Currency.bdt ? '৳' : '\$';
  }

  static String currencyCode(Currency currency) {
    return currency == Currency.bdt ? 'BDT' : 'USD';
  }
}
