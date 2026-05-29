import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/weapon_provider.dart';
import '../widgets/weapon_image.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descController = TextEditingController();
  final _newCategoryController = TextEditingController();
  int? _selectedCategoryId;
  XFile? _imageFile;
  Uint8List? _imagePreviewBytes;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  void _submit({int? editId}) async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select a weapon type'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade800,
          )
        );
        return;
      }
      setState(() => _isLoading = true);
      try {
        final weapon = Weapon(
          id: editId ?? 0,
          name: _nameController.text,
          type: '',
          categoryId: _selectedCategoryId!,
          price: double.parse(_priceController.text),
          stock: int.parse(_stockController.text),
          description: _descController.text,
          image: '',
        );
        final auth = context.read<AuthProvider>();
        if (editId != null) {
          await context.read<WeaponProvider>().editWeapon(editId, weapon, auth.user!.token!, imageFile: _imageFile);
        } else {
          await context.read<WeaponProvider>().addWeapon(weapon, auth.user!.token!, imageFile: _imageFile);
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), behavior: SnackBarBehavior.floating));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _manageCategory({Category? category}) async {
    final name = _newCategoryController.text.trim();
    if (name.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        final auth = context.read<AuthProvider>();
        if (category != null) {
          await context.read<WeaponProvider>().editCategory(category.id, name, auth.user!.token!);
        } else {
          await context.read<WeaponProvider>().addCategory(name, auth.user!.token!);
        }
        _newCategoryController.clear();
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), behavior: SnackBarBehavior.floating));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final weaponProv = context.watch<WeaponProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Admin Console'),
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.shield_outlined), text: 'Weapons'),
            Tab(icon: Icon(Icons.category_outlined), text: 'Categories'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWeaponsTab(weaponProv),
          _buildCategoriesTab(weaponProv),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddWeaponDialog();
          } else {
            _showCategoryDialog();
          }
        },
        label: Text(_tabController.index == 0 ? 'Add Weapon' : 'Add Category'),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildWeaponsTab(WeaponProvider weaponProv) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: weaponProv.weapons.length,
      itemBuilder: (context, i) {
        final weapon = weaponProv.weapons[i];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50, 
                borderRadius: BorderRadius.circular(12)
              ),
              child: WeaponImage(
                imageUrl: weapon.image,
                borderRadius: BorderRadius.circular(12),
                iconSize: 24,
              ),
            ),
            title: Text(weapon.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${weapon.type} • \$${weapon.price}', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 12, color: weapon.stock < 5 ? Colors.red : Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Stock: ${weapon.stock}',
                      style: TextStyle(
                        fontSize: 12, 
                        color: weapon.stock < 5 ? Colors.red : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                        fontWeight: weapon.stock < 5 ? FontWeight.bold : FontWeight.normal
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: () => _showAddWeaponDialog(weapon: weapon)),
                IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.red), onPressed: () => _confirmDeleteWeapon(weapon)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesTab(WeaponProvider weaponProv) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: weaponProv.categories.length,
      itemBuilder: (context, i) {
        final cat = weaponProv.categories[i];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF5F5F5),
              child: Icon(Icons.category_outlined, size: 20, color: isDark ? Colors.blue.shade300 : Colors.blueGrey),
            ),
            title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: () => _showCategoryDialog(category: cat)),
                IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.red), onPressed: () => _confirmDeleteCategory(cat)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteWeapon(Weapon weapon) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Weapon?'),
        content: Text('Are you sure you want to delete ${weapon.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<WeaponProvider>().deleteWeapon(weapon.id, context.read<AuthProvider>().user!.token!);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Weapon deleted'), behavior: SnackBarBehavior.floating));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), behavior: SnackBarBehavior.floating));
      }
    }
  }

  void _confirmDeleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text('Delete "${category.name}"? This will only work if no weapons are using it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<WeaponProvider>().deleteCategory(category.id, context.read<AuthProvider>().user!.token!);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category deleted'), behavior: SnackBarBehavior.floating));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), behavior: SnackBarBehavior.floating));
      }
    }
  }

  void _showCategoryDialog({Category? category}) {
    _newCategoryController.text = category?.name ?? '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(category == null ? 'New Category' : 'Edit Category', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            TextFormField(
              controller: _newCategoryController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g. Scythe',
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => _manageCategory(category: category), 
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(category == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _showAddWeaponDialog({Weapon? weapon}) {
    final weaponProv = context.read<WeaponProvider>();
    
    _selectedCategoryId = weapon?.categoryId;
    _nameController.text = weapon?.name ?? '';
    _priceController.text = weapon?.price.toString() ?? '';
    _stockController.text = weapon?.stock.toString() ?? '';
    _descController.text = weapon?.description ?? '';
    _imageFile = null;
    _imagePreviewBytes = null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            title: Row(
              children: [
                Icon(weapon == null ? Icons.add_circle_outline : Icons.edit_note_rounded, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(weapon == null ? 'New Weapon' : 'Edit Weapon', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Form(
              key: _formKey,
              child: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () async {
                            try {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                                maxWidth: 1024,
                                maxHeight: 1024,
                                imageQuality: 85,
                              );
                              
                              if (image != null) {
                                final bytes = await image.readAsBytes();
                                setState(() {
                                  _imageFile = image;
                                  _imagePreviewBytes = bytes;
                                });
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Could not open file picker: $e'))
                                );
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
                            ),
                            child: _imagePreviewBytes != null
                                ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.memory(_imagePreviewBytes!, fit: BoxFit.cover))
                                : weapon != null && weapon.image.isNotEmpty
                                    ? WeaponImage(imageUrl: weapon.image, borderRadius: BorderRadius.circular(16), iconSize: 40)
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_a_photo_outlined, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                          const SizedBox(height: 8),
                                          Text('Select Weapon Image', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12)),
                                        ],
                                      ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController, 
                        decoration: _inputDecoration('Weapon Name', Icons.title_rounded),
                        validator: (v) => v!.isEmpty ? 'Required' : null
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        decoration: _inputDecoration('Weapon Type', Icons.category_rounded),
                        items: weaponProv.categories.map((cat) => DropdownMenuItem(
                          value: cat.id,
                          child: Text(cat.name),
                        )).toList(),
                        onChanged: (v) => setState(() => _selectedCategoryId = v),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController, 
                              decoration: _inputDecoration('Price', Icons.attach_money_rounded),
                              keyboardType: TextInputType.number, 
                              validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _stockController, 
                              decoration: _inputDecoration('Stock', Icons.inventory_2_rounded),
                              keyboardType: TextInputType.number, 
                              validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid' : null
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descController, 
                        decoration: _inputDecoration('Description', Icons.description_rounded),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: _isLoading ? null : () => _submit(editId: weapon?.id), 
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(140, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(weapon == null ? 'Add Weapon' : 'Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
