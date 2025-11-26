import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  Stream<List<Map<String, dynamic>>> _fetchNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('notifications')
          .doc(user.uid)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) {
          return [];
        }
        final data = snapshot.data() as Map<String, dynamic>;

        final list = data.entries.map((entry) {
          final notification = entry.value as Map<String, dynamic>;
          return {
            'id': entry.key,
            'title': notification['title'],
            'body': notification['body'],
            'isRead': notification['isRead'],
            'timestamp': notification['timestamp'], // Firestore Timestamp
          };
        }).toList();

        // ✅ Sort: terbaru dulu (timestamp besar ke kecil)
        list.sort((a, b) {
          final ta = a['timestamp'] as Timestamp?;
          final tb = b['timestamp'] as Timestamp?;
          if (ta == null && tb == null) return 0;
          if (ta == null) return 1; // null dianggap paling lama
          if (tb == null) return -1;
          return tb.compareTo(ta); // descending
        });

        return list;
      });
    }
    return const Stream.empty();
  }

  Future<void> _markNotificationsAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef =
          FirebaseFirestore.instance.collection('notifications').doc(user.uid);
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final updatedData = data.map((key, value) {
          final notification = value as Map<String, dynamic>;
          notification['isRead'] = true;
          return MapEntry(key, notification);
        });
        await docRef.update(updatedData);
      }
    }
  }

  // Aksi untuk Clear All
  Future<void> _clearAllNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef =
          FirebaseFirestore.instance.collection('notifications').doc(user.uid);
      await docRef.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    _markNotificationsAsRead();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 148, 33, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 148, 33, 1),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // Aksi untuk Clear All
              _clearAllNotifications();
            },
            child:
                const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
        title: const Text(
          "Notifikasi",
          style: TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _fetchNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No notifications available'));
            }

            final notifications = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final timestamp =
                    (notification['timestamp'] as Timestamp).toDate();
                final formattedTime =
                    "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";
                return NotificationTile(
                  // if map is "welcome" path to logo image
                  imagePath:
                      notification['title'] == 'Selamat Datang di E-Cycle!'
                          ? 'assets/images/icon.png'
                          : 'assets/images/coin.png',
                  title: notification['title'],
                  description: notification['body'],
                  time: formattedTime,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final String time;

  const NotificationTile({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            child: Image.asset(
              imagePath,
              width: 200,
              height: 200,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
