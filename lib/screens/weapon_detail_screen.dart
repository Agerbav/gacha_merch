import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/weapon_provider.dart';

class WeaponDetailScreen extends StatelessWidget {
  final Weapon weapon;

  const WeaponDetailScreen({super.key, required this.weapon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Center(
                child: Hero(
                  tag: 'weapon-${weapon.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: Icon(Icons.shield, size: 160, color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              weapon.name, 
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                weapon.type.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.amber.shade900, 
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${weapon.price}', 
                        style: TextStyle(
                          fontSize: 28, 
                          color: Theme.of(context).colorScheme.primary, 
                          fontWeight: FontWeight.w900
                        )
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      _buildInfoChip(Icons.inventory_2_outlined, '${weapon.stock} in stock', weapon.stock > 0 ? Colors.green : Colors.red),
                      const SizedBox(width: 12),
                      _buildInfoChip(Icons.star_outline_rounded, 'Legendary', Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Description', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                  ),
                  const SizedBox(height: 12),
                  Text(
                    weapon.description,
                    style: TextStyle(
                      fontSize: 16, 
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 120), // Spacing for bottom button
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: weapon.stock > 0 
              ? () {
                  context.read<WeaponProvider>().addToCart(weapon);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${weapon.name} added to cart'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    )
                  );
                }
              : null,
            child: const Text('Add to Shopping Bag'),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
