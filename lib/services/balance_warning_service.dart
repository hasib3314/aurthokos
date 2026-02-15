import '../data/repositories/finance_repository.dart';
import '../core/constants/app_strings.dart';
import 'notification_service.dart';

class BalanceWarningService {
  final FinanceRepository _repository = FinanceRepository();
  final NotificationService _notificationService = NotificationService();

  static const int _lowBalanceNotificationId = 1001;

  /// Check balance and trigger warning if below threshold
  Future<bool> checkAndNotify() async {
    final balance = await _repository.getBalance();
    final threshold = await _repository.getLowBalanceThreshold();
    final settings = await _repository.getSettings();
    final notificationsEnabled = (settings['enableNotifications'] as int) == 1;

    if (balance < threshold && notificationsEnabled) {
      await _notificationService.showNotification(
        id: _lowBalanceNotificationId,
        title: AppStrings.lowBalanceTitle,
        body:
            '${AppStrings.lowBalanceBody}\nCurrent: ৳${balance.toStringAsFixed(2)} | Threshold: ৳${threshold.toStringAsFixed(2)}',
      );
      return true;
    }
    return false;
  }

  /// Get current balance status
  Future<Map<String, dynamic>> getBalanceStatus() async {
    final balance = await _repository.getBalance();
    final threshold = await _repository.getLowBalanceThreshold();

    return {
      'balance': balance,
      'threshold': threshold,
      'isBelowThreshold': balance < threshold,
      'percentage': threshold > 0 ? (balance / threshold * 100) : 100.0,
    };
  }
}
