import 'package:e_cycle/screens/transactionHistory/widgets/ongoing_transaction_card.dart';
import 'package:flutter/material.dart';
// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OngoingTransactionTab extends StatefulWidget {
  const OngoingTransactionTab({super.key});

  @override
  _OngoingTransactionTabState createState() => _OngoingTransactionTabState();
}

class _OngoingTransactionTabState extends State<OngoingTransactionTab> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("User not logged in"));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('e_pickup')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            !snapshot.data!.exists) {
          return const Center(child: Text("No Data Available"));
        }

        Map<String, dynamic> transactionData =
            snapshot.data!.data() as Map<String, dynamic>;

        return Column(
          children: [
            OngoingTransactionCard(
              selectedItems:
                  Map<String, int>.from(transactionData['selectedItems']),
              selectedTimes: transactionData['selectedTimes'],
              streetName: transactionData['streetName'],
              totalPrice: transactionData['totalPrice'],
              adminFee: transactionData['adminFee'],
              points: transactionData['points'],
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
