import 'dart:math' as math;

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
  static const _background = Color(0xFFF4EFE7);
  static const _surface = Color(0xFFFFFCF7);
  static const _surfaceRaised = Color(0xFFECE1D2);
  static const _primaryText = Color(0xFF1D2A24);
  static const _secondaryText = Color(0xFF68746D);
  static const _accent = Color(0xFFA24B2A);
  final TextEditingController _searchController = TextEditingController();
  late final AnimationController _motionController;

  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Handicrafts',
    'Textiles',
    'Jewellery',
    'Pottery',
    'Woodwork',
    'Paintings',
    'Home Decor',
  ];

  final Color primary = const Color(0xFFA24B2A);

  User? get _user => FirebaseAuth.instance.currentUser;

  CollectionReference<Map<String, dynamic>> get _cartCollection {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_user?.uid)
        .collection('cart');
  }

  CollectionReference<Map<String, dynamic>> get _wishlistCollection {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_user?.uid)
        .collection('wishlist');
  }

  @override
  void initState() {
    super.initState();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to continue.')),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: _background,
        cardColor: _surface,
        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
          filled: true,
          fillColor: _surface,
          hintStyle: const TextStyle(color: _secondaryText),
          prefixIconColor: _accent,
          suffixIconColor: _secondaryText,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD9D0C4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _accent, width: 1.5),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: _background,
        floatingActionButton: const SupportChatbot(role: 'customer'),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildHeader(context),

              SliverToBoxAdapter(
                child:
                    AnimatedBuilder(
                          animation: _motionController,
                          builder: (context, child) => _buildWelcomeSection(
                            context: context,
                            motion: _motionController.value,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 550.ms, curve: Curves.easeOutCubic)
                        .slideY(
                          begin: -0.08,
                          end: 0,
                          duration: 550.ms,
                          curve: Curves.easeOutCubic,
                        ),
              ),

              SliverToBoxAdapter(
                child: _buildSearchBar()
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    ),
              ),

              SliverToBoxAdapter(
                child: _buildCategories()
                    .animate(delay: 180.ms)
                    .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
                    .slideX(
                      begin: 0.06,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                            child: Text(
                              'Explore Artisan Products',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: _primaryText,
                              ),
                            ),
                          )
                          .animate(delay: 240.ms)
                          .fadeIn(duration: 450.ms, curve: Curves.easeOutCubic),
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collectionGroup('products')
                            .snapshots(),
                        builder: (context, snapshot) {
                          final count = snapshot.data?.docs.length ?? 0;

                          return Text(
                            '$count products',
                            style: TextStyle(
                              color: _secondaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              _buildProductGrid(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  SliverAppBar _buildHeader(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 560;
    return SliverAppBar(
      pinned: true,
      backgroundColor: _background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 70,
      titleSpacing: 20,
      title: Row(
        children: [
          AnimatedBuilder(
            animation: _motionController,
            builder: (context, child) {
              final wave =
                  (math.sin(_motionController.value * math.pi * 2) + 1) / 2;
              return Transform.rotate(
                angle: wave * 0.08 - 0.04,
                child: Transform.scale(scale: 1 + wave * 0.04, child: child),
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(13),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33176B5B),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: _surfaceRaised,
                size: 22,
              ),
            ),
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
                  color: _primaryText,
                ),
              ),
              Text(
                'Crafted by heritage',
                style: TextStyle(
                  fontSize: 10,
                  color: _secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Orders
        IconButton(
          tooltip: 'Rare Auctions',
          onPressed: () {
            Navigator.pushNamed(context, '/customer-auctions');
          },
          icon: AnimatedBuilder(
            animation: _motionController,
            builder: (context, child) {
              final pulse =
                  (math.sin(_motionController.value * math.pi * 2) + 1) / 2;
              return Transform.scale(scale: 1 + pulse * 0.08, child: child);
            },
            child: const Icon(Icons.gavel_outlined, color: _accent),
          ),
        ),

        if (!isCompact) ...[
          IconButton(
            tooltip: 'My Orders',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomerOrdersScreen()),
              );
            },
            icon: const Icon(Icons.receipt_long_outlined, color: _primaryText),
          ),
          IconButton(
            tooltip: 'Wishlist',
            onPressed: () {
              Navigator.pushNamed(context, '/customer-wishlist');
            },
            icon: const Icon(Icons.favorite_border, color: _primaryText),
          ),
        ],

        // Cart
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _cartCollection.snapshots(),
          builder: (context, snapshot) {
            final count = snapshot.data?.docs.length ?? 0;

            return Stack(
              children: [
                IconButton(
                  tooltip: 'Cart',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomerCartScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: _primaryText,
                  ),
                ),

                if (count > 0)
                  Positioned(
                    right: 5,
                    top: 5,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _background, width: 2),
                      ),
                      child: Text(
                        '$count',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _surface,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

        if (!isCompact)
          IconButton(
            tooltip: 'Profile & Settings',
            onPressed: () {
              Navigator.pushNamed(context, '/customer-profile');
            },
            icon: const Icon(
              Icons.account_circle_outlined,
              color: _primaryText,
            ),
          ),
        if (!isCompact)
          IconButton(
            tooltip: 'Heritage Intelligence',
            onPressed: () {
              Navigator.pushNamed(context, '/heritage-features');
            },
            icon: const Icon(Icons.account_tree_outlined, color: _accent),
          ),
        if (isCompact)
          PopupMenuButton<String>(
            tooltip: 'More customer options',
            icon: const Icon(Icons.more_vert, color: _primaryText),
            color: _surface,
            onSelected: (value) {
              switch (value) {
                case 'orders':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CustomerOrdersScreen(),
                    ),
                  );
                case 'wishlist':
                  Navigator.pushNamed(context, '/customer-wishlist');
                case 'profile':
                  Navigator.pushNamed(context, '/customer-profile');
                case 'heritage':
                  Navigator.pushNamed(context, '/heritage-features');
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'orders',
                child: ListTile(
                  leading: Icon(Icons.receipt_long_outlined, color: _accent),
                  title: Text(
                    'My Orders',
                    style: TextStyle(color: _primaryText),
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'wishlist',
                child: ListTile(
                  leading: Icon(Icons.favorite_border, color: _accent),
                  title: Text(
                    'Wishlist',
                    style: TextStyle(color: _primaryText),
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.account_circle_outlined, color: _accent),
                  title: Text(
                    'Profile & Settings',
                    style: TextStyle(color: _primaryText),
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'heritage',
                child: ListTile(
                  leading: Icon(Icons.account_tree_outlined, color: _accent),
                  title: Text(
                    'Heritage Intelligence',
                    style: TextStyle(color: _primaryText),
                  ),
                ),
              ),
            ],
          ),

        const SizedBox(width: 8),
      ],
    );
  }

  // ============================================================
  // WELCOME
  // ============================================================

  Widget _buildWelcomeSection({
    required BuildContext context,
    required double motion,
  }) {
    final isCompact = MediaQuery.sizeOf(context).width < 560;
    final email = _user?.email ?? 'Customer';
    final name = email.split('@').first;

    final displayName = name.isEmpty
        ? 'Customer'
        : name[0].toUpperCase() + name.substring(1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 5),
      child: AnimatedContainer(
        width: double.infinity,
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(isCompact ? 17 : 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primary, const Color(0xFF0F5145)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20 + math.sin(motion * math.pi * 2) * 18,
              top: -25 + math.cos(motion * math.pi * 2) * 10,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              right: 30 + math.cos(motion * math.pi * 2) * 22,
              bottom: -55 + math.sin(motion * math.pi * 2) * 10,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              right: 34,
              top: 30 + math.sin(motion * math.pi * 2) * 8,
              child: Transform.rotate(
                angle: -0.12 + math.sin(motion * math.pi * 2) * 0.08,
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0x66FFFFFF),
                  size: 54,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WELCOME TO HERITRACE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hello, $displayName 👋',
                  style: TextStyle(
                    color: _surface,
                    fontSize: isCompact ? 19 : 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: isCompact ? 6 : 8),
                SizedBox(
                  width: isCompact ? double.infinity : 500,
                  child: const Text(
                    'Discover authentic handcrafted products directly from talented artisans.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.trim().toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search handcrafted products...',
          prefixIcon: const Icon(Icons.search, color: _accent),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();

                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.close),
                )
              : null,
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Widget _buildCategories() {
    return SizedBox(
      height: 55,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 5),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final selected = category == _selectedCategory;

          return ChoiceChip(
            label: Text(category),
            selected: selected,
            onSelected: (_) {
              setState(() {
                _selectedCategory = category;
              });
            },
            backgroundColor: _surface,
            selectedColor: primary,
            side: BorderSide(
              color: selected ? primary : const Color(0xFFE3E8E5),
            ),
            labelStyle: TextStyle(
              color: selected ? _background : _secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          );
        },
      ),
    );
  }

  // ============================================================
  // PRODUCT GRID
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
            child: Center(child: CircularProgressIndicator(color: _accent)),
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
              _selectedCategory == 'All' ||
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
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 35),
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

                  return _ProductCard(
                        document: doc,
                        onAddToCart: () {
                          _addToCart(doc);
                        },
                        onWishlist: () {
                          _toggleWishlist(doc);
                        },
                        onOpen: () {
                          _showProductDetails(doc);
                        },
                      )
                      .animate(
                        delay: Duration(milliseconds: 280 + (index % 6) * 70),
                      )
                      .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
                      .slideY(
                        begin: 0.08,
                        end: 0,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      );
                }, childCount: filteredDocs.length),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.70,
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ============================================================
  // CATEGORY MATCH
  // ============================================================

  bool _categoryMatches(String productCategory, String selectedCategory) {
    final product = productCategory.toLowerCase();

    switch (selectedCategory) {
      case 'Handicrafts':
        return product.contains('handicraft') || product.contains('craft');

      case 'Textiles':
        return product.contains('textile') ||
            product.contains('cloth') ||
            product.contains('weave');

      case 'Jewellery':
        return product.contains('jewellery') || product.contains('jewelry');

      case 'Pottery':
        return product.contains('pottery') || product.contains('ceramic');

      case 'Woodwork':
        return product.contains('wood');

      case 'Paintings':
        return product.contains('paint');

      case 'Home Decor':
        return product.contains('decor') || product.contains('home');

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

      if (user == null) {
        return;
      }

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

      _showMessage('Added to cart successfully.');
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

      if (user == null) {
        return;
      }

      final data = productDoc.data();

      final artisanId = _getArtisanId(productDoc);

      if (artisanId.isEmpty) {
        _showMessage('Unable to identify the artisan.', isError: true);
        return;
      }

      final wishlistId = '${artisanId}_${productDoc.id}';

      final wishlistRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wishlist')
          .doc(wishlistId);

      final existing = await wishlistRef.get();

      if (existing.exists) {
        await wishlistRef.delete();

        _showMessage('Removed from wishlist.');
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

        _showMessage('Added to wishlist.');
      }
    } catch (e) {
      _showMessage('Could not update wishlist.', isError: true);
    }
  }

  // ============================================================
  // ARTISAN ID
  // ============================================================

  String _getArtisanId(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final path = doc.reference.path.split('/');

    // Expected:
    // users/{artisanId}/products/{productId}

    if (path.length >= 4 && path[0] == 'users' && path[2] == 'products') {
      return path[1];
    }

    return '';
  }

  // ============================================================
  // PRODUCT DETAILS
  // ============================================================

  void _showProductDetails(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    final name = (data['name'] ?? 'Handcrafted Product').toString();

    final category = (data['category'] ?? 'Handicraft').toString();

    final description = (data['description'] ?? 'Authentic artisan product.')
        .toString();

    final price = _toDouble(data['price']);

    final imageUrl = (data['imageUrl'] ?? '').toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: const BoxConstraints(maxHeight: 680),
          decoration: const BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: _secondaryText,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  _LargeProductImage(
                    imageUrl: imageUrl,
                    productName: name,
                    category: category,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                                color: _primaryText,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF21463B),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        '₹${price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: primary,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'About this product',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _primaryText,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    description.isEmpty
                        ? 'This handcrafted product is made by an artisan and carries the unique character of traditional craftsmanship.'
                        : description,
                    style: const TextStyle(
                      color: _secondaryText,
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _toggleWishlist(doc);
                          },
                          icon: const Icon(Icons.favorite_border),
                          label: const Text('Wishlist'),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _addToCart(doc);
                          },
                          icon: const Icon(Icons.shopping_bag_outlined),
                          label: const Text('Add to Cart'),
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
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFF2E6DA),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.search_off_outlined,
                size: 45,
                color: _accent,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No products found',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 8),

            const Text(
              'Try changing your search or selecting another category.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _secondaryText, height: 1.5),
            ),

            const SizedBox(height: 18),

            OutlinedButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _selectedCategory = 'All';
                });
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 55,
              color: Colors.redAccent,
            ),

            const SizedBox(height: 15),

            const Text(
              'Unable to load marketplace',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 8),

            Text(
              error,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _secondaryText),
            ),

            const SizedBox(height: 18),

            OutlinedButton.icon(
              onPressed: () {
                setState(() {});
              },
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
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red.shade700 : primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

// =================================================================
// PRODUCT CARD
// =================================================================

class _ProductCard extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> document;
  final VoidCallback onAddToCart;
  final VoidCallback onWishlist;
  final VoidCallback onOpen;

  const _ProductCard({
    required this.document,
    required this.onAddToCart,
    required this.onWishlist,
    required this.onOpen,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _isWishlisted = false;
  bool _isHovered = false;
  static const _cardSurface = Color(0xFF1A302A);
  static const _cardAccent = Color(0xFFE0A95E);
  static const _cardSecondary = Color(0xFFA7BBB4);
  static const _cardText = Color(0xFFF2FAF6);
  static const _cardBackground = Color(0xFF0B1513);

  @override
  void initState() {
    super.initState();
    _checkWishlist();
  }

  Future<void> _checkWishlist() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final path = widget.document.reference.path.split('/');

    if (path.length < 4) {
      return;
    }

    final artisanId = path[1];

    final wishlistId = '${artisanId}_${widget.document.id}';

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(wishlistId);

    final snapshot = await ref.get();

    if (mounted) {
      setState(() {
        _isWishlisted = snapshot.exists;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.document.data();

    final name = (data['name'] ?? 'Handcrafted Product').toString();

    final category = (data['category'] ?? 'Handicraft').toString();

    final description = (data['description'] ?? '').toString();

    final imageUrl = (data['imageUrl'] ?? '').toString();

    final price = _toDouble(data['price']);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.025 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: Card(
          color: _cardSurface,
          clipBehavior: Clip.antiAlias,
          elevation: _isHovered ? 8 : 2,
          shadowColor: const Color(0x44176B5B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            onTap: widget.onOpen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                      Positioned(
                        top: 10,
                        right: 10,
                        child: Material(
                          color: _cardSurface.withValues(alpha: 0.96),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              setState(() {
                                _isWishlisted = !_isWishlisted;
                              });

                              widget.onWishlist();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                _isWishlisted
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 19,
                                color: _isWishlisted
                                    ? Colors.redAccent
                                    : _cardAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(13, 11, 13, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2E6DA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _cardAccent,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        const SizedBox(height: 7),

                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _cardText,
                          ),
                        ),

                        const SizedBox(height: 4),

                        if (description.isNotEmpty)
                          Text(
                            description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _cardSecondary,
                              fontSize: 10,
                            ),
                          ),

                        const Spacer(),

                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '₹${price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: _cardAccent,
                                ),
                              ),
                            ),

                            Material(
                              color: _cardAccent,
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: widget.onAddToCart,
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 18,
                                    color: _cardBackground,
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
        ),
      ),
    );
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

// =================================================================
// PRODUCT IMAGE
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
    if (name.contains('basket') || type.contains('bamboo')) {
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
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          color: const Color(0xFFF2E6DA),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFA24B2A),
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
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: double.infinity,
        height: 260,
        child: _ProductImage(
          imageUrl: imageUrl,
          productName: productName,
          category: category,
        ),
      ),
    );
  }
}
