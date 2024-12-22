import 'package:e_cycle/constants/colors.dart';
import 'package:e_cycle/screens/auth/login.dart';
import 'package:e_cycle/screens/profile/Peringkat/national.dart';
import 'package:e_cycle/screens/profile/widgets/header.dart';
import 'package:e_cycle/screens/profile/widgets/list_menu.dart';
import 'package:e_cycle/screens/profile/widgets/list_menua.dart';
import 'package:e_cycle/screens/profile/widgets/logout.dart';
import 'package:e_cycle/screens/transactionHistory/transaction_history.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_cycle/screens/splash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_cycle/screens/withdraw/withdraw.dart';
import 'package:e_cycle/screens/notification/notification_page.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Stream<DocumentSnapshot> _userPointsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 72,
              child: Header,
              decoration: const BoxDecoration(
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 7),
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: Colors.white, // White outline
                              width: 3.0,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              widget.user.photoURL ??
                                  'https://via.placeholder.com/150',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          widget.user.displayName ?? 'No Name',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          widget.user.email ?? 'No Email',
                          style: TextStyle(
                            color: const Color(0xff000000).withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 26),
                        _buildPointsCard(),
                        const SizedBox(height: 35),
                        _buildMenuItems(context),
                        const SizedBox(height: 127),
                        const Align(
                          alignment: Alignment.center,
                          child: Text("Versi 1.0.0"),
                        ),
                        const SizedBox(height: 72),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsCard() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userPointsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text("No data available");
        }
        final userDoc = snapshot.data!;
        final points = userDoc['points'] ?? 0;
        return Container(
          width: 372,
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                offset: const Offset(2, 2),
                color: primaryColor.withOpacity(0.24),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(width: 22),
                  Image.asset('assets/images/coin.png', width: 36),
                  Text(
                    "$points",
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 20),
                  ),
                  const Text(
                    " E-Point",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
                  ),
                ],
              ),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 0.5,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to tukar
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const WithdrawPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff009421),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Tukarkan",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NationalPage()),
          ),
          child: ListMenua(
            title: 'Peringkat',
            image: 'assets/images/v_rank.png',
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationPage()),
          ),
          child: ListMenua(
              title: 'Notifikasi', image: 'assets/images/v_notif.png'),
        ),
        const SizedBox(height: 10),
        ListMenu(
          title: 'Kebijakan Privasi',
          image: 'assets/images/v_policy.png',
        ),
        const SizedBox(height: 10),
        ListMenua(title: 'Medali-ku', image: 'assets/images/v_medal.png'),
        const SizedBox(height: 10),
        ListMenua(title: 'Ganti Password', image: 'assets/images/v_pass.png'),
        const SizedBox(height: 10),
        ListMenua(title: 'Pusat Bantuan', image: 'assets/images/v_help.png'),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return const Login();
                },
              ),
              (_) => false,
            );
          },
          child: Logout(title: 'Log Out', image: 'assets/images/v_logout.png'),
        ),
      ],
    );
  }
}
