import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/weapon_provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final weapon = Weapon(
        id: 0,
        name: _nameController.text,
        type: _typeController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        description: _descController.text,
        image: '',
      );
      final auth = context.read<AuthProvider>();
      await context.read<WeaponProvider>().addWeapon(weapon, auth.user!.token!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weaponProv = context.watch<WeaponProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Inventory Management'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: weaponProv.weapons.length,
        itemBuilder: (context, i) {
          final weapon = weaponProv.weapons[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(weapon.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                '\$${weapon.price} • ${weapon.stock} units',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                onPressed: () => weaponProv.deleteWeapon(weapon.id, context.read<AuthProvider>().user!.token!),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        label: const Text('Add Weapon'),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Add New Weapon', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _typeController, decoration: const InputDecoration(labelText: 'Type'), validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number, validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _stockController, decoration: const InputDecoration(labelText: 'Stock'), keyboardType: TextInputType.number, validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: _submit, 
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 45)),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
