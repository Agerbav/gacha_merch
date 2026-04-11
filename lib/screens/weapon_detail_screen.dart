import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/weapon_provider.dart';

class WeaponDetailScreen extends StatelessWidget {
  final Weapon weapon;

  WeaponDetailScreen({required this.weapon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(weapon.name)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[300],
              child: Icon(Icons.image, size: 100, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(weapon.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text('\$${weapon.price}', style: TextStyle(fontSize: 20, color: Colors.blue[900], fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Chip(label: Text(weapon.type), backgroundColor: Colors.amber[100]),
                  SizedBox(height: 10),
                  Text('Stock: ${weapon.stock}', style: TextStyle(color: weapon.stock > 0 ? Colors.green : Colors.red)),
                  SizedBox(height: 20),
                  Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 10),
                  Text(weapon.description),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: weapon.stock > 0 
                        ? () {
                            context.read<WeaponProvider>().addToCart(weapon);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added ${weapon.name} to cart')));
                          }
                        : null,
                      child: Text('Add to Cart'),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
