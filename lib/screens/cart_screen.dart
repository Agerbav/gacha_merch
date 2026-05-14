import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weapon_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/weapon_image.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weaponProv = context.watch<WeaponProvider>();
    final auth = context.read<AuthProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cartItems = weaponProv.cart.entries.toList();

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Shopping Bag', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.shopping_bag_outlined, 
                      size: 64, 
                      color: isDark ? Colors.white30 : Colors.grey.shade400
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Your bag is empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Looks like you haven\'t added\nany legendary weapons yet.', 
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14, 
                      color: isDark ? Colors.white60 : Colors.grey.shade600, 
                      height: 1.5
                    )
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Start Exploring'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: cartItems.length,
                    itemBuilder: (context, i) {
                      final entry = cartItems[i];
                      final weapon = weaponProv.weapons.firstWhere((w) => w.id == entry.key);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black26 : Colors.black.withOpacity(0.03), 
                              blurRadius: 15, 
                              offset: const Offset(0, 8)
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFF5F5F7),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: WeaponImage(
                                  imageUrl: weapon.image,
                                  fit: BoxFit.cover,
                                  borderRadius: BorderRadius.circular(12),
                                  iconSize: 24,
                                ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      weapon.name, 
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      weapon.type,
                                      style: TextStyle(
                                        fontSize: 12, 
                                        color: isDark ? Colors.white60 : Colors.grey.shade500, 
                                        fontWeight: FontWeight.w600
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '\$${weapon.price}',
                                          style: TextStyle(
                                            color: colorScheme.primary, 
                                            fontWeight: FontWeight.w900, 
                                            fontSize: 16
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Qty: ${entry.value}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(isDark ? 0.1 : 0.05), 
                                    shape: BoxShape.circle
                                  ),
                                  child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                ),
                                onPressed: () => weaponProv.removeFromCart(weapon.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black45 : Colors.black.withOpacity(0.05), 
                        blurRadius: 20, 
                        offset: const Offset(0, -5)
                      )
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal', 
                              style: TextStyle(
                                fontSize: 16, 
                                color: isDark ? Colors.white60 : Colors.grey.shade600, 
                                fontWeight: FontWeight.w500
                              )
                            ),
                            Text(
                              '\$${weaponProv.cartTotal.toStringAsFixed(2)}', 
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Shipping', 
                              style: TextStyle(
                                fontSize: 16, 
                                color: isDark ? Colors.white60 : Colors.grey.shade600, 
                                fontWeight: FontWeight.w500
                              )
                            ),
                            const Text(
                              'FREE', 
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)
                            ),
                          ],
                        ),
                        Divider(height: 40, color: isDark ? Colors.white12 : null),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Bill', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                            Text(
                              '\$${weaponProv.cartTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 24, 
                                fontWeight: FontWeight.w900, 
                                color: colorScheme.primary
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () async {
                            final err = await weaponProv.checkout(auth.user!.token!);
                            if (err == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Order placed successfully!'), 
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  backgroundColor: Colors.green.shade800,
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $err'), 
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.red.shade800,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            elevation: 4,
                            shadowColor: colorScheme.primary.withOpacity(0.3),
                          ),
                          child: const Text('Confirm Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
