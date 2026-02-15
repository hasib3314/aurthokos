import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/transaction_model.dart';
import '../common/transaction_list_screen.dart';

class LoanScreen extends StatelessWidget {
  const LoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TransactionListScreen(
      title: AppStrings.loan,
      titleBn: AppStrings.loanBn,
      type: TransactionType.loan,
      accentColor: AppColors.loanColor,
      icon: Icons.handshake_outlined,
    );
  }
}
