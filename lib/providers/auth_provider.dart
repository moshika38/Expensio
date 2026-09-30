import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  static const String _onboardingKey = 'has_completed_onboarding';

  User? _user;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _errorMessage;
  bool _isOnboardingCompleted = false;

  StreamSubscription<User?>? _authStateSubscription;

  AuthProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository() {
    _init();
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;
  bool get isOnboardingCompleted => _isOnboardingCompleted;

  Future<void> _init() async {
    await checkOnboardingStatus();
    _user = _authRepository.currentUser;

    _authStateSubscription = _authRepository.authStateChanges.listen((user) {
      _user = user;
      _isInitializing = false;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = 'Authentication error: $error';
      _isInitializing = false;
      notifyListeners();
    });
  }

  /// Check whether onboarding has been completed in local storage
  Future<void> checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isOnboardingCompleted = prefs.getBool(_onboardingKey) ?? false;
      notifyListeners();
    } catch (_) {
      _isOnboardingCompleted = false;
    }
  }

  /// Mark onboarding as completed locally
  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
      _isOnboardingCompleted = true;
      notifyListeners();
    } catch (e) {
      _isOnboardingCompleted = true;
      notifyListeners();
    }
  }

  /// Sign in with Google Account
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.signInWithGoogle();
      _isLoading = false;
      if (user != null) {
        _user = user;
        notifyListeners();
        return true;
      } else {
        // User cancelled sign-in prompt
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Sign-in failed. Please check internet connection and try again.';
      notifyListeners();
      return false;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.signOut();
      _user = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to sign out: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
