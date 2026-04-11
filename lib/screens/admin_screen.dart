import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/weapon_provider.dart';

class AdminScreen extends StatefulWidget {
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
      appBar: AppBar(title: Text('Admin Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => _showAddDialog(),
              child: Text('Add New Weapon'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: weaponProv.weapons.length,
              itemBuilder: (context, i) {
                final weapon = weaponProv.weapons[i];
                return ListTile(
                  title: Text(weapon.name),
                  subtitle: Text('\$${weapon.price} - Stock: ${weapon.stock}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => weaponProv.deleteWeapon(weapon.id, context.read<AuthProvider>().user!.token!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add Weapon'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: _nameController, decoration: InputDecoration(labelText: 'Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
                TextFormField(controller: _typeController, decoration: InputDecoration(labelText: 'Type'), validator: (v) => v!.isEmpty ? 'Required' : null),
                TextFormField(controller: _priceController, decoration: InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number, validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null),
                TextFormField(controller: _stockController, decoration: InputDecoration(labelText: 'Stock'), keyboardType: TextInputType.number, validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid' : null),
                TextFormField(controller: _descController, decoration: InputDecoration(labelText: 'Description'), maxLines: 3),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(onPressed: _submit, child: Text('Add')),
        ],
      ),
    );
  }
}
