import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/weapon_provider.dart';
import 'weapon_detail_screen.dart';
import 'cart_screen.dart';
import 'admin_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<WeaponProvider>().fetchWeapons());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final weaponProv = context.watch<WeaponProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Teyvat Market'),
        actions: [
          if (auth.isAdmin)
            IconButton(icon: Icon(Icons.admin_panel_settings), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminScreen()))),
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
                if (weaponProv.cart.isNotEmpty)
                  Positioned(right: 0, top: 0, child: CircleAvatar(radius: 7, backgroundColor: Colors.red, child: Text('${weaponProv.cart.length}', style: TextStyle(fontSize: 10)))),
              ],
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen())),
          ),
          IconButton(icon: Icon(Icons.logout), onPressed: () => auth.logout()),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: weaponProv.weapons.length,
        itemBuilder: (context, i) {
          final weapon = weaponProv.weapons[i];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WeaponDetailScreen(weapon: weapon))),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      child: Container(
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Icon(Icons.image, size: 50, color: Colors.grey), // Placeholder
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(weapon.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(weapon.type, style: TextStyle(color: Colors.amber[800], fontSize: 12)),
                        SizedBox(height: 5),
                        Text('\$${weapon.price}', style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.add_shopping_cart, size: 20),
                            onPressed: () => weaponProv.addToCart(weapon),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
