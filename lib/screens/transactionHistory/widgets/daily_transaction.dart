import 'package:flutter/material.dart';
import '../../../constants/app_styles.dart';
import 'transaction_tile.dart';

class DailyTransaction extends StatelessWidget {
  final String date;
  final List<Map<String, dynamic>> transactionData;

  const DailyTransaction({
    super.key,
    required this.date,
    required this.transactionData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                date,
                style: AppStyles.boldStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: transactionData.map((e) {
            // Normalisasi semua field ke String aman
            final norm = {
              'title': (e['title'] ?? '').toString(),
              'subtitle': (e['subtitle'] ?? '').toString(),
              'status': (e['status'] ?? '').toString(),
              'amount': (e['amount'] ?? '').toString(),
              'createdAt': e['createdAt'], // biarkan Timestamp kalau ada
            };
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TransactionTile(transactionData: norm),
            );
          }).toList(),
        ),
      ],
    );
  }
}
