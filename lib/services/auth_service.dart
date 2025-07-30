import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Add these for better compatibility
    signInOption: SignInOption.standard,
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await result.user?.updateDisplayName(username);

      // Create user document in Firestore
      await createUserDocument(result.user!, username);

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Ensure user document exists for existing users too
      if (result.user != null) {
        await ensureUserDocument(result.user!);
      }
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Clear any existing sign-in state from GoogleSignIn
      await _googleSignIn.signOut();

      // Trigger the Google Sign In flow with error handling
      GoogleSignInAccount? googleUser;
      try {
        googleUser = await _googleSignIn.signIn();
      } catch (e) {
        if (e.toString().contains('PigeonUserDetails') || e.toString().contains('List<Object?>')) {
          // Clear any cached sign-in attempts
          await _googleSignIn.signOut();
          // Try one more time after clearing cache
          googleUser = await _googleSignIn.signIn();
        } else {
          rethrow;
        }
      }

      if (googleUser == null) {
        // User cancelled the sign-in flow
        throw FirebaseAuthException(
          code: 'user-cancelled',
          message: 'Google sign in was cancelled by the user.',
        );
      }

      // Use a different approach to get authentication
      GoogleSignInAuthentication googleAuth;
      try {
        googleAuth = await googleUser.authentication;
      } catch (e) {
        if (kDebugMode) {
          log('Error getting Google auth: $e');
        }
        // Fallback to direct token retrieval
        final auth = await _googleSignIn.currentUser?.authentication;
        if (auth == null) {
          throw FirebaseAuthException(
            code: 'google-auth-failed',
            message: 'Failed to authenticate with Google.',
          );
        }
        googleAuth = auth;
      }

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw FirebaseAuthException(
          code: 'invalid-google-credentials',
          message: 'Failed to get Google authentication tokens.',
        );
      }

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-user-after-google-sign-in',
          message: 'No user returned after Google Sign-In with Firebase.',
        );
      }

      // Get user info safely
      String displayName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
      String email = user.email ?? '';
      String photoUrl = user.photoURL ?? '';

      // If it's a new user, create their document. Otherwise, ensure it exists.
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await createUserDocument(user, displayName);
      } else {
        await ensureUserDocument(user);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        log('Firebase Auth Error (Google Sign In): ${e.code} - ${e.message}');
      }
      // Re-throw the handled exception
      throw _handleAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        log('Unexpected error during Google Sign In: $e');
      }
      // General error for unexpected issues during Google Sign-In
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: 'Google sign-in failed. Please try again or use email login.',
      );
    }
  }

  // Create user document in Firestore
  Future<void> createUserDocument(User user, String username) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'username': username,
        'fullName': user.displayName ?? username,
        'institution': '',
        'field': '',
        'year': '',
        'profileImageUrl': user.photoURL ?? '',
        'monthlyBudget': 0.0,
        'totalExpenses': 0.0,
        'totalWithdrawn': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        log('Error creating user document: $e');
      }
      throw Exception('Failed to create user profile');
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;

        // Convert Firestore Timestamps to DateTime strings if needed
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        if (data['updatedAt'] is Timestamp) {
          data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
        }
        if (data['lastActive'] is Timestamp) {
          data['lastActive'] = (data['lastActive'] as Timestamp).toDate().toIso8601String();
        }

        return data;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        log('Error getting user data: $e');
      }
      return null;
    }
  }

  // Update or create user data (handles both cases)
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      // First check if document exists
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        // Document doesn't exist, create it with default values
        final currentUser = _auth.currentUser;
        await _firestore.collection('users').doc(uid).set({
          'uid': uid,
          'email': currentUser?.email ?? '',
          'username': data['username'] ?? currentUser?.displayName ?? 'User',
          'fullName': data['fullName'] ?? currentUser?.displayName ?? 'User',
          'institution': data['institution'] ?? '',
          'field': data['field'] ?? '',
          'year': data['year'] ?? '',
          'profileImageUrl': data['profileImageUrl'] ?? currentUser?.photoURL ?? '',
          'monthlyBudget': data['monthlyBudget'] ?? 0.0,
          'totalExpenses': data['totalExpenses'] ?? 0.0,
          'totalWithdrawn': data['totalWithdrawn'] ?? 0.0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastActive': FieldValue.serverTimestamp(),
        });
      } else {
        // Document exists, update it
        final updateData = {
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
          'lastActive': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('users').doc(uid).update(updateData);
      }
    } catch (e) {
      if (kDebugMode) {
        log('Error updating user data: $e');
      }
      throw Exception('Failed to update user data: $e');
    }
  }

  // Ensure user document exists (call this after login)
  Future<void> ensureUserDocument(User user) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        await createUserDocument(user, user.displayName ?? 'User');
      }
      // Always update lastActive on login/ensure
      await updateUserActivity();
    } catch (e) {
      if (kDebugMode) {
        log('Error ensuring user document: $e');
      }
    }
  }

  // Update user activity
  Future<void> updateUserActivity() async {
    if (currentUser != null) {
      try {
        await _firestore.collection('users').doc(currentUser!.uid).set({
          'lastActive': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        if (kDebugMode) {
          log('Error updating user activity: $e');
        }
      }
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      User? user = currentUser;
      if (user == null) throw Exception('No user logged in');

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

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut(); // Ensure Google session is also signed out
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        log('Error signing out: $e');
      }
    }
  }

  // Handle auth exceptions
  FirebaseAuthException _handleAuthException(FirebaseAuthException e) {
    if (kDebugMode) {
      log('Auth Error: ${e.code} - ${e.message}');
    }

    // Map Firebase error codes to user-friendly messages
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found with this email address.';
        break;
      case 'wrong-password':
      case 'invalid-credential': // Sometimes Google sign-in can throw this if credentials are bad
        message = 'Incorrect password or invalid credentials. Please try again.';
        break;
      case 'email-already-in-use':
        message = 'An account already exists with this email address.';
        break;
      case 'invalid-email':
        message = 'The email address is not valid.';
        break;
      case 'user-disabled':
        message = 'This user account has been disabled.';
        break;
      case 'too-many-requests':
        message = 'Too many failed login attempts. Please try again later.';
        break;
      case 'weak-password':
        message = 'The password provided is too weak.';
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your internet connection.';
        break;
      case 'user-cancelled':
        message = 'The sign-in process was cancelled by the user.';
        break;
      case 'google-sign-in-failed':
      case 'invalid-google-credentials':
      case 'no-user-after-google-sign-in':
      case 'google-sign-in-type-error':
        message = 'Google sign-in failed. Please try again or use email login.';
        break;
      default:
        message = e.message ?? 'An unexpected authentication error occurred.';
    }

    return FirebaseAuthException(
      code: e.code,
      message: message,
    );
  }
}
