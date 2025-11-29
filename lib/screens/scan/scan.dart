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
import 'dart:developer';

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
  bool _isScanning = false;
  bool _isCameraInitialized = false;
  bool showInfo = false;
  bool _canTap = true; // Prevent multiple taps
  String result = 'Unknown';
  int points = 0;
  String condition = 'unknown'; // Kondisi barang dari Gemini

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
    _initializeStatusListener(); // Listen for status changes

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
          enableAudio: false,
        );

        await _cameraController?.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      } else {
        log("Tidak ada kamera yang tersedia.");
      }
    } catch (e) {
      log("Error saat menginisialisasi kamera: $e");
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

  Future<void> _saveScanResult(
      String name, int earnedPoints, String condition) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = FirebaseFirestore.instance
          .collection('scans')
          .doc(user.uid)
          .collection('items')
          .doc(); // unique
      await doc.set({
        'id': doc.id,
        'name': name,
        'points': earnedPoints,
        'condition': condition,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    } catch (e) {
      log('Save scan error: $e');
    }
  }

  String _detectMime(String path) {
    final p = path.toLowerCase();
    if (p.endsWith('.png')) return 'image/png';
    return 'image/jpeg';
  }

  /* -------------------------- Image classification Start -------------------------- */
  Future<void> _classifyImage(File imageFile) async {
    try {
      setState(() => _isScanning = true);
      log("📸 Starting image classification for: ${imageFile.path}");
      log("📸 File exists: ${imageFile.existsSync()}");
      log("📸 File size: ${imageFile.lengthSync()} bytes");

      const apiKey = '';

      if (apiKey.isEmpty) {
        throw Exception('API key missing');
      }

      const prompt =
          'You are an electronic device appraiser. Analyze this image of an electronic device and provide a JSON response.\n\nIMPORTANT: Return ONLY valid JSON, no other text.\n\nAnalyze the device:\n1. Identify the device type and brand (if visible)\n2. Estimate original retail price in IDR\n3. Assess condition based on visible damage\n4. Calculate estimated value\n\nCondition assessment guide:\n- excellent: No visible damage, like new condition\n- good: Minor scratches or marks, fully functional\n- fair: Noticeable damage (small cracks/dents), still functional\n- poor: Significant damage, broken parts, or severely worn\n\nPrice calculation:\n- excellent = 85% of original price\n- good = 70% of original price  \n- fair = 40% of original price\n- poor = 15% of original price\n\nReturn JSON with exactly these fields:\n{\n  "name": "Device Type - Brand (or just Device Type if brand unknown)",\n  "originalPrice": (integer, estimated original price in IDR),\n  "condition": "excellent|good|fair|poor",\n  "estimatedPrice": (integer, condition-based price in IDR)\n}';

      final imageBytes = await imageFile.readAsBytes();
      final mime = _detectMime(imageFile.path);
      log("✓ Image read: ${imageBytes.length} bytes, mime: $mime");

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart(mime, imageBytes),
        ])
      ];
      log("✓ Content prepared");

      final model = GenerativeModel(
        model: 'gemini-2.0-flash-lite',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 500,
          responseMimeType: 'application/json',
          responseSchema: Schema(
            SchemaType.object,
            properties: {
              "name": Schema(SchemaType.string),
              "originalPrice": Schema(SchemaType.integer),
              "condition": Schema(SchemaType.string),
              "estimatedPrice": Schema(SchemaType.integer),
            },
            requiredProperties: [
              "name",
              "originalPrice",
              "condition",
              "estimatedPrice"
            ],
          ),
        ),
      );
      log("✓ Model initialized, sending request to Gemini...");

      final response = await model.generateContent(content);
      log("✓ Response received from Gemini");

      log("Response candidates count: ${response.candidates.length}");
      if (response.candidates.isNotEmpty) {
        final content = response.candidates.first.content;
        log("First candidate content parts: ${content.parts.length}");
        for (var i = 0; i < content.parts.length; i++) {
          log("Part $i: ${content.parts[i].runtimeType} - ${content.parts[i]}");
        }
      }

      if (response.text != null && response.text!.isNotEmpty) {
        try {
          log("Raw response from Gemini: ${response.text}");

          // Remove any whitespace and parse JSON
          final cleanText = response.text!.trim();
          final responseJson = jsonDecode(cleanText);

          log("Parsed JSON: $responseJson");

          final extractedName =
              responseJson['name']?.toString() ?? 'No result available';
          final estimatedPrice = (responseJson['estimatedPrice'] is int)
              ? responseJson['estimatedPrice'] as int
              : int.tryParse(
                      responseJson['estimatedPrice']?.toString() ?? '0') ??
                  0;
          final extractedCondition =
              responseJson['condition']?.toString() ?? 'unknown';
          final calculatedPoints = (estimatedPrice / 1000).toInt();

          log("✓ Extracted - Name: $extractedName, Price: $estimatedPrice, Condition: $extractedCondition, Points: $calculatedPoints");

          setState(() {
            result = extractedName;
            points = calculatedPoints;
            condition = extractedCondition;
          });

          // Save the scan result dengan kondisi dan calculated points (status will be 'pending')
          await _saveScanResult(result, calculatedPoints, extractedCondition);
        } catch (jsonError, stackTrace) {
          log("❌ JSON parsing error: $jsonError", stackTrace: stackTrace);
          setState(() {
            result = 'Error parsing response';
            points = 0;
            condition = 'unknown';
          });
        }
      } else {
        log("❌ Empty or null response from Gemini");
        setState(() {
          result = 'No result available';
          points = 0;
          condition = 'unknown';
        });
      }
      // } catch (e, stackTrace) {
      //   log("Error classifying image: $e");
      //   log("Stack trace: $stackTrace");
      // }
      await _updateMissionStatus();
    } catch (e, st) {
      log("❌ CRITICAL Classification error: $e");
      log("Stack trace: $st");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memproses gambar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }
  /* ------------------------ image classification end ------------------------ */

  /* -------------------- Monitor Scan Status Changes -------------------- */
  Future<void> _initializeStatusListener() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      FirebaseFirestore.instance
          .collection('scans')
          .doc(user.uid)
          .collection('items')
          .snapshots()
          .listen((snapshot) {
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final status = (data['status'] ?? 'pending').toString().toLowerCase();
          final points = (data['points'] ?? 0) as int;
          final name = (data['name'] ?? '').toString();

          // Check if status changed to 'success' and points haven't been added yet
          if (status == 'success' && data['pointsAdded'] != true) {
            // Add points to user account
            _addPointsToUserFromSuccessfulScan(points, name, doc.id, user.uid);
          }
        }
      });
    } catch (e) {
      log('Error initializing status listener: $e');
    }
  }

  Future<void> _addPointsToUserFromSuccessfulScan(
      int points, String name, String scanDocId, String uid) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        if (snapshot.exists) {
          final currentPoints = snapshot['points'] ?? 0;
          transaction.update(userDoc, {'points': currentPoints + points});
          _showNotification(
              "E-Points", "Scan Berhasil! Anda Mendapatkan +$points E-Points!");

          await _addNotificationToFirebase(
              "E-Points", "Scan Berhasil! Anda Mendapatkan +$points E-Points!");
        }

        // Mark that points have been added to this scan
        final scanDoc = FirebaseFirestore.instance
            .collection('scans')
            .doc(uid)
            .collection('items')
            .doc(scanDocId);
        transaction.update(scanDoc, {'pointsAdded': true});
      });

      log('Points added successfully for scan: $scanDocId');
    } catch (e) {
      log('Error adding points from successful scan: $e');
    }
  }
  /* -------------------- End Status Listener -------------------- */

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
      log("Error adding points to user: $e");
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
      log("Error updating mission status: $e");
    }
  }

  /* -------------------- tangkap dan klasifikasikan gambar ------------------- */
  Future<void> _captureAndClassifyImage() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _cameraController!.value.isTakingPicture ||
        _isScanning) {
      log('Skip capture: kondisi belum siap');
      return;
    }
    try {
      final XFile shot = await _cameraController!.takePicture();
      // Hentikan preview agar buffer tidak terus mengalir saat proses berat
      await _cameraController?.pausePreview();
      await _classifyImage(File(shot.path));
      setState(() => showInfo = true);
    } catch (e, st) {
      log("Error capture/classify", error: e, stackTrace: st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengambil gambar')),
        );
      }
    }
  }

  void _resumePreviewIfNeeded() async {
    if (_cameraController != null &&
        _cameraController!.value.isInitialized &&
        _cameraController!.value.isPreviewPaused) {
      try {
        await _cameraController!.resumePreview();
        log('Preview dilanjutkan');
      } catch (e) {
        log('Gagal resume preview: $e');
      }
    }
  }

  /* ---------------------------- fungsi tap kamera --------------------------- */
  void _onCameraTap() async {
    if (!_canTap || _isScanning) return;
    setState(() {
      _canTap = false;
      showInfo = false;
    });
    await _captureAndClassifyImage();
    if (mounted) setState(() => _canTap = true);
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
                      onVerticalDragEnd: (details) async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Estimasi(
                                result: result,
                                points: points,
                                condition: condition),
                          ),
                        );
                        _resumePreviewIfNeeded(); // lanjutkan preview setelah kembali
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
            if (_isScanning)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(.55),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          "Memproses gambar...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
