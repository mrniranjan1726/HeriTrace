import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  static const _background = Color(0xFF0B1513);
  static const _surface = Color(0xFF12231F);
  static const _surfaceRaised = Color(0xFF1A302A);
  static const _text = Color(0xFFF2FAF6);
  static const _muted = Color(0xFFA7BBB4);
  static const _accent = Color(0xFF4FD1B5);

  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';
  String _searchText = '';

  final List<String> _categories = [
    'All',
    'Textiles',
    'Home Decor',
    'Bamboo Craft',
    'Pottery',
    'Jewellery',
    'Wood Craft',
    'Handicraft',
  ];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesProduct(Map<String, dynamic> data) {
    final name = (data['name'] ?? '').toString().toLowerCase();
    final category = (data['category'] ?? '').toString().toLowerCase();
    final description = (data['description'] ?? '').toString().toLowerCase();

    final matchesSearch =
        _searchText.isEmpty ||
        name.contains(_searchText) ||
        category.contains(_searchText) ||
        description.contains(_searchText);

    final matchesCategory =
        _selectedCategory == 'All' ||
        category == _selectedCategory.toLowerCase();

    return matchesSearch && matchesCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collectionGroup('products')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: _accent),
              );
            }

            if (snapshot.hasError) {
              return _errorView(snapshot.error.toString());
            }

            final documents = snapshot.data?.docs ?? [];

            final products = documents
                .where((doc) => _matchesProduct(doc.data()))
                .toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(context, documents.length),
                ),

                SliverToBoxAdapter(child: _buildSearchSection()),

                SliverToBoxAdapter(child: _buildCategories()),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 26, 20, 16),
                    child: Row(
                      children: [
                        const Text(
                          'Explore Products',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: _text,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${products.length} products',
                          style: const TextStyle(
                            color: _muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (products.isEmpty)
                  SliverToBoxAdapter(child: _emptyState())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.crossAxisExtent;

                        int columns = 1;

                        if (width >= 1100) {
                          columns = 4;
                        } else if (width >= 800) {
                          columns = 3;
                        } else if (width >= 520) {
                          columns = 2;
                        }

                        return SliverGrid(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final product = products[index];

                            return _ProductCard(
                              data: product.data(),
                              onTap: () {
                                _showProductDetails(context, product.data());
                              },
                            );
                          }, childCount: products.length),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 18,
                                mainAxisSpacing: 18,
                                childAspectRatio: columns == 1 ? 1.55 : 0.73,
                              ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int productCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: Color(0xFF29443B))),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1250),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF21463B),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: _accent,
                  size: 25,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HeriTrace Marketplace',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: _text,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Discover authentic products crafted by local artisans',
                      style: TextStyle(color: _muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (productCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: _surfaceRaised,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$productCount available',
                    style: const TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 6),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1250),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF29443B)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search crafts, textiles, pottery...',
                hintStyle: const TextStyle(color: _muted),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF21463B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.search_rounded, color: _accent),
                ),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.close_rounded, color: _muted),
                      )
                    : null,
                border: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 62,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final selected = category == _selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
              decoration: BoxDecoration(
                color: selected ? _accent : _surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected ? _accent : const Color(0xFF29443B),
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? _background : _muted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 55),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF29443B)),
        ),
        child: Column(
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: const Color(0xFF21463B),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 38,
                color: _accent,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No products found',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: _text,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try another search or choose a different category.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 55, color: _accent),
            const SizedBox(height: 15),
            const Text(
              'Marketplace could not load',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(BuildContext context, Map<String, dynamic> data) {
    final name = (data['name'] ?? 'Untitled Product').toString();
    final category = (data['category'] ?? 'Handicraft').toString();
    final description = (data['description'] ?? 'No description available.')
        .toString();
    final notes = (data['notes'] ?? '').toString();
    final price = data['price'];
    final imageUrl = (data['imageUrl'] ?? '').toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          constraints: const BoxConstraints(maxWidth: 700),
          decoration: const BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9DEDB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _detailImage(imageUrl),
                const SizedBox(height: 20),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF21463B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _formatPrice(price),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _accent,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'About this product',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  style: const TextStyle(height: 1.55, color: _muted),
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const Text(
                    'Additional notes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    notes,
                    style: const TextStyle(height: 1.55, color: _muted),
                  ),
                ],
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Cart functionality is the next customer module.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text(
                      'Add to Cart',
                      style: TextStyle(fontWeight: FontWeight.w700),
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

  Widget _detailImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        height: 230,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF21463B),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(Icons.image_outlined, size: 70, color: _accent),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: 230,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Container(
            height: 230,
            color: const Color(0xFF21463B),
            child: const Icon(
              Icons.broken_image_outlined,
              size: 60,
              color: _accent,
            ),
          );
        },
      ),
    );
  }

  String _formatPrice(dynamic value) {
    if (value == null) {
      return 'Price not available';
    }

    if (value is num) {
      return '₹${value.toStringAsFixed(0)}';
    }

    final parsed = double.tryParse(value.toString());

    if (parsed != null) {
      return '₹${parsed.toStringAsFixed(0)}';
    }

    return '₹$value';
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _ProductCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = (data['name'] ?? 'Untitled Product').toString();
    final category = (data['category'] ?? 'Handicraft').toString();
    final description = (data['description'] ?? '').toString();
    final imageUrl = (data['imageUrl'] ?? '').toString();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: _MarketplaceScreenState._surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF29443B)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  Positioned.fill(child: _productImage(imageUrl)),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _MarketplaceScreenState._surfaceRaised
                            .withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _MarketplaceScreenState._accent,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _MarketplaceScreenState._surfaceRaised
                            .withValues(alpha: 0.96),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 19,
                        color: Color(0xFF46514C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _MarketplaceScreenState._text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (description.isNotEmpty)
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          height: 1.35,
                          color: _MarketplaceScreenState._muted,
                        ),
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          _price(data['price']),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _MarketplaceScreenState._accent,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                          color: _MarketplaceScreenState._accent,
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

  Widget _productImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        color: _MarketplaceScreenState._surfaceRaised,
        child: const Center(
          child: Icon(
            Icons.handyman_outlined,
            size: 58,
            color: _MarketplaceScreenState._accent,
          ),
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        return Container(
          color: _MarketplaceScreenState._surfaceRaised,
          child: const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: _MarketplaceScreenState._accent,
            ),
          ),
        );
      },
    );
  }

  String _price(dynamic value) {
    if (value == null) {
      return '₹—';
    }

    if (value is num) {
      return '₹${value.toStringAsFixed(0)}';
    }

    final parsed = double.tryParse(value.toString());

    if (parsed != null) {
      return '₹${parsed.toStringAsFixed(0)}';
    }

    return '₹$value';
  }
}
