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
  // Brand & Flipkart-style Design Palette
  static const Color _purpleHeaderStart = Color(0xFF7B00C7);
  static const Color _purpleHeaderEnd = Color(0xFF9E00EE);
  static const Color _purpleDarkPill = Color(0xFF55008E);
  static const Color _flipkartYellow = Color(0xFFFFE500);
  static const Color _bodyBg = Color(0xFFF1F2F4);
  static const Color _primaryText = Color(0xFF1E1E24);
  static const Color _secondaryText = Color(0xFF71747E);
  static const Color _discountGreen = Color(0xFF26A541);

  final TextEditingController _searchController = TextEditingController();
  final PageController _carouselPageController = PageController();

  late final AnimationController _pulseController;
  Timer? _searchHintTimer;
  Timer? _carouselTimer;

  int _searchHintIndex = 0;
  int _currentCarouselIndex = 0;
  bool _isPipVisible = true;
  String _selectedDeliveryAddress = 'HOME Banisri Bihar, Patna 800001';
  int _userCoins = 120;

  String _searchQuery = '';
  String _selectedCategory = 'For You';
  String _selectedTopService = 'HeriTrace';
  int _bottomNavIndex = 0;

  final List<String> _searchHints = [
    'Handcrafted Pashmina Shawls',
    'Banarasi Silk Handloom Sarees',
    'Jaipur Blue Pottery Vases',
    'Bastar Dhokra Brass Idols',
    'Channapatna Wooden Toys',
    'Madhubani Folk Paintings',
    'Tanjore 22K Gold Wall Art',
  ];

  final List<Map<String, dynamic>> _topServices = [
    {
      'title': 'HeriTrace',
      'sub': 'Marketplace',
      'icon': Icons.auto_awesome,
      'isBrand': true,
    },
    {
      'title': 'Heritage 365',
      'sub': 'Under ₹999',
      'icon': Icons.local_offer_outlined,
      'isBrand': false,
    },
    {
      'title': 'Auctions',
      'sub': 'Live Bidding',
      'icon': Icons.gavel_outlined,
      'isBrand': false,
    },
    {
      'title': 'Direct GI',
      'sub': 'Artisan Craft',
      'icon': Icons.verified_outlined,
      'isBrand': false,
    },
    {
      'title': 'Culture Gazette',
      'sub': 'Daily News',
      'icon': Icons.newspaper_rounded,
      'isBrand': false,
    },
  ];

  final List<Map<String, dynamic>> _categoryTabs = [
    {'name': 'For You', 'icon': Icons.shopping_bag_outlined},
    {'name': 'Textiles', 'icon': Icons.dry_cleaning_outlined},
    {'name': 'Pottery', 'icon': Icons.bubble_chart_outlined},
    {'name': 'Jewellery', 'icon': Icons.diamond_outlined},
    {'name': 'Woodcraft', 'icon': Icons.carpenter_outlined},
    {'name': 'Paintings', 'icon': Icons.palette_outlined},
    {'name': 'Decor', 'icon': Icons.chair_outlined},
  ];

  final List<Map<String, dynamic>> _promoBanners = [
    {
      'tag': 'HERITRACE EXCLUSIVE',
      'title': 'Banarasi Silk Saree',
      'subtitle': 'Launching 24th Sep',
      'badge': '100% GI Handloom',
      'imageUrl':
          'https://utkalikaodisha.com/wp-content/uploads/2023/01/TRI3D__Smb_3__silk_set172_srijla_front__2023-1-4-13-27-43__1200X1200_11zon.jpg',
      'ad': true,
    },
    {
      'tag': 'ROYAL WEAVES',
      'title': 'Kashmir Pashmina Shawls',
      'subtitle': 'Winter Festive Edition',
      'badge': 'Hand-spun Artisan GI',
      'imageUrl':
          'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?auto=format&fit=crop&w=900&q=80',
      'ad': false,
    },
    {
      'tag': 'TRIBAL HERITAGE',
      'title': 'Dhokra Lost-Wax Idols',
      'subtitle': 'Direct from Bastar Artisans',
      'badge': '4000 yr Ancient Craft',
      'imageUrl':
          'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=900&q=80',
      'ad': false,
    },
  ];

  final List<Map<String, dynamic>> _weekendDeals = [
    {
      'name': 'Kashmir Walnut Carving Box',
      'category': 'Woodcraft',
      'price': 899,
      'originalPrice': 1799,
      'discount': '50% off',
      'imageUrl':
          'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=600&q=80',
    },
    {
      'name': 'Peacock Brass Pooja Diya',
      'category': 'Decor',
      'price': 649,
      'originalPrice': 1299,
      'discount': '50% off',
      'imageUrl':
          'https://images.unsplash.com/photo-1610701596007-11502861dcfa?auto=format&fit=crop&w=600&q=80',
    },
    {
      'name': 'Jaipur Blue Pottery Vase',
      'category': 'Pottery',
      'price': 499,
      'originalPrice': 1199,
      'discount': '58% off',
      'imageUrl':
          'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=600&q=80',
    },
    {
      'name': 'Madhubani Fish Art Painting',
      'category': 'Paintings',
      'price': 999,
      'originalPrice': 1999,
      'discount': '50% off',
      'imageUrl':
          'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=600&q=80',
    },
    {
      'name': 'Handloom Tussar Silk Dupatta',
      'category': 'Textiles',
      'price': 1499,
      'originalPrice': 2999,
      'discount': '50% off',
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

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Search placeholder rotator
    _searchHintTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _searchHintIndex = (_searchHintIndex + 1) % _searchHints.length;
        });
      }
    });

    // Auto-scroll promo banner carousel
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && _carouselPageController.hasClients) {
        final nextIndex = (_currentCarouselIndex + 1) % _promoBanners.length;
        _carouselPageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchHintTimer?.cancel();
    _carouselTimer?.cancel();
    _searchController.dispose();
    _carouselPageController.dispose();
    _pulseController.dispose();
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
      backgroundColor: _bodyBg,
      floatingActionButton: const SupportChatbot(role: 'customer', compact: true),
      body: CustomScrollView(
        slivers: [
          // Purple Header with Brand switcher, Address/Coins, Search, Categories
          _buildSliverHeader(context),

          // Live Auction Alert Banner (Inline, completely non-overlapping)
          if (_isPipVisible)
            SliverToBoxAdapter(
              child: _buildLiveAuctionAlertBanner()
                  .animate()
                  .fadeIn(duration: 350.ms),
            ),

          // Campaign Mega Banner ("The Big Heritage Days")
          SliverToBoxAdapter(
            child: _buildMegaCampaignBanner()
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.05, end: 0),
          ),

          // Promotional Carousel Banner with Flipkart-style dots
          SliverToBoxAdapter(
            child: _buildCarouselSection()
                .animate(delay: 80.ms)
                .fadeIn(duration: 450.ms),
          ),

          // Personalized Deal Rail: "NIRANJAN, weekend is here 🎉"
          SliverToBoxAdapter(
            child: _buildPersonalizedDealRail()
                .animate(delay: 140.ms)
                .fadeIn(duration: 450.ms)
                .slideY(begin: 0.05, end: 0),
          ),

          // Sliding Sponsored Product Advertisements (Flipkart-style)
          SliverToBoxAdapter(
            child: _buildSlidingProductAdvertisementsRail()
                .animate(delay: 180.ms)
                .fadeIn(duration: 450.ms)
                .slideY(begin: 0.05, end: 0),
          ),

          // Feed Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _purpleHeaderStart,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedCategory == 'For You'
                          ? 'Suggested For You'
                          : '$_selectedCategory Collection',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _primaryText,
                      ),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collectionGroup('products')
                        .snapshots(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count items',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _secondaryText,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Real 2-Column Product Grid
          _buildProductGrid(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ============================================================
  // FLIPKART-STYLE PURPLE HEADER
  // ============================================================

  Widget _buildSliverHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_purpleHeaderStart, _purpleHeaderEnd],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Brand / Service Switcher Pills
              _buildTopServiceSwitcher(),

              // 2. Delivery Address & SuperCoins Row
              _buildAddressAndCoinsRow(),

              // 3. Rounded Search Bar with Mic & QR Lens
              _buildCommercialSearchBar(),

              // 4. Horizontal Category Rail with active underline
              _buildCategoryRail(),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Brand Service Switcher Tiles
  Widget _buildTopServiceSwitcher() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: _topServices.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final service = _topServices[index];
          final isSelected = _selectedTopService == service['title'];
          final isBrand = service['isBrand'] == true;

          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              setState(() {
                _selectedTopService = service['title'] as String;
                if (_selectedTopService == 'Auctions') {
                  Navigator.pushNamed(context, '/customer-auctions');
                } else if (_selectedTopService == 'Heritage 365') {
                  _selectedCategory = 'Decor';
                } else if (_selectedTopService == 'Direct GI') {
                  _selectedCategory = 'Textiles';
                } else if (_selectedTopService == 'Culture Gazette') {
                  Navigator.pushNamed(context, '/heritage-news');
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected && isBrand
                    ? _flipkartYellow
                    : isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    service['icon'] as IconData,
                    size: 18,
                    color: isSelected && isBrand
                        ? const Color(0xFF1B1464)
                        : isSelected
                        ? _purpleHeaderStart
                        : const Color(0xFFE53935),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['title'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: isSelected && isBrand
                              ? const Color(0xFF1B1464)
                              : const Color(0xFF212121),
                        ),
                      ),
                      Text(
                        service['sub'] as String,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isSelected && isBrand
                              ? const Color(0xFF1B1464).withValues(alpha: 0.8)
                              : const Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 2. Delivery Address & SuperCoins Row
  Widget _buildAddressAndCoinsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 6),
      child: Row(
        children: [
          // Address Capsule
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _showDeliveryAddressModal,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _purpleDarkPill,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.home, color: Colors.white, size: 15),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _selectedDeliveryAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Coupon Badge
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _showOffersModal,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: _purpleDarkPill,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 0.8,
                ),
              ),
              child: const Icon(
                Icons.confirmation_num_outlined,
                color: Color(0xFFFFB300),
                size: 15,
              ),
            ),
          ),

          const SizedBox(width: 6),

          // SuperCoins Capsule
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _showCoinsModal,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _purpleDarkPill,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: _flipkartYellow, size: 15),
                  const SizedBox(width: 3),
                  Text(
                    '$_userCoins',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 6),

          // Customer Orders Receipt Button
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomerOrdersScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: _purpleDarkPill,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 0.8,
                ),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Commercial Rounded Search Bar with Mic & Lens
  Widget _buildCommercialSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search, color: Color(0xFF757575), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  if (_searchQuery.isEmpty)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.4),
                            end: Offset.zero,
                          ).animate(animation),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        'Search ${_searchHints[_searchHintIndex]}',
                        key: ValueKey<int>(_searchHintIndex),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim().toLowerCase();
                      });
                    },
                    style: const TextStyle(
                      color: _primaryText,
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
                icon: const Icon(
                  Icons.close,
                  size: 18,
                  color: Color(0xFF757575),
                ),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              ),
            // Voice Search Mic Icon
            IconButton(
              icon: const Icon(Icons.mic, color: Color(0xFF757575), size: 22),
              tooltip: 'Voice Search',
              onPressed: _triggerVoiceSearch,
            ),
            // QR Scanner / Heritage Lens Icon
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _purpleHeaderStart, width: 1.5),
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: _purpleHeaderStart,
                  size: 15,
                ),
              ),
              tooltip: 'Heritage Authenticity Lens',
              onPressed: () {
                Navigator.pushNamed(context, '/heritage-features');
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  // 4. Horizontal Category Rail (with active indicator underline)
  Widget _buildCategoryRail() {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: _categoryTabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final tab = _categoryTabs[index];
          final name = tab['name'] as String;
          final icon = tab['icon'] as IconData;
          final isSelected = _selectedCategory == name;

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                _selectedCategory = name;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.28)
                        : Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.3),
                      width: isSelected ? 1.5 : 0.8,
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                // Active Underline Indicator
                Container(
                  width: isSelected ? 22 : 0,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // CAMPAIGN MEGA BANNER ("THE BIG HERITAGE FESTIVAL")
  // ============================================================

  Widget _buildMegaCampaignBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF7209B7), Color(0xFF3F37C9), Color(0xFF4361EE)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3F37C9).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background celebratory circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                // Starburst Seal / Festival Badge
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _flipkartYellow,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'THE BIG',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1B1464),
                          ),
                        ),
                        Text(
                          'HERITAGE',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFD50000),
                          ),
                        ),
                        Text(
                          'DAYS',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1B1464),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Main headline
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'STARTS ON 9TH OCT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Early Access for HeriTrace Club & Artisans Direct',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Explore Offers',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF3F37C9),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              size: 11,
                              color: Color(0xFF3F37C9),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Right artisan craft seal
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.military_tech_outlined,
                      color: _flipkartYellow,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROMOTIONAL CAROUSEL BANNER (With dot indicators)
  // ============================================================

  Widget _buildCarouselSection() {
    return Column(
      children: [
        SizedBox(
          height: 175,
          child: PageView.builder(
            controller: _carouselPageController,
            itemCount: _promoBanners.length,
            onPageChanged: (index) {
              setState(() => _currentCarouselIndex = index);
            },
            itemBuilder: (context, index) {
              final banner = _promoBanners[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      // Banner Image
                      Positioned.fill(
                        child: Image.network(
                          banner['imageUrl'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: const Color(0xFF2B3A42),
                            child: const Center(
                              child: Icon(Icons.image, color: Colors.white38),
                            ),
                          ),
                        ),
                      ),

                      // Gradient overlay
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black.withValues(alpha: 0.82),
                                Colors.black.withValues(alpha: 0.45),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Banner Content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _flipkartYellow,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                banner['tag'] as String,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1B1464),
                                ),
                              ),
                            ),
                            const SizedBox(height: 7),
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
                              banner['subtitle'] as String,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                banner['badge'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // AD Badge
                      if (banner['ad'] == true)
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'AD',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Flipkart-style Carousel Indicators (pill for active, dots for inactive)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_promoBanners.length, (index) {
            final isActive = index == _currentCarouselIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: isActive ? 18 : 6,
              height: 5,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF212121)
                    : const Color(0xFFCFD8DC),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ============================================================
  // PERSONALIZED GREETING & DEAL RAIL
  // ============================================================

  Widget _buildPersonalizedDealRail() {
    final email = _user?.email ?? 'Customer';
    final name = email.split('@').first;
    final displayName = name.isEmpty ? 'FRIEND' : name.toUpperCase();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 14, 12, 4),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD0E1F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$displayName, weekend is here 🎉',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF153243),
                    ),
                  ),
                ),
                const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2874F0),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 188,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              itemCount: _weekendDeals.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final deal = _weekendDeals[index];

                return Container(
                  width: 130,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Deal Image
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                          child: Image.network(
                            deal['imageUrl'] as String,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: const Color(0xFFECEFF1),
                              child: const Icon(
                                Icons.image,
                                color: Color(0xFFB0BEC5),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Details
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              deal['name'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _primaryText,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Text(
                                  '₹${deal['price']}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: _primaryText,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '₹${deal['originalPrice']}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    decoration: TextDecoration.lineThrough,
                                    color: _secondaryText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              deal['discount'] as String,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: _discountGreen,
                              ),
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
        ],
      ),
    );
  }

  // ============================================================
  // SLIDING SPONSORED PRODUCT ADVERTISEMENTS (FLIPKART-STYLE)
  // ============================================================

  Widget _buildSlidingProductAdvertisementsRail() {
    final List<Map<String, dynamic>> sponsoredAds = [
      {
        'title': 'Kashmiri Handloom Pashmina',
        'badge': 'SPONSORED • GI ASSURED',
        'deal': 'FLAT 50% OFF',
        'price': '₹4,999',
        'mrp': '₹9,999',
        'sub': 'Pure Himalayan Changthangi Weave',
        'imageUrl':
            'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?auto=format&fit=crop&w=600&q=80',
        'bgGradient': const [Color(0xFF2C1307), Color(0xFF632810)],
      },
      {
        'title': 'Dhokra Lost-Wax Bell Metal',
        'badge': 'TRIBAL CRAFT • AD',
        'deal': 'FESTIVE SPECIAL',
        'price': '₹1,899',
        'mrp': '₹3,499',
        'sub': '4,000-Yr Bronze Casting',
        'imageUrl':
            'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=600&q=80',
        'bgGradient': const [Color(0xFF0F261E), Color(0xFF1B4D3C)],
      },
      {
        'title': 'Varanasi Pure Katan Silk',
        'badge': 'EXCLUSIVE • TOP SELLER',
        'deal': '45% OFF',
        'price': '₹3,299',
        'mrp': '₹6,599',
        'sub': 'Royal Gold Zari Brocade',
        'imageUrl':
            'https://utkalikaodisha.com/wp-content/uploads/2023/01/TRI3D__Smb_3__silk_set172_srijla_front__2023-1-4-13-27-43__1200X1200_11zon.jpg',
        'bgGradient': const [Color(0xFF33092E), Color(0xFF6B1D61)],
      },
      {
        'title': 'Jaipur Cobalt Blue Pottery',
        'badge': 'HAND-PAINTED • AD',
        'deal': 'UNDER ₹799',
        'price': '₹649',
        'mrp': '₹1,499',
        'sub': 'Quartz & Fullers Earth Glaze',
        'imageUrl':
            'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=600&q=80',
        'bgGradient': const [Color(0xFF071F36), Color(0xFF124B82)],
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE500),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'AD',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1B1464),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Sponsored Craft Masterpieces',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: _primaryText,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/heritage-news'),
                child: const Row(
                  children: [
                    Icon(
                      Icons.newspaper_rounded,
                      size: 14,
                      color: Color(0xFF2874F0),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Craft Gazette',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2874F0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: sponsoredAds.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final ad = sponsoredAds[index];
                return Container(
                  width: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: ad['bgGradient'] as List<Color>,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  ad['badge'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                ad['title'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ad['sub'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    ad['price'] as String,
                                    style: const TextStyle(
                                      color: Color(0xFFFFE500),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    ad['mrp'] as String,
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 10,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Image.network(
                          ad['imageUrl'] as String,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              Container(color: Colors.black26),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INLINE LIVE AUCTION ALERT BANNER (NON-OVERLAPPING)
  // ============================================================

  Widget _buildLiveAuctionAlertBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // LIVE indicator badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
            decoration: BoxDecoration(
              color: const Color(0xFFD50000),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 6, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, '/customer-auctions'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Rare Heritage Auctions: Live Bidding Active',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 1),
                  Text(
                    'Bid on GI handlooms & sculptures • Extra ₹500 discount',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFFFFE500),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => Navigator.pushNamed(context, '/customer-auctions'),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _flipkartYellow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Enter',
                style: TextStyle(
                  color: Color(0xFF1B1464),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => setState(() => _isPipVisible = false),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 16, color: Colors.white60),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCT GRID FEED (COMMERCIAL 2-COLUMN)
  // ============================================================

  Widget _buildProductGrid() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collectionGroup('products')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _buildErrorState(snapshot.error.toString()),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: CircularProgressIndicator(color: _purpleHeaderStart),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        final filteredDocs = docs.where((doc) {
          final data = doc.data();
          final name = (data['name'] ?? '').toString().toLowerCase();
          final category = (data['category'] ?? '').toString().toLowerCase();
          final description = (data['description'] ?? '')
              .toString()
              .toLowerCase();

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
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 110),
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
                  return _FlipkartProductCard(
                    document: doc,
                    onAddToCart: () => _addToCart(doc),
                    onWishlist: () => _toggleWishlist(doc),
                    onOpen: () => _showProductDetails(doc),
                  );
                }, childCount: filteredDocs.length),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.62,
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ============================================================
  // 5-TAB COMMERCIAL BOTTOM NAVIGATION BAR
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
                onTap: () {
                  Navigator.pushNamed(context, '/customer-auctions');
                },
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
                label: 'Account',
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                onTap: () {
                  Navigator.pushNamed(context, '/customer-profile');
                },
              ),
              // Cart with Live StreamBuilder badge!
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _cartCollection.snapshots(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.docs.length ?? 0;
                  return _buildBottomNavItem(
                    index: 4,
                    label: 'Cart',
                    icon: Icons.shopping_cart_outlined,
                    activeIcon: Icons.shopping_cart,
                    badgeCount: count,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CustomerCartScreen(),
                        ),
                      );
                    },
                  );
                },
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
    int badgeCount = 0,
  }) {
    final isSelected = _bottomNavIndex == index;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 62,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected
                      ? const Color(0xFF2874F0)
                      : const Color(0xFF757575),
                  size: 24,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -7,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD50000),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$badgeCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF2874F0)
                    : const Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INTERACTIVE MODALS (Address, Coins, Offers, Categories)
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
                    const Icon(Icons.location_on, color: _purpleHeaderStart),
                    const SizedBox(width: 8),
                    const Text(
                      'Select Delivery Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _primaryText,
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
                  leading: const Icon(Icons.home, color: _purpleHeaderStart),
                  title: const Text(
                    'Banisri Bihar, Patna',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    'Pin: 800001 • Fast 2-Day Delivery Available',
                  ),
                  trailing: const Icon(
                    Icons.check_circle,
                    color: _discountGreen,
                  ),
                  onTap: () {
                    setState(() {
                      _selectedDeliveryAddress =
                          'HOME Banisri Bihar, Patna 800001';
                    });
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.work_outline),
                  title: const Text('New Delhi Artisan Hub'),
                  subtitle: const Text('Pin: 110001'),
                  onTap: () {
                    setState(() {
                      _selectedDeliveryAddress =
                          'WORK Connaught Place, New Delhi 110001';
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showMessage('New address manager opened.');
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
                        color: _purpleHeaderStart,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bolt,
                        color: _flipkartYellow,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_userCoins Heritage Coins',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _primaryText,
                          ),
                        ),
                        const Text(
                          'Earn 10 coins for every ₹100 spent',
                          style: TextStyle(color: _secondaryText, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.stars, color: _discountGreen),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'You can redeem ₹120 directly on your next craft order!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E7D32),
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
                      backgroundColor: _purpleHeaderStart,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_userCoins >= 50) {
                          _userCoins -= 50;
                          _showMessage(
                            'Redeemed 50 Heritage Coins for ₹50 instant checkout discount! ⚡',
                          );
                        } else {
                          _showMessage(
                            'Need at least 50 coins to redeem.',
                            isError: true,
                          );
                        }
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Redeem 50 Coins for ₹50 Off (Balance: $_userCoins)',
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
                  'Exclusive Heritage Offers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _primaryText,
                  ),
                ),
                const SizedBox(height: 14),
                _offerTile(
                  code: 'HERITAGE500',
                  desc:
                      'Flat ₹500 off on orders above ₹1,999 from Verified GI Artisans',
                ),
                const SizedBox(height: 8),
                _offerTile(
                  code: 'FIRSTCRAFT',
                  desc:
                      'Free Express Delivery + 15% instant discount on first purchase',
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
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _purpleHeaderStart,
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
              style: const TextStyle(fontSize: 11, color: _primaryText),
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
                  'All Heritage Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _categoryTabs.map((tab) {
                    final name = tab['name'] as String;
                    return ActionChip(
                      avatar: Icon(tab['icon'] as IconData, size: 16),
                      label: Text(name),
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
    _showMessage('Listening... Say product name or craft region 🎙️');
  }

  // ============================================================
  // CATEGORY MATCH
  // ============================================================

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

  // ============================================================
  // ADD TO CART
  // ============================================================

  Future<void> _addToCart(
    QueryDocumentSnapshot<Map<String, dynamic>> productDoc,
  ) async {
    try {
      final user = _user;
      if (user == null) return;

      final data = productDoc.data();
      final artisanId = _getArtisanId(productDoc);
      if (artisanId.isEmpty) {
        _showMessage('Unable to identify the artisan.', isError: true);
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

  // ============================================================
  // WISHLIST
  // ============================================================

  Future<void> _toggleWishlist(
    QueryDocumentSnapshot<Map<String, dynamic>> productDoc,
  ) async {
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

  // ============================================================
  // PRODUCT DETAILS MODAL
  // ============================================================

  void _showProductDetails(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final name = (data['name'] ?? 'Handcrafted Product').toString();
    final category = (data['category'] ?? 'Handicraft').toString();
    final description = (data['description'] ?? 'Authentic artisan product.')
        .toString();
    final price = _toDouble(data['price']);
    final originalPrice = (price * 1.6).roundToDouble();
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

                  // Large Product Image
                  _LargeProductImage(
                    imageUrl: imageUrl,
                    productName: name,
                    category: category,
                  ),

                  const SizedBox(height: 16),

                  // Category & GI Tag badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.verified,
                              size: 13,
                              color: _discountGreen,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'HeriTrace GI Assured',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: _discountGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Product Title
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _primaryText,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Price block with Flipkart formatting
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹${price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: _primaryText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${originalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                          color: _secondaryText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '38% off',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: _discountGreen,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Artisan Traceability card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9FB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Row(
                      children: const [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0xFFFFECB3),
                          child: Icon(
                            Icons.handyman,
                            color: Color(0xFFF57F17),
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Direct from Master Artisan Atelier',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _primaryText,
                                ),
                              ),
                              Text(
                                'Zero middlemen markup • 100% fair artisan royalty',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _secondaryText,
                                ),
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
                      color: _primaryText,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    description.isEmpty
                        ? 'This authentic handcrafted product is created with heritage craft traditions. Verified for cultural provenance.'
                        : description,
                    style: const TextStyle(
                      color: _secondaryText,
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFBDBDBD)),
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _toggleWishlist(doc);
                          },
                          icon: const Icon(
                            Icons.favorite_border,
                            color: _primaryText,
                          ),
                          label: const Text(
                            'Wishlist',
                            style: TextStyle(color: _primaryText),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _flipkartYellow,
                            foregroundColor: const Color(0xFF1B1464),
                            elevation: 0,
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _addToCart(doc);
                          },
                          icon: const Icon(Icons.shopping_cart, size: 20),
                          label: const Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
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

  // ============================================================
  // EMPTY & ERROR STATES
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 40,
                color: _secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No crafts found in this view',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try changing your search term or exploring another category.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _secondaryText, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _purpleHeaderStart,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _selectedCategory = 'For You';
                });
              },
              child: const Text('Reset All Filters'),
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
              'Unable to load crafts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _secondaryText, fontSize: 12),
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

  // ============================================================
  // HELPERS
  // ============================================================

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
          backgroundColor: isError
              ? Colors.red.shade700
              : const Color(0xFF212121),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

// =================================================================
// FLIPKART-STYLE COMMERCIAL PRODUCT CARD
// =================================================================

class _FlipkartProductCard extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> document;
  final VoidCallback onAddToCart;
  final VoidCallback onWishlist;
  final VoidCallback onOpen;

  const _FlipkartProductCard({
    required this.document,
    required this.onAddToCart,
    required this.onWishlist,
    required this.onOpen,
  });

  @override
  State<_FlipkartProductCard> createState() => _FlipkartProductCardState();
}

class _FlipkartProductCardState extends State<_FlipkartProductCard> {
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
    if (path.length < 4) return;

    final artisanId = path[1];
    final wishlistId = '${artisanId}_${widget.document.id}';

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(wishlistId);

    final snapshot = await ref.get();
    if (mounted) {
      setState(() => _isWishlisted = snapshot.exists);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.document.data();
    final name = (data['name'] ?? 'Handcrafted Product').toString();
    final category = (data['category'] ?? 'Handicraft').toString();
    final imageUrl = (data['imageUrl'] ?? '').toString();
    final price = _toDouble(data['price']);
    final originalPrice = (price * 1.6).roundToDouble();

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFE0E0E0), width: 0.8),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Wishlist Button
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _ProductImage(
                      imageUrl: imageUrl,
                      productName: name,
                      category: category,
                    ),
                  ),

                  // Assured Badge
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            size: 10,
                            color: Color(0xFF26A541),
                          ),
                          SizedBox(width: 2),
                          Text(
                            'Assured',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF26A541),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Wishlist heart
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
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            _isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color: _isWishlisted
                                ? Colors.redAccent
                                : const Color(0xFF757575),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Details Block
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Title (2 lines max)
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF212121),
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Star Rating Pill
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF26A541),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '4.8',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(Icons.star, color: Colors.white, size: 8),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '(124)',
                          style: TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Price Layout
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₹${price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF212121),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '₹${originalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                            color: Color(0xFF757575),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '38% off',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF26A541),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 2),

                    // Free Delivery Tag + Add to Cart mini button
                    Row(
                      children: [
                        const Text(
                          'Free delivery',
                          style: TextStyle(
                            color: Color(0xFF616161),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: widget.onAddToCart,
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE500),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1B1464),
                              ),
                            ),
                          ),
                        ),
                      ],
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
    if (name.contains('saree') ||
        name.contains('ikat') ||
        type.contains('textile')) {
      return 'https://utkalikaodisha.com/wp-content/uploads/2023/01/TRI3D__Smb_3__silk_set172_srijla_front__2023-1-4-13-27-43__1200X1200_11zon.jpg';
    }
    if (name.contains('kurta') || name.contains('dress')) {
      return 'https://5.imimg.com/data5/ECOM/Default/2023/8/331186386/FZ/KN/HT/67173095/1690936764682-sku-3379-0-1000x1000.jpg';
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
    return Image.network(
      imageUrl.isNotEmpty ? imageUrl : _fallbackUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) {
        return Image.network(_fallbackUrl, fit: BoxFit.cover);
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
                color: Color(0xFF7B00C7),
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
