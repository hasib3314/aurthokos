import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_converter.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/glassmorphic_card.dart';
import '../../data/models/transaction_model.dart';
import 'add_transaction_viewmodel.dart';

class AddTransactionScreen extends StatelessWidget {
  final TransactionType initialType;
  final TransactionModel? existingTransaction;

  const AddTransactionScreen({
    super.key,
    this.initialType = TransactionType.earn,
    this.existingTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddTransactionViewModel(
        initialType: initialType,
        existingTransaction: existingTransaction,
      ),
      child: const _AddTransactionBody(),
    );
  }
}

class _AddTransactionBody extends StatelessWidget {
  const _AddTransactionBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Consumer<AddTransactionViewModel>(
            builder: (context, vm, _) {
              return Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTypeSelector(context, vm),
                          const SizedBox(height: 20),
                          _buildFormFields(context, vm),
                          const SizedBox(height: 30),
                          _buildSaveButton(context, vm),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final vm = context.read<AddTransactionViewModel>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GlassmorphicIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          Text(
            vm.isEditMode ? 'Edit Transaction' : 'Add Transaction',
            style: context.textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(
      BuildContext context, AddTransactionViewModel vm) {
    final types = [
      (TransactionType.earn, 'Earn', Icons.trending_up_rounded, AppColors.earnColor),
      (TransactionType.expense, 'Expense', Icons.trending_down_rounded, AppColors.expenseColor),
      (TransactionType.loan, 'Loan', Icons.handshake_outlined, AppColors.loanColor),
      (TransactionType.savings, 'Savings', Icons.savings_outlined, AppColors.savingsColor),
    ];

    return GlassmorphicCard(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: types.map((t) {
          final isSelected = vm.type == t.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => vm.setType(t.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? t.$4.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: t.$4.withValues(alpha: 0.5))
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(t.$3, color: isSelected ? t.$4 : AppColors.textMuted, size: 22),
                    const SizedBox(height: 4),
                    Text(
                      t.$2,
                      style: TextStyle(
                        color: isSelected ? t.$4 : AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFormFields(
      BuildContext context, AddTransactionViewModel vm) {
    return Column(
      children: [
        _buildTextField(
          controller: vm.titleController,
          label: 'Title',
          icon: Icons.title_rounded,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildTextField(
                controller: vm.amountController,
                label: 'Amount',
                icon: Icons.attach_money_rounded,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: _buildCurrencyToggle(vm),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: vm.categoryController,
          label: 'Category',
          icon: Icons.category_outlined,
          hint: _getCategoryHint(vm.type),
        ),
        const SizedBox(height: 14),
        _buildDatePicker(context, vm),
        const SizedBox(height: 14),
        if (vm.type == TransactionType.loan) ...[
          _buildLoanTypeSelector(vm),
          const SizedBox(height: 14),
          _buildTextField(
            controller: vm.personNameController,
            label: 'Person Name',
            icon: Icons.person_outlined,
          ),
          const SizedBox(height: 14),
          _buildDueDatePicker(context, vm),
          const SizedBox(height: 14),
        ],
        if (vm.type == TransactionType.savings) ...[
          _buildTextField(
            controller: vm.goalAmountController,
            label: 'Goal Amount (Optional)',
            icon: Icons.flag_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          _buildTargetDatePicker(context, vm),
          const SizedBox(height: 14),
        ],
        _buildTextField(
          controller: vm.noteController,
          label: 'Note (Optional)',
          icon: Icons.note_outlined,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? hint,
    int maxLines = 1,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.emeraldLight, size: 20),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.07),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.emerald, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyToggle(AddTransactionViewModel vm) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(0),
      borderRadius: 14,
      margin: EdgeInsets.zero,
      onTap: () {
        vm.setCurrency(
            vm.currency == Currency.bdt ? Currency.usd : Currency.bdt);
      },
      child: Container(
        height: 56,
        alignment: Alignment.center,
        child: Text(
          vm.currency == Currency.bdt ? '৳ BDT' : '\$ USD',
          style: const TextStyle(
            color: AppColors.goldLight,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(
      BuildContext context, AddTransactionViewModel vm) {
    return GlassmorphicCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 14,
      margin: EdgeInsets.zero,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: vm.selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) => _datePickerTheme(child),
        );
        if (date != null) vm.setDate(date);
      },
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded,
              color: AppColors.emeraldLight, size: 20),
          const SizedBox(width: 12),
          Text(
            'Date: ${vm.selectedDate.formatted}',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildDueDatePicker(
      BuildContext context, AddTransactionViewModel vm) {
    return GlassmorphicCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 14,
      margin: EdgeInsets.zero,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: vm.dueDate ?? DateTime.now().add(const Duration(days: 30)),
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
          builder: (context, child) => _datePickerTheme(child),
        );
        vm.setDueDate(date);
      },
      child: Row(
        children: [
          const Icon(Icons.event_outlined,
              color: AppColors.loanColor, size: 20),
          const SizedBox(width: 12),
          Text(
            vm.dueDate != null
                ? 'Due: ${vm.dueDate!.formatted}'
                : 'Set Due Date (Optional)',
            style: TextStyle(
              color: vm.dueDate != null
                  ? AppColors.textPrimary
                  : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetDatePicker(
      BuildContext context, AddTransactionViewModel vm) {
    return GlassmorphicCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 14,
      margin: EdgeInsets.zero,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: vm.targetDate ?? DateTime.now().add(const Duration(days: 90)),
          firstDate: DateTime.now(),
          lastDate: DateTime(2035),
          builder: (context, child) => _datePickerTheme(child),
        );
        vm.setTargetDate(date);
      },
      child: Row(
        children: [
          const Icon(Icons.flag_outlined,
              color: AppColors.savingsColor, size: 20),
          const SizedBox(width: 12),
          Text(
            vm.targetDate != null
                ? 'Target: ${vm.targetDate!.formatted}'
                : 'Set Target Date (Optional)',
            style: TextStyle(
              color: vm.targetDate != null
                  ? AppColors.textPrimary
                  : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanTypeSelector(AddTransactionViewModel vm) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(8),
      borderRadius: 14,
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => vm.setLoanType(LoanType.taken),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: vm.loanType == LoanType.taken
                      ? AppColors.loanColor.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Taken',
                    style: TextStyle(
                      color: vm.loanType == LoanType.taken
                          ? AppColors.loanColor
                          : AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => vm.setLoanType(LoanType.given),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: vm.loanType == LoanType.given
                      ? AppColors.emerald.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Given',
                    style: TextStyle(
                      color: vm.loanType == LoanType.given
                          ? AppColors.emerald
                          : AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(
      BuildContext context, AddTransactionViewModel vm) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: ElevatedButton(
            onPressed: vm.isSaving
                ? null
                : () async {
                    final error = vm.validate();
                    if (error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error),
                          backgroundColor: AppColors.expenseColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                      return;
                    }
                    final success = await vm.saveTransaction();
                    if (success && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: vm.isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    vm.isEditMode ? 'Update Transaction' : 'Save Transaction',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _datePickerTheme(Widget? child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: AppColors.emerald,
          surface: AppColors.bgMedium,
          onSurface: AppColors.textPrimary,
        ),
      ),
      child: child!,
    );
  }

  String _getCategoryHint(TransactionType type) {
    switch (type) {
      case TransactionType.earn:
        return 'e.g., Salary, Freelance, Business';
      case TransactionType.expense:
        return 'e.g., Food, Transport, Rent';
      case TransactionType.loan:
        return 'e.g., Personal, Business, Emergency';
      case TransactionType.savings:
        return 'e.g., Emergency Fund, Travel, Education';
    }
  }
}
