import 'package:e_cycle/constants/colors.dart';
import 'package:e_cycle/screens/home.dart';
import 'package:e_cycle/screens/navbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  Future<User?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user != null) {
        // Save user data to Firestore
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Mission
        final missionDoc =
            FirebaseFirestore.instance.collection('missions').doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (docSnapshot.exists) {
          // If user document exists, update the existing fields without resetting points
          await userDoc.set({
            'displayName': user.displayName,
            'email': user.email,
            'photoURL': user.photoURL,
          }, SetOptions(merge: true));
        } else {
          // If user document does not exist, create it with points set to 0
          await userDoc.set({
            'displayName': user.displayName,
            'email': user.email,
            'photoURL': user.photoURL,
            'points': 0,
          });

          // Create Notification Welcome
          await FirebaseFirestore.instance
              .collection('notifications')
              .doc(user.uid)
              .set({
            'welcome': {
              'title': 'Selamat Datang di E-Cycle!',
              'body':
                  'Mulai kumpulkan sampah elektronik dan tukarkan poinmu! #CycleYourElectronic!',
              'isRead': false,
              'timestamp': FieldValue.serverTimestamp(),
            }
          });

          // Create mission document
          await missionDoc.set({
            // Map of mission data
            'harian1': {
              'completed': false,
              'points': 15,
              'title': 'Scan Elektronik Hari Ini',
              'desc':
                  'Kumpulkan sampah di sekitar Anda, lalu lakukan pemindaian untuk identifikasi.',
            },
            'harian2': {
              'completed': false,
              'points': 15,
              'title': 'Scan Elektronik Hari Ini',
              'desc':
                  'Kumpulkan sampah di sekitar Anda, lalu lakukan pemindaian untuk identifikasi.',
            },
            'harian3': {
              'completed': false,
              'points': 15,
              'title': 'Scan Elektronik Hari Ini',
              'desc':
                  'Kumpulkan sampah di sekitar Anda, lalu lakukan pemindaian untuk identifikasi.',
            },
          });
        }
      }

      return user;
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_secondary.png',
                width: 100,
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'Masuk atau Daftar',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 16,
              ),
              Container(
                width: 320,
                height: 57,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Container(
                width: 320,
                height: 57,
                child: ElevatedButton(
                    onPressed: () {
                      // Navigate to home
                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => Navbar()),
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      "Selanjutnya",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    )),
              ),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                width: 372,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 140, height: 2, color: Colors.black),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text('OR'),
                    const SizedBox(
                      width: 5,
                    ),
                    Container(width: 140, height: 2, color: Colors.black),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Container(
                  width: 320,
                  height: 57,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      User? user = await _signInWithGoogle();
                      if (user != null) {
                        // Navigate to home with user information
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Navbar(user: user)),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage('assets/images/logo_google.png'),
                          width: 24,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Masuk dengan Google',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                  )),
              const SizedBox(
                height: 16,
              ),
              Container(
                  width: 320,
                  height: 57,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage('assets/images/logo_facebook.png'),
                          width: 24,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Masuk dengan Facebook',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
