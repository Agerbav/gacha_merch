import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
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

  static Future<Map<String, dynamic>> googleLogin(String? idToken, String? accessToken) async {
    debugPrint('POST to: $baseUrl/auth/google');
    final response = await http.post(
      Uri.parse('$baseUrl/auth/google'),
      headers: _headers(null),
      body: jsonEncode({
        'idToken': idToken,
        'accessToken': accessToken,
      }),
    );
    return _handleResponse(response);
  }

  // Weapons
  static Future<List<Weapon>> getWeapons() async {
    final response = await http.get(Uri.parse('$baseUrl/weapons'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((item) {
        final weapon = Weapon.fromJson(item);
        if (weapon.image.startsWith('/uploads')) {
          return Weapon.fromJson({
            ...item,
            'image': '$baseUrl${weapon.image}',
          });
        }
        return weapon;
      }).toList();
    }
    throw Exception('Failed to load weapons');
  }

  static Future<void> createWeapon(Weapon weapon, String token, {XFile? imageFile}) async {
    final uri = Uri.parse('$baseUrl/weapons');
    final request = http.MultipartRequest('POST', uri);
    
    request.headers.addAll({
      if (token != null) 'Authorization': 'Bearer $token',
    });
    
    request.fields['name'] = weapon.name;
    request.fields['category_id'] = weapon.categoryId.toString();
    request.fields['description'] = weapon.description;
    request.fields['stock'] = weapon.stock.toString();
    request.fields['price'] = weapon.price.toString();

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'image_file',
        bytes,
        filename: imageFile.name,
        contentType: MediaType('image', 'jpeg'),
      ));
    } else {
      request.fields['image'] = weapon.image;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    _handleResponse(response);
  }

  static Future<void> updateWeapon(int id, Weapon weapon, String token, {XFile? imageFile}) async {
    final uri = Uri.parse('$baseUrl/weapons/$id');
    final request = http.MultipartRequest('PUT', uri);
    
    request.headers.addAll({
      if (token != null) 'Authorization': 'Bearer $token',
    });
    
    request.fields['name'] = weapon.name;
    request.fields['category_id'] = weapon.categoryId.toString();
    request.fields['description'] = weapon.description;
    request.fields['stock'] = weapon.stock.toString();
    request.fields['price'] = weapon.price.toString();

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'image_file',
        bytes,
        filename: imageFile.name,
        contentType: MediaType('image', 'jpeg'),
      ));
    } else {
      request.fields['image'] = weapon.image;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
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

  // Categories
  static Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((item) => Category.fromJson(item)).toList();
    }
    throw Exception('Failed to load categories');
  }

  static Future<void> createCategory(String name, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categories'),
      headers: _headers(token),
      body: jsonEncode({'name': name}),
    );
    _handleResponse(response);
  }

  static Future<void> updateCategory(int id, String name, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/categories/$id'),
      headers: _headers(token),
      body: jsonEncode({'name': name}),
    );
    _handleResponse(response);
  }

  static Future<void> deleteCategory(int id, String token) async {
    final url = '$baseUrl/categories/$id';
    debugPrint('DELETE to: $url');
    final response = await http.delete(
      Uri.parse(url),
      headers: _headers(token),
    );
    _handleResponse(response);
  }
}
