class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final String? token;

  User({required this.id, required this.username, required this.email, required this.role, this.token});

  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? 'User',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      token: token,
    );
  }
}

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class Weapon {
  final int id;
  final String name;
  final String type; // This will still hold the category name for display
  final int categoryId;
  final String description;
  final int stock;
  final String image;
  final double price;

  Weapon({
    required this.id,
    required this.name,
    required this.type,
    required this.categoryId,
    required this.description,
    required this.stock,
    required this.image,
    required this.price,
  });

  factory Weapon.fromJson(Map<String, dynamic> json) {
    return Weapon(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Weapon',
      type: json['category_name'] ?? json['type'] ?? 'General',
      categoryId: json['category_id'] ?? 0,
      description: json['description'] ?? '',
      stock: json['stock'] ?? 0,
      image: json['image'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category_id': categoryId,
      'description': description,
      'stock': stock,
      'image': image,
      'price': price,
    };
  }
}
