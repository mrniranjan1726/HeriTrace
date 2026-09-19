import 'package:flutter/material.dart';

import 'products_screen.dart';
import 'add_product_screen.dart';
import 'pricing_screen.dart';
import 'marketplace_screen.dart';
import 'business_screen.dart';
import 'image_studio_screen.dart';
import 'artisan_profile_screen.dart';
import 'artisan_auctions_screen.dart';
import 'artisan_community_screen.dart';
import '../widgets/support_chatbot.dart';

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
      ArtisanAuctionsScreen(),
      ArtisanCommunityScreen(),
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
      // AI STUDIO & CHATBOT BUTTONS
      // ========================================================
      floatingActionButton: _currentIndex == 0
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'artisan-ai-studio',
                  onPressed: _openImageStudio,
                  backgroundColor: const Color(0xFFA24B2A),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text(
                    'AI Studio',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                const SupportChatbot(role: 'artisan'),
              ],
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
        indicatorColor: const Color(0xFFF3E2D1),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.handyman_outlined),
            selectedIcon: Icon(Icons.handyman, color: Color(0xFFA24B2A)),
            label: 'Atelier',
          ),
          NavigationDestination(
            icon: Icon(Icons.palette_outlined),
            selectedIcon: Icon(Icons.palette, color: Color(0xFFA24B2A)),
            label: 'Crafts',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle, color: Color(0xFFA24B2A)),
            label: 'Create',
          ),
          NavigationDestination(
            icon: Icon(Icons.gavel_outlined),
            selectedIcon: Icon(Icons.gavel, color: Color(0xFFA24B2A)),
            label: 'Auctions',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum, color: Color(0xFFA24B2A)),
            label: 'Community',
          ),
          NavigationDestination(
            icon: Icon(Icons.balance_outlined),
            selectedIcon: Icon(Icons.balance, color: Color(0xFFA24B2A)),
            label: 'Fair Price',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront, color: Color(0xFFA24B2A)),
            label: 'Market',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: Color(0xFFA24B2A)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
