import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/weapon_provider.dart';
import 'weapon_detail_screen.dart';
import 'cart_screen.dart';
import 'admin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Teyvat Market', style: Theme.of(context).textTheme.titleLarge),
            Text('Find your legendary weapon', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined), 
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen()))
            ),
          if (!auth.isAdmin)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                ),
                if (weaponProv.cart.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${weaponProv.cart.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.logout_rounded), 
            onPressed: () {
              weaponProv.clearCart();
              auth.logout();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: weaponProv.isLoading 
          ? const Center(key: ValueKey('loading'), child: CircularProgressIndicator())
          : RefreshIndicator(
              key: const ValueKey('content'),
              onRefresh: () => weaponProv.fetchWeapons(),
              child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                childAspectRatio: 0.8, 
                crossAxisSpacing: 16, 
                mainAxisSpacing: 16
              ),
              itemCount: weaponProv.weapons.length,
              itemBuilder: (context, i) {
                final weapon = weaponProv.weapons[i];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WeaponDetailScreen(weapon: weapon))),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Hero(
                                  tag: 'weapon-${weapon.id}',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: weapon.image.isNotEmpty 
                                        ? Image.network(
                                            weapon.image, 
                                            fit: BoxFit.cover, 
                                            errorBuilder: (_, __, ___) => Icon(Icons.shield_moon_outlined, size: 48, color: Colors.grey.shade400)
                                          )
                                        : Icon(Icons.shield_moon_outlined, size: 48, color: Colors.grey.shade400),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)
                                    ]
                                  ),
                                  child: Text(
                                    weapon.type.toUpperCase(),
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade800, letterSpacing: 0.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weapon.name, 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.5), 
                                maxLines: 1, 
                                overflow: TextOverflow.ellipsis
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '\$${weapon.price}', 
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary, 
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (!auth.isAdmin)
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          weaponProv.addToCart(weapon);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${weapon.name} added to cart'),
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                          foregroundColor: Colors.white,
                                          minimumSize: const Size(0, 44),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          elevation: 2,
                                          shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                                        ),
                                        child: const Text('Add', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WeaponDetailScreen(weapon: weapon))),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(0, 44),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      side: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    child: Text('Manage', style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade700, fontWeight: FontWeight.bold)),
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
          ),
      ),
    );
  }
}
