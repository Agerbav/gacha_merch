import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/weapon_provider.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weaponProv = context.watch<WeaponProvider>();
    final auth = context.read<AuthProvider>();

    final cartItems = weaponProv.cart.entries.toList();

    return Scaffold(
      appBar: AppBar(title: Text('Your Cart')),
      body: cartItems.isEmpty
          ? Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, i) {
                      final entry = cartItems[i];
                      final weapon = weaponProv.weapons.firstWhere((w) => w.id == entry.key);
                      return ListTile(
                        leading: Icon(Icons.shopping_bag),
                        title: Text(weapon.name),
                        subtitle: Text('${entry.value} x \$${weapon.price}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => weaponProv.removeFromCart(weapon.id),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total: \$${weaponProv.cartTotal.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        onPressed: () async {
                          final err = await weaponProv.checkout(auth.user!.token!);
                          if (err == null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order placed successfully!')));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $err')));
                          }
                        },
                        child: Text('Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
