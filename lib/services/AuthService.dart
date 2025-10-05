import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  static bool get isLoggedIn => _auth.currentUser != null;

  // Stream of auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  static Future<UserCredential?> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      // Create user document in Firestore
      await _createUserDocument(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
    bool keepLoggedIn = false,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save login preference
      if (keepLoggedIn) {
        await _saveLoginPreference(userCredential.user!.uid);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Create user document if it doesn't exist
      await _createUserDocumentIfNotExists(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email!,
        name: userCredential.user!.displayName ?? 'User',
        photoUrl: userCredential.user!.photoURL,
      );

      return userCredential;
    } catch (e) {
      throw 'Google sign-in failed: $e';
    }
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Change password
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw 'No user logged in';

      // Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update user profile
  static Future<void> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? photoUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw 'No user logged in';

      Map<String, dynamic> updateData = {};

      if (name != null) {
        await user.updateDisplayName(name);
        updateData['name'] = name;
      }

      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
        updateData['photoUrl'] = photoUrl;
      }

      if (phoneNumber != null) {
        updateData['phoneNumber'] = phoneNumber;
      }

      if (additionalData != null) {
        updateData.addAll(additionalData);
      }

      if (updateData.isNotEmpty) {
        updateData['updatedAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('users').doc(user.uid).update(updateData);
      }
    } catch (e) {
      throw 'Failed to update profile: $e';
    }
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw 'Failed to get user data: $e';
    }
  }

  // Update user statistics
  static Future<void> updateUserStats({
    int? hadithRead,
    int? mosqueVisited,
    int? tasbeehCount,
    int? quranPagesRead,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      Map<String, dynamic> updateData = {};

      if (hadithRead != null) {
        updateData['stats.hadithRead'] = FieldValue.increment(hadithRead);
      }
      if (mosqueVisited != null) {
        updateData['stats.mosqueVisited'] = FieldValue.increment(mosqueVisited);
      }
      if (tasbeehCount != null) {
        updateData['stats.tasbeehCount'] = FieldValue.increment(tasbeehCount);
      }
      if (quranPagesRead != null) {
        updateData['stats.quranPagesRead'] = FieldValue.increment(quranPagesRead);
      }

      if (updateData.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(updateData);
      }
    } catch (e) {
      print('Failed to update user stats: $e');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      
      // Clear saved preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('uid');
      await prefs.remove('keepLoggedIn');
    } catch (e) {
      throw 'Failed to sign out: $e';
    }
  }

  // Delete account
  static Future<void> deleteAccount(String password) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw 'No user logged in';

      // Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Delete user document
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete user account
      await user.delete();

      // Clear saved preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Check if email is verified
  static bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Send email verification
  static Future<void> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw 'Failed to send verification email: $e';
    }
  }

  // Private helper methods
  static Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String name,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber ?? '',
      'photoUrl': photoUrl ?? '',
      'stats': {
        'hadithRead': 0,
        'mosqueVisited': 0,
        'tasbeehCount': 0,
        'quranPagesRead': 0,
      },
      'preferences': {
        'notifications': true,
        'prayerReminders': true,
        'dhikrReminders': true,
        'language': 'en',
      },
      'favorites': {
        'hadiths': [],
        'duas': [],
        'mosques': [],
      },
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> _createUserDocumentIfNotExists({
    required String uid,
    required String email,
    required String name,
    String? photoUrl,
  }) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      await _createUserDocument(
        uid: uid,
        email: email,
        name: name,
        photoUrl: photoUrl,
      );
    }
  }

  static Future<void> _saveLoginPreference(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
    await prefs.setBool('keepLoggedIn', true);
  }

  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'requires-recent-login':
        return 'Please log in again to perform this action.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  // Check auto login
  static Future<bool> checkAutoLogin() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? keepLoggedIn = prefs.getBool('keepLoggedIn');
      String? uid = prefs.getString('uid');

      return keepLoggedIn == true && uid != null && _auth.currentUser != null;
    } catch (e) {
      return false;
    }
  }

  // Guest mode functions
  static Future<void> enableGuestMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGuestMode', true);
  }

  static Future<bool> isGuestMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isGuestMode') ?? false;
  }

  static Future<void> disableGuestMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isGuestMode');
  }
}