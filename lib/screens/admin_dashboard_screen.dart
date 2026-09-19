import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'heritage_features_screen.dart';
import '../widgets/support_chatbot.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  int _selectedIndex = 0;
  String _searchQuery = '';
  bool _isRefreshing = false;

  final Color background = const Color(0xFFF5F7F5);
  final Color dark = const Color(0xFF17221E);
  final Color green = const Color(0xFFA24B2A);
  final Color lightGreen = const Color(0xFFE2F2EC);
  final Color muted = const Color(0xFF6B756F);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _isRefreshing = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800;

    return Scaffold(
      backgroundColor: background,
      floatingActionButton: const SupportChatbot(role: 'admin'),
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(isMobile),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _buildCurrentPage(isMobile),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile ? _buildMobileNavigation() : null,
    );
  }

  // ============================================================
  // SIDEBAR
  // ============================================================

  Widget _buildSidebar() {
    return Container(
      width: 255,
      decoration: BoxDecoration(
        color: const Color(0xFF14201C),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 25,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 25),

            // LOGO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF49A78D), Color(0xFFA24B2A)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HeriTrace',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'ADMIN CENTER',
                        style: TextStyle(
                          color: Color(0xFF7F958D),
                          fontSize: 9,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            _sidebarItem(0, Icons.dashboard_rounded, 'Dashboard'),

            _sidebarItem(1, Icons.people_alt_rounded, 'Users'),

            _sidebarItem(2, Icons.inventory_2_rounded, 'Products'),

            _sidebarItem(3, Icons.shopping_bag_rounded, 'Orders'),

            _sidebarItem(4, Icons.analytics_rounded, 'Analytics'),

            _sidebarItem(
              5,
              Icons.account_tree_rounded,
              'Heritage Intelligence',
            ),

            const Spacer(),

            // ADMIN PROFILE
            Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.admin_panel_settings_rounded,
                      color: green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Administrator',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Platform Admin',
                          style: TextStyle(
                            color: Color(0xFF84958F),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
              child: InkWell(
                onTap: _logout,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 13,
                    horizontal: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFFF8C8C),
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Color(0xFFFFA0A0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebarItem(int index, IconData icon, String title) {
    final selected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
            _searchQuery = '';
          });
        },
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF24584C) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : const Color(0xFF8B9B95),
                size: 21,
              ),
              const SizedBox(width: 13),
              Text(
                title,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF9AA8A3),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar(bool isMobile) {
    return Container(
      height: 78,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          if (isMobile)
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.shield_rounded, color: green),
            ),

          if (isMobile) const SizedBox(width: 12),

          Expanded(
            child: Text(
              _pageTitle(),
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.w800,
                color: dark,
              ),
            ),
          ),

          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4F2),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF33423C),
                  ),
                ),
                Positioned(
                  top: 9,
                  right: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          if (!isMobile)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user_rounded, size: 17, color: green),
                  const SizedBox(width: 7),
                  Text(
                    'Admin',
                    style: TextStyle(
                      color: green,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(width: 10),

          InkWell(
            onTap: () => Navigator.pushNamed(context, '/admin-profile'),
            borderRadius: BorderRadius.circular(13),
            child: const CircleAvatar(
              radius: 21,
              backgroundColor: Color(0xFFE2F2EC),
              child: Icon(
                Icons.admin_panel_settings_rounded,
                color: Color(0xFFA24B2A),
              ),
            ),
          ),

          const SizedBox(width: 10),

          InkWell(
            onTap: _refresh,
            borderRadius: BorderRadius.circular(13),
            child: Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4F2),
                borderRadius: BorderRadius.circular(13),
              ),
              child: _isRefreshing
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded, color: Color(0xFF33423C)),
            ),
          ),
        ],
      ),
    );
  }

  String _pageTitle() {
    switch (_selectedIndex) {
      case 1:
        return 'User Management';
      case 2:
        return 'Product Management';
      case 3:
        return 'Order Management';
      case 4:
        return 'Platform Analytics';
      default:
        return 'Admin Dashboard';
    }
  }

  // ============================================================
  // CURRENT PAGE
  // ============================================================

  Widget _buildCurrentPage(bool isMobile) {
    switch (_selectedIndex) {
      case 1:
        return _buildUsersPage();
      case 2:
        return _buildProductsPage();
      case 3:
        return _buildOrdersPage();
      case 4:
        return _buildAnalyticsPage();
      case 5:
        return const HeritageFeaturesScreen();
      default:
        return _buildDashboardPage(isMobile);
    }
  }

  // ============================================================
  // DASHBOARD
  // ============================================================

  Widget _buildDashboardPage(bool isMobile) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, userSnapshot) {
        final users = userSnapshot.data?.docs ?? [];

        final artisans = users
            .where((u) => u.data()['role'] == 'artisan')
            .length;

        final customers = users
            .where((u) => u.data()['role'] == 'customer')
            .length;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collectionGroup('products')
              .snapshots(),
          builder: (context, productSnapshot) {
            final products = productSnapshot.data?.docs ?? [];

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('orders')
                  .snapshots(),
              builder: (context, orderSnapshot) {
                final orders = orderSnapshot.data?.docs ?? [];

                double revenue = 0;

                for (final order in orders) {
                  final data = order.data();
                  final value = data['total'];

                  if (value is num) {
                    revenue += value.toDouble();
                  }
                }

                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.easeOut,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 16 : 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroSection(
                          users.length,
                          products.length,
                          orders.length,
                        ),

                        const SizedBox(height: 24),

                        _buildStatsGrid(
                          users.length,
                          artisans,
                          customers,
                          products.length,
                          orders.length,
                          revenue,
                          isMobile,
                        ),

                        const SizedBox(height: 28),

                        _buildDashboardLowerSection(
                          users,
                          orders,
                          products,
                          isMobile,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildHeroSection(int users, int products, int orders) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF173E35), Color(0xFFA24B2A), Color(0xFF2D8A74)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: green.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.circle, color: Color(0xFF75E5B8), size: 8),
                          SizedBox(width: 6),
                          Text(
                            'PLATFORM ONLINE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Welcome, Administrator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Monitor artisans, customers, products and orders from one place.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _miniHeroStat('$users', 'Users'),
                    const SizedBox(width: 25),
                    _miniHeroStat('$products', 'Products'),
                    const SizedBox(width: 25),
                    _miniHeroStat('$orders', 'Orders'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            width: 105,
            height: 105,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.09),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 52,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniHeroStat(String value, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  Widget _buildStatsGrid(
    int users,
    int artisans,
    int customers,
    int products,
    int orders,
    double revenue,
    bool isMobile,
  ) {
    final cards = [
      _statCard(
        'Registered Users',
        '$users',
        Icons.people_alt_rounded,
        const Color(0xFFA24B2A),
      ),
      _statCard(
        'Artisans',
        '$artisans',
        Icons.handyman_rounded,
        const Color(0xFF8A5B1E),
      ),
      _statCard(
        'Customers',
        '$customers',
        Icons.shopping_bag_rounded,
        const Color(0xFF5366A3),
      ),
      _statCard(
        'Products',
        '$products',
        Icons.inventory_2_rounded,
        const Color(0xFF8A4F83),
      ),
      _statCard(
        'Orders',
        '$orders',
        Icons.receipt_long_rounded,
        const Color(0xFF9A5437),
      ),
      _statCard(
        'Revenue',
        '₹${revenue.toStringAsFixed(0)}',
        Icons.currency_rupee_rounded,
        const Color(0xFF39724C),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int columns;

        if (constraints.maxWidth < 600) {
          columns = 2;
        } else if (constraints.maxWidth < 1000) {
          columns = 3;
        } else {
          columns = 6;
        }

        final itemWidth =
            (constraints.maxWidth - ((columns - 1) * 14)) / columns;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: cards
              .map((card) => SizedBox(width: itemWidth, child: card))
              .toList(),
        );
      },
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3E9E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              color: dark,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: TextStyle(
              color: muted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DASHBOARD LOWER SECTION
  // ============================================================

  Widget _buildDashboardLowerSection(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> users,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> orders,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> products,
    bool isMobile,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 850) {
          return Column(
            children: [
              _buildRecentUsers(users),
              const SizedBox(height: 20),
              _buildRecentOrders(orders),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildRecentUsers(users)),
            const SizedBox(width: 20),
            Expanded(child: _buildRecentOrders(orders)),
          ],
        );
      },
    );
  }

  Widget _buildRecentUsers(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> users,
  ) {
    final recent = users.reversed.take(5).toList();

    return _sectionCard(
      title: 'Recent Users',
      icon: Icons.people_alt_rounded,
      child: recent.isEmpty
          ? _emptyState('No users registered yet.')
          : Column(
              children: recent
                  .map((user) => _userRow(user.data(), user.id))
                  .toList(),
            ),
    );
  }

  Widget _buildRecentOrders(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> orders,
  ) {
    final recent = orders.reversed.take(5).toList();

    return _sectionCard(
      title: 'Recent Orders',
      icon: Icons.receipt_long_rounded,
      child: recent.isEmpty
          ? _emptyState('No orders available yet.')
          : Column(
              children: recent
                  .map((order) => _orderRow(order.data(), order.id))
                  .toList(),
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
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE3E9E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: green, size: 19),
              ),
              const SizedBox(width: 11),
              Text(
                title,
                style: TextStyle(
                  color: dark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
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

  // ============================================================
  // USERS PAGE
  // ============================================================

  Widget _buildUsersPage() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loading();
        }

        final users = snapshot.data?.docs ?? [];

        final filtered = users.where((user) {
          final data = user.data();

          final email = (data['email'] ?? '').toString().toLowerCase();

          final role = (data['role'] ?? '').toString().toLowerCase();

          return email.contains(_searchQuery.toLowerCase()) ||
              role.contains(_searchQuery.toLowerCase());
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pageHeader(
                'Manage Users',
                'View and monitor every HeriTrace account.',
                Icons.people_alt_rounded,
              ),

              const SizedBox(height: 22),

              _searchBox('Search by email or role...'),

              const SizedBox(height: 20),

              _userSummary(users),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                decoration: _boxDecoration(),
                child: filtered.isEmpty
                    ? _emptyState('No matching users found.')
                    : Column(
                        children: filtered
                            .map((user) => _userManagementRow(user))
                            .toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _userSummary(List<QueryDocumentSnapshot<Map<String, dynamic>>> users) {
    final artisans = users.where((u) => u.data()['role'] == 'artisan').length;

    final customers = users.where((u) => u.data()['role'] == 'customer').length;

    final admins = users.where((u) => u.data()['role'] == 'admin').length;

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        _smallSummary('All Users', users.length, Icons.people_rounded),
        _smallSummary('Artisans', artisans, Icons.handyman_rounded),
        _smallSummary('Customers', customers, Icons.shopping_bag_rounded),
        _smallSummary('Admins', admins, Icons.admin_panel_settings_rounded),
      ],
    );
  }

  Widget _smallSummary(String title, int value, IconData icon) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E9E5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: green),
          const SizedBox(width: 11),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: TextStyle(
                  color: dark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(title, style: TextStyle(color: muted, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _userManagementRow(QueryDocumentSnapshot<Map<String, dynamic>> user) {
    final data = user.data();

    final email = (data['email'] ?? 'Unknown').toString();

    final role = (data['role'] ?? 'unknown').toString();

    final status = (data['status'] ?? 'active').toString();

    final isActive = status != 'suspended';

    return InkWell(
      onTap: () {
        _showUserDetails(user.id, data);
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            _avatarForRole(role),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    email,
                    style: TextStyle(color: dark, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'UID: ${user.id}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: muted, fontSize: 10),
                  ),
                ],
              ),
            ),

            _roleBadge(role),

            const SizedBox(width: 10),

            _statusBadge(isActive),

            const SizedBox(width: 8),

            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'view') {
                  _showUserDetails(user.id, data);
                }

                if (value == 'toggle') {
                  _toggleUserStatus(user.id, isActive);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'view', child: Text('View Details')),
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(isActive ? 'Suspend User' : 'Activate User'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _userRow(Map<String, dynamic> data, String uid) {
    final role = (data['role'] ?? 'unknown').toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          _avatarForRole(role),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['email'] ?? 'Unknown',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: dark,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  role.toUpperCase(),
                  style: TextStyle(color: muted, fontSize: 9),
                ),
              ],
            ),
          ),
          _roleBadge(role),
        ],
      ),
    );
  }

  Widget _avatarForRole(String role) {
    IconData icon;

    Color color;

    switch (role) {
      case 'artisan':
        icon = Icons.handyman_rounded;
        color = const Color(0xFF8A5B1E);
        break;
      case 'customer':
        icon = Icons.shopping_bag_rounded;
        color = const Color(0xFF5366A3);
        break;
      default:
        icon = Icons.admin_panel_settings_rounded;
        color = green;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _roleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          color: green,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _statusBadge(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE5F6EA) : const Color(0xFFFFE7E7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        active ? 'ACTIVE' : 'SUSPENDED',
        style: TextStyle(
          color: active ? const Color(0xFF2D7B46) : Colors.red,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCTS PAGE
  // ============================================================

  Widget _buildProductsPage() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collectionGroup('products')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loading();
        }

        final products = snapshot.data?.docs ?? [];

        final filtered = products.where((product) {
          final data = product.data();

          final name = (data['name'] ?? '').toString().toLowerCase();

          final category = (data['category'] ?? '').toString().toLowerCase();

          return name.contains(_searchQuery.toLowerCase()) ||
              category.contains(_searchQuery.toLowerCase());
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pageHeader(
                'Product Moderation',
                'Review products published by artisans.',
                Icons.inventory_2_rounded,
              ),

              const SizedBox(height: 22),

              _buildAdminProductSummary(products),

              const SizedBox(height: 20),

              _searchBox('Search products or categories...'),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                decoration: _boxDecoration(),
                child: filtered.isEmpty
                    ? _emptyState('No products available.')
                    : Column(
                        children: filtered
                            .map((product) => _productManagementRow(product))
                            .toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdminProductSummary(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> products,
  ) {
    final pending = products
        .where(
          (product) => (product.data()['status'] ?? 'approved') == 'pending',
        )
        .length;
    final approved = products
        .where(
          (product) => (product.data()['status'] ?? 'approved') == 'approved',
        )
        .length;

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        _smallSummary(
          'Total products',
          products.length,
          Icons.inventory_2_outlined,
        ),
        _smallSummary(
          'Pending review',
          pending,
          Icons.pending_actions_outlined,
        ),
        _smallSummary('Approved', approved, Icons.verified_outlined),
      ],
    );
  }

  Widget _productManagementRow(
    QueryDocumentSnapshot<Map<String, dynamic>> product,
  ) {
    final data = product.data();

    final name = (data['name'] ?? 'Unnamed Product').toString();

    final category = (data['category'] ?? 'General').toString();

    final price = data['price'] is num
        ? (data['price'] as num).toDouble()
        : 0.0;

    final artisanId =
        (data['artisanId'] ?? product.reference.parent.parent?.id ?? '')
            .toString();

    final status = (data['status'] ?? 'approved').toString();
    final imageUrl = (data['imageUrl'] ?? '').toString();

    final isPending = status == 'pending';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: SizedBox(
              width: 55,
              height: 55,
              child: imageUrl.isEmpty
                  ? Container(
                      color: lightGreen,
                      child: const Icon(
                        Icons.handyman_outlined,
                        color: Color(0xFF4B766A),
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: lightGreen,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: Color(0xFF4B766A),
                        ),
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(color: dark, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(category, style: TextStyle(color: muted, fontSize: 11)),
                const SizedBox(height: 4),
                Text(
                  'Artisan: ${artisanId.isEmpty ? 'Unknown' : artisanId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: muted, fontSize: 9),
                ),
              ],
            ),
          ),

          Text(
            '₹${price.toStringAsFixed(0)}',
            style: TextStyle(
              color: dark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(width: 15),

          if (isPending)
            Row(
              children: [
                _actionButton(
                  'Approve',
                  Icons.check_rounded,
                  const Color(0xFF287B4A),
                  () => _updateProductStatus(product.reference, 'approved'),
                ),
                const SizedBox(width: 7),
                _actionButton(
                  'Reject',
                  Icons.close_rounded,
                  Colors.red,
                  () => _updateProductStatus(product.reference, 'rejected'),
                ),
              ],
            )
          else
            _productStatusBadge(status),
        ],
      ),
    );
  }

  Widget _productStatusBadge(String status) {
    final approved = status == 'approved';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: approved ? const Color(0xFFE5F6EA) : const Color(0xFFFFE7E7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: approved ? const Color(0xFF287B4A) : Colors.red,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _actionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ORDERS PAGE
  // ============================================================

  Widget _buildOrdersPage() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collectionGroup('orders').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loading();
        }

        final orders = snapshot.data?.docs ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pageHeader(
                'Order Management',
                'Monitor every marketplace order.',
                Icons.receipt_long_rounded,
              ),

              const SizedBox(height: 22),

              _searchBox('Search by order ID or customer...'),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                decoration: _boxDecoration(),
                child: orders.isEmpty
                    ? _emptyState('No orders available.')
                    : Column(
                        children: orders
                            .where((order) {
                              final data = order.data();

                              final orderId = (data['orderId'] ?? order.id)
                                  .toString()
                                  .toLowerCase();

                              final customer = (data['customerId'] ?? '')
                                  .toString()
                                  .toLowerCase();

                              return orderId.contains(
                                    _searchQuery.toLowerCase(),
                                  ) ||
                                  customer.contains(_searchQuery.toLowerCase());
                            })
                            .map((order) => _orderManagementRow(order))
                            .toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _orderManagementRow(
    QueryDocumentSnapshot<Map<String, dynamic>> order,
  ) {
    final data = order.data();

    final orderId = (data['orderId'] ?? order.id).toString();

    final customer = (data['customerId'] ?? 'Unknown').toString();

    final total = data['total'] is num
        ? (data['total'] as num).toDouble()
        : 0.0;

    final status = (data['status'] ?? 'pending').toString();

    final items = data['items'] is List ? (data['items'] as List).length : 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.shopping_bag_rounded, color: green, size: 21),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #$orderId',
                  style: TextStyle(color: dark, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Customer: $customer',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: muted, fontSize: 10),
                ),
              ],
            ),
          ),

          Text(
            '$items item${items == 1 ? '' : 's'}',
            style: TextStyle(color: muted, fontSize: 11),
          ),

          const SizedBox(width: 18),

          Text(
            '₹${total.toStringAsFixed(0)}',
            style: TextStyle(color: dark, fontWeight: FontWeight.w800),
          ),

          const SizedBox(width: 15),

          _orderStatusDropdown(order.reference, status),
        ],
      ),
    );
  }

  Widget _orderStatusDropdown(
    DocumentReference<Map<String, dynamic>> reference,
    String status,
  ) {
    const statuses = [
      'pending',
      'confirmed',
      'processing',
      'shipped',
      'delivered',
      'cancelled',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5F3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: statuses.contains(status) ? status : 'pending',
          isDense: true,
          items: statuses
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item.toUpperCase(),
                    style: TextStyle(
                      color: dark,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              reference.update({'status': value});
            }
          },
        ),
      ),
    );
  }

  Widget _orderRow(Map<String, dynamic> data, String orderId) {
    final total = data['total'] is num
        ? (data['total'] as num).toDouble()
        : 0.0;

    final status = (data['status'] ?? 'pending').toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(Icons.receipt_long_rounded, color: green, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '#$orderId',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: dark,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
          Text(
            '₹${total.toStringAsFixed(0)}',
            style: TextStyle(
              color: dark,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 8),
          _compactStatus(status),
        ],
      ),
    );
  }

  Widget _compactStatus(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: green,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // ANALYTICS
  // ============================================================

  Widget _buildAnalyticsPage() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, userSnapshot) {
        final users = userSnapshot.data?.docs ?? [];

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collectionGroup('products')
              .snapshots(),
          builder: (context, productSnapshot) {
            final products = productSnapshot.data?.docs ?? [];

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('orders')
                  .snapshots(),
              builder: (context, orderSnapshot) {
                final orders = orderSnapshot.data?.docs ?? [];

                double revenue = 0;
                int delivered = 0;
                int pending = 0;
                int cancelled = 0;

                for (final order in orders) {
                  final data = order.data();

                  if (data['total'] is num) {
                    revenue += (data['total'] as num).toDouble();
                  }

                  final status = data['status'];

                  if (status == 'delivered') {
                    delivered++;
                  } else if (status == 'pending') {
                    pending++;
                  } else if (status == 'cancelled') {
                    cancelled++;
                  }
                }

                final artisans = users
                    .where((u) => u.data()['role'] == 'artisan')
                    .length;

                final customers = users
                    .where((u) => u.data()['role'] == 'customer')
                    .length;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _pageHeader(
                        'Platform Analytics',
                        'Live overview of marketplace performance.',
                        Icons.analytics_rounded,
                      ),

                      const SizedBox(height: 25),

                      Wrap(
                        spacing: 15,
                        runSpacing: 15,
                        children: [
                          _analyticsCard(
                            'Total Users',
                            '${users.length}',
                            Icons.people_alt_rounded,
                          ),
                          _analyticsCard(
                            'Artisans',
                            '$artisans',
                            Icons.handyman_rounded,
                          ),
                          _analyticsCard(
                            'Customers',
                            '$customers',
                            Icons.shopping_bag_rounded,
                          ),
                          _analyticsCard(
                            'Products',
                            '${products.length}',
                            Icons.inventory_2_rounded,
                          ),
                          _analyticsCard(
                            'Total Orders',
                            '${orders.length}',
                            Icons.receipt_long_rounded,
                          ),
                          _analyticsCard(
                            'Revenue',
                            '₹${revenue.toStringAsFixed(0)}',
                            Icons.currency_rupee_rounded,
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      _buildOrderAnalytics(
                        orders.length,
                        delivered,
                        pending,
                        cancelled,
                      ),

                      const SizedBox(height: 25),

                      _buildPlatformHealth(
                        users.length,
                        products.length,
                        orders.length,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _analyticsCard(String title, String value, IconData icon) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(21),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: green, size: 25),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              color: dark,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: muted, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildOrderAnalytics(
    int total,
    int delivered,
    int pending,
    int cancelled,
  ) {
    return _sectionCard(
      title: 'Order Performance',
      icon: Icons.trending_up_rounded,
      child: Column(
        children: [
          _progressRow('Delivered', delivered, total, const Color(0xFF2D7B46)),
          const SizedBox(height: 15),
          _progressRow('Pending', pending, total, const Color(0xFFB67A22)),
          const SizedBox(height: 15),
          _progressRow('Cancelled', cancelled, total, Colors.red),
        ],
      ),
    );
  }

  Widget _progressRow(String title, int value, int total, Color color) {
    final percentage = total == 0 ? 0.0 : value / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: dark,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            Text(
              '$value',
              style: TextStyle(color: dark, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 9,
            backgroundColor: const Color(0xFFE8ECE9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformHealth(int users, int products, int orders) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE7F5EF), Color(0xFFF7FBF9)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD4E9DF)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.health_and_safety_rounded,
              color: green,
              size: 27,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Platform Health',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF17221E),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'HeriTrace marketplace is operating normally.',
                  style: TextStyle(color: Color(0xFF6B756F), fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F4E7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'HEALTHY',
              style: TextStyle(
                color: Color(0xFF287B4A),
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _searchBox(String hint) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE0E6E2)),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: muted, fontSize: 12),
          prefixIcon: Icon(Icons.search_rounded, color: muted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _pageHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFA24B2A), Color(0xFF32977F)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white, size: 25),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: dark,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: muted, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // USER DETAILS
  // ============================================================

  void _showUserDetails(String uid, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'User Details',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: SizedBox(
            width: 430,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Email', (data['email'] ?? 'N/A').toString()),
                _detailRow('Role', (data['role'] ?? 'N/A').toString()),
                _detailRow('Status', (data['status'] ?? 'active').toString()),
                _detailRow('UID', uid),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: green)),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: muted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: TextStyle(
              color: dark,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FIRESTORE ACTIONS
  // ============================================================

  Future<void> _toggleUserStatus(String uid, bool currentlyActive) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'status': currentlyActive ? 'suspended' : 'active',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentlyActive
                ? 'User marked as suspended.'
                : 'User marked as active.',
          ),
        ),
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _updateProductStatus(
    DocumentReference<Map<String, dynamic>> reference,
    String status,
  ) async {
    try {
      await reference.update({
        'status': status,
        'moderatedAt': FieldValue.serverTimestamp(),
        'moderatedBy': FirebaseAuth.instance.currentUser?.uid,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'approved'
                ? 'Product approved successfully.'
                : 'Product rejected.',
          ),
        ),
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        content: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  // ============================================================
  // MOBILE NAVIGATION
  // ============================================================

  Widget _buildMobileNavigation() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
          _searchQuery = '';
        });
      },
      backgroundColor: Colors.white,
      indicatorColor: lightGreen,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline_rounded),
          selectedIcon: Icon(Icons.people_alt_rounded),
          label: 'Users',
        ),
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2_rounded),
          label: 'Products',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long_rounded),
          label: 'Orders',
        ),
        NavigationDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics_rounded),
          label: 'Stats',
        ),
      ],
    );
  }

  // ============================================================
  // COMMON UI
  // ============================================================

  Widget _loading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: green),
          const SizedBox(height: 15),
          Text(
            'Loading HeriTrace data...',
            style: TextStyle(color: muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String text) {
    return Padding(
      padding: const EdgeInsets.all(35),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, color: Colors.grey.shade400, size: 42),
            const SizedBox(height: 10),
            Text(text, style: TextStyle(color: muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFE3E9E5)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.025),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}
