import 'package:flutter/material.dart';

import 'products_screen.dart';
import 'business_screen.dart';
import 'artisan_auctions_screen.dart';
import 'artisan_community_screen.dart';
import 'artisan_hub_screen.dart';
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
      ArtisanAuctionsScreen(),
      ArtisanCommunityScreen(),
      ArtisanHubScreen(),
    ];
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
      // CHATBOT BUTTON (COMPACT CIRCULAR TO PREVENT OVERLAP)
      // ========================================================
      floatingActionButton: _currentIndex == 0
          ? const SupportChatbot(role: 'artisan', compact: true)
          : null,

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // ========================================================
      // 5-DESTINATION CLEAN BOTTOM NAVIGATION BAR
      // ========================================================
      bottomNavigationBar: NavigationBar(
        height: 72,
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
            icon: Icon(Icons.gavel_outlined),
            selectedIcon: Icon(Icons.gavel, color: Color(0xFFA24B2A)),
            label: 'Auctions',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum, color: Color(0xFFA24B2A)),
            label: 'Guild',
          ),
          NavigationDestination(
            icon: Icon(Icons.widgets_outlined),
            selectedIcon: Icon(Icons.widgets, color: Color(0xFFA24B2A)),
            label: 'Hub',
          ),
        ],
      ),
    );
  }
}
