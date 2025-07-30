import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  Timer? _inactivityTimer;
  Timer? _activityUpdateTimer;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        // Ensure user document exists
        await _authService.ensureUserDocument(user);
        await _loadUserData();
        _startInactivityTimer();
        _startActivityUpdateTimer();
      } else {
        _userData = null;
        _stopTimers();
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData() async {
    if (_user != null) {
      try {
        _userData = await _authService.getUserData(_user!.uid);
        notifyListeners();
      } catch (e) {
        if (kDebugMode) {
          log('Error loading user data: $e');
        }
      }
    }
  }

  void _startInactivityTimer() {
    _stopInactivityTimer();
    _inactivityTimer = Timer(const Duration(minutes: 30), () {
      signOut();
    });
  }

  void _stopInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  void _startActivityUpdateTimer() {
    _activityUpdateTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _authService.updateUserActivity();
    });
  }

  void _stopTimers() {
    _stopInactivityTimer();
    _activityUpdateTimer?.cancel();
    _activityUpdateTimer = null;
  }

  void resetInactivityTimer() {
    if (_user != null) {
      _startInactivityTimer();
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Attempt to sign up
      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        username: username,
      );

      // No immediate signOut here.
      // The _initializeAuth listener will pick up the new user state.
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Only one robust Google sign-in attempt
      await _authService.signInWithGoogle();
      return null;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        log('Google Sign-in Error: ${e.code} - ${e.message}');
      }
      return e.message;
    } catch (e) {
      if (kDebugMode) {
        log('Unexpected Google sign-in error: $e');
      }
      return 'Google sign-in failed. Please try again or use email login.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    if (_user != null) {
      try {
        await _authService.updateUserData(_user!.uid, data);
        // Reload user data to update local state
        await _loadUserData();
      } catch (e) {
        if (kDebugMode) {
          log('Error updating user data: $e');
        }
        rethrow;
      }
    }
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    _stopTimers();
    await _authService.signOut();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  String get displayName {
    return _userData?['username'] ?? _user?.displayName ?? 'User';
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }
}