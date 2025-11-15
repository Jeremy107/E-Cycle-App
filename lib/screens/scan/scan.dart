import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:e_cycle/constants/colors.dart';
import 'package:e_cycle/screens/scan/widgets/estimasi.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Scan extends StatefulWidget {
  const Scan({Key? key}) : super(key: key);

  @override
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<Scan> with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isCameraInitialized = false;
  bool showInfo = false;
  bool _canTap = true; // Prevent multiple taps
  String result = 'Unknown';
  int points = 0;

  /* --------------------------------- variabel animasi ------------------------- */
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  late final AnimationController _blinkController;
  late final Animation<double> _blinkAnimation;

  final Map<String, String> deviceTypeMapping = {
    'hp': 'handphone',
    'handphone': 'handphone',
    'smartphone': 'handphone',
    'phone': 'handphone',
    'android': 'handphone',
    'laptop': 'laptop',
    'iphone': 'iphone',
    'macbook': 'macbook',
    'tablet': 'tablet',
    'ipad': 'ipad',
    'smartwatch': 'smartwatch',
    'watch': 'smartwatch',
    'earphone': 'earphone',
    'headphone': 'headphone',
    'speaker': 'speaker',
    'monitor': 'monitor',
    'tv': 'tv',
    'printer': 'printer',
    'camera': 'camera',
    'drone': 'drone',
    'game console': 'game console',
  };

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeNotifications();

    /* ------------------------------ animasi start ----------------------------- */
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<double>(begin: 20, end: 40).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);

    // Initialize blink animation
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    _blinkController.repeat(reverse: true);
    /* ------------------------------- animasi end ------------------------------ */
  }

  /* ------------------------------ mulai kamera ------------------------------ */
  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();

      if (cameras != null && cameras!.isNotEmpty) {
        _cameraController = CameraController(
          cameras![0],
          ResolutionPreset.high,
        );

        await _cameraController?.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      } else {
        print("Tidak ada kamera yang tersedia.");
      }
    } catch (e) {
      print("Error saat menginisialisasi kamera: $e");
    }
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'e_cycle_channel_id',
      'E-Cycle Notifications',
      channelDescription: 'Notifications for E-Cycle app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _animationController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  Icon getDeviceIcon(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'handphone':
      case 'smartphone':
      case 'phone':
      case 'android':
      case 'iphone':
        return const Icon(Icons.phone_android, color: Colors.green, size: 40);
      case 'laptop':
      case 'macbook':
        return const Icon(Icons.laptop, color: Colors.green, size: 40);
      case 'tablet':
      case 'ipad':
        return const Icon(Icons.tablet, color: Colors.green);
      case 'smartwatch':
      case 'watch':
        return const Icon(Icons.watch, color: Colors.green);
      case 'earphone':
      case 'headphone':
        return const Icon(Icons.headset, color: Colors.green);
      case 'speaker':
        return const Icon(Icons.speaker, color: Colors.green);
      case 'monitor':
        return const Icon(Icons.desktop_windows, color: Colors.green);
      case 'tv':
        return const Icon(Icons.tv, color: Colors.green);
      case 'printer':
        return const Icon(Icons.print, color: Colors.green);
      case 'camera':
        return const Icon(Icons.camera_alt, color: Colors.green);
      case 'drone':
        return const Icon(Icons.toys, color: Colors.green);
      case 'game console':
        return const Icon(Icons.videogame_asset, color: Colors.green);
      default:
        return const Icon(Icons.devices_other, color: Colors.green);
    }
  }

  /* -------------------------- Image classification Start -------------------------- */
  Future<void> _classifyImage(File imageFile) async {
    try {
      // const apiKey = 'AIzaSyD8blGqOYS86v0zV50BW4csSp2tI4n_sZg';
      const apiKey = 'AIzaSyBgHH5k23-P6lYie7zmK5dDRgS9pd_x28A';

      if (apiKey == null) {
        stderr.writeln('No API key provided');
        exit(1);
      }

      const prompt =
          'Classify this electronic image. Provide a “name” output for the brand name if present(“<Electronic Type> - <Full Brand>”), if not present(<Electronic Type>)';

      final imageBytes = await imageFile.readAsBytes();

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/png', imageBytes),
        ])
      ];

      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 1,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 8192,
          responseMimeType: 'application/json',
          responseSchema: Schema(
            SchemaType.object,
            properties: {
              "name": Schema(
                SchemaType.string,
              ),
            },
          ),
        ),
      );

      final response = await model.generateContent(content);

      setState(() {
        result = response.text != null
            ? jsonDecode(response.text!)['name'] ?? 'No result available'
            : 'No result available';
      });
      // Fetch points from Firestore based on the normalized device type
      await _fetchPoints(result.split(' - ')[0].toLowerCase());

      // Add 10 points to the user's account
      await _addPointsToUser(5);

      // Update the mission status
      await _updateMissionStatus();

      print("Hasil Points : $points");
    } catch (e, stackTrace) {
      print("Error classifying image: $e");
      print("Stack trace: $stackTrace");
    }
  }
  /* ------------------------ image classification end ------------------------ */

  Future<void> _fetchPoints(String deviceType) async {
    try {
      // Normalize the device type using the mapping
      String normalizedDeviceType = deviceTypeMapping[deviceType] ?? deviceType;

      final doc = await FirebaseFirestore.instance
          .collection('device_points')
          .doc(normalizedDeviceType)
          .get();

      if (doc.exists) {
        setState(() {
          points = doc['points'];
        });
      } else {
        print("No points found for device type: $normalizedDeviceType");
      }
    } catch (e) {
      print("Error fetching points: $e");
    }
  }

  // Add Notifications to Firebase
  Future<void> _addNotificationToFirebase(String title, String body) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final notificationDoc = FirebaseFirestore.instance
            .collection('notifications')
            .doc(user.uid);

        await notificationDoc.set({
          DateTime.now().millisecondsSinceEpoch.toString(): {
            'title': title,
            'body': body,
            'isRead': false,
            'timestamp': DateTime.now(),
          }
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print("Error adding notification to Firebase: $e");
    }
  }

  Future<void> _addPointsToUser(int additionalPoints) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(userDoc);
          if (snapshot.exists) {
            final currentPoints = snapshot['points'] ?? 0;
            transaction
                .update(userDoc, {'points': currentPoints + additionalPoints});
            _showNotification(
                "E-Points", "Anda Mendapatkan +$additionalPoints E-Points!");

            await _addNotificationToFirebase(
                "E-Points", "Anda Mendapatkan +$additionalPoints E-Points!");
          }
        });
      }
    } catch (e) {
      print("Error adding points to user: $e");
    }
  }

  Future<void> _updateMissionStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final missionDoc =
            FirebaseFirestore.instance.collection('missions').doc(user.uid);
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(missionDoc);
          if (snapshot.exists) {
            final missions = snapshot.data() as Map<String, dynamic>;
            for (var entry in missions.entries) {
              if (!entry.value['completed']) {
                transaction.update(missionDoc, {
                  '${entry.key}.completed': true,
                });
                await _addPointsToUser(entry.value['points']);
                _showNotification("Misi Selesai", "Salah satu Misi selesai!");
                break;
              }
            }
          }
        });
      }
    } catch (e) {
      print("Error updating mission status: $e");
    }
  }

  /* -------------------- tangkap dan klasifikasikan gambar ------------------- */
  Future<void> _captureAndClassifyImage() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        // Take a picture and get the file path
        final XFile imageFile = await _cameraController!.takePicture();

        // Compress and classify the image
        await _classifyImage(File(imageFile.path));

        setState(() {
          showInfo = true;
        });
      } catch (e) {
        print("Error capturing and classifying image: $e");
      }
    }
  }

  /* ---------------------------- fungsi tap kamera --------------------------- */
  void _onCameraTap() async {
    if (!_canTap) return; // Prevent multiple taps

    setState(() {
      _canTap = false; // Disable further taps
    });

    await _captureAndClassifyImage();

    // Re-enable tapping after 5 seconds
    Timer(Duration(seconds: 5), () {
      setState(() {
        _canTap = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _onCameraTap,
        child: Stack(
          children: [
            if (_isCameraInitialized)
              Positioned.fill(
                child: AspectRatio(
                  aspectRatio: _cameraController!.value.aspectRatio,
                  child: CameraPreview(_cameraController!),
                ),
              )
            else
              const Center(child: CircularProgressIndicator()),
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Stack(
                  children: [
                    const Positioned(
                      top: 40,
                      left: 0,
                      right: 0,
                      child: Text(
                        "Tap Layar Satu kali untuk Scan Perangkat",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Center(
                      child: FadeTransition(
                        opacity: _blinkAnimation,
                        child: Image.asset(
                          "assets/images/scan.png",
                          width: 260,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showInfo)
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Positioned(
                    bottom: _animation.value + 70,
                    left: 20,
                    right: 20,
                    child: GestureDetector(
                      onVerticalDragEnd: (DragEndDetails details) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Estimasi(result: result, points: points)),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Elektronik",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                getDeviceIcon(result
                                    .split(' - ')[0]), // Use the dynamic icon
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      result,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Taruh di tempat drop-off e-cycle \nuntuk diremanufaktur",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
