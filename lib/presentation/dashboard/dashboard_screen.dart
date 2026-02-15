import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_converter.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/glassmorphic_card.dart';
import '../../data/models/transaction_model.dart';
import '../add_transaction/add_transaction_screen.dart';
import '../earn/earn_screen.dart';
import '../expense/expense_screen.dart';
import '../loan/loan_screen.dart';
import '../savings/savings_screen.dart';
import '../settings/settings_screen.dart';
import 'dashboard_viewmodel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadDashboard();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Consumer<DashboardViewModel>(
              builder: (context, vm, _) {
                if (vm.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.emerald),
                  );
                }
                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildAppBar(vm),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 8),
                          _buildBalanceCard(vm),
                          const SizedBox(height: 24),
                          _buildCategoryGrid(vm),
                          const SizedBox(height: 24),
                          _buildRecentTransactionsHeader(),
                          const SizedBox(height: 8),
                          ...vm.recentTransactions.isEmpty
                              ? [_buildEmptyState()]
                              : vm.recentTransactions
                                  .map((t) => _buildTransactionTile(t, vm)),
                          const SizedBox(height: 80),
                        ]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildAppBar(DashboardViewModel vm) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.goldAccentGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '৳',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appName,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                AppStrings.appTagline,
                style: context.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
      actions: [
        GlassmorphicIconButton(
          icon: Icons.settings_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ).then((_) => vm.loadDashboard());
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBalanceCard(DashboardViewModel vm) {
    return GlassmorphicCard(
      blur: 30,
      opacity: 0.15,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.emeraldDark.withValues(alpha: 0.6),
          AppColors.emeraldDarkest.withValues(alpha: 0.8),
          const Color(0xFF0A3D2E).withValues(alpha: 0.6),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.totalBalance,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.emeraldLightest,
                ),
              ),
              GestureDetector(
                onTap: vm.toggleCurrency,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    CurrencyConverter.currencyCode(vm.selectedCurrency),
                    style: const TextStyle(
                      color: AppColors.goldLightest,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (vm.isLowBalance)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.goldLight,
                    size: 28,
                  ),
                ),
              Expanded(
                child: Text(
                  CurrencyConverter.format(
                      vm.totalBalance, vm.selectedCurrency),
                  style: context.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: vm.isLowBalance
                        ? AppColors.goldLight
                        : AppColors.textPrimary,
                    fontSize: 36,
                  ),
                ),
              ),
            ],
          ),
          if (vm.isLowBalance)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.goldLight.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: AppColors.goldLight, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Balance below threshold',
                    style: TextStyle(color: AppColors.goldLight, fontSize: 12),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          // Mini summary row
          Row(
            children: [
              _buildMiniStat(
                  'Income', vm.totalEarnings, AppColors.earnColor, vm),
              _buildMiniStat(
                  'Expense', vm.totalExpenses, AppColors.expenseColor, vm),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
      String label, double amount, Color color, DashboardViewModel vm) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                Text(
                  CurrencyConverter.formatCompact(
                      amount, vm.selectedCurrency),
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(DashboardViewModel vm) {
    final categories = [
      _CategoryItem(
        title: AppStrings.earn,
        titleBn: AppStrings.earnBn,
        icon: Icons.trending_up_rounded,
        amount: vm.totalEarnings,
        color: AppColors.earnColor,
        screen: const EarnScreen(),
      ),
      _CategoryItem(
        title: AppStrings.expense,
        titleBn: AppStrings.expenseBn,
        icon: Icons.trending_down_rounded,
        amount: vm.totalExpenses,
        color: AppColors.expenseColor,
        screen: const ExpenseScreen(),
      ),
      _CategoryItem(
        title: AppStrings.loan,
        titleBn: AppStrings.loanBn,
        icon: Icons.handshake_outlined,
        amount: vm.totalLoans,
        color: AppColors.loanColor,
        screen: const LoanScreen(),
      ),
      _CategoryItem(
        title: AppStrings.savings,
        titleBn: AppStrings.savingsBn,
        icon: Icons.savings_outlined,
        amount: vm.totalSavings,
        color: AppColors.savingsColor,
        screen: const SavingsScreen(),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return _buildCategoryCard(cat, vm);
      },
    );
  }

  Widget _buildCategoryCard(_CategoryItem cat, DashboardViewModel vm) {
    return GlassmorphicCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => cat.screen),
        ).then((_) => vm.loadDashboard());
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(cat.icon, color: cat.color, size: 22),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textMuted,
                size: 14,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cat.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                CurrencyConverter.formatCompact(
                    cat.amount, vm.selectedCurrency),
                style: TextStyle(
                  color: cat.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppStrings.recentTransactions,
          style: context.textTheme.headlineMedium,
        ),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.glassWhite,
          ),
          child: const Icon(
            Icons.history_rounded,
            color: AppColors.textMuted,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            color: AppColors.textMuted,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noTransactions,
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first entry',
            style: context.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(
      TransactionModel transaction, DashboardViewModel vm) {
    final isIncome = transaction.type == TransactionType.earn ||
        transaction.type == TransactionType.savings;
    final color = _getTypeColor(transaction.type);
    final icon = _getTypeIcon(transaction.type);

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) => vm.deleteTransaction(transaction.id),
      child: GlassmorphicCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        borderRadius: 16,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${transaction.category} • ${transaction.date.relativeDate}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}${CurrencyConverter.format(transaction.amount, transaction.currency)}',
              style: TextStyle(
                color: isIncome ? AppColors.earnColor : AppColors.expenseColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Consumer<DashboardViewModel>(
      builder: (context, vm, _) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: AppColors.goldAccentGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddTransactionScreen()),
            ).then((_) => vm.loadDashboard());
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    );
  }

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.earn:
        return AppColors.earnColor;
      case TransactionType.expense:
        return AppColors.expenseColor;
      case TransactionType.loan:
        return AppColors.loanColor;
      case TransactionType.savings:
        return AppColors.savingsColor;
    }
  }

  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.earn:
        return Icons.trending_up_rounded;
      case TransactionType.expense:
        return Icons.trending_down_rounded;
      case TransactionType.loan:
        return Icons.handshake_outlined;
      case TransactionType.savings:
        return Icons.savings_outlined;
    }
  }
}

class _CategoryItem {
  final String title;
  final String titleBn;
  final IconData icon;
  final double amount;
  final Color color;
  final Widget screen;

  _CategoryItem({
    required this.title,
    required this.titleBn,
    required this.icon,
    required this.amount,
    required this.color,
    required this.screen,
  });
}
