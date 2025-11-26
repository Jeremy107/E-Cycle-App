import 'package:e_cycle/constants/app_styles.dart';
import 'package:e_cycle/constants/colors.dart';
import 'package:e_cycle/models/withdraw_items.dart';
import 'package:e_cycle/screens/withdraw/widgets/withdraw_icon.dart';
import 'package:flutter/material.dart';

class WithdrawMoneyTab extends StatelessWidget {
  const WithdrawMoneyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section with Icon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Withdraw Point",
                      style: AppStyles.titleStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Tukar point-mu menjadi saldo",
                      style: AppStyles.descriptionStyle.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // E-Wallet Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 0,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.phone_android_rounded,
                      color: Colors.orange.shade600,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'E-Wallet',
                    style: AppStyles.titleStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  WithdrawIcon(
                      image: 'assets/images/withdraw_dana.png', title: 'Dana'),
                  WithdrawIcon(
                      image: 'assets/images/withdraw_gopay.png',
                      title: 'Gopay'),
                  WithdrawIcon(
                      image: 'assets/images/withdraw_ovo.png', title: 'OVO'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Bank Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 0,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.account_balance_rounded,
                      color: primaryColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Transfer Bank',
                    style: AppStyles.titleStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Bank Grid - First Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  WithdrawIcon(
                    title: withdrawItems[0]['title']!,
                    image: withdrawItems[0]['image']!,
                  ),
                  WithdrawIcon(
                    title: withdrawItems[1]['title']!,
                    image: withdrawItems[1]['image']!,
                  ),
                  WithdrawIcon(
                    title: withdrawItems[2]['title']!,
                    image: withdrawItems[2]['image']!,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Bank Grid - Second Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  WithdrawIcon(
                    title: withdrawItems[3]['title']!,
                    image: withdrawItems[3]['image']!,
                  ),
                  WithdrawIcon(
                    title: withdrawItems[4]['title']!,
                    image: withdrawItems[4]['image']!,
                  ),
                  WithdrawIcon(
                    title: withdrawItems[5]['title']!,
                    image: withdrawItems[5]['image']!,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Bank Grid - Third Row
            ],
          ),
        ),
      ],
    );
  }
}
