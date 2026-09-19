import 'package:flutter/material.dart';

import 'products_screen.dart';
import 'add_product_screen.dart';
import 'pricing_screen.dart';
import 'marketplace_screen.dart';
import 'business_screen.dart';
import 'image_studio_screen.dart';
import 'artisan_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = const [
      BusinessScreen(),
      ProductsScreen(),
      AddProductScreen(),
      PricingScreen(),
      MarketplaceScreen(),
      ArtisanProfileScreen(),
    ];
  }

  // ============================================================
  // OPEN AI IMAGE STUDIO
  // ============================================================

  void _openImageStudio() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ImageStudioScreen()));
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  void _onNavigationChanged(int index) {
    if (index < 0 || index >= _pages.length) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EFE7),

      // ========================================================
      // PAGE CONTENT
      // ========================================================
      body: IndexedStack(index: _currentIndex, children: _pages),

      // ========================================================
      // AI IMAGE STUDIO BUTTON
      // ========================================================
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _openImageStudio,

              backgroundColor: const Color(0xFFA24B2A),

              foregroundColor: Colors.white,

              elevation: 8,

              icon: const Icon(Icons.auto_fix_high),

              label: const Text(
                'AI Image Studio',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            )
          : null,

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================
      bottomNavigationBar: NavigationBar(
        height: 78,

        backgroundColor: Colors.white,

        elevation: 4,

        selectedIndex: _currentIndex,

        onDestinationSelected: _onNavigationChanged,

        indicatorColor: const Color(0xFFDDF1EA),

        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

        destinations: const [
          // ====================================================
          // HOME
          // ====================================================

          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),

          // ====================================================
          // PRODUCTS
          // ====================================================
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),

          // ====================================================
          // ADD
          // ====================================================
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Add',
          ),

          // ====================================================
          // PRICING
          // ====================================================
          NavigationDestination(
            icon: Icon(Icons.auto_graph_outlined),
            selectedIcon: Icon(Icons.auto_graph),
            label: 'Pricing',
          ),

          // ====================================================
          // MARKET
          // ====================================================
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Market',
          ),

          // ====================================================
          // AI MANAGER
          // ====================================================
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
