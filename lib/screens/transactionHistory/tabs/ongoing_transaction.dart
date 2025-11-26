import 'package:e_cycle/screens/transactionHistory/widgets/ongoing_transaction_card.dart';
import 'package:e_cycle/screens/transactionHistory/widgets/withdraw_request_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OngoingTransactionTab extends StatefulWidget {
  const OngoingTransactionTab({super.key});

  @override
  State<OngoingTransactionTab> createState() => _OngoingTransactionTabState();
}

class _OngoingTransactionTabState extends State<OngoingTransactionTab> {
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _pickupStream(User user) {
    return FirebaseFirestore.instance
        .collection('e_pickup')
        .doc(user.uid)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _withdrawUserDocStream(
      User user) {
    return FirebaseFirestore.instance
        .collection('withdraw_requests')
        .doc(user.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_circle_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                "User not logged in",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Pickup ongoing
          // StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          //   stream: _pickupStream(user),
          //   builder: (context, snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return const Padding(
          //         padding: EdgeInsets.all(16),
          //         child: CircularProgressIndicator(),
          //       );
          //     }
          //     if (!snapshot.hasData ||
          //         snapshot.data == null ||
          //         !snapshot.data!.exists) {
          //       return const SizedBox.shrink();
          //     }
          //     final data = snapshot.data!.data()!;
          //     return Column(
          //       children: [
          //         OngoingTransactionCard(
          //           selectedItems:
          //               Map<String, int>.from(data['selectedItems'] ?? {}),
          //           selectedTimes: data['selectedTimes'],
          //           streetName: data['streetName'] ?? data['dropPointAddress'],
          //           totalPrice: data['totalPrice'],
          //           adminFee: data['adminFee'],
          //           points: data['points'],
          //         ),
          //         const SizedBox(height: 8),
          //       ],
          //     );
          //   },
          // ),
          // Withdraw pending list (nested fields)
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _withdrawUserDocStream(user),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const CircularProgressIndicator(),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Error memuat withdraw",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Tidak ada penarikan pending",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Penarikan yang sedang diproses akan muncul di sini",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final raw = snapshot.data!.data()!;
              // Ambil setiap field yang berisi Map request
              final List<Map<String, dynamic>> pending = [];
              raw.forEach((key, value) {
                if (value is Map &&
                    value.containsKey('status') &&
                    value['status'] == 'pending') {
                  pending.add({
                    'id': key,
                    'data': value,
                  });
                }
              });

              if (pending.isEmpty) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Tidak ada penarikan pending",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Penarikan yang sedang diproses akan tampil di sini",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Sort descending by createdAt
              pending.sort((a, b) {
                final ta = a['data']['createdAt'] as Timestamp?;
                final tb = b['data']['createdAt'] as Timestamp?;
                if (ta == null && tb == null) return 0;
                if (ta == null) return 1;
                if (tb == null) return -1;
                return tb.compareTo(ta);
              });

              return Column(
                children: pending.map((e) {
                  final d = e['data'] as Map<String, dynamic>;
                  return WithdrawRequestCard(
                    userId: user.uid,
                    requestKey: e['id'] as String,
                    points: (d['pointsRequested'] ?? 0) as int,
                    bank: (d['bank'] ?? '') as String,
                    accountNumber: (d['accountNumber'] ?? '') as String,
                    status: (d['status'] ?? '') as String,
                    createdAt: d['createdAt'] as Timestamp?,
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
