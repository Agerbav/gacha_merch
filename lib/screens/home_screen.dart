import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/weapon_provider.dart';
import '../providers/theme_provider.dart';
import 'weapon_detail_screen.dart';
import 'cart_screen.dart';
import 'admin_screen.dart';

import '../widgets/weapon_image.dart';

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
    final themeProv = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Teyvat Market', style: Theme.of(context).textTheme.titleLarge),
            Text('Find your legendary weapon', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(themeProv.themeMode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_outlined),
            onPressed: () => themeProv.toggleTheme(),
          ),
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
              child: weaponProv.weapons.isEmpty 
                ? const Center(child: Text('No weapons found matching your criteria'))
                : GridView.builder(
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
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
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
                                  color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF5F5F7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Hero(
                                  tag: 'weapon-${weapon.id}',
                                  child: WeaponImage(
                                    imageUrl: weapon.image,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF2C2C2E) : Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)
                                    ]
                                  ),
                                  child: Text(
                                    weapon.type.toUpperCase(),
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: isDark ? Colors.blue.shade300 : Colors.blueGrey.shade800, letterSpacing: 0.5),
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
                                      side: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                                    ),
                                    child: Text('Manage', style: TextStyle(fontSize: 13, color: isDark ? Colors.blue.shade300 : Colors.blueGrey.shade700, fontWeight: FontWeight.bold)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFilterDialog(context),
        backgroundColor: isDark ? const Color(0xFF1E88E5) : Colors.white,
        foregroundColor: isDark ? Colors.white : Theme.of(context).colorScheme.primary,
        elevation: 4,
        child: const Icon(Icons.filter_list_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showFilterDialog(BuildContext context) {
    final weaponProv = context.read<WeaponProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameController = TextEditingController(text: weaponProv.searchQuery);
    final minPriceController = TextEditingController(text: weaponProv.minPrice?.toString() ?? '');
    final maxPriceController = TextEditingController(text: weaponProv.maxPrice?.toString() ?? '');
    int? selectedCatId = weaponProv.selectedCategoryId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filter Weapons', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  TextButton(
                    onPressed: () {
                      weaponProv.clearFilters();
                      Navigator.pop(context);
                    }, 
                    child: const Text('Clear All')
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Search by Name',
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 20),
              const Text('Price Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Min Price',
                        prefixIcon: const Icon(Icons.attach_money_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: maxPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Max Price',
                        prefixIcon: const Icon(Icons.attach_money_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: selectedCatId == null,
                    onSelected: (v) => setModalState(() => selectedCatId = null),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  ...weaponProv.categories.map((cat) => FilterChip(
                    label: Text(cat.name),
                    selected: selectedCatId == cat.id,
                    onSelected: (v) => setModalState(() => selectedCatId = v ? cat.id : null),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  )),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    weaponProv.setFilters(
                      query: nameController.text,
                      categoryId: selectedCatId,
                      minPrice: double.tryParse(minPriceController.text),
                      maxPrice: double.tryParse(maxPriceController.text),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
