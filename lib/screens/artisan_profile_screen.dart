import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ArtisanProfileScreen extends StatefulWidget {
  const ArtisanProfileScreen({super.key});

  @override
  State<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends State<ArtisanProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _loading = true;
  bool _editing = false;
  bool _saving = false;

  int _productCount = 0;
  int _orderCount = 0;

  double _totalRevenue = 0;
  double _averageOrderValue = 0;

  int _pendingOrders = 0;
  int _confirmedOrders = 0;
  int _processingOrders = 0;
  int _shippedOrders = 0;
  int _deliveredOrders = 0;
  int _cancelledOrders = 0;

  String _name = 'Artisan';
  String _email = '';
  String _craft = 'Traditional Artisan';
  String _location = 'India';
  String _about =
      'Traditional artisan creating handcrafted products with cultural heritage.';

  late TextEditingController _nameController;
  late TextEditingController _craftController;
  late TextEditingController _locationController;
  late TextEditingController _aboutController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _craftController = TextEditingController();
    _locationController = TextEditingController();
    _aboutController = TextEditingController();

    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _craftController.dispose();
    _locationController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD PROFILE + REAL ANALYTICS
  // ============================================================

  Future<void> _loadProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    try {
      final uid = user.uid;

      // --------------------------------------------------------
      // PROFILE
      // --------------------------------------------------------

      final userDoc = await _db.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() ?? {};

        _name = _readString(data, [
          'name',
          'displayName',
        ], fallback: user.displayName ?? 'Artisan');

        _email = _readString(data, ['email'], fallback: user.email ?? '');

        _craft = _readString(data, [
          'craft',
          'specialization',
        ], fallback: 'Traditional Artisan');

        _location = _readString(data, [
          'location',
          'address',
        ], fallback: 'India');

        _about = _readString(
          data,
          ['about', 'bio', 'description'],
          fallback:
              'Traditional artisan creating handcrafted products with cultural heritage.',
        );
      } else {
        _name = user.displayName ?? 'Artisan';
        _email = user.email ?? '';
      }

      // --------------------------------------------------------
      // REAL PRODUCTS
      //
      // users/{artisanUid}/products/{productId}
      // --------------------------------------------------------

      final productsSnapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('products')
          .get();

      _productCount = productsSnapshot.docs.length;

      // --------------------------------------------------------
      // REAL ORDERS + REVENUE
      //
      // Orders are stored under customer:
      // users/{customerUid}/orders/{orderId}
      //
      // Each order contains:
      // items[].artisanId
      // items[].price
      // items[].quantity
      // --------------------------------------------------------

      int orderCount = 0;
      double revenue = 0;

      int pending = 0;
      int confirmed = 0;
      int processing = 0;
      int shipped = 0;
      int delivered = 0;
      int cancelled = 0;

      try {
        final ordersSnapshot = await _db.collectionGroup('orders').get();

        for (final orderDoc in ordersSnapshot.docs) {
          final data = orderDoc.data();
          final items = data['items'];

          if (items is! List) continue;

          bool belongsToArtisan = false;
          double artisanOrderTotal = 0;

          for (final item in items) {
            if (item is! Map) continue;

            final artisanId =
                (item['artisanId'] ??
                        item['artisanID'] ??
                        item['ownerId'] ??
                        item['userId'] ??
                        '')
                    .toString();

            if (artisanId != uid) continue;

            belongsToArtisan = true;

            double price = 0;
            int quantity = 1;

            final rawPrice = item['price'];
            final rawQuantity = item['quantity'];

            if (rawPrice is num) {
              price = rawPrice.toDouble();
            } else {
              price = double.tryParse(rawPrice?.toString() ?? '0') ?? 0;
            }

            if (rawQuantity is num) {
              quantity = rawQuantity.toInt();
            } else {
              quantity = int.tryParse(rawQuantity?.toString() ?? '1') ?? 1;
            }

            if (quantity < 1) quantity = 1;

            artisanOrderTotal += price * quantity;
          }

          if (!belongsToArtisan) continue;

          orderCount++;

          final status = (data['status'] ?? 'pending')
              .toString()
              .toLowerCase()
              .trim();

          switch (status) {
            case 'confirmed':
              confirmed++;
              break;

            case 'processing':
              processing++;
              break;

            case 'shipped':
              shipped++;
              break;

            case 'delivered':
              delivered++;
              break;

            case 'cancelled':
              cancelled++;
              break;

            default:
              pending++;
          }

          // Cancelled orders are not counted as earned revenue.
          if (status != 'cancelled') {
            revenue += artisanOrderTotal;
          }
        }
      } catch (_) {
        // Keep profile usable even if collectionGroup is unavailable.
      }

      _orderCount = orderCount;
      _totalRevenue = revenue;

      if (orderCount > 0) {
        _averageOrderValue = revenue / orderCount;
      } else {
        _averageOrderValue = 0;
      }

      _pendingOrders = pending;
      _confirmedOrders = confirmed;
      _processingOrders = processing;
      _shippedOrders = shipped;
      _deliveredOrders = delivered;
      _cancelledOrders = cancelled;

      // --------------------------------------------------------
      // CONTROLLERS
      // --------------------------------------------------------

      _nameController.text = _name;
      _craftController.text = _craft;
      _locationController.text = _location;
      _aboutController.text = _about;

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not load profile: $e')));
    }
  }

  String _readString(
    Map<String, dynamic> data,
    List<String> keys, {
    required String fallback,
  }) {
    for (final key in keys) {
      final value = data[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return fallback;
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;

    if (user == null) return;

    setState(() {
      _saving = true;
    });

    try {
      final name = _nameController.text.trim();
      final craft = _craftController.text.trim();
      final location = _locationController.text.trim();
      final about = _aboutController.text.trim();

      final finalName = name.isEmpty ? 'Artisan' : name;

      final finalCraft = craft.isEmpty ? 'Traditional Artisan' : craft;

      final finalLocation = location.isEmpty ? 'India' : location;

      final finalAbout = about.isEmpty
          ? 'Traditional artisan creating handcrafted products with cultural heritage.'
          : about;

      await _db.collection('users').doc(user.uid).set({
        'name': finalName,
        'displayName': finalName,
        'craft': finalCraft,
        'location': finalLocation,
        'about': finalAbout,
        'email': user.email ?? '',
        'role': 'artisan',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      setState(() {
        _name = finalName;
        _craft = finalCraft;
        _location = finalLocation;
        _about = finalAbout;

        _editing = false;
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    }
  }

  void _cancelEdit() {
    _nameController.text = _name;
    _craftController.text = _craft;
    _locationController.text = _location;
    _aboutController.text = _about;

    setState(() {
      _editing = false;
    });
  }

  String get _initial {
    final value = _editing ? _nameController.text.trim() : _name.trim();

    if (value.isEmpty) return 'A';

    return value[0].toUpperCase();
  }

  // ============================================================
  // MAIN UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F7),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF17201E),

        title: const Text(
          'Artisan Profile',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),

        actions: [
          if (!_loading && !_editing)
            IconButton(
              tooltip: 'Edit profile',
              onPressed: () {
                setState(() {
                  _editing = true;
                });
              },
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfile,

              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.all(20),

                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        _buildProfileHeader(),

                        const SizedBox(height: 22),

                        _buildStatsSection(),

                        const SizedBox(height: 22),

                        _buildAnalyticsSection(),

                        const SizedBox(height: 22),

                        _buildMyProductsSection(),

                        const SizedBox(height: 22),

                        _buildMyOrdersSection(),

                        const SizedBox(height: 22),

                        if (_editing)
                          _buildEditSection()
                        else
                          _buildAboutSection(),

                        const SizedBox(height: 22),

                        _buildAccountSection(),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    const primary = Color(0xFF176B5B);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF6F1), Color(0xFFF8FBFA)],
        ),

        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: const Color(0xFFDCEBE5)),
      ),

      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 600;

          final avatar = CircleAvatar(
            radius: 48,
            backgroundColor: primary,

            child: Text(
              _initial,

              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
          );

          final information = Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                _name,

                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF16211E),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                _craft,

                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),

              const SizedBox(height: 9),

              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 17,
                    color: Color(0xFF64736E),
                  ),

                  const SizedBox(width: 5),

                  Expanded(
                    child: Text(
                      _location,

                      style: const TextStyle(
                        color: Color(0xFF64736E),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 7),

              if (_email.isNotEmpty)
                Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 17,
                      color: Color(0xFF64736E),
                    ),

                    const SizedBox(width: 5),

                    Flexible(
                      child: Text(
                        _email,

                        style: const TextStyle(
                          color: Color(0xFF64736E),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          );

          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [avatar, const SizedBox(height: 18), information],
            );
          }

          return Row(
            children: [
              avatar,
              const SizedBox(width: 22),
              Expanded(child: information),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStatsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 600;

        final cards = [
          _statCard(
            icon: Icons.inventory_2_outlined,
            title: 'Products',
            value: _productCount.toString(),
            color: const Color(0xFF176B5B),
          ),

          _statCard(
            icon: Icons.shopping_bag_outlined,
            title: 'Orders',
            value: _orderCount.toString(),
            color: const Color(0xFF8A5A12),
          ),

          _statCard(
            icon: Icons.verified_outlined,
            title: 'Status',
            value: 'Active',
            color: const Color(0xFF287A4A),
          ),
        ];

        if (narrow) {
          return Column(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i != cards.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 14),
            Expanded(child: cards[1]),
            const SizedBox(width: 14),
            Expanded(child: cards[2]),
          ],
        );
      },
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: const Color(0xFFE5ECE9)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon, color: color, size: 24),

          const SizedBox(height: 12),

          Text(
            value,

            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: Color(0xFF17201E),
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,

            style: const TextStyle(
              color: Color(0xFF71807B),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REVENUE & ANALYTICS
  // ============================================================

  Widget _buildAnalyticsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: const Color(0xFFE4EBE8)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,

                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6F1),
                  borderRadius: BorderRadius.circular(13),
                ),

                child: const Icon(
                  Icons.analytics_outlined,
                  color: Color(0xFF176B5B),
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Revenue & Analytics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A2522),
                      ),
                    ),

                    SizedBox(height: 3),

                    Text(
                      'Your real business performance',
                      style: TextStyle(fontSize: 12, color: Color(0xFF71807B)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 600;

              final cards = [
                _analyticsCard(
                  icon: Icons.currency_rupee,
                  title: 'Total Revenue',
                  value: '₹${_totalRevenue.toStringAsFixed(0)}',
                  subtitle: 'Excluding cancelled orders',
                  color: const Color(0xFF176B5B),
                ),

                _analyticsCard(
                  icon: Icons.receipt_long_outlined,
                  title: 'Average Order',
                  value: '₹${_averageOrderValue.toStringAsFixed(0)}',
                  subtitle: 'Average artisan order value',
                  color: const Color(0xFF8A5A12),
                ),
              ];

              if (narrow) {
                return Column(
                  children: [cards[0], const SizedBox(height: 12), cards[1]],
                );
              }

              return Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 12),
                  Expanded(child: cards[1]),
                ],
              );
            },
          ),

          const SizedBox(height: 22),

          const Text(
            'Order Status',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF25312D),
            ),
          ),

          const SizedBox(height: 14),

          _statusProgress(
            label: 'Pending',
            count: _pendingOrders,
            color: Colors.amber.shade800,
          ),

          _statusProgress(
            label: 'Confirmed',
            count: _confirmedOrders,
            color: Colors.blue,
          ),

          _statusProgress(
            label: 'Processing',
            count: _processingOrders,
            color: Colors.orange,
          ),

          _statusProgress(
            label: 'Shipped',
            count: _shippedOrders,
            color: Colors.indigo,
          ),

          _statusProgress(
            label: 'Delivered',
            count: _deliveredOrders,
            color: Colors.green,
          ),

          _statusProgress(
            label: 'Cancelled',
            count: _cancelledOrders,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _analyticsCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFA),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: const Color(0xFFE5ECE9)),
      ),

      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,

            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(icon, color: color, size: 23),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF71807B),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,

                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,

                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF8A9691),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusProgress({
    required String label,
    required int count,
    required Color color,
  }) {
    final total = _orderCount;

    final percentage = total == 0 ? 0.0 : count / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),

      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,

                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  label,

                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF596863),
                  ),
                ),
              ),

              Text(
                '$count',

                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF25312D),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),

            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),

              minHeight: 7,

              backgroundColor: const Color(0xFFEDF2F0),

              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MY PRODUCTS
  // ============================================================

  Widget _buildMyProductsSection() {
    final user = _auth.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: const Color(0xFFE4EBE8)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 22,
                color: Color(0xFF176B5B),
              ),

              const SizedBox(width: 9),

              const Expanded(
                child: Text(
                  'My Products',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A2522),
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6F1),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Text(
                  '$_productCount items',

                  style: const TextStyle(
                    color: Color(0xFF176B5B),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _db
                .collection('users')
                .doc(user.uid)
                .collection('products')
                .snapshots(),

            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(
                  'Unable to load products: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(25),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(25),

                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAF9),
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: const Column(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 42,
                        color: Color(0xFF8A9993),
                      ),

                      SizedBox(height: 10),

                      Text(
                        'No products yet',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        'Your published products will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF71807B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: docs.map((doc) {
                  return _buildProductCard(doc.id, doc.data());
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget _buildProductCard(String id, Map<String, dynamic> data) {
    final name = (data['name'] ?? 'Unnamed Product').toString();

    final category = (data['category'] ?? 'Other').toString();

    final description = (data['description'] ?? '').toString();

    final imageUrl = (data['imageUrl'] ?? '').toString();

    double price = 0;

    final rawPrice = data['price'];

    if (rawPrice is num) {
      price = rawPrice.toDouble();
    } else {
      price = double.tryParse(rawPrice?.toString() ?? '0') ?? 0;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFA),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: const Color(0xFFE5ECE9)),
      ),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),

              child: SizedBox(
                width: 90,
                height: 90,

                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,

                        errorBuilder: (context, error, stackTrace) {
                          return _imagePlaceholder();
                        },
                      )
                    : _imagePlaceholder(),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    name,

                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A2522),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF6F1),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      category,

                      style: const TextStyle(
                        color: Color(0xFF176B5B),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 7),

                  if (description.isNotEmpty)
                    Text(
                      description,

                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: Color(0xFF71807B),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),

                  const SizedBox(height: 8),

                  Text(
                    '₹${price.toStringAsFixed(0)}',

                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF176B5B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFE8EFEC),

      child: const Center(
        child: Icon(Icons.image_outlined, size: 32, color: Color(0xFF7B8984)),
      ),
    );
  }

  // ============================================================
  // MY ORDERS
  // ============================================================

  Widget _buildMyOrdersSection() {
    final user = _auth.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: const Color(0xFFE4EBE8)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 22,
                color: Color(0xFF8A5A12),
              ),

              const SizedBox(width: 9),

              const Expanded(
                child: Text(
                  'My Orders',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A2522),
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4DE),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Text(
                  '$_orderCount orders',

                  style: const TextStyle(
                    color: Color(0xFF8A5A12),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _db.collectionGroup('orders').snapshots(),

            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Unable to load orders.',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(25),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final allOrders = snapshot.data?.docs ?? [];

              final artisanOrders = allOrders.where((doc) {
                final data = doc.data();
                final items = data['items'];

                if (items is! List) {
                  return false;
                }

                for (final item in items) {
                  if (item is! Map) continue;

                  final artisanId =
                      (item['artisanId'] ??
                              item['artisanID'] ??
                              item['ownerId'] ??
                              item['userId'] ??
                              '')
                          .toString();

                  if (artisanId == user.uid) {
                    return true;
                  }
                }

                return false;
              }).toList();

              if (artisanOrders.isEmpty) {
                return Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(25),

                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAF9),
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: const Column(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 42,
                        color: Color(0xFF8A9993),
                      ),

                      SizedBox(height: 10),

                      Text(
                        'No orders yet',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        'Customer orders will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF71807B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: artisanOrders.map((doc) {
                  return _buildOrderCard(doc.id, doc.data(), user.uid);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ORDER CARD
  // ============================================================

  Widget _buildOrderCard(
    String orderId,
    Map<String, dynamic> data,
    String artisanUid,
  ) {
    final status = (data['status'] ?? 'pending').toString();

    final customerId = (data['customerId'] ?? 'Customer').toString();

    final items = data['items'];

    String productName = 'Order';

    if (items is List) {
      for (final item in items) {
        if (item is! Map) continue;

        final artisanId =
            (item['artisanId'] ??
                    item['artisanID'] ??
                    item['ownerId'] ??
                    item['userId'] ??
                    '')
                .toString();

        if (artisanId == artisanUid) {
          productName = (item['name'] ?? 'Product').toString();
          break;
        }
      }
    }

    double artisanTotal = 0;

    if (items is List) {
      for (final item in items) {
        if (item is! Map) continue;

        final artisanId =
            (item['artisanId'] ??
                    item['artisanID'] ??
                    item['ownerId'] ??
                    item['userId'] ??
                    '')
                .toString();

        if (artisanId != artisanUid) continue;

        double price = 0;
        int quantity = 1;

        final rawPrice = item['price'];
        final rawQuantity = item['quantity'];

        if (rawPrice is num) {
          price = rawPrice.toDouble();
        } else {
          price = double.tryParse(rawPrice?.toString() ?? '0') ?? 0;
        }

        if (rawQuantity is num) {
          quantity = rawQuantity.toInt();
        } else {
          quantity = int.tryParse(rawQuantity?.toString() ?? '1') ?? 1;
        }

        artisanTotal += price * quantity;
      }
    }

    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFA),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: const Color(0xFFE5ECE9)),
      ),

      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,

            decoration: BoxDecoration(
              color: const Color(0xFFFFF4DE),
              borderRadius: BorderRadius.circular(14),
            ),

            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xFF8A5A12),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  productName,

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Order #${_shortId(orderId)}',

                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7A8984),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Customer: ${_shortId(customerId)}',

                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7A8984),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,

            children: [
              Text(
                '₹${artisanTotal.toStringAsFixed(0)}',

                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF176B5B),
                ),
              ),

              const SizedBox(height: 6),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),

                decoration: BoxDecoration(
                  color: _statusColor(status).withOpacity(0.12),

                  borderRadius: BorderRadius.circular(20),
                ),

                child: Text(
                  status.toUpperCase(),

                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: _statusColor(status),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _shortId(String value) {
    if (value.length <= 10) {
      return value;
    }

    return value.substring(0, 10);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.blue;

      case 'processing':
        return Colors.orange;

      case 'shipped':
        return Colors.indigo;

      case 'delivered':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      default:
        return Colors.amber.shade800;
    }
  }

  // ============================================================
  // ABOUT
  // ============================================================

  Widget _buildAboutSection() {
    return _sectionCard(
      title: 'About Artisan',
      icon: Icons.person_outline,

      child: Text(
        _about,

        style: const TextStyle(
          height: 1.6,
          fontSize: 15,
          color: Color(0xFF596863),
        ),
      ),
    );
  }

  // ============================================================
  // ACCOUNT INFORMATION
  // ============================================================

  Widget _buildAccountSection() {
    return _sectionCard(
      title: 'Account Information',
      icon: Icons.account_circle_outlined,

      child: Column(
        children: [
          _infoRow(
            Icons.email_outlined,
            'Email',
            _email.isEmpty ? 'Not available' : _email,
          ),

          const Divider(height: 26),

          _infoRow(Icons.category_outlined, 'Craft', _craft),

          const Divider(height: 26),

          _infoRow(Icons.location_on_outlined, 'Location', _location),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: const Color(0xFFE4EBE8)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: const Color(0xFF176B5B)),

              const SizedBox(width: 9),

              Text(
                title,

                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A2522),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 21, color: const Color(0xFF176B5B)),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                title,

                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF82908B),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,

                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF25312D),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EDIT PROFILE
  // ============================================================

  Widget _buildEditSection() {
    const primary = Color(0xFF176B5B);

    return _sectionCard(
      title: 'Edit Profile',
      icon: Icons.edit_outlined,

      child: Column(
        children: [
          _input(
            controller: _nameController,
            label: 'Name',
            icon: Icons.person_outline,
          ),

          const SizedBox(height: 15),

          _input(
            controller: _craftController,
            label: 'Craft / Specialization',
            icon: Icons.category_outlined,
          ),

          const SizedBox(height: 15),

          _input(
            controller: _locationController,
            label: 'Location',
            icon: Icons.location_on_outlined,
          ),

          const SizedBox(height: 15),

          TextField(
            controller: _aboutController,

            maxLines: 5,

            decoration: InputDecoration(
              labelText: 'About',

              alignLabelWithHint: true,

              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 70),

                child: Icon(Icons.description_outlined),
              ),

              filled: true,

              fillColor: const Color(0xFFF7FAF9),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : _cancelEdit,

                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  child: const Text('Cancel'),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveProfile,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,

                    minimumSize: const Size.fromHeight(50),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,

                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Changes',

                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,

      decoration: InputDecoration(
        labelText: label,

        prefixIcon: Icon(icon),

        filled: true,

        fillColor: const Color(0xFFF7FAF9),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
