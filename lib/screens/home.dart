import 'package:badges/badges.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_cycle/constants/colors.dart';
import 'package:e_cycle/models/news.dart';
import 'package:e_cycle/screens/article/article_detail.dart';
import 'package:e_cycle/screens/community/community.dart';
import 'package:e_cycle/screens/drop_off/drop_off_screen.dart';
import 'package:e_cycle/screens/notification/notification_page.dart';
import 'package:e_cycle/screens/widgets/card_home.dart';
import 'package:e_cycle/screens/widgets/fitur_unggulan.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:e_cycle/screens/withdraw/withdraw.dart';
import 'package:badges/badges.dart' as badges;

class Home extends StatefulWidget {
  final User user;

  const Home({super.key, required this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Stream<DocumentSnapshot> _userPointsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .snapshots();
  }

  Stream<int> _unreadNotificationsCount() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .doc(widget.user.uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return 0;
      }
      final data = snapshot.data() as Map<String, dynamic>;
      int unreadCount = 0;
      data.forEach((key, value) {
        if (value['isRead'] == false) {
          unreadCount++;
        }
      });
      return unreadCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    // News Item
    final berita = NewsItem.newsItem();

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 25.0, right: 25.0, top: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Profile Icon
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.white, // White outline
                        width: 1.0,
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
                  // Greeting Text
                  Text(
                    "Selamat Siang, \n${widget.user.displayName}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  // Notification Icon with Badge
                  StreamBuilder<int>(
                    stream: _unreadNotificationsCount(),
                    builder: (context, snapshot) {
                      int unreadCount = snapshot.data ?? 0;
                      return badges.Badge(
                        badgeContent: Text(
                          unreadCount.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        showBadge: unreadCount > 0,
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        NotificationPage()));
                          },
                          icon: const Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      StreamBuilder<DocumentSnapshot>(
                        stream: _userPointsStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                          return CardHome(points: points);
                        },
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 25.0),
                          child: Text(
                            "Fitur Unggulan",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      const SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FiturUnggulan(
                              imagePath: "assets/images/icon_motorbike.png",
                              label: "E-Waste Drop off",
                              page: DropOffScreen(),
                            ),
                            FiturUnggulan(
                              imagePath: "assets/images/icon_withdraw.png",
                              label: "E-Point Withdraw",
                              page: WithdrawPage(),
                            ),
                            FiturUnggulan(
                              imagePath: "assets/images/icon_community.png",
                              label: "E-Waste Community",
                              page: CommunityPage(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Divider
                      Container(
                        height: 1,
                        width: 300,
                        color: Colors.grey[300],
                      ),

                      const SizedBox(height: 10),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 25.0),
                          child: Text(
                            "Refurbished Store",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Carousel Slider
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: CarouselSlider(
                          options: CarouselOptions(
                            height: 115.0, // Set a reasonable height
                            aspectRatio: 16 / 9,
                            viewportFraction: 1.0,
                            initialPage: 0,
                            enableInfiniteScroll: true,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 10),
                            autoPlayAnimationDuration:
                                const Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: true,
                            scrollDirection: Axis.horizontal,
                          ),
                          items: [
                            "assets/images/carousel1.png",
                            "assets/images/carousel2.png",
                            "assets/images/carousel3.png",
                          ].map((item) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  width: 371,
                                  child: Image.asset(item, fit: BoxFit.cover),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Divider
                      Container(
                        height: 1,
                        width: 300,
                        color: Colors.grey[300],
                      ),

                      const SizedBox(height: 10),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 25.0),
                          child: Text(
                            "E-Waste News",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const ArticleDetailPage(),
                            ),
                          ),
                          child: Column(
                            children: berita
                                .map(
                                  (item) => Column(
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            item.imageUrl,
                                            width: 120,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.title,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 7),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        item.date,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                      Text(
                                                        item.link,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: primaryColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
