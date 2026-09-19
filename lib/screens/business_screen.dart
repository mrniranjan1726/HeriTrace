import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'add_product_screen.dart';
import 'pricing_screen.dart';
import 'image_studio_screen.dart';
import 'artisan_orders_screen.dart';
import 'artisan_auctions_screen.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const _terracotta = Color(0xFFA24B2A);
  static const _forest = Color(0xFF1F4D3B);
  static const _gold = Color(0xFFD39A3F);
  static const _cream = Color(0xFFF4EFE7);
  static const _surface = Color(0xFFFFFCF7);
  static const _ink = Color(0xFF1D2A24);
  static const _muted = Color(0xFF68746D);

  bool loading = true;

  int productCount = 0;
  int orderCount = 0;
  int pendingOrders = 0;
  int deliveredOrders = 0;

  double totalSales = 0;
  double pendingSales = 0;

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> recentOrders = [];
  String? orderDataWarning;
  String artisanName = 'Master Artisan';

  @override
  void initState() {
    super.initState();
    loadBusinessData();
  }

  // ============================================================
  // LOAD BUSINESS DATA
  // ============================================================
  Future<void> loadBusinessData() async {
    final user = _auth.currentUser;

    if (user == null) {
      if (mounted) setState(() => loading = false);
      return;
    }

    try {
      // 1. Load user profile name
      final userDoc = await _db.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() ?? {};
        artisanName =
            data['name']?.toString() ??
            data['displayName']?.toString() ??
            user.displayName ??
            'Master Artisan';
      }

      // 2. Load products
      final productSnapshot = await _db
          .collection('users')
          .doc(user.uid)
          .collection('products')
          .get();

      final loadedProducts = productSnapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();

      // 3. Load orders via collectionGroup
      int totalOrders = 0;
      int pending = 0;
      int delivered = 0;
      double sales = 0;
      double pendingAmount = 0;
      final List<Map<String, dynamic>> artisanOrders = [];

      try {
        final orderSnapshot = await _db.collectionGroup('orders').get();

        for (final doc in orderSnapshot.docs) {
          final data = doc.data();
          final dynamic rawItems = data['items'];
          if (rawItems is! List) continue;

          bool belongsToArtisan = false;
          for (final item in rawItems) {
            if (item is! Map) continue;
            final artisanId =
                item['artisanId']?.toString() ??
                item['artisanID']?.toString() ??
                item['ownerId']?.toString() ??
                item['userId']?.toString();

            if (artisanId == user.uid) {
              belongsToArtisan = true;
              break;
            }
          }

          if (!belongsToArtisan) continue;

          totalOrders++;
          final status = data['status']?.toString().toLowerCase() ?? 'pending';
          final total = _toDouble(data['total']);

          if (status == 'pending' ||
              status == 'confirmed' ||
              status == 'processing' ||
              status == 'shipped') {
            pending++;
            pendingAmount += total;
          }

          if (status == 'delivered') {
            delivered++;
            sales += total;
          }

          artisanOrders.add({'id': doc.id, ...data});
        }

        artisanOrders.sort((a, b) {
          final aDate = _timestampToDate(a['createdAt']);
          final bDate = _timestampToDate(b['createdAt']);
          return bDate.compareTo(aDate);
        });
      } catch (e) {
        debugPrint('Orders loading note: $e');
      }

      if (!mounted) return;
      setState(() {
        products = loadedProducts;
        productCount = loadedProducts.length;
        orderCount = totalOrders;
        pendingOrders = pending;
        deliveredOrders = delivered;
        totalSales = sales;
        pendingSales = pendingAmount;
        recentOrders = artisanOrders.take(5).toList();
        loading = false;
        orderDataWarning = null;
      });
    } catch (e) {
      debugPrint('Error loading artisan data: $e');
      if (mounted) setState(() => loading = false);
    }
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  DateTime _timestampToDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: _terracotta.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.handyman_rounded,
                color: _terracotta,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Artisan Atelier & Studio',
              style: TextStyle(
                color: _ink,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Live Auctions',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ArtisanAuctionsScreen()),
            ),
            icon: const Icon(Icons.gavel_rounded, color: _gold),
          ),
          IconButton(
            tooltip: 'Refresh Atelier',
            onPressed: loading ? null : loadBusinessData,
            icon: const Icon(Icons.refresh_rounded, color: _ink),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: _terracotta))
          : RefreshIndicator(
              onRefresh: loadBusinessData,
              color: _terracotta,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
                children: [
                  _buildAtelierHeroBanner(),
                  const SizedBox(height: 20),
                  _buildLiveAuctionsSpotlightCard(),
                  const SizedBox(height: 24),
                  _buildStudioQuickActions(),
                  const SizedBox(height: 28),
                  _buildFinancialAndImpactMetrics(),
                  const SizedBox(height: 28),
                  _buildMasterpiecesSection(),
                  const SizedBox(height: 28),
                  _buildPatronOrdersSection(),
                  const SizedBox(height: 28),
                  _buildHeritageAdvisoryCard(),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // 1. ATELIER HERO BANNER
  // ============================================================
  Widget _buildAtelierHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8A3418), Color(0xFF1A4533)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8A3418).withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE8C582), width: 2),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFE8C582),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artisanName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.verified,
                          color: Color(0xFFE8C582),
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'GI Heritage Verified Artisan',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.3, 1.3),
                    ),
                const SizedBox(width: 8),
                const Text(
                  'Atelier Active • Accepting Custom Patron Commissions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.06, end: 0);
  }

  // ============================================================
  // 1B. LIVE AUCTIONS SPOTLIGHT CARD
  // ============================================================
  Widget _buildLiveAuctionsSpotlightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E1206), Color(0xFF4C1E0C), Color(0xFF1B3D2B)],
        ),
        border: Border.all(
          color: const Color(0xFFE8C582).withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF381406).withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8C582).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE8C582),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.gavel_rounded,
                  color: Color(0xFFFFD54F),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD32F2F),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, color: Colors.white, size: 6),
                              SizedBox(width: 4),
                              Text(
                                'LIVE NOW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'GLOBAL HERITAGE BIDDING',
                          style: TextStyle(
                            color: Color(0xFFFFD54F),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Rare Craft Auctions House',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Present your finest handcrafted masterpieces to verified collectors worldwide. Set custom reserve prices, launch live bidding rooms, and earn premium fair-market value directly.',
            style: TextStyle(
              color: Color(0xFFEDE0D4),
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD39A3F),
                    foregroundColor: const Color(0xFF1D2A24),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ArtisanAuctionsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text(
                    'Open Auction House',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ArtisanAuctionsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text(
                    'View Bids',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.04, end: 0);
  }

  // ============================================================
  // 2. STUDIO QUICK ACTIONS (AI VISION, STORY, PRICING, AUCTION)
  // ============================================================
  Widget _buildStudioQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Artisan AI Studio Tools',
              style: TextStyle(
                color: _ink,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
            const Spacer(),
            Text(
              'AI Powered',
              style: TextStyle(
                color: _terracotta,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 650;
            return GridView.count(
              crossAxisCount: isWide ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: isWide ? 1.3 : 1.15,
              children: [
                _actionCard(
                  icon: Icons.auto_fix_high_rounded,
                  title: 'AI Photo Studio',
                  subtitle: 'Studio lighting & framing',
                  color: _terracotta,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ImageStudioScreen(),
                    ),
                  ),
                ),
                _actionCard(
                  icon: Icons.history_edu_rounded,
                  title: 'Story Writer',
                  subtitle: 'Cultural craft storytelling',
                  color: _forest,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddProductScreen()),
                  ),
                ),
                _actionCard(
                  icon: Icons.balance_rounded,
                  title: 'Fair Pricing',
                  subtitle: 'Living wages + materials',
                  color: _gold,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PricingScreen()),
                  ),
                ),
                _actionCard(
                  icon: Icons.gavel_rounded,
                  title: 'Live Auctions',
                  subtitle: 'Real-time bidder room',
                  color: const Color(0xFF7A3E65),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ArtisanAuctionsScreen(),
                    ),
                  ),
                ),
                _actionCard(
                  icon: Icons.biotech_rounded,
                  title: 'Craft DNA',
                  subtitle: 'Material & dye genetics',
                  color: const Color(0xFF00897B),
                  onTap: () =>
                      Navigator.pushNamed(context, '/heritage-features'),
                ),
                _actionCard(
                  icon: Icons.fingerprint_rounded,
                  title: 'Technique Fingerprint',
                  subtitle: 'Biometric handcraft signature',
                  color: const Color(0xFF5E35B1),
                  onTap: () =>
                      Navigator.pushNamed(context, '/heritage-features'),
                ),
              ],
            );
          },
        ),
      ],
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.20)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: _ink,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 3. FINANCIAL & IMPACT METRICS
  // ============================================================
  Widget _buildFinancialAndImpactMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Atelier Impact & Financials',
          style: TextStyle(
            color: _ink,
            fontSize: 19,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _metricBox(
                title: 'Total Heritage Sales',
                value: '₹${totalSales.toStringAsFixed(0)}',
                subtitle: '100% Direct Revenue',
                icon: Icons.currency_rupee_rounded,
                accentColor: _terracotta,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _metricBox(
                title: 'Active Masterpieces',
                value: productCount.toString(),
                subtitle: 'In Online Catalog',
                icon: Icons.palette_outlined,
                accentColor: _forest,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _metricBox(
                title: 'Patron Orders',
                value: orderCount.toString(),
                subtitle: '$pendingOrders in creation',
                icon: Icons.handshake_outlined,
                accentColor: _gold,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _metricBox(
                title: 'Living Wage Index',
                value: '100%',
                subtitle: 'Zero Middlemen Cut',
                icon: Icons.favorite_rounded,
                accentColor: const Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _metricBox({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6DDD2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              color: _ink,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(
              color: accentColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 4. MASTERPIECES SHOWCASE (CATALOG)
  // ============================================================
  Widget _buildMasterpiecesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Your Active Masterpieces',
              style: TextStyle(
                color: _ink,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddProductScreen()),
              ),
              icon: const Icon(Icons.add, size: 17),
              label: const Text('Add Craft'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (products.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE6DDD2)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.brush_outlined,
                    size: 44,
                    color: _terracotta.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No crafts published yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Use our AI Story Writer and Image Studio to publish your first handcrafted masterpiece.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: _muted),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddProductScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Publish First Craft'),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final p = products[index];
                final name = p['name']?.toString() ?? 'Handcrafted Piece';
                final category = p['category']?.toString() ?? 'Handicraft';
                final price = _toDouble(p['price']);
                final imgUrl = p['imageUrl']?.toString() ?? '';

                return Container(
                  width: 170,
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE6DDD2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: SizedBox(
                          height: 110,
                          width: double.infinity,
                          child: imgUrl.isNotEmpty
                              ? Image.network(imgUrl, fit: BoxFit.cover)
                              : Container(
                                  color: _forest.withValues(alpha: 0.1),
                                  child: const Icon(
                                    Icons.palette_outlined,
                                    color: _forest,
                                    size: 36,
                                  ),
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: _ink,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              category,
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: _terracotta,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1);
              },
            ),
          ),
      ],
    ).animate().fadeIn(delay: 260.ms).slideY(begin: 0.05, end: 0);
  }

  // ============================================================
  // 5. PATRON ORDERS PIPELINE
  // ============================================================
  Widget _buildPatronOrdersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recent Patron Commissions',
              style: TextStyle(
                color: _ink,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ArtisanOrdersScreen()),
              ),
              child: const Text('View All Orders'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentOrders.isEmpty)
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE6DDD2)),
            ),
            child: Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: _muted, size: 30),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Awaiting new patron orders',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'When customers purchase your crafts, their orders and shipping details will appear here.',
                        style: TextStyle(fontSize: 12, color: _muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          ...recentOrders.map((order) {
            final total = _toDouble(order['total']);
            final status = order['status']?.toString() ?? 'pending';
            final orderId =
                order['orderId'] ?? order['id'] ?? 'HeriTrace Order';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE6DDD2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _forest.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: _forest,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #$orderId',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${total.toStringAsFixed(0)} · Direct Payment',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _terracotta,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildArtisanStatusChip(status),
                ],
              ),
            );
          }),
      ],
    ).animate().fadeIn(delay: 320.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildArtisanStatusChip(String status) {
    Color bg = _terracotta.withValues(alpha: 0.12);
    Color fg = _terracotta;
    String label = 'Loom Setup';

    switch (status.toLowerCase()) {
      case 'processing':
        bg = _gold.withValues(alpha: 0.18);
        fg = const Color(0xFF946200);
        label = 'Crafting';
        break;
      case 'shipped':
        bg = const Color(0xFF1976D2).withValues(alpha: 0.12);
        fg = const Color(0xFF1976D2);
        label = 'Dispatched';
        break;
      case 'delivered':
        bg = const Color(0xFF2E7D32).withValues(alpha: 0.12);
        fg = const Color(0xFF2E7D32);
        label = 'Delivered';
        break;
      default:
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 11),
      ),
    );
  }

  // ============================================================
  // 6. HERITAGE ADVISORY & TIPS
  // ============================================================
  Widget _buildHeritageAdvisoryCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            _gold.withValues(alpha: 0.18),
            _gold.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: _gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: Color(0xFF8C5C00),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Heritage Market Advisory',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Patrons pay 40% higher for crafts with authentic provenance stories. Use the AI Story Writer to document the traditional motifs and heritage behind your creations.',
                  style: TextStyle(fontSize: 13, height: 1.5, color: _muted),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 380.ms).scale(begin: const Offset(0.97, 0.97));
  }
}
