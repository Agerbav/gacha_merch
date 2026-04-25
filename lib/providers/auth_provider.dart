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
      // Handle error
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
        return null;
      }
      return res['message'] ?? 'Registration failed';
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return 'Google sign in cancelled';
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null && accessToken == null) {
        return 'Failed to get authentication tokens from Google.';
      }

      final res = await ApiService.googleLogin(idToken, accessToken);
      
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
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        // Handle error
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }
}
