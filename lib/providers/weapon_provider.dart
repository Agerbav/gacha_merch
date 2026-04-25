import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class WeaponProvider with ChangeNotifier {
  List<Weapon> _weapons = [];
  List<Category> _categories = [];
  final Map<int, int> _cart = {}; // weaponId -> quantity
  bool _isLoading = false;

  List<Weapon> get weapons => _weapons;
  List<Category> get categories => _categories;
  Map<int, int> get cart => _cart;
  bool get isLoading => _isLoading;

  double get cartTotal {
    double total = 0;
    _cart.forEach((id, qty) {
      final w = _weapons.firstWhere((element) => element.id == id);
      total += w.price * qty;
    });
    return total;
  }

  Future<void> fetchWeapons() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        ApiService.getWeapons(),
        ApiService.getCategories(),
      ]);
      _weapons = results[0] as List<Weapon>;
      _categories = results[1] as List<Category>;
    } catch (e) {
      debugPrint('Error fetching data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addToCart(Weapon weapon) {
    if (_cart.containsKey(weapon.id)) {
      _cart[weapon.id] = _cart[weapon.id]! + 1;
    } else {
      _cart[weapon.id] = 1;
    }
    notifyListeners();
  }

  void removeFromCart(int id) {
    _cart.remove(id);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  Future<String?> checkout(String token) async {
    if (_cart.isEmpty) return 'Cart is empty';
    final items = _cart.entries.map((e) => {'weapon_id': e.key, 'quantity': e.value}).toList();
    try {
      final res = await ApiService.buy(items, token);
      if (res['message'] == 'Purchase successful') {
        _cart.clear();
        await fetchWeapons();
        return null;
      }
      return res['message'];
    } catch (e) {
      return e.toString();
    }
  }

  // Admin CRUD
  Future<void> addWeapon(Weapon weapon, String token, {XFile? imageFile}) async {
    await ApiService.createWeapon(weapon, token, imageFile: imageFile);
    await fetchWeapons();
  }

  Future<void> editWeapon(int id, Weapon weapon, String token, {XFile? imageFile}) async {
    await ApiService.updateWeapon(id, weapon, token, imageFile: imageFile);
    await fetchWeapons();
  }

  Future<void> deleteWeapon(int id, String token) async {
    await ApiService.deleteWeapon(id, token);
    await fetchWeapons();
  }

  Future<void> addCategory(String name, String token) async {
    await ApiService.createCategory(name, token);
    await fetchWeapons();
  }

  Future<void> editCategory(int id, String name, String token) async {
    await ApiService.updateCategory(id, name, token);
    await fetchWeapons();
  }

  Future<void> deleteCategory(int id, String token) async {
    await ApiService.deleteCategory(id, token);
    await fetchWeapons();
  }
}
