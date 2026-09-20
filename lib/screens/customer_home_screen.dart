import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'customer_cart_screen.dart';
import 'customer_orders_screen.dart';
import '../widgets/support_chatbot.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen>
    with SingleTickerProviderStateMixin {
  // Clean Premium Heritage Palette
  static const Color _primaryTerracotta = Color(0xFF7A2012); // Deep Terracotta
  static const Color _accentCrimson = Color(0xFF9E341B);     // Warm Crimson
  static const Color _darkCapsule = Color(0xFF5A1409);       // Header Capsule
  static const Color _heirloomGold = Color(0xFFD4A056);      // Warm Antique Gold
  static const Color _lightGoldWash = Color(0xFFFDF6EC);     // Soft Gold Surface
  static const Color _pageBackground = Color(0xFFF7F3EE);    // Warm Linen
  static const Color _textPrimary = Color(0xFF1D2A24);       // Charcoal Ink
  static const Color _textSecondary = Color(0xFF68726C);     // Muted Sage
  static const Color _badgeGreen = Color(0xFF1F4D3B);        // Certified Green
  static const Color _cardBorder = Color(0xFFE8DFD3);        // Clean Border

  final TextEditingController _searchController = TextEditingController();
  final PageController _carouselPageController = PageController();
  late final ScrollController _scrollController;

  Timer? _searchHintTimer;
  Timer? _carouselTimer;

  final ValueNotifier<int> _searchHintNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _carouselIndexNotifier = ValueNotifier<int>(0);

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _productsStream;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _cartStream;

  bool _isAuctionAlertVisible = true;
  String _selectedDeliveryAddress = 'Banisri Bihar, Patna 800001';
  int _userCoins = 120;

  String _searchQuery = '';
  String _selectedCategory = 'For You';
  int _bottomNavIndex = 0;

  final List<String> _searchHints = [
    'Handmade Silk Sarees',
    'Pure Woollen Shawls',
    'Blue Ceramic Pottery',
    'Handcrafted Brass Idols',
    'Carved Wooden Boxes',
    'Traditional Folk Paintings',
    'Handmade Home Decor',
  ];

  final List<Map<String, dynamic>> _categoryTabs = [
    {'name': 'For You', 'label': 'All Crafts', 'icon': Icons.auto_awesome},
    {'name': 'Textiles', 'label': 'Silk & Textiles', 'icon': Icons.dry_cleaning_outlined},
    {'name': 'Pottery', 'label': 'Ceramics & Pots', 'icon': Icons.bubble_chart_outlined},
    {'name': 'Jewellery', 'label': 'Jewellery', 'icon': Icons.diamond_outlined},
    {'name': 'Woodcraft', 'label': 'Woodcraft', 'icon': Icons.carpenter_outlined},
    {'name': 'Paintings', 'label': 'Paintings', 'icon': Icons.palette_outlined},
    {'name': 'Decor', 'label': 'Home Decor', 'icon': Icons.chair_outlined},
  ];

  final List<Map<String, dynamic>> _heroBanners = [
    {
      'tag': 'HERITAGE ARTISAN SHIRT',
      'title': 'Handblock Heritage Resort Shirt',
      'subtitle': 'Vibrant traditional lotus motifs printed on pure breathable cotton.',
      'artisan': 'Jaipur Handblock Artisans, Rajasthan',
      'price': '₹1,499',
      'badge': '100% Breathable Cotton',
      'imageUrl': 'assets/images/heritage_shirt.png',
    },
    {
      'tag': '100% CERTIFIED HANDLOOM',
      'title': 'Pure Silk Handloom Saree',
      'subtitle': 'Woven on traditional wooden pit looms with authentic gold zari patterns.',
      'artisan': 'Direct from Master Weavers in Varanasi',
      'price': '₹4,999',
      'badge': 'Zero Middlemen Markup',
      'imageUrl':
          'https://utkalikaodisha.com/wp-content/uploads/2023/01/TRI3D__Smb_3__silk_set172_srijla_front__2023-1-4-13-27-43__1200X1200_11zon.jpg',
    },
    {
      'tag': 'PREMIUM ARTISAN WEAVE',
      'title': 'Hand-spun Woollen Shawl',
      'subtitle': 'Crafted with fine mountain wool by master artisans in the Kashmir valley.',
      'artisan': 'Crafted by Farooq & Family, Srinagar',
      'price': '₹8,499',
      'badge': 'Artisan Certified',
      'imageUrl':
          'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?auto=format&fit=crop&w=900&q=80',
    },
    {
      'tag': 'ANCIENT BRONZE CASTING',
      'title': 'Lost-Wax Bell Metal Sculpture',
      'subtitle': 'Hand-poured bronze bell metal crafted using traditional tribal methods.',
      'artisan': 'Bastar Tribal Crafts Cluster',
      'price': '₹2,199',
      'badge': 'Authentic Handcraft',
      'imageUrl':
          'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=900&q=80',
    },
  ];

  final List<Map<String, dynamic>> _trendingItems = [
    {
      'name': 'Heritage Printed Resort Shirt',
      'category': 'Textiles',
      'origin': 'Jaipur, Rajasthan',
      'price': 1499,
      'originalPrice': 2499,
      'artisanShare': 'Artisan receives ₹1,100',
      'imageUrl': 'assets/images/heritage_shirt.png',
    },
    {
      'name': 'Carved Walnut Wood Box',
      'category': 'Woodcraft',
      'origin': 'Srinagar, Kashmir',
      'price': 899,
      'originalPrice': 1799,
      'artisanShare': 'Artisan receives ₹620',
      'imageUrl':
          'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=600&q=80',
    },
    {
      'name': 'Handmade Peacock Brass Lamp',
      'category': 'Decor',
      'origin': 'Moradabad, UP',
      'price': 649,
      'originalPrice': 1299,
      'artisanShare': 'Artisan receives ₹480',
      'imageUrl':
          'https://images.unsplash.com/photo-1610701596007-11502861dcfa?auto=format&fit=crop&w=600&q=80',
    },
    {
      'name': 'Jaipur Blue Ceramic Vase',
      'category': 'Pottery',
      'origin': 'Jaipur, Rajasthan',
      'price': 499,
      'originalPrice': 1199,
      'artisanShare': 'Artisan receives ₹350',
      'imageUrl':
          'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=600&q=80',
    },
    {
      'name': 'Handmade Folk Art Painting',
      'category': 'Paintings',
      'origin': 'Madhubani, Bihar',
      'price': 999,
      'originalPrice': 1999,
      'artisanShare': 'Artisan receives ₹750',
      'imageUrl':
          'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=600&q=80',
    },
    {
      'name': 'Handloom Tussar Silk Shawl',
      'category': 'Textiles',
      'origin': 'Bhagalpur, Bihar',
      'price': 1499,
      'originalPrice': 2999,
      'artisanShare': 'Artisan receives ₹1,150',
      'imageUrl':
          'https://utkalikaodisha.com/wp-content/uploads/2023/01/TRI3D__Smb_3__silk_set172_srijla_front__2023-1-4-13-27-43__1200X1200_11zon.jpg',
    },
  ];

  User? get _user => FirebaseAuth.instance.currentUser;

  CollectionReference<Map<String, dynamic>> get _cartCollection {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_user?.uid)
        .collection('cart');
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _productsStream = FirebaseFirestore.instance
        .collectionGroup('products')
        .snapshots();
    _cartStream = _cartCollection.snapshots();

    _searchHintTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _searchHintNotifier.value =
            (_searchHintNotifier.value + 1) % _searchHints.length;
      }
    });

    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _carouselPageController.hasClients) {
        // Prevent auto-scrolling hero banner when user is scrolled down into the products
        if (!_scrollController.hasClients || _scrollController.offset < 280) {
          final nextIndex =
              (_carouselIndexNotifier.value + 1) % _heroBanners.length;
          _carouselPageController.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _searchHintTimer?.cancel();
    _carouselTimer?.cancel();
    _searchHintNotifier.dispose();
    _carouselIndexNotifier.dispose();
    _searchController.dispose();
    _carouselPageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to continue.')),
      );
    }

    return Scaffold(
      backgroundColor: _pageBackground,
      floatingActionButton: const SupportChatbot(role: 'customer', compact: true),
      body: CustomScrollView(
        key: const PageStorageKey<String>('customer_home_scroll'),
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // 1. Clean Premium Header (Welcome, Coins, Address, Search, Categories)
          _buildHeader(context),

          // 2. Compact Live Auction Alert (Single-line, non-intrusive)
          if (_isAuctionAlertVisible)
            SliverToBoxAdapter(
              child: _buildLiveAuctionAlert(),
            ),

          // 3. Featured Hero Showcase Banner (Single prominent carousel)
          SliverToBoxAdapter(
            child: _buildHeroCarousel(),
          ),

          // 4. Clean 4-Button Quick Navigation
          SliverToBoxAdapter(
            child: _buildQuickServices(),
          ),

          // 5. Trending Handcrafted Items Rail
          SliverToBoxAdapter(
            child: _buildTrendingRail(),
          ),

          // 6. Section Title for All Products
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _primaryTerracotta,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCategory == 'For You'
                              ? 'All Handcrafted Products'
                              : '$_selectedCategory Collection',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _textPrimary,
                          ),
                        ),
                        const Text(
                          'Direct from certified artisans across India',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _productsStream,
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _lightGoldWash,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _heirloomGold.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          '$count items',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _primaryTerracotta,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 7. 2-Column Product Catalog Grid
          _buildProductGrid(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ============================================================
  // 1. CLEAN PREMIUM HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    final email = _user?.email ?? 'Customer';
    final rawName = email.split('@').first;
    final userName = rawName.isEmpty ? 'Friend' : rawName[0].toUpperCase() + rawName.substring(1);

    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primaryTerracotta, _accentCrimson],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x224A1208),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting & Action Buttons Row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Hello, $userName',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, color: _heirloomGold, size: 16),
                            ],
                          ),
                          const Text(
                            'Authentic Indian Handcrafts',
                            style: TextStyle(
                              color: Color(0xFFE8C8A3),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Coins Button
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _showCoinsModal,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _darkCapsule,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _heirloomGold, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt, color: _heirloomGold, size: 16),
                            const SizedBox(width: 3),
                            Text(
                              '$_userCoins Coins',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Orders Button
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CustomerOrdersScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _darkCapsule,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(
                          Icons.receipt_long_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Cart with Live Count Badge
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _cartStream,
                      builder: (context, snapshot) {
                        final count = snapshot.data?.docs.length ?? 0;
                        return InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CustomerCartScreen()),
                            );
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _darkCapsule,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: _heirloomGold, width: 1),
                                ),
                                child: const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              if (count > 0)
                                Positioned(
                                  right: -3,
                                  top: -3,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: _heirloomGold,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                    child: Center(
                                      child: Text(
                                        '$count',
                                        style: const TextStyle(
                                          color: Color(0xFF4A1208),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Delivery Address Row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _showDeliveryAddressModal,
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: _heirloomGold, size: 14),
                      const SizedBox(width: 4),
                      const Text(
                        'Deliver to: ',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      Expanded(
                        child: Text(
                          _selectedDeliveryAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 16),
                    ],
                  ),
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(23),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      const Icon(Icons.search, color: _primaryTerracotta, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            if (_searchQuery.isEmpty)
                              ValueListenableBuilder<int>(
                                valueListenable: _searchHintNotifier,
                                builder: (context, hintIdx, _) {
                                  return AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Text(
                                      'Search ${_searchHints[hintIdx]}',
                                      key: ValueKey<int>(hintIdx),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF9E9E9E),
                                        fontSize: 13,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val.trim().toLowerCase();
                                });
                              },
                              style: const TextStyle(
                                color: _textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: _textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.mic_none_rounded, color: _textSecondary, size: 20),
                        tooltip: 'Voice Search',
                        onPressed: _triggerVoiceSearch,
                      ),
                      InkWell(
                        onTap: () => Navigator.pushNamed(context, '/heritage-features'),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _lightGoldWash,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _heirloomGold),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.qr_code_scanner, color: _primaryTerracotta, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Verify',
                                style: TextStyle(
                                  color: _primaryTerracotta,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Category Tabs (Horizontal Scrollable Chips)
              SizedBox(
                height: 44,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categoryTabs.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categoryTabs[index];
                    final name = cat['name'] as String;
                    final label = cat['label'] as String;
                    final icon = cat['icon'] as IconData;
                    final isSelected = _selectedCategory == name;

                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => setState(() => _selectedCategory = name),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.white30,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              icon,
                              size: 15,
                              color: isSelected ? _primaryTerracotta : Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              label,
                              style: TextStyle(
                                color: isSelected ? _primaryTerracotta : Colors.white,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 2. COMPACT LIVE AUCTION ALERT
  // ============================================================

  Widget _buildLiveAuctionAlert() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF38120B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _heirloomGold.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.redAccent,
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(1, 1),
                end: const Offset(1.4, 1.4),
                duration: 800.ms,
              ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Live Auction Now: Kashmiri Shawls • 7 Bidders',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          InkWell(
            onTap: () => Navigator.pushNamed(context, '/customer-auctions'),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _heirloomGold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Join Bidding',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4A1208),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.close, color: Colors.white60, size: 16),
            onPressed: () => setState(() => _isAuctionAlertVisible = false),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 3. HERO SHOWCASE CAROUSEL
  // ============================================================

  Widget _buildHeroCarousel() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          SizedBox(
            height: 175,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) => true,
              child: PageView.builder(
                controller: _carouselPageController,
                itemCount: _heroBanners.length,
                onPageChanged: (i) => _carouselIndexNotifier.value = i,
                itemBuilder: (context, index) {
                  final banner = _heroBanners[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: (banner['imageUrl'] as String).startsWith('assets/')
                                ? Image.asset(
                                    banner['imageUrl'] as String,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Image.network(
                                      'https://heritrace.web.app/assets/images/heritage_shirt.png',
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Image.network(
                                    banner['imageUrl'] as String,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(color: Colors.grey.shade300),
                                  ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.85),
                                    Colors.black.withValues(alpha: 0.45),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _heirloomGold,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    banner['tag'] as String,
                                    style: const TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF4A1208),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  banner['title'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  banner['artisan'] as String,
                                  style: const TextStyle(
                                    color: Color(0xFFE8C8A3),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${banner['badge']} • ${banner['price']}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
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
          const SizedBox(height: 8),
          ValueListenableBuilder<int>(
            valueListenable: _carouselIndexNotifier,
            builder: (context, activeIndex, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_heroBanners.length, (i) {
                  final isActive = i == activeIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 20 : 6,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive ? _primaryTerracotta : _cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 4. QUICK SHORTCUTS (4 Clean Buttons)
  // ============================================================

  Widget _buildQuickServices() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: Row(
        children: [
          Expanded(
            child: _quickActionBtn(
              icon: Icons.gavel_rounded,
              label: 'Auctions',
              onTap: () => Navigator.pushNamed(context, '/customer-auctions'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _quickActionBtn(
              icon: Icons.newspaper_rounded,
              label: 'Craft News',
              onTap: () => Navigator.pushNamed(context, '/heritage-news'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _quickActionBtn(
              icon: Icons.verified_outlined,
              label: 'Certified GI',
              onTap: () => setState(() => _selectedCategory = 'Textiles'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _quickActionBtn(
              icon: Icons.local_offer_outlined,
              label: 'Offers',
              onTap: _showOffersModal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: _primaryTerracotta),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 5. TRENDING HANDCRAFTS RAIL
  // ============================================================

  Widget _buildTrendingRail() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Trending Handcrafted Items',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: _textPrimary,
                        ),
                      ),
                      Text(
                        'Handmade by verified generational artisans',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => _selectedCategory = 'For You'),
                  child: const Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _primaryTerracotta,
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 10, color: _primaryTerracotta),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 195,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) => true,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                scrollDirection: Axis.horizontal,
                itemCount: _trendingItems.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                final item = _trendingItems[index];
                return Container(
                  width: 135,
                  decoration: BoxDecoration(
                    color: _pageBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: (item['imageUrl'] as String).startsWith('assets/')
                                    ? Image.asset(
                                        item['imageUrl'] as String,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Image.network(
                                          'https://heritrace.web.app/assets/images/heritage_shirt.png',
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Image.network(
                                        item['imageUrl'] as String,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Container(color: Colors.grey.shade200),
                                      ),
                              ),
                              Positioned(
                                top: 5,
                                left: 5,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item['origin'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['artisanShare'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: _badgeGreen,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Text(
                                  '₹${item['price']}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: _textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '₹${item['originalPrice']}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    decoration: TextDecoration.lineThrough,
                                    color: _textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        ],
      ),
    );
  }

  // ============================================================
  // 7. 2-COLUMN PRODUCT GRID
  // ============================================================

  Widget _buildProductGrid() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _productsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _buildErrorState(snapshot.error.toString()),
          );
        }

        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: CircularProgressIndicator(color: _primaryTerracotta),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        final filteredDocs = docs.where((doc) {
          final data = doc.data();
          final name = (data['name'] ?? '').toString().toLowerCase();
          final category = (data['category'] ?? '').toString().toLowerCase();
          final description = (data['description'] ?? '').toString().toLowerCase();

          final searchMatches =
              _searchQuery.isEmpty ||
              name.contains(_searchQuery) ||
              category.contains(_searchQuery) ||
              description.contains(_searchQuery);

          final categoryMatches =
              _selectedCategory == 'For You' ||
              _categoryMatches(category, _selectedCategory);

          return searchMatches && categoryMatches;
        }).toList();

        if (filteredDocs.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyState(),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.crossAxisExtent;
              int columns = 2;
              if (width >= 1200) {
                columns = 5;
              } else if (width >= 950) {
                columns = 4;
              } else if (width >= 650) {
                columns = 3;
              }

              return SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final doc = filteredDocs[index];
                  return _HeritageProductCard(
                    document: doc,
                    onAddToCart: () => _addToCart(doc),
                    onWishlist: () => _toggleWishlist(doc),
                    onOpen: () => _showProductDetails(doc),
                  );
                }, childCount: filteredDocs.length),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.64,
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ============================================================
  // 5-TAB CLEAN BOTTOM NAVIGATION BAR
  // ============================================================

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(
                index: 0,
                label: 'Home',
                icon: Icons.home_outlined,
                activeIcon: Icons.home_filled,
                onTap: () => setState(() => _bottomNavIndex = 0),
              ),
              _buildBottomNavItem(
                index: 1,
                label: 'Auctions',
                icon: Icons.gavel_outlined,
                activeIcon: Icons.gavel_rounded,
                onTap: () => Navigator.pushNamed(context, '/customer-auctions'),
              ),
              _buildBottomNavItem(
                index: 2,
                label: 'Categories',
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view_rounded,
                onTap: _showCategoriesModal,
              ),
              _buildBottomNavItem(
                index: 3,
                label: 'News',
                icon: Icons.newspaper_outlined,
                activeIcon: Icons.newspaper_rounded,
                onTap: () => Navigator.pushNamed(context, '/heritage-news'),
              ),
              _buildBottomNavItem(
                index: 4,
                label: 'Account',
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                onTap: () => Navigator.pushNamed(context, '/customer-profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required VoidCallback onTap,
  }) {
    final isSelected = _bottomNavIndex == index;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 62,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? _primaryTerracotta : _textSecondary,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                color: isSelected ? _primaryTerracotta : _textSecondary,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _primaryTerracotta,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MODALS (Delivery Address, Coins, Offers, Categories)
  // ============================================================

  void _showDeliveryAddressModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: _primaryTerracotta),
                    const SizedBox(width: 8),
                    const Text(
                      'Delivery Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: const Icon(Icons.home, color: _primaryTerracotta),
                  title: const Text(
                    'Banisri Bihar, Patna',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Pin: 800001 • Fast Insured Delivery'),
                  trailing: const Icon(Icons.check_circle, color: _badgeGreen),
                  onTap: () {
                    setState(() {
                      _selectedDeliveryAddress = 'Banisri Bihar, Patna 800001';
                    });
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.work_outline),
                  title: const Text('New Delhi Office'),
                  subtitle: const Text('Pin: 110001'),
                  onTap: () {
                    setState(() {
                      _selectedDeliveryAddress = 'Connaught Place, New Delhi 110001';
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryTerracotta,
                      side: const BorderSide(color: _primaryTerracotta),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showMessage('Address manager opened.');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Address'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCoinsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: _primaryTerracotta,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bolt, color: _heirloomGold, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_userCoins Reward Coins',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _textPrimary,
                          ),
                        ),
                        const Text(
                          'Earn 10 coins for every ₹100 spent on handcrafts',
                          style: TextStyle(color: _textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _lightGoldWash,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _heirloomGold.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.stars, color: _primaryTerracotta),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'You can redeem ₹120 directly on your next order!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryTerracotta,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        if (_userCoins >= 50) {
                          _userCoins -= 50;
                          _showMessage('Redeemed 50 Coins for ₹50 instant checkout discount! 🪙');
                        } else {
                          _showMessage('Need at least 50 coins to redeem.', isError: true);
                        }
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Redeem 50 Coins for ₹50 Off (Balance: $_userCoins)',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOffersModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Exclusive Offers & Coupons',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                _offerTile(
                  code: 'CRAFT500',
                  desc: 'Flat ₹500 discount on orders above ₹1,999 from certified artisans',
                ),
                const SizedBox(height: 8),
                _offerTile(
                  code: 'FIRSTORDER',
                  desc: 'Free Insured Delivery + 15% discount on your first order',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _offerTile({required String code, required String desc}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _pageBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _primaryTerracotta,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              code,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(fontSize: 11, color: _textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoriesModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'All Craft Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _categoryTabs.map((cat) {
                    final name = cat['name'] as String;
                    final label = cat['label'] as String;
                    return ActionChip(
                      avatar: Icon(cat['icon'] as IconData, size: 16),
                      label: Text(label),
                      onPressed: () {
                        setState(() => _selectedCategory = name);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _triggerVoiceSearch() {
    _showMessage('Listening... State product name or craft region 🎙️');
  }

  bool _categoryMatches(String productCategory, String selectedCategory) {
    final product = productCategory.toLowerCase();
    switch (selectedCategory) {
      case 'Textiles':
        return product.contains('textile') ||
            product.contains('cloth') ||
            product.contains('saree') ||
            product.contains('weave');
      case 'Jewellery':
        return product.contains('jewellery') || product.contains('jewelry');
      case 'Pottery':
        return product.contains('pottery') || product.contains('ceramic');
      case 'Woodcraft':
        return product.contains('wood') || product.contains('craft');
      case 'Paintings':
        return product.contains('paint') || product.contains('art');
      case 'Decor':
        return product.contains('decor') ||
            product.contains('home') ||
            product.contains('brass');
      default:
        return true;
    }
  }

  Future<void> _addToCart(QueryDocumentSnapshot<Map<String, dynamic>> productDoc) async {
    try {
      final user = _user;
      if (user == null) return;

      final data = productDoc.data();
      final artisanId = _getArtisanId(productDoc);
      if (artisanId.isEmpty) {
        _showMessage('Unable to identify the artisan studio.', isError: true);
        return;
      }

      final cartId = '${artisanId}_${productDoc.id}';
      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(cartId);

      final existing = await cartRef.get();
      if (existing.exists) {
        final existingData = existing.data() ?? {};
        final currentQuantity = _toInt(existingData['quantity']);
        await cartRef.update({
          'quantity': currentQuantity + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await cartRef.set({
          'productId': productDoc.id,
          'artisanId': artisanId,
          'name': data['name'] ?? 'Product',
          'category': data['category'] ?? 'Handicraft',
          'description': data['description'] ?? '',
          'price': _toDouble(data['price']),
          'imageUrl': data['imageUrl'] ?? '',
          'quantity': 1,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      _showMessage('Added to Cart! 🛍️');
    } catch (e) {
      _showMessage('Could not add product to cart.', isError: true);
    }
  }

  Future<void> _toggleWishlist(QueryDocumentSnapshot<Map<String, dynamic>> productDoc) async {
    try {
      final user = _user;
      if (user == null) return;

      final data = productDoc.data();
      final artisanId = _getArtisanId(productDoc);
      if (artisanId.isEmpty) return;

      final wishlistId = '${artisanId}_${productDoc.id}';
      final wishlistRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wishlist')
          .doc(wishlistId);

      final existing = await wishlistRef.get();
      if (existing.exists) {
        await wishlistRef.delete();
        _showMessage('Removed from Wishlist.');
      } else {
        await wishlistRef.set({
          'productId': productDoc.id,
          'artisanId': artisanId,
          'name': data['name'] ?? 'Product',
          'category': data['category'] ?? 'Handicraft',
          'description': data['description'] ?? '',
          'price': _toDouble(data['price']),
          'imageUrl': data['imageUrl'] ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
        _showMessage('Added to Wishlist ❤️');
      }
    } catch (e) {
      _showMessage('Could not update wishlist.', isError: true);
    }
  }

  String _getArtisanId(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final path = doc.reference.path.split('/');
    if (path.length >= 4 && path[0] == 'users' && path[2] == 'products') {
      return path[1];
    }
    return '';
  }

  void _showProductDetails(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final name = (data['name'] ?? 'Handcrafted Product').toString();
    final category = (data['category'] ?? 'Handicraft').toString();
    final description = (data['description'] ?? 'Authentic artisan handcrafted item.').toString();
    final price = _toDouble(data['price']);
    final originalPrice = (price * 1.5).roundToDouble();
    final imageUrl = (data['imageUrl'] ?? '').toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          constraints: const BoxConstraints(maxHeight: 700),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _LargeProductImage(
                    imageUrl: imageUrl,
                    productName: name,
                    category: category,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _lightGoldWash,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _heirloomGold),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified, size: 13, color: _primaryTerracotta),
                            SizedBox(width: 4),
                            Text(
                              'Certified Authentic',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: _primaryTerracotta,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _pageBackground,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹${price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${originalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                          color: _textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Direct Artisan Price',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: _badgeGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _pageBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: _lightGoldWash,
                          child: Icon(Icons.handyman, color: _primaryTerracotta, size: 18),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Direct from Master Artisan Studio',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _textPrimary,
                                ),
                              ),
                              Text(
                                'Zero middleman markup • 100% fair artisan payment',
                                style: TextStyle(fontSize: 10, color: _textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Product Details',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description.isEmpty
                        ? 'This authentic handcrafted item is made using traditional Indian craft techniques.'
                        : description,
                    style: const TextStyle(color: _textSecondary, height: 1.5, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF7F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: _primaryTerracotta,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '7-Day Easy Return & Replacement Guarantee',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Doorstep reverse pickup • Replacement or full refund',
                                style: TextStyle(fontSize: 10, color: _textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: _cardBorder),
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _toggleWishlist(doc);
                          },
                          icon: const Icon(Icons.favorite_border, color: _textPrimary),
                          label: const Text('Wishlist', style: TextStyle(color: _textPrimary)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryTerracotta,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _addToCart(doc);
                          },
                          icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                          label: const Text(
                            'Add to Cart',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _cardBorder),
              ),
              child: const Icon(Icons.search_off_rounded, size: 36, color: _textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              'No products found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try changing your search term or exploring another category.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryTerracotta,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _selectedCategory = 'For You';
                });
              },
              child: const Text('Reset Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 50, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text(
              'Unable to load products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red.shade700 : _textPrimary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

// =================================================================
// BESPOKE MASTERPIECE PRODUCT CARD
// =================================================================

class _HeritageProductCard extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> document;
  final VoidCallback onAddToCart;
  final VoidCallback onWishlist;
  final VoidCallback onOpen;

  const _HeritageProductCard({
    required this.document,
    required this.onAddToCart,
    required this.onWishlist,
    required this.onOpen,
  });

  @override
  State<_HeritageProductCard> createState() => _HeritageProductCardState();
}

class _HeritageProductCardState extends State<_HeritageProductCard> {
  bool _isWishlisted = false;

  @override
  void initState() {
    super.initState();
    _checkWishlist();
  }

  Future<void> _checkWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final path = widget.document.reference.path.split('/');
    if (path.length >= 4 && path[0] == 'users' && path[2] == 'products') {
      final artisanId = path[1];
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wishlist')
          .doc('${artisanId}_${widget.document.id}')
          .get();
      if (mounted && doc.exists) {
        setState(() => _isWishlisted = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.document.data();
    final name = (data['name'] ?? 'Handcrafted Product').toString();
    final category = (data['category'] ?? 'Handicraft').toString();
    final price = _toDouble(data['price']);
    final originalPrice = (price * 1.5).roundToDouble();
    final imageUrl = (data['imageUrl'] ?? '').toString();

    return InkWell(
      onTap: widget.onOpen,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8DFD3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Certified badge & Wishlist button
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: _ProductImage(
                      imageUrl: imageUrl,
                      productName: name,
                      category: category,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A056),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 9, color: Color(0xFF4A1208)),
                          SizedBox(width: 2),
                          Text(
                            'Certified',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF4A1208),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.92),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          setState(() => _isWishlisted = !_isWishlisted);
                          widget.onWishlist();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Icon(
                            _isWishlisted ? Icons.favorite : Icons.favorite_border,
                            size: 15,
                            color: _isWishlisted ? Colors.redAccent : const Color(0xFF6B746E),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Details
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D2A24),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Direct Artisan Earnings',
                      style: TextStyle(
                        color: Color(0xFF1F4D3B),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₹${price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1D2A24),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '₹${originalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                            color: Color(0xFF68726C),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: widget.onAddToCart,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7A2012),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_bag_outlined, size: 11, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Add to Cart',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

// =================================================================
// PRODUCT IMAGE (With cultural fallbacks)
// =================================================================

class _ProductImage extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String category;

  const _ProductImage({
    required this.imageUrl,
    required this.productName,
    required this.category,
  });

  String get _fallbackUrl {
    final name = productName.toLowerCase();
    final type = category.toLowerCase();
    if (name.contains('shirt') ||
        name.contains('kurta') ||
        name.contains('dress')) {
      return 'assets/images/heritage_shirt.png';
    }
    if (name.contains('saree') ||
        name.contains('ikat') ||
        type.contains('textile')) {
      return 'https://utkalikaodisha.com/wp-content/uploads/2023/01/TRI3D__Smb_3__silk_set172_srijla_front__2023-1-4-13-27-43__1200X1200_11zon.jpg';
    }
    if (name.contains('basket') ||
        type.contains('bamboo') ||
        name.contains('wood')) {
      return 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=900&q=82';
    }
    if (name.contains('pot') ||
        name.contains('ceramic') ||
        type.contains('pottery')) {
      return 'https://images.unsplash.com/photo-1610701596007-11502861dcfa?auto=format&fit=crop&w=900&q=82';
    }
    return 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=900&q=82';
  }

  @override
  Widget build(BuildContext context) {
    final effectiveUrl = imageUrl.isNotEmpty ? imageUrl : _fallbackUrl;
    if (effectiveUrl.startsWith('assets/')) {
      return Image.asset(
        effectiveUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => Image.network(
          'https://heritrace.web.app/assets/images/heritage_shirt.png',
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.network(
      effectiveUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) {
        final fallback = _fallbackUrl;
        if (fallback.startsWith('assets/')) {
          return Image.asset(fallback, fit: BoxFit.cover);
        }
        return Image.network(fallback, fit: BoxFit.cover);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: const Color(0xFFF1F2F4),
          child: const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF7A2012),
              ),
            ),
          ),
        );
      },
    );
  }
}

// =================================================================
// LARGE PRODUCT IMAGE
// =================================================================

class _LargeProductImage extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String category;

  const _LargeProductImage({
    required this.imageUrl,
    required this.productName,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: double.infinity,
        height: 250,
        child: _ProductImage(
          imageUrl: imageUrl,
          productName: productName,
          category: category,
        ),
      ),
    );
  }
}
