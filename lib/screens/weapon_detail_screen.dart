import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/weapon_provider.dart';
import '../widgets/weapon_image.dart';

class WeaponDetailScreen extends StatefulWidget {
  final Weapon weapon;

  const WeaponDetailScreen({super.key, required this.weapon});

  @override
  State<WeaponDetailScreen> createState() => _WeaponDetailScreenState();
}

class _WeaponDetailScreenState extends State<WeaponDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descController;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.weapon.name);
    _priceController = TextEditingController(text: widget.weapon.price.toString());
    _stockController = TextEditingController(text: widget.weapon.stock.toString());
    _descController = TextEditingController(text: widget.weapon.description);
    _selectedCategoryId = widget.weapon.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weaponProv = context.watch<WeaponProvider>();
    final currentWeapon = weaponProv.weapons.firstWhere((w) => w.id == widget.weapon.id, orElse: () => widget.weapon);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Center(
                child: Hero(
                  tag: 'weapon-${currentWeapon.id}',
                  child: WeaponImage(
                    imageUrl: currentWeapon.image,
                    width: double.infinity,
                    height: 400,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                    iconSize: 100,
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
                              currentWeapon.name, 
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.amber.withOpacity(0.1) : Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                currentWeapon.type.toUpperCase(),
                                style: TextStyle(
                                  color: isDark ? Colors.amber.shade300 : Colors.amber.shade900, 
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
                        '\$${currentWeapon.price}', 
                        style: TextStyle(
                          fontSize: 28, 
                          color: colorScheme.primary, 
                          fontWeight: FontWeight.w900
                        )
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.inventory_2_outlined, 
                        '${currentWeapon.stock} in stock', 
                        currentWeapon.stock > 0 ? Colors.green : Colors.red,
                        isDark,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.star_outline_rounded, 
                        'Legendary', 
                        Colors.blue,
                        isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Description', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentWeapon.description,
                    style: TextStyle(
                      fontSize: 16, 
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<AuthProvider>(
        builder: (context, auth, _) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black45 : Colors.black.withOpacity(0.05), 
                blurRadius: 20, 
                offset: const Offset(0, -5)
              )
            ],
          ),
          child: SafeArea(
            child: auth.isAdmin 
              ? ElevatedButton.icon(
                  onPressed: () => _showEditDialog(context),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit Weapon Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? colorScheme.primaryContainer : Colors.blueGrey.shade800,
                    foregroundColor: isDark ? colorScheme.onPrimaryContainer : Colors.white,
                  ),
                )
              : ElevatedButton(
                  onPressed: currentWeapon.stock > 0 
                    ? () {
                        context.read<WeaponProvider>().addToCart(currentWeapon);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${currentWeapon.name} added to cart'),
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
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final weaponProv = context.read<WeaponProvider>();
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Edit Weapon', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Weapon Type'),
                    items: weaponProv.categories.map((cat) => DropdownMenuItem(
                      value: cat.id,
                      child: Text(cat.name),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
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
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final updatedWeapon = Weapon(
                    id: widget.weapon.id,
                    name: _nameController.text,
                    type: '', // Set by DB
                    categoryId: _selectedCategoryId!,
                    price: double.parse(_priceController.text),
                    stock: int.parse(_stockController.text),
                    description: _descController.text,
                    image: widget.weapon.image,
                  );
                  final auth = context.read<AuthProvider>();
                  await context.read<WeaponProvider>().editWeapon(widget.weapon.id, updatedWeapon, auth.user!.token!);
                  if (mounted) Navigator.pop(context);
                }
              }, 
              style: ElevatedButton.styleFrom(minimumSize: const Size(100, 45)),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isDark ? color.withOpacity(0.9) : color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: isDark ? color.withOpacity(0.9) : color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
