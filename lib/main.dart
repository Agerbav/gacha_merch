import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/weapon_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WeaponProvider()),
      ],
      child: const GenshinImportApp(),
    ),
  );
}

class GenshinImportApp extends StatelessWidget {
  const GenshinImportApp({super.key});

  @override
  Widget build(BuildContext context) {
    // UI Theme Customizations:
    // 1. Font Family (custom via default theme)
    // 2. Background Color (Scaffold background)
    // 3. Tint (Primary Color)
    // 4. Content Mode (via card themes/button styles)
    
    return MaterialApp(
      title: 'Teyvat Market',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1C1E), // Deep Midnight Blue
          primary: const Color(0xFF1E88E5),    // Vibrant Blue
          secondary: const Color(0xFFFFA000),  // Warm Gold
          surface: Colors.white,
          background: const Color(0xFFF8F9FA),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        
        // Typography
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E)),
          titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A1C1E)),
          bodyLarge: TextStyle(color: Color(0xFF424242)),
        ),

        // Component Themes
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF1A1C1E)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1A1C1E),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          color: Colors.white,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFF1E88E5),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: auth.isAuthenticated 
                ? const HomeScreen(key: ValueKey('HomeScreen')) 
                : const LoginScreen(key: ValueKey('LoginScreen')),
          );
        },
      ),
    );
  }
}
