import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Stream<User?>? _authStateCache;

  static User? get currentUser => _auth.currentUser;
  static bool get isLoggedIn => _auth.currentUser != null;

  static Stream<User?> get authState {
    _authStateCache ??= _auth.authStateChanges();
    return _authStateCache!;
  }

  // ✅ Input validation
  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Sign in with Google
  static Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        await _saveUserToFirestore(user);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      log("Firebase Auth Error: ${e.code} - ${e.message}");
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw 'Akun sudah terdaftar dengan metode login lain';
        case 'invalid-credential':
          throw 'Kredensial tidak valid';
        case 'operation-not-allowed':
          throw 'Login dengan Google tidak diizinkan';
        case 'user-disabled':
          throw 'Akun telah dinonaktifkan';
        default:
          throw 'Login dengan Google gagal';
      }
    } catch (e) {
      log("Error signing in with Google: $e");
      if (e is String) rethrow;
      throw 'Terjadi kesalahan tak terduga';
    }
  }

  /// Sign in with email and password
  static Future<User?> signInWithEmail(String email, String password) async {
    try {
      // ✅ Validasi input
      if (email.isEmpty || password.isEmpty) {
        throw 'Email dan password tidak boleh kosong';
      }

      if (!_isValidEmail(email)) {
        throw 'Format email tidak valid';
      }

      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      log("Firebase Auth Error: ${e.code} - ${e.message}");
      switch (e.code) {
        case 'user-not-found':
          throw 'Email tidak terdaftar';
        case 'wrong-password':
          throw 'Password salah';
        case 'invalid-email':
          throw 'Format email tidak valid';
        case 'user-disabled':
          throw 'Akun telah dinonaktifkan';
        case 'too-many-requests':
          throw 'Terlalu banyak percobaan. Coba lagi nanti';
        default:
          throw 'Login gagal';
      }
    } catch (e) {
      log("Error signing in with email: $e");
      if (e is String) rethrow;
      throw 'Terjadi kesalahan tak terduga';
    }
  }

  /// Sign up with email and password
  static Future<User?> signUpWithEmail(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw 'Email dan password tidak boleh kosong';
      }

      if (!_isValidEmail(email)) {
        throw 'Format email tidak valid';
      }

      if (!_isValidPassword(password)) {
        throw 'Password minimal 6 karakter';
      }

      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      final User? user = userCredential.user;

      if (user != null) {
        await _saveUserToFirestore(user);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      log("Firebase Auth Error: ${e.code} - ${e.message}");
      switch (e.code) {
        case 'weak-password':
          throw 'Password terlalu lemah';
        case 'email-already-in-use':
          throw 'Email sudah terdaftar';
        case 'invalid-email':
          throw 'Format email tidak valid';
        default:
          throw 'Pendaftaran gagal';
      }
    } catch (e) {
      log("Error signing up with email: $e");
      if (e is String) rethrow;
      throw 'Terjadi kesalahan tak terduga';
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      // ✅ Clear cache setelah logout
      _authStateCache = null;
    } catch (e) {
      log("Error signing out: $e");
      // Don't throw error for sign out - user should be signed out from Firebase Auth anyway
    }
  }

  /// Save user data to Firestore
  static Future<void> _saveUserToFirestore(User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final missionDoc = _firestore.collection('missions').doc(user.uid);
      final docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        await userDoc.update({
          'displayName': user.displayName ?? '',
          'email': user.email ?? '',
          'photoURL': user.photoURL ?? '',
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else {
        await userDoc.set({
          'displayName': user.displayName ?? '',
          'email': user.email ?? '',
          'photoURL': user.photoURL ?? '',
          'points': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });

        // ✅ Run in parallel untuk performa lebih baik
        await Future.wait([
          _createWelcomeNotification(user.uid),
          _createUserMissions(user.uid, missionDoc),
        ]);
      }
    } catch (e) {
      log("Error saving user to Firestore: $e");
      // Don't throw - user auth sudah berhasil, ini hanya untuk data tambahan
    }
  }

  /// Create welcome notification for new users
  static Future<void> _createWelcomeNotification(String userId) async {
    try {
      await _firestore.collection('notifications').doc(userId).set({
        'welcome': {
          'title': 'Selamat Datang di E-Cycle!',
          'body':
              'Mulai kumpulkan sampah elektronik dan tukarkan poinmu! #CycleYourElectronic!',
          'isRead': false,
          'timestamp': FieldValue.serverTimestamp(),
        }
      });
    } catch (e) {
      log("Error creating welcome notification: $e");
    }
  }

  /// Create initial missions for new users
  static Future<void> _createUserMissions(
      String userId, DocumentReference missionDoc) async {
    try {
      await missionDoc.set({
        'harian1': {
          'completed': false,
          'points': 15,
          'title': 'Scan Elektronik Pertama',
          'desc': 'Kumpulkan sampah elektronik dan lakukan pemindaian pertama.',
        },
        'harian2': {
          'completed': false,
          'points': 20,
          'title': 'Kumpulkan 3 Item',
          'desc': 'Scan 3 sampah elektronik berbeda dalam sehari.',
        },
        'harian3': {
          'completed': false,
          'points': 25,
          'title': 'Eco Warrior',
          'desc': 'Ajak teman untuk bergabung menggunakan E-Cycle.',
        },
      });
    } catch (e) {
      log("Error creating user missions: $e");
    }
  }

  /// Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      if (email.isEmpty) {
        throw 'Email tidak boleh kosong';
      }

      if (!_isValidEmail(email)) {
        throw 'Format email tidak valid';
      }

      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      log("Firebase Auth Error: ${e.code} - ${e.message}");
      switch (e.code) {
        case 'user-not-found':
          throw 'Email tidak terdaftar';
        case 'invalid-email':
          throw 'Format email tidak valid';
        default:
          throw 'Gagal mengirim email reset';
      }
    } catch (e) {
      log("Error sending password reset email: $e");
      if (e is String) rethrow;
      throw 'Terjadi kesalahan tak terduga';
    }
  }
}
