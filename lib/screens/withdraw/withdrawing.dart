import 'package:e_cycle/constants/app_styles.dart';
import 'package:e_cycle/constants/colors.dart';
import 'package:e_cycle/screens/withdraw/widgets/airplane_gif.dart';
import 'package:e_cycle/screens/withdraw/widgets/withdraw_inputfield.dart';
import 'package:e_cycle/screens/widgets/new_header.dart';
import 'package:flutter/material.dart';

// Firebase Data
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Withdrawing extends StatelessWidget {
  final String withdrawDestination;
  const Withdrawing({super.key, required this.withdrawDestination});

  // Fetching User Data
  Stream<Map<String, dynamic>> _fetchUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((snapshot) => snapshot.data() ?? {});
    }
    return const Stream.empty();
  }

  // Get Points from User Data
  Stream<int> _fetchUserPoints() {
    return _fetchUserData().map((data) => data['points'] ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: NewHeader(title: "Withdraw"),
      body: Container(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 45),
            Center(
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Text(
                    'Tukar Ke ${withdrawDestination.toUpperCase()}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 20),
                  ),
                  const Text(
                    'Silahkan masukkan jumlah yang ingin ditukar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  WithdrawInputfield(),
                  const SizedBox(
                    height: 8,
                  ),
                  StreamBuilder<int>(
                    stream: _fetchUserPoints(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return const Text('Error fetching points');
                      }
                      int points = snapshot.data ?? 0;
                      return Row(
                        children: [
                          const Text(
                            'Poin Kamu :',
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 13,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Image.asset(
                            'assets/images/coin.png',
                            width: 30,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            '$points',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w200,
                              fontFamily: 'Poppins',
                            ),
                          )
                        ],
                      );
                    },
                  ),
                  const SizedBox(
                    height: 128,
                  ),
                  ElevatedButton(
                    onPressed: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => const MenukarDialog(),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: primaryColor,
                      minimumSize: const Size(372, 50),
                    ),
                    child: Text(
                      "Tukarkan",
                      style: AppStyles.descriptionStyle
                          .copyWith(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenukarDialog extends StatelessWidget {
  const MenukarDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => const BerhasilDialog(),
          );
        },
        child: Container(
          width: 372,
          height: 200,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AirplaneGif(),
              const SizedBox(
                height: 10,
              ),
              Text('Menukar...',
                  style: AppStyles.descriptionStyle.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class BerhasilDialog extends StatelessWidget {
  const BerhasilDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Container(
        width: 372,
        height: 200,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/success-tick.gif',
              width: 140,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Berhasil!',
              style: AppStyles.descriptionStyle.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
