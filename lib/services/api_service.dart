import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    } else {
      return 'http://localhost:3000';
    }
  }

  static Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final message = jsonDecode(response.body)['message'] ?? 'An error occurred';
      throw Exception(message);
    }
  }

  // Auth
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(null),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers(null),
      body: jsonEncode({'username': username, 'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> googleLogin(String idToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/google'),
      headers: _headers(null),
      body: jsonEncode({'idToken': idToken}),
    );
    return _handleResponse(response);
  }

  // Weapons
  static Future<List<Weapon>> getWeapons() async {
    final response = await http.get(Uri.parse('$baseUrl/weapons'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((item) => Weapon.fromJson(item)).toList();
    }
    throw Exception('Failed to load weapons');
  }

  static Future<void> createWeapon(Weapon weapon, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/weapons'),
      headers: _headers(token),
      body: jsonEncode(weapon.toJson()),
    );
    _handleResponse(response);
  }

  static Future<void> updateWeapon(int id, Weapon weapon, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/weapons/$id'),
      headers: _headers(token),
      body: jsonEncode(weapon.toJson()),
    );
    _handleResponse(response);
  }

  static Future<void> deleteWeapon(int id, String token) async {
    final response = await http.delete(Uri.parse('$baseUrl/weapons/$id'), headers: _headers(token));
    _handleResponse(response);
  }

  // Transactions
  static Future<Map<String, dynamic>> buy(List<Map<String, dynamic>> items, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/buy'),
      headers: _headers(token),
      body: jsonEncode({'items': items}),
    );
    return _handleResponse(response);
  }
}
