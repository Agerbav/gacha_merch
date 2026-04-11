class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final String? token;

  User({required this.id, required this.username, required this.email, required this.role, this.token});

  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      token: token,
    );
  }
}

class Weapon {
  final int id;
  final String name;
  final String type;
  final String description;
  final int stock;
  final String image;
  final double price;

  Weapon({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.stock,
    required this.image,
    required this.price,
  });

  factory Weapon.fromJson(Map<String, dynamic> json) {
    return Weapon(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      description: json['description'] ?? '',
      stock: json['stock'],
      image: json['image'] ?? '',
      price: double.parse(json['price'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'description': description,
      'stock': stock,
      'image': image,
      'price': price,
    };
  }
}
