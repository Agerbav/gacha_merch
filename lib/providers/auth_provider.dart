import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  late final GoogleSignIn _googleSignIn;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.role == 'admin';

  AuthProvider() {
    _googleSignIn = GoogleSignIn(
      clientId: '293637566492-3upe6b0guabti3vev33noirub0d94add.apps.googleusercontent.com',
      serverClientId: kIsWeb ? null : '293637566492-3upe6b0guabti3vev33noirub0d94add.apps.googleusercontent.com',
    );
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      final token = prefs.getString('token');
      if (userStr != null && token != null) {
        _user = User.fromJson(jsonDecode(userStr), token: token);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final res = await ApiService.login(email, password);
      if (res['token'] != null) {
        _user = User.fromJson(res['user'], token: res['token']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(res['user']));
        await prefs.setString('token', res['token']);
        notifyListeners();
        return null;
      }
      return 'Invalid response from server';
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> register(String username, String email, String password) async {
    try {
      final res = await ApiService.register(username, email, password);
      if (res['message'] == 'User registered') {
        return null; // Success
      }
      return res['message'] ?? 'Registration failed';
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      debugPrint('Starting Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('Google Sign-In cancelled by user.');
        return 'Google sign in cancelled';
      }

      debugPrint('Getting Google Authentication for: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      debugPrint('Google Auth Response: idToken=${idToken != null ? "present (${idToken.length} chars)" : "NULL"}, accessToken=${accessToken != null ? "present" : "NULL"}');

      if (idToken == null && accessToken == null) {
        return 'Failed to get authentication tokens from Google.';
      }

      debugPrint('Calling backend googleLogin with: idToken=${idToken != null ? "YES" : "NO"}, accessToken=${accessToken != null ? "YES" : "NO"}');
      final res = await ApiService.googleLogin(idToken, accessToken);
      debugPrint('Backend Response: $res');
      
      if (res['token'] != null) {
        _user = User.fromJson(res['user'], token: res['token']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(res['user']));
        await prefs.setString('token', res['token']);
        notifyListeners();
        return null;
      }
      return 'Invalid response from server';
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> logout() async {
    try {
      _user = null;
      // Google logout can fail if not configured for web, wrap it
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        debugPrint('Google sign out error: $e');
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }
}
