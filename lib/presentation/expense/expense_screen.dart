import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/transaction_model.dart';
import '../common/transaction_list_screen.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TransactionListScreen(
      title: AppStrings.expense,
      titleBn: AppStrings.expenseBn,
      type: TransactionType.expense,
      accentColor: AppColors.expenseColor,
      icon: Icons.trending_down_rounded,
    );
  }
}
