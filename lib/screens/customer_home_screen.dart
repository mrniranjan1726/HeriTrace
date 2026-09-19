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
  // HeriTrace Signature Haute Heritage Palette
  static const Color _terracottaSilk = Color(0xFF7A2012); // Royal Terracotta
  static const Color _crimsonSilk = Color(0xFF9E341B);   // Heirloom Crimson
  static const Color _winePill = Color(0xFF5A1409);      // Wine Capsule
  static const Color _antiqueGold = Color(0xFFD4A056);   // Antique Gold
  static const Color _goldLight = Color(0xFFFDF6EC);     // Light Gold Wash
  static const Color _warmLinen = Color(0xFFF7F2EB);     // Warm Artisanal Linen
  static const Color _charcoalInk = Color(0xFF1D2A24);   // Deep Charcoal Ink
  static const Color _sageMuted = Color(0xFF6B746E);     // Muted Heritage Sage
  static const Color _forestGreen = Color(0xFF1F4D3B);   // GI / Fair Trade Forest
  static const Color _cardBorder = Color(0xFFE8DFD3);    // Warm Border

  final TextEditingController _searchController = TextEditingController();
  final PageController _carouselPageController = PageController();

  late final AnimationController _pulseController;
  Timer? _searchHintTimer;
  Timer? _carouselTimer;

  int _searchHintIndex = 0;
  int _currentCarouselIndex = 0;
  bool _isAuctionAlertVisible = true;
  String _selectedDeliveryAddress = 'Banisri Bihar, Patna 800001';
  int _userCoins = 120;

  String _searchQuery = '';
  String _selectedCategory = 'For You';
  int _bottomNavIndex = 0;

  final List<String> _searchHints = [
    'Handcrafted Pashmina Shawls',
    'Banarasi Silk Handloom Sarees',
    'Jaipur Blue Pottery Vases',
    'Bastar Dhokra Brass Sculptures',
    'Channapatna Natural Woodcraft',
    'Madhubani Folk Paintings',
    'Tanjore 22K Gold Foil Relics',
  ];

  final List<Map<String, dynamic>> _craftGuilds = [
    {'name': 'For You', 'label': 'Masterpieces', 'icon': Icons.auto_awesome},
    {'name': 'Textiles', 'label': 'Royal Weaves', 'icon': Icons.dry_cleaning_outlined},
    {'name': 'Pottery', 'label': 'Ceramic Art', 'icon': Icons.bubble_chart_outlined},
    {'name': 'Jewellery', 'label': 'Heirloom Gems', 'icon': Icons.diamond_outlined},
    {'name': 'Woodcraft', 'label': 'Sacred Wood', 'icon': Icons.carpenter_outlined},
    {'name': 'Paintings', 'label': 'Folk Canvas', 'icon': Icons.palette_outlined},
    {'name': 'Decor', 'label': 'Temple Decor', 'icon': Icons.chair_outlined},
  ];

  final List<Map<String, dynamic>> _spotlightBanners = [
    {
      'tag': '100% GI CERTIFIED',
      'artisan': 'Master Weaver Rajeshwar • Varanasi Ateliers',
      'title': 'Katan Silk Kadwa Brocade',
      'subtitle': 'Pure Mulberry Silk woven on traditional wooden pit looms with real zari embellishment.',
      'badge': 'Zero Middlemen Markup',
      'price': '₹4,999',
      'imageUrl':
          'https://utkalikaodisha.com/wp-content/uploads/2023/01/TRI3D__Smb_3__silk_set172_srijla_front__2023-1-4-13-27-43__1200X1200_11zon.jpg',
    },
    {
      'tag': 'HERITAGE GUILD RESERVE',
      'artisan': 'Farooq Ahmad & Sons • Srinagar',
      'title': 'Kashmiri Hand-spun Pashmina',
      'subtitle': 'Changthangi goat fleece spun by generational craft custodians in the Kashmir valley.',
      'badge': 'GI Authenticity Lens Ready',
      'price': '₹8,499',
      'imageUrl':
          'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?auto=format&fit=crop&w=900&q=80',
    },
    {
      'tag': '4,000-YR ANCIENT CASTING',
      'artisan': 'Devi Baghel Guild • Bastar Tribal Cluster',
      'title': 'Dhokra Lost-Wax Bell Metal',
      'subtitle': 'Non-ferrous bronze cast using beeswax, clay, and river silt techniques dating back to Mohenjo-Daro.',
      'badge': 'Collector Grade Artifact',
      'price': '₹2,199',
      'imageUrl':
          'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=900&q=80',
    },
  ];

  final List<Map<String, dynamic>> _curatorReserve = [
    {
      'name': 'Kashmir Walnut Carving Box',
      'category': 'Woodcraft',
      'origin': 'Srinagar, J&K',
      'price': 899,
      'originalPrice': 1799,
      'artisanShare': '₹620 direct to artisan',
      'imageUrl':
          'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=600&q=80',
    },
    {
      'name': 'Peacock Brass Temple Diya',
      'category': 'Decor',
      'origin': 'Moradabad, UP',
      'price': 649,
      'originalPrice': 1299,
      'artisanShare': '₹480 direct to artisan',
      'imageUrl':
          'https://images.unsplash.com/photo-1610701596007-11502861dcfa?auto=format&fit=crop&w=600&q=80',
    },
    {
      'name': 'Jaipur Cobalt Blue Urn',
      'category': 'Pottery',
      'origin': 'Kot Jewar, Rajasthan',
      'price': 499,
      'originalPrice': 1199,
      'artisanShare': '₹350 direct to artisan',
      'imageUrl':
          'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=600&q=80',
    },
    {
      'name': 'Madhubani Kohbar Painting',
      'category': 'Paintings',
      'origin': 'Madhubani, Bihar',
      'price': 999,
      'originalPrice': 1999,
      'artisanShare': '₹750 direct to artisan',
      'imageUrl':
          'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=600&q=80',
    },
    {
      'name': 'Handloom Tussar Silk Shawl',
      'category': 'Textiles',
      'origin': 'Bhagalpur, Bihar',
      'price': 1499,
      'originalPrice': 2999,
      'artisanShare': '₹1,150 direct to artisan',
      'imageUrl':
          'https://utkalikaodisha.com/wp-content/uploads/2023/01/TRI3D__Smb_3__silk_set172_srijla_front__2023-1-4-13-27-43__1200X1200_11zon.jpg',
    },
  ];

  final List<Map<String, dynamic>> _gazetteStories = [
    {
      'headline': 'The 4,000-Year Secrets of Bastar Lost-Wax Bronze',
      'summary': 'How tribal artisans in Chhattisgarh preserve Mohenjo-Daro metal casting techniques.',
      'category': 'Ancient Metallurgy',
      'readTime': '4 min read',
      'gradient': const [Color(0xFF2C1307), Color(0xFF6B2810)],
      'imageUrl': 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=600&q=80',
    },
    {
      'headline': 'Why Kanchipuram Mulberry Silk Lasts Three Generations',
      'summary': 'Discover the sacred Korvai weaving method and pure silver zari hallmarks.',
      'category': 'Royal Handlooms',
      'readTime': '5 min read',
      'gradient': const [Color(0xFF3B0B2E), Color(0xFF7A1B60)],
      'imageUrl': 'https://utkalikaodisha.com/wp-content/uploads/2023/01/TRI3D__Smb_3__silk_set172_srijla_front__2023-1-4-13-27-43__1200X1200_11zon.jpg',
    },
    {
      'headline': 'Jaipur Blue Pottery: Revival of Emperor Akbar\'s Glaze',
      'summary': 'Crafted entirely without clay using quartz powder, Fuller’s earth, and natural gum.',
      'category': 'Architectural Pottery',
      'readTime': '3 min read',
      'gradient': const [Color(0xFF0A2540), Color(0xFF1E5B94)],
      'imageUrl': 'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=600&q=80',
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

    _searchHintTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _searchHintIndex = (_searchHintIndex + 1) % _searchHints.length;
        });
      }
    });

    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _carouselPageController.hasClients) {
        final nextIndex = (_currentCarouselIndex + 1) % _spotlightBanners.length;
        _carouselPageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 550),
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
      backgroundColor: _warmLinen,
      floatingActionButton: const SupportChatbot(role: 'customer', compact: true),
      body: CustomScrollView(
        slivers: [
          // 1. Royal Silk Terracotta Header (Patron Monogram, Coins, Address, Search, Guilds)
          _buildRoyalHeader(context),

          // 2. Bento Navigation Portals (Auctions, Gazette, Direct GI, Lens)
          SliverToBoxAdapter(
            child: _buildBentoPortals()
                .animate()
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.04, end: 0),
          ),

          // 3. Live Rare Auctions Alert Ticker (Dismissible, pulsating)
          if (_isAuctionAlertVisible)
            SliverToBoxAdapter(
              child: _buildLiveAuctionAlertBanner()
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.05, end: 0),
            ),

          // 4. Curator's Spotlight Masterpiece Showcase (Magazine-style Animated Carousel)
          SliverToBoxAdapter(
            child: _buildSpotlightCarousel()
                .animate(delay: 80.ms)
                .fadeIn(duration: 450.ms),
          ),

          // 5. Curator's Seasonal Reserve (Warm Linen Editorial Showcase)
          SliverToBoxAdapter(
            child: _buildCuratorReserveRail()
                .animate(delay: 140.ms)
                .fadeIn(duration: 450.ms)
                .slideY(begin: 0.05, end: 0),
          ),

          // 6. Living Cultural Gazette & Masterpiece Stories (Interactive Editorial Rail)
          SliverToBoxAdapter(
            child: _buildGazetteEditorialRail()
                .animate(delay: 180.ms)
                .fadeIn(duration: 450.ms)
                .slideY(begin: 0.05, end: 0),
          ),

          // 7. Masterpiece Gallery Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _terracottaSilk,
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
                              ? 'Curated Masterpiece Gallery'
                              : '$_selectedCategory Heritage Guild',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _charcoalInk,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const Text(
                          'Direct GI Certified Artisans • Zero Intermediary Markups',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _sageMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collectionGroup('products')
                        .snapshots(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _goldLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _antiqueGold.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          '$count Heirlooms',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _terracottaSilk,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 8. 2-Column Luxury Masterpiece Grid
          _buildProductGrid(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ============================================================
  // 1. ROYAL SILK TERRACOTTA HEADER
  // ============================================================

  Widget _buildRoyalHeader(BuildContext context) {
    final email = _user?.email ?? 'Patron';
    final rawName = email.split('@').first;
    final patronName = rawName.isEmpty
        ? 'PATRON'
        : rawName.replaceAll('.', ' ').toUpperCase();

    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_terracottaSilk, _crimsonSilk, Color(0xFF63150A)],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x334A1208),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Patron Monogram & Quick Privilege Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    // Monogram Seal
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _winePill,
                        border: Border.all(color: _antiqueGold, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.spa_rounded,
                          color: _antiqueGold,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'NAMASTE, $patronName',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                color: _antiqueGold,
                                size: 14,
                              ),
                            ],
                          ),
                          const Text(
                            'Custodian of Living Indian Heritage',
                            style: TextStyle(
                              color: Color(0xFFE8C8A3),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Patron Gold Coins Vault Pill
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _showCoinsModal,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: _winePill,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _antiqueGold.withValues(alpha: 0.7),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt, color: _antiqueGold, size: 15),
                            const SizedBox(width: 2),
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
                    ).animate().shimmer(duration: 2000.ms, color: Colors.white24),

                    const SizedBox(width: 6),

                    // Offers / Royal Grants
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _showOffersModal,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: _winePill,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: const Icon(
                          Icons.confirmation_num_outlined,
                          color: _antiqueGold,
                          size: 16,
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Patron Receipts (Orders)
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
                          color: _winePill,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: const Icon(
                          Icons.receipt_long_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Patron Bag (Cart) with Live Firestore Badge
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _cartCollection.snapshots(),
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
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: _winePill,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _antiqueGold.withValues(alpha: 0.8),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              if (count > 0)
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: _antiqueGold,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
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

              // Curated Delivery Ribbon
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _showDeliveryAddressModal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: _antiqueGold,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Delivering to: ',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
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
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Haute Heritage Search Bar & Authenticity Lens
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
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
                      const SizedBox(width: 14),
                      const Icon(Icons.search, color: _terracottaSilk, size: 22),
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
                                  'Explore ${_searchHints[_searchHintIndex]}',
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
                                color: _charcoalInk,
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
                          icon: const Icon(Icons.close, size: 18, color: _sageMuted),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.mic_none_rounded, color: _sageMuted, size: 22),
                        tooltip: 'Voice Search',
                        onPressed: _triggerVoiceSearch,
                      ),
                      // Heritage Authenticity Scanner Button
                      InkWell(
                        onTap: () => Navigator.pushNamed(context, '/heritage-features'),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _goldLight,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: _antiqueGold, width: 1.2),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.qr_code_scanner, color: _terracottaSilk, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Verify GI',
                                style: TextStyle(
                                  color: _terracottaSilk,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
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

              // Craft Guilds Category Selector Rail
              _buildCraftGuildsRail(),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // Craft Guilds Category Horizontal Rail
  Widget _buildCraftGuildsRail() {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _craftGuilds.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final guild = _craftGuilds[index];
          final name = guild['name'] as String;
          final label = guild['label'] as String;
          final icon = guild['icon'] as IconData;
          final isSelected = _selectedCategory == name;

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() {
                _selectedCategory = name;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _antiqueGold
                        : Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: _antiqueGold.withValues(alpha: 0.45),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? const Color(0xFF4A1208) : Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 18 : 0,
                  height: 3,
                  decoration: BoxDecoration(
                    color: _antiqueGold,
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
  // 2. BENTO NAVIGATION PORTALS
  // ============================================================

  Widget _buildBentoPortals() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: Row(
        children: [
          // 1. Live Auctions
          Expanded(
            child: _bentoTile(
              title: 'Live Auctions',
              subtitle: 'Rare Lots',
              icon: Icons.gavel_rounded,
              accentColor: const Color(0xFF9E341B),
              onTap: () => Navigator.pushNamed(context, '/customer-auctions'),
            ),
          ),
          const SizedBox(width: 8),

          // 2. Craft Gazette
          Expanded(
            child: _bentoTile(
              title: 'Craft Gazette',
              subtitle: 'Culture News',
              icon: Icons.newspaper_rounded,
              accentColor: const Color(0xFF1F4D3B),
              onTap: () => Navigator.pushNamed(context, '/heritage-news'),
            ),
          ),
          const SizedBox(width: 8),

          // 3. Direct GI
          Expanded(
            child: _bentoTile(
              title: 'Direct GI',
              subtitle: '100% Artisan',
              icon: Icons.verified_outlined,
              accentColor: const Color(0xFF7A2012),
              onTap: () {
                setState(() => _selectedCategory = 'Textiles');
              },
            ),
          ),
          const SizedBox(width: 8),

          // 4. Heritage Lens
          Expanded(
            child: _bentoTile(
              title: 'Craft Lens',
              subtitle: 'Provenance DNA',
              icon: Icons.document_scanner_outlined,
              accentColor: const Color(0xFF5A1409),
              onTap: () => Navigator.pushNamed(context, '/heritage-features'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bentoTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: _charcoalInk,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: _sageMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 3. LIVE RARE AUCTIONS ALERT BANNER
  // ============================================================

  Widget _buildLiveAuctionAlertBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF38120B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _antiqueGold.withValues(alpha: 0.6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pulsing Live Indicator
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.redAccent,
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(1, 1),
                end: const Offset(1.35, 1.35),
                duration: 900.ms,
              ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'LIVE ATELIER AUCTION IN PROGRESS',
                  style: TextStyle(
                    color: _antiqueGold,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '18th-C. Recreated Pashmina Jamawar • 7 Patrons Bidding',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          InkWell(
            onTap: () => Navigator.pushNamed(context, '/customer-auctions'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _antiqueGold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.gavel_rounded, size: 13, color: Color(0xFF4A1208)),
                  SizedBox(width: 4),
                  Text(
                    'Bid Room',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4A1208),
                    ),
                  ),
                ],
              ),
            ),
          ),

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
  // 4. CURATOR'S SPOTLIGHT MASTERPIECE CAROUSEL
  // ============================================================

  Widget _buildSpotlightCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 185,
          child: PageView.builder(
            controller: _carouselPageController,
            itemCount: _spotlightBanners.length,
            onPageChanged: (index) {
              setState(() => _currentCarouselIndex = index);
            },
            itemBuilder: (context, index) {
              final banner = _spotlightBanners[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Backdrop Image
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

                      // Rich Silk Gradient Overlay
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                const Color(0xFF38120B).withValues(alpha: 0.92),
                                const Color(0xFF38120B).withValues(alpha: 0.65),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _antiqueGold,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                banner['tag'] as String,
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF4A1208),
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              banner['title'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              banner['artisan'] as String,
                              style: const TextStyle(
                                color: Color(0xFFE8C8A3),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 220,
                              child: Text(
                                banner['subtitle'] as String,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.white30, width: 0.8),
                              ),
                              child: Text(
                                '${banner['badge']} • ${banner['price']}',
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
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Animated Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_spotlightBanners.length, (index) {
            final isActive = index == _currentCarouselIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 22 : 6,
              height: 5,
              decoration: BoxDecoration(
                color: isActive ? _terracottaSilk : _cardBorder,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ============================================================
  // 5. CURATOR'S SEASONAL RESERVE (Linen Editorial Rail)
  // ============================================================

  Widget _buildCuratorReserveRail() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                        'Curator\'s Seasonal Reserve',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: _charcoalInk,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'Limited heirloom craft runs with verified direct artisan revenue',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _sageMuted,
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
                        'Explore All',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _terracottaSilk,
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 10, color: _terracottaSilk),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 205,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              itemCount: _curatorReserve.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = _curatorReserve[index];

                return Container(
                  width: 140,
                  decoration: BoxDecoration(
                    color: _warmLinen,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.network(
                                  item['imageUrl'] as String,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image, color: Colors.grey),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 6,
                                left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(6),
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

                      // Details
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
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: _charcoalInk,
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
                                color: _forestGreen,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '₹${item['price']}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: _charcoalInk,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '₹${item['originalPrice']}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    decoration: TextDecoration.lineThrough,
                                    color: _sageMuted,
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
        ],
      ),
    );
  }

  // ============================================================
  // 6. LIVING CULTURAL GAZETTE & MASTERPIECE STORIES
  // ============================================================

  Widget _buildGazetteEditorialRail() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: _terracottaSilk,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'GAZETTE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Living Culture & Heritage Dispatches',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: _charcoalInk,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/heritage-news'),
                child: const Row(
                  children: [
                    Text(
                      'All News',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _terracottaSilk,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 10, color: _terracottaSilk),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 165,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _gazetteStories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final story = _gazetteStories[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => Navigator.pushNamed(context, '/heritage-news'),
                  child: Container(
                    width: 270,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: story['gradient'] as List<Color>,
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
                    child: Stack(
                      children: [
                        // Subtle Background Image
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Opacity(
                              opacity: 0.25,
                              child: Image.network(
                                story['imageUrl'] as String,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const SizedBox(),
                              ),
                            ),
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: _antiqueGold,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      story['category'] as String,
                                      style: const TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF4A1208),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    story['readTime'] as String,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                story['headline'] as String,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                story['summary'] as String,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10.5,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Row(
                                children: [
                                  Text(
                                    'Read Editorial & View Relics',
                                    style: TextStyle(
                                      color: _antiqueGold,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward, size: 11, color: _antiqueGold),
                                ],
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
        ],
      ),
    );
  }

  // ============================================================
  // 8. LUXURY 2-COLUMN MASTERPIECE GRID
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
              child: CircularProgressIndicator(color: _terracottaSilk),
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
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 110),
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
                  childAspectRatio: 0.63,
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ============================================================
  // 5-TAB HERITRACE BOTTOM NAVIGATION BAR
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
                label: 'Atelier',
                icon: Icons.temple_hindu_outlined,
                activeIcon: Icons.temple_hindu_rounded,
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
                label: 'Guilds',
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view_rounded,
                onTap: _showCategoriesModal,
              ),
              _buildBottomNavItem(
                index: 3,
                label: 'Gazette',
                icon: Icons.newspaper_outlined,
                activeIcon: Icons.newspaper_rounded,
                onTap: () {
                  Navigator.pushNamed(context, '/heritage-news');
                },
              ),
              _buildBottomNavItem(
                index: 4,
                label: 'Patron',
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                onTap: () {
                  Navigator.pushNamed(context, '/customer-profile');
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
                  color: isSelected ? _terracottaSilk : _sageMuted,
                  size: 22,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -7,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: _antiqueGold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$badgeCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF4A1208),
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
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                color: isSelected ? _terracottaSilk : _sageMuted,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _terracottaSilk,
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
                    const Icon(Icons.location_on, color: _terracottaSilk),
                    const SizedBox(width: 8),
                    const Text(
                      'Patron Delivery Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _charcoalInk,
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
                  leading: const Icon(Icons.home, color: _terracottaSilk),
                  title: const Text(
                    'Banisri Bihar, Patna',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Pin: 800001 • Fast Insured Heritage Dispatch'),
                  trailing: const Icon(Icons.check_circle, color: _forestGreen),
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
                  title: const Text('New Delhi Artisan Hub'),
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
                      foregroundColor: _terracottaSilk,
                      side: const BorderSide(color: _terracottaSilk),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showMessage('Address manager opened.');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Delivery Landmark'),
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
                        color: _terracottaSilk,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bolt, color: _antiqueGold, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_userCoins Heritage Patron Coins',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _charcoalInk,
                          ),
                        ),
                        const Text(
                          'Earn 10 coins for every ₹100 spent on certified crafts',
                          style: TextStyle(color: _sageMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _goldLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _antiqueGold.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.stars, color: _terracottaSilk),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'You can redeem ₹120 directly on your next craft order!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _charcoalInk,
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
                      backgroundColor: _terracottaSilk,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        if (_userCoins >= 50) {
                          _userCoins -= 50;
                          _showMessage(
                            'Redeemed 50 Heritage Coins for ₹50 instant checkout discount! 🪙',
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
                  'Exclusive Patron Privileges & Grants',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _charcoalInk,
                  ),
                ),
                const SizedBox(height: 14),
                _offerTile(
                  code: 'HERITAGE500',
                  desc: 'Flat ₹500 grant on orders above ₹1,999 from Verified GI Artisans',
                ),
                const SizedBox(height: 8),
                _offerTile(
                  code: 'FIRSTPATRON',
                  desc: 'Insured Express Dispatch + 15% patron welcome privilege',
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
        color: _warmLinen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _terracottaSilk,
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
              style: const TextStyle(fontSize: 11, color: _charcoalInk),
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
                  'All Heritage Guilds & Disciplines',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _craftGuilds.map((guild) {
                    final name = guild['name'] as String;
                    final label = guild['label'] as String;
                    return ActionChip(
                      avatar: Icon(guild['icon'] as IconData, size: 16),
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
    _showMessage('Listening... State craft discipline or master artisan region 🎙️');
  }

  // Category Matcher
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

  // Add to Cart
  Future<void> _addToCart(
    QueryDocumentSnapshot<Map<String, dynamic>> productDoc,
  ) async {
    try {
      final user = _user;
      if (user == null) return;

      final data = productDoc.data();
      final artisanId = _getArtisanId(productDoc);
      if (artisanId.isEmpty) {
        _showMessage('Unable to identify the artisan atelier.', isError: true);
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

      _showMessage('Added to Patron Bag! 🛍️');
    } catch (e) {
      _showMessage('Could not add heirloom to bag.', isError: true);
    }
  }

  // Wishlist
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
        _showMessage('Removed from Patron Wishlist.');
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
        _showMessage('Added to Patron Wishlist ❤️');
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

  // Product Details Modal
  void _showProductDetails(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final name = (data['name'] ?? 'Handcrafted Heirloom').toString();
    final category = (data['category'] ?? 'Handicraft').toString();
    final description = (data['description'] ?? 'Authentic artisan masterpiece.')
        .toString();
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
                          color: _goldLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _antiqueGold),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified, size: 13, color: _terracottaSilk),
                            SizedBox(width: 4),
                            Text(
                              'GI Authenticity Certified',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: _terracottaSilk,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _warmLinen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _sageMuted,
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
                      color: _charcoalInk,
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
                          color: _charcoalInk,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${originalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                          color: _sageMuted,
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
                            color: _forestGreen,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Direct Artisan Pledge Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _warmLinen,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: Row(
                      children: const [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: _goldLight,
                          child: Icon(Icons.handyman, color: _terracottaSilk, size: 18),
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
                                  color: _charcoalInk,
                                ),
                              ),
                              Text(
                                'Zero intermediary markups • 100% fair patron royalty',
                                style: TextStyle(fontSize: 10, color: _sageMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Provenance & Craft Tradition',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _charcoalInk,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    description.isEmpty
                        ? 'This authentic handcrafted heirloom is created using ancestral techniques handed down through generations. Certified for cultural provenance.'
                        : description,
                    style: const TextStyle(color: _sageMuted, height: 1.5, fontSize: 13),
                  ),

                  const SizedBox(height: 22),

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
                          icon: const Icon(Icons.favorite_border, color: _charcoalInk),
                          label: const Text('Wishlist', style: TextStyle(color: _charcoalInk)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _terracottaSilk,
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
                            'Add to Patron Bag',
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _cardBorder),
              ),
              child: const Icon(Icons.search_off_rounded, size: 40, color: _sageMuted),
            ),
            const SizedBox(height: 16),
            const Text(
              'No heirlooms found in this view',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try changing your search term or exploring another craft guild.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _sageMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _terracottaSilk,
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
              'Unable to load heirlooms',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _sageMuted, fontSize: 12),
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
          backgroundColor: isError ? Colors.red.shade700 : _charcoalInk,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

// =================================================================
// BESPOKE HERITRACE MASTERPIECE PRODUCT CARD
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
    final name = (data['name'] ?? 'Handcrafted Heirloom').toString();
    final category = (data['category'] ?? 'Heritage Craft').toString();
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
            // Image with GI seal badge and wishlist
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

                  // GI Certified Gold Seal Badge
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A056),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 9, color: Color(0xFF4A1208)),
                          SizedBox(width: 2),
                          Text(
                            'GI Seal',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF4A1208),
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

                    Row(
                      children: const [
                        Text(
                          'Direct Artisan Royalty',
                          style: TextStyle(
                            color: Color(0xFF1F4D3B),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
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
                            color: Color(0xFF1D2A24),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '₹${originalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                            color: Color(0xFF6B746E),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Patronize Action Mini Button
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
                              'Patronize',
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
