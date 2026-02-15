import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/transaction_model.dart';
import '../common/transaction_list_screen.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TransactionListScreen(
      title: AppStrings.savings,
      titleBn: AppStrings.savingsBn,
      type: TransactionType.savings,
      accentColor: AppColors.savingsColor,
      icon: Icons.savings_outlined,
    );
  }
}
