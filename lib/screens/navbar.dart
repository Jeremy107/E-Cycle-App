import 'package:e_cycle/screens/scan/scan.dart';
import 'package:e_cycle/screens/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:e_cycle/constants/colors.dart';
import 'package:e_cycle/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'transactionHistory/transaction_history.dart';
import 'task/task.dart';

class Navbar extends StatefulWidget {
  final User user;

  const Navbar({Key? key, required this.user}) : super(key: key);

  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  late List<Widget> _pages;

  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pages = [
      Home(user: widget.user),
      const TransactionHistory(),
      const Scan(),
      const ETaskPage(),
      ProfilePage(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      hideNavigationBar: false,
      tabs: [
        PersistentTabConfig(
          screen: Home(user: widget.user),
          item: ItemConfig(
              icon: Icon(Icons.home),
              title: "Beranda",
              activeForegroundColor: primaryColor),
        ),
        PersistentTabConfig(
          screen: const TransactionHistory(),
          item: ItemConfig(
              icon: Icon(Icons.history),
              title: "Histori",
              activeForegroundColor: primaryColor),
        ),
        PersistentTabConfig(
          screen: Scan(),
          item: ItemConfig(
            icon: Icon(Icons.camera_alt_outlined),
            title: "E-Scan",
            inactiveForegroundColor: Colors.white,
            inactiveBackgroundColor: Colors.white,
            activeForegroundColor: primaryColor,
            activeColorSecondary: primaryColor,
            inactiveIcon: Icon(Icons.camera_alt_outlined, color: Colors.white),
          ),
        ),
        PersistentTabConfig(
          screen: const ETaskPage(),
          item: ItemConfig(
              icon: Icon(Icons.document_scanner_outlined),
              title: "Tugas",
              activeForegroundColor: primaryColor),
        ),
        PersistentTabConfig(
          screen: ProfilePage(user: widget.user),
          item: ItemConfig(
              icon: Icon(Icons.person),
              title: "Profil",
              activeForegroundColor: primaryColor),
        ),
      ],
      navBarBuilder: (navBarConfig) => Style16BottomNavBar(
        navBarConfig: navBarConfig,
      ),
    );
  }

  // List<PersistentBottomNavBarItem> _navBarsItems() {
  //   return [
  //     PersistentBottomNavBarItem(
  //       icon: const Icon(Icons.home, size: 32),
  //       title: "Beranda",
  //       activeColorPrimary: primaryColor,
  //       inactiveColorPrimary: Colors.grey,
  //     ),
  //     PersistentBottomNavBarItem(
  //       icon: const Icon(Icons.history, size: 32),
  //       title: "Histori",
  //       activeColorPrimary: primaryColor,
  //       inactiveColorPrimary: Colors.grey,
  //     ),
  //     PersistentBottomNavBarItem(
  //       icon: const Icon(
  //         Icons.camera_alt_outlined,
  //         size: 32,
  //         color: Colors.white,
  //       ), // Ukuran ikon lebih besar
  //       title: "E-Scan",
  //       activeColorPrimary: primaryColor,
  //       inactiveColorPrimary: Colors.grey,
  //     ),
  //     PersistentBottomNavBarItem(
  //       icon: const Icon(Icons.document_scanner_outlined, size: 32),
  //       title: "Tugas",
  //       activeColorPrimary: primaryColor,
  //       inactiveColorPrimary: Colors.grey,
  //     ),
  //     PersistentBottomNavBarItem(
  //       icon: const Icon(Icons.person, size: 32),
  //       title: "Profil",
  //       activeColorPrimary: primaryColor,
  //       inactiveColorPrimary: Colors.grey,
  //     ),
  //   ];
  // }
}
