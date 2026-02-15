import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_converter.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/glassmorphic_card.dart';
import '../../data/repositories/finance_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FinanceRepository _repository = FinanceRepository();
  final _thresholdController = TextEditingController();
  Currency _defaultCurrency = Currency.bdt;
  bool _notificationsEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _repository.getSettings();
    setState(() {
      _defaultCurrency = Currency.values[settings['defaultCurrency'] as int];
      _thresholdController.text =
          (settings['lowBalanceThreshold'] as num).toStringAsFixed(0);
      _notificationsEnabled = (settings['enableNotifications'] as int) == 1;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    await _repository.updateSettings({
      'defaultCurrency': _defaultCurrency.index,
      'lowBalanceThreshold':
          double.tryParse(_thresholdController.text) ?? 1000.0,
      'enableNotifications': _notificationsEnabled ? 1 : 0,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Settings saved'),
          backgroundColor: AppColors.emerald,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.emerald))
              : Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Currency'),
                            const SizedBox(height: 8),
                            _buildCurrencySelector(),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Low Balance Warning'),
                            const SizedBox(height: 8),
                            _buildThresholdField(),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Notifications'),
                            const SizedBox(height: 8),
                            _buildNotificationToggle(),
                            const SizedBox(height: 40),
                            _buildSaveButton(),
                            const SizedBox(height: 24),
                            _buildAboutCard(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GlassmorphicIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          Text('Settings', style: context.textTheme.headlineMedium),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          _currencyOption(Currency.bdt, '৳ BDT', 'Bangladeshi Taka'),
          const SizedBox(width: 8),
          _currencyOption(Currency.usd, '\$ USD', 'US Dollar'),
        ],
      ),
    );
  }

  Widget _currencyOption(Currency currency, String label, String subtitle) {
    final isSelected = _defaultCurrency == currency;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _defaultCurrency = currency),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.emerald.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: AppColors.emerald.withValues(alpha: 0.4))
                : null,
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color:
                      isSelected ? AppColors.emerald : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: isSelected ? AppColors.emeraldLight : AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThresholdField() {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'You\'ll be notified when your balance drops below this amount',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: TextField(
                controller: _thresholdController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  prefixText:
                      '${CurrencyConverter.currencySymbol(_defaultCurrency)} ',
                  prefixStyle: const TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return GlassmorphicCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enable Notifications',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Low balance & loan reminders',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
          Switch.adaptive(
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
            activeTrackColor: AppColors.emerald,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emerald,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: const Text(
          'Save Settings',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return Center(
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'images/Orthokosh.png',
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.appName,
              style: context.textTheme.headlineMedium?.copyWith(
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'v1.0.0 • Personal Finance Manager',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),

          ],
        ),
      ),
    );
  }
}
