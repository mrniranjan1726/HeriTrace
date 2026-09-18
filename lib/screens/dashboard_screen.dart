import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color primary = Color(0xFF176B5B);
  static const Color background = Color(0xFFF7F8F4);
  static const Color darkText = Color(0xFF17201D);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final email = user?.email ?? 'artisan@heritrace.com';

    final name = email.split('@').first;

    final displayName = name.isEmpty
        ? 'Artisan'
        : name[0].toUpperCase() + name.substring(1);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;

            return Row(
              children: [
                if (isDesktop) _buildSidebar(context),

                Expanded(
                  child: Column(
                    children: [
                      _buildTopBar(context, displayName, isDesktop),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 32 : 18,
                            vertical: 22,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildWelcome(context, displayName)
                                  .animate()
                                  .fadeIn(
                                    duration: 500.ms,
                                    curve: Curves.easeOutCubic,
                                  )
                                  .slideY(begin: -0.06, end: 0),

                              const SizedBox(height: 24),

                              _buildStats()
                                  .animate(delay: 100.ms)
                                  .fadeIn(duration: 450.ms)
                                  .slideY(begin: 0.06, end: 0),

                              const SizedBox(height: 28),

                              _buildSectionTitle(
                                'Manage your business',
                                'Everything you need to grow your craft online',
                              ),

                              const SizedBox(height: 15),

                              _buildBusinessGrid(context, isDesktop)
                                  .animate(delay: 180.ms)
                                  .fadeIn(duration: 500.ms)
                                  .slideY(begin: 0.05, end: 0),

                              const SizedBox(height: 30),

                              _buildOrdersCard(context)
                                  .animate(delay: 260.ms)
                                  .fadeIn(duration: 500.ms)
                                  .slideX(begin: 0.04, end: 0),

                              const SizedBox(height: 24),

                              _buildQuickTips()
                                  .animate(delay: 340.ms)
                                  .fadeIn(duration: 500.ms)
                                  .slideY(begin: 0.05, end: 0),

                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // SIDEBAR
  // ============================================================

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 245,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE6EBE8))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white),
                ),
                const SizedBox(width: 11),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HeriTrace',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: darkText,
                      ),
                    ),
                    Text(
                      'Artisan Studio',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          _sidebarItem(
            context,
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
            selected: true,
            onTap: () {},
          ),

          _sidebarItem(
            context,
            icon: Icons.inventory_2_outlined,
            title: 'My Products',
            onTap: () {
              Navigator.pushNamed(context, '/products');
            },
          ),

          _sidebarItem(
            context,
            icon: Icons.add_box_outlined,
            title: 'Add Product',
            onTap: () {
              Navigator.pushNamed(context, '/add');
            },
          ),

          _sidebarItem(
            context,
            icon: Icons.auto_graph_outlined,
            title: 'AI Pricing',
            onTap: () {
              Navigator.pushNamed(context, '/pricing');
            },
          ),

          _sidebarItem(
            context,
            icon: Icons.receipt_long_outlined,
            title: 'Customer Orders',
            onTap: () {
              Navigator.pushNamed(context, '/artisan-orders');
            },
          ),

          _sidebarItem(
            context,
            icon: Icons.gavel_outlined,
            title: 'Rare Auctions',
            onTap: () {
              Navigator.pushNamed(context, '/artisan-auctions');
            },
          ),

          _sidebarItem(
            context,
            icon: Icons.account_tree_outlined,
            title: 'Heritage Intelligence',
            onTap: () {
              Navigator.pushNamed(context, '/heritage-features');
            },
          ),

          _sidebarItem(
            context,
            icon: Icons.storefront_outlined,
            title: 'Marketplace',
            onTap: () {
              Navigator.pushNamed(context, '/marketplace');
            },
          ),

          _sidebarItem(
            context,
            icon: Icons.business_center_outlined,
            title: 'My Business',
            onTap: () {
              Navigator.pushNamed(context, '/business');
            },
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(18),
            child: OutlinedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 46),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    bool selected = false,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: selected ? const Color(0xFFEAF4F0) : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected ? primary : Colors.grey.shade700,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: selected ? primary : darkText,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
                if (selected)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar(
    BuildContext context,
    String displayName,
    bool isDesktop,
  ) {
    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE7EBE8))),
      ),
      child: Row(
        children: [
          if (!isDesktop)
            IconButton(
              onPressed: () {
                _showMobileMenu(context);
              },
              icon: const Icon(Icons.menu),
            ),

          if (!isDesktop) const SizedBox(width: 5),

          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Artisan Dashboard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                  ),
                ),
                Text(
                  'Manage your craft business',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4F0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                const Text(
                  'Online',
                  style: TextStyle(
                    color: primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/artisan-profile');
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: CircleAvatar(
                radius: 19,
                backgroundColor: const Color(0xFFEAF4F0),
                child: Text(
                  displayName[0].toUpperCase(),
                  style: const TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WELCOME
  // ============================================================

  Widget _buildWelcome(BuildContext context, String displayName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF176B5B), Color(0xFF0F5145)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -45,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ARTISAN STUDIO',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Welcome back, $displayName 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Turn your traditional craft into a thriving digital business.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  _welcomeButton(
                    icon: Icons.add,
                    label: 'Add Product',
                    onTap: () {
                      Navigator.pushNamed(context, '/add');
                    },
                  ),
                  const SizedBox(width: 10),
                  _welcomeButton(
                    icon: Icons.receipt_long_outlined,
                    label: 'View Orders',
                    onTap: () {
                      Navigator.pushNamed(context, '/artisan-orders');
                    },
                    light: true,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _welcomeButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool light = false,
  }) {
    return Material(
      color: light ? Colors.white.withValues(alpha: 0.12) : Colors.white,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: light ? Colors.white : primary),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: light ? Colors.white : primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final columns = width > 800 ? 4 : 2;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: width > 800 ? 2.2 : 1.7,
          children: [
            _statCard(
              icon: Icons.inventory_2_outlined,
              title: 'Products',
              value: '0',
              subtitle: 'Published products',
            ),
            _statCard(
              icon: Icons.receipt_long_outlined,
              title: 'Orders',
              value: '0',
              subtitle: 'Customer orders',
            ),
            _statCard(
              icon: Icons.currency_rupee,
              title: 'Revenue',
              value: '₹0',
              subtitle: 'Total earnings',
            ),
            _statCard(
              icon: Icons.people_outline,
              title: 'Customers',
              value: '0',
              subtitle: 'People reached',
            ),
          ],
        );
      },
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EBE8)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4F0),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: primary, size: 21),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: darkText,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: darkText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  // ============================================================
  // BUSINESS GRID
  // ============================================================

  Widget _buildBusinessGrid(BuildContext context, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 1;

        if (constraints.maxWidth >= 900) {
          columns = 4;
        } else if (constraints.maxWidth >= 550) {
          columns = 2;
        }

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: columns == 1 ? 3.0 : 1.35,
          children: [
            _featureCard(
              context,
              icon: Icons.add_photo_alternate_outlined,
              title: 'Add Product',
              description: 'Create a new product listing',
              onTap: () {
                Navigator.pushNamed(context, '/add');
              },
            ),

            _featureCard(
              context,
              icon: Icons.inventory_2_outlined,
              title: 'My Products',
              description: 'Manage your product catalog',
              onTap: () {
                Navigator.pushNamed(context, '/products');
              },
            ),

            _featureCard(
              context,
              icon: Icons.auto_graph_outlined,
              title: 'AI Pricing',
              description: 'Get intelligent price suggestions',
              onTap: () {
                Navigator.pushNamed(context, '/pricing');
              },
            ),

            _featureCard(
              context,
              icon: Icons.storefront_outlined,
              title: 'Marketplace',
              description: 'Explore the artisan marketplace',
              onTap: () {
                Navigator.pushNamed(context, '/marketplace');
              },
            ),

            _featureCard(
              context,
              icon: Icons.gavel_outlined,
              title: 'Rare Auctions',
              description: 'Run live bidding for unique crafts',
              onTap: () {
                Navigator.pushNamed(context, '/artisan-auctions');
              },
            ),
          ],
        );
      },
    );
  }

  Widget _featureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: primary),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ORDERS CARD
  // ============================================================

  Widget _buildOrdersCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7EBE8)),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: primary,
              size: 27,
            ),
          ),

          const SizedBox(width: 15),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Orders',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: darkText,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'View purchases from customers and update order status.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          FilledButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/artisan-orders');
            },
            icon: const Icon(Icons.arrow_forward, size: 17),
            label: const Text('View Orders'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK TIPS
  // ============================================================

  Widget _buildQuickTips() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.lightbulb_outline, color: primary),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip for better sales',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                SizedBox(height: 5),
                Text(
                  'Add clear product photos, accurate descriptions and AI-assisted pricing to make your products easier for customers to discover.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
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

  // ============================================================
  // MOBILE MENU
  // ============================================================

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 5, 15, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _mobileMenuItem(
                  context,
                  Icons.dashboard_outlined,
                  'Dashboard',
                  () {
                    Navigator.pop(context);
                  },
                ),

                _mobileMenuItem(
                  context,
                  Icons.inventory_2_outlined,
                  'My Products',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/products');
                  },
                ),

                _mobileMenuItem(
                  context,
                  Icons.add_box_outlined,
                  'Add Product',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/add');
                  },
                ),

                _mobileMenuItem(
                  context,
                  Icons.auto_graph_outlined,
                  'AI Pricing',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/pricing');
                  },
                ),

                _mobileMenuItem(
                  context,
                  Icons.receipt_long_outlined,
                  'Customer Orders',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/artisan-orders');
                  },
                ),

                _mobileMenuItem(
                  context,
                  Icons.storefront_outlined,
                  'Marketplace',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/marketplace');
                  },
                ),

                _mobileMenuItem(
                  context,
                  Icons.business_center_outlined,
                  'My Business',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/business');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _mobileMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }
}
