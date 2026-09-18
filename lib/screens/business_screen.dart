import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool loading = true;

  int productCount = 0;
  int orderCount = 0;
  int pendingOrders = 0;
  int deliveredOrders = 0;

  double totalSales = 0;
  double pendingSales = 0;

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> recentOrders = [];

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
      setState(() {
        loading = false;
      });
      return;
    }

    try {
      // ----------------------------------------------------------
      // PRODUCTS
      // ----------------------------------------------------------

      final productSnapshot = await _db
          .collection('users')
          .doc(user.uid)
          .collection('products')
          .get();

      final loadedProducts = productSnapshot.docs.map((doc) {
        final data = doc.data();

        return {'id': doc.id, ...data};
      }).toList();

      // ----------------------------------------------------------
      // ORDERS
      // ----------------------------------------------------------

      final orderSnapshot = await _db.collectionGroup('orders').get();

      int totalOrders = 0;
      int pending = 0;
      int delivered = 0;

      double sales = 0;
      double pendingAmount = 0;

      final List<Map<String, dynamic>> artisanOrders = [];

      for (final doc in orderSnapshot.docs) {
        final data = doc.data();

        final dynamic rawItems = data['items'];

        if (rawItems is! List) {
          continue;
        }

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

        if (!belongsToArtisan) {
          continue;
        }

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

      // Sort newest first.
      artisanOrders.sort((a, b) {
        final aDate = _timestampToDate(a['createdAt']);
        final bDate = _timestampToDate(b['createdAt']);

        return bDate.compareTo(aDate);
      });

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
      });
    } catch (e) {
      debugPrint('BUSINESS DATA ERROR: $e');

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load business data: $e')),
      );
    }
  }

  // ============================================================
  // DOUBLE CONVERSION
  // ============================================================

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  // ============================================================
  // DATE CONVERSION
  // ============================================================

  DateTime _timestampToDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  // ============================================================
  // BUSINESS HEALTH
  // ============================================================

  String get businessStatus {
    if (productCount == 0) {
      return 'Start adding products';
    }

    if (orderCount == 0) {
      return 'Ready for your first order';
    }

    if (pendingOrders > 0) {
      return 'Orders need attention';
    }

    return 'Business is active';
  }

  IconData get businessStatusIcon {
    if (productCount == 0) {
      return Icons.inventory_2_outlined;
    }

    if (orderCount == 0) {
      return Icons.shopping_bag_outlined;
    }

    if (pendingOrders > 0) {
      return Icons.notifications_active_outlined;
    }

    return Icons.check_circle_outline;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Business Manager'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: loading ? null : loadBusinessData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadBusinessData,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  buildHeader(),

                  const SizedBox(height: 22),

                  buildOverviewSection(),

                  const SizedBox(height: 25),

                  buildBusinessHealth(),

                  const SizedBox(height: 25),

                  buildInsightsSection(),

                  const SizedBox(height: 25),

                  buildRecentOrders(),

                  const SizedBox(height: 25),

                  buildInventorySection(),

                  const SizedBox(height: 25),

                  buildBusinessTip(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget buildHeader() {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withValues(alpha: 0.14),
            primary.withValues(alpha: 0.035),
          ],
        ),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: primary.withValues(alpha: 0.12),
            ),
            child: Icon(Icons.auto_awesome, size: 31, color: primary),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Business Manager',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Your intelligent business companion for managing products, orders and sales.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: primary.withValues(alpha: 0.09),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: primary),
                      const SizedBox(width: 7),
                      Text(
                        'Live business data',
                        style: TextStyle(
                          color: primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
  // OVERVIEW
  // ============================================================

  Widget buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Business Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 14),

        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final cardWidth = width > 650 ? (width - 18) / 2 : width;

            return Wrap(
              spacing: 18,
              runSpacing: 18,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: overviewCard(
                    title: 'Products',
                    value: productCount.toString(),
                    subtitle: 'Published products',
                    icon: Icons.inventory_2_outlined,
                  ),
                ),

                SizedBox(
                  width: cardWidth,
                  child: overviewCard(
                    title: 'Orders',
                    value: orderCount.toString(),
                    subtitle: 'Total orders',
                    icon: Icons.shopping_bag_outlined,
                  ),
                ),

                SizedBox(
                  width: cardWidth,
                  child: overviewCard(
                    title: 'Sales',
                    value: '₹${totalSales.toStringAsFixed(0)}',
                    subtitle: 'Delivered order value',
                    icon: Icons.currency_rupee,
                    highlighted: true,
                  ),
                ),

                SizedBox(
                  width: cardWidth,
                  child: overviewCard(
                    title: 'Pending',
                    value: pendingOrders.toString(),
                    subtitle: 'Orders in progress',
                    icon: Icons.pending_actions,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // OVERVIEW CARD
  // ============================================================

  Widget overviewCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    bool highlighted = false,
  }) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: highlighted
            ? primary.withValues(alpha: 0.07)
            : Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: highlighted
              ? primary.withValues(alpha: 0.30)
              : Colors.grey.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: primary.withValues(alpha: 0.10),
            ),
            child: Icon(icon, color: primary),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUSINESS HEALTH
  // ============================================================

  Widget buildBusinessHealth() {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withValues(alpha: 0.10),
            ),
            child: Icon(businessStatusIcon, color: primary),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Business Status',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),

                const SizedBox(height: 4),

                Text(
                  businessStatus,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
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
  // INSIGHTS
  // ============================================================

  Widget buildInsightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Business Insights',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 14),

        insightCard(
          icon: Icons.trending_up,
          title: 'Demand Forecast',
          description: productCount == 0
              ? 'Add products to start receiving demand insights.'
              : 'Your marketplace products are ready for demand analysis.',
        ),

        insightCard(
          icon: Icons.inventory_2_outlined,
          title: 'Inventory Alert',
          description: productCount == 0
              ? 'Your inventory is currently empty.'
              : '$productCount product${productCount == 1 ? '' : 's'} available in your catalog.',
        ),

        insightCard(
          icon: Icons.currency_rupee,
          title: 'Pricing Insight',
          description:
              'Use the AI Pricing Assistant to calculate prices based on cost, quality and demand.',
        ),

        insightCard(
          icon: Icons.groups_outlined,
          title: 'B2B Opportunities',
          description:
              'Your published products can be presented to larger buyers through the marketplace.',
        ),
      ],
    );
  }

  // ============================================================
  // INSIGHT CARD
  // ============================================================

  Widget insightCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: primary.withValues(alpha: 0.09),
            ),
            child: Icon(icon, color: primary),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    height: 1.45,
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
  // RECENT ORDERS
  // ============================================================

  Widget buildRecentOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Recent Orders',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            if (orderCount > 5)
              Text(
                'Latest 5',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
              ),
          ],
        ),

        const SizedBox(height: 14),

        if (recentOrders.isEmpty)
          emptyCard(
            icon: Icons.shopping_bag_outlined,
            title: 'No orders yet',
            description: 'Orders from customers will appear here.',
          )
        else
          ...recentOrders.map((order) => orderCard(order)),
      ],
    );
  }

  // ============================================================
  // ORDER CARD
  // ============================================================

  Widget orderCard(Map<String, dynamic> order) {
    final status = order['status']?.toString() ?? 'pending';

    final total = _toDouble(order['total']);

    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: primary.withValues(alpha: 0.09),
            ),
            child: Icon(Icons.receipt_long_outlined, color: primary),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order['orderId'] ?? order['id']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),

                Text(
                  '₹${total.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),

          statusBadge(status),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // INVENTORY
  // ============================================================

  Widget buildInventorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Catalog',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 14),

        if (products.isEmpty)
          emptyCard(
            icon: Icons.inventory_2_outlined,
            title: 'No products',
            description:
                'Publish your first product to build your digital catalog.',
          )
        else
          ...products.take(5).map((product) => productCard(product)),
      ],
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget productCard(Map<String, dynamic> product) {
    final name = product['name']?.toString() ?? 'Unnamed Product';

    final category = product['category']?.toString() ?? 'Handicraft';

    final price = _toDouble(product['price']);

    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: primary.withValues(alpha: 0.09),
            ),
            child: Icon(Icons.inventory_2_outlined, color: primary),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  category,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          Text(
            '₹${price.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY CARD
  // ============================================================

  Widget emptyCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.20)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.grey),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 5),

          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUSINESS TIP
  // ============================================================

  Widget buildBusinessTip() {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: primary.withValues(alpha: 0.05),
        border: Border.all(color: primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: primary),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Business Tip',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),

                SizedBox(height: 6),

                Text(
                  'Keep your product catalog updated, use AI pricing recommendations and respond quickly to customer orders to improve your digital business presence.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
