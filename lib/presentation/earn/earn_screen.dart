import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/transaction_model.dart';
import '../common/transaction_list_screen.dart';

class EarnScreen extends StatelessWidget {
  const EarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TransactionListScreen(
      title: AppStrings.earn,
      titleBn: AppStrings.earnBn,
      type: TransactionType.earn,
      accentColor: AppColors.earnColor,
      icon: Icons.trending_up_rounded,
    );
  }
}
