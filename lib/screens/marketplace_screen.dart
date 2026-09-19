import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
  static const _accent = Color(0xFFE0A95E);

  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';
  String _searchText = '';

  static String _imageForProduct(
    Map<String, dynamic> data, {
    bool ignoreStoredUrl = false,
  }) {
    final name = (data['name'] ?? '').toString().toLowerCase();
    final category = (data['category'] ?? '').toString().toLowerCase();
    final storedUrl = (data['imageUrl'] ?? '').toString().trim();

    if (!ignoreStoredUrl && storedUrl.isNotEmpty) {
      return storedUrl;
    }

    if (name.contains('saree') ||
        name.contains('ikat') ||
        category.contains('textile')) {
      return 'https://utkalikaodisha.com/wp-content/uploads/2023/01/TRI3D__Smb_3__silk_set172_srijla_front__2023-1-4-13-27-43__1200X1200_11zon.jpg';
    }
    if (name.contains('kurta') || name.contains('dress')) {
      return 'https://5.imimg.com/data5/ECOM/Default/2023/8/331186386/FZ/KN/HT/67173095/1690936764682-sku-3379-0-1000x1000.jpg';
    }
    if (name.contains('basket') || category.contains('bamboo')) {
      return 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=900&q=82';
    }
    if (category.contains('pottery') || name.contains('ceramic')) {
      return 'https://images.unsplash.com/photo-1610701596007-11502861dcfa?auto=format&fit=crop&w=900&q=82';
    }
    if (category.contains('jewellery') || category.contains('jewelry')) {
      return 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?auto=format&fit=crop&w=900&q=82';
    }
    if (category.contains('painting') || name.contains('pattachitra')) {
      return 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?auto=format&fit=crop&w=900&q=82';
    }
    if (category.contains('wood')) {
      return 'https://images.unsplash.com/photo-1549490349-8643362247b5?auto=format&fit=crop&w=900&q=82';
    }
    if (category.contains('decor') || category.contains('handicraft')) {
      return 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=900&q=82';
    }

    return 'https://images.unsplash.com/photo-1452860606245-08bea0c7d33c?auto=format&fit=crop&w=900&q=82';
  }

  static const _demoProducts = [
    {
      'name': 'Sambalpuri Ikat Saree',
      'category': 'Textiles',
      'description':
          'Handwoven Sambalpuri Ikat created with a traditional tie-and-dye weaving technique.',
      'price': 2499,
      'origin': 'Sambalpur, Odisha',
      'material': 'Cotton and natural dyes',
      'technique': 'Ikat weaving',
      'tradition': 'Sambalpuri handloom',
      'verified': true,
    },
    {
      'name': 'Sambalpuri Everyday Kurta',
      'category': 'Textiles',
      'description':
          'A comfortable handloom kurta carrying the rhythm of Odisha motifs.',
      'price': 1299,
      'origin': 'Bargarh, Odisha',
      'material': 'Handloom cotton',
      'technique': 'Traditional loom weaving',
      'tradition': 'Sambalpuri textile craft',
      'verified': true,
    },
    {
      'name': 'Handwoven Bamboo Basket',
      'category': 'Bamboo Craft',
      'description':
          'Lightweight utility basket woven by hand from locally sourced bamboo.',
      'price': 699,
      'origin': 'Koraput, Odisha',
      'material': 'Natural bamboo',
      'technique': 'Bamboo coiling and weaving',
      'tradition': 'Tribal bamboo craft',
      'verified': true,
    },
    {
      'name': 'Terracotta Heritage Pot',
      'category': 'Pottery',
      'description':
          'A warm terracotta vessel shaped and fired using a time-tested pottery tradition.',
      'price': 899,
      'origin': 'Khurda, Odisha',
      'material': 'Local terracotta clay',
      'technique': 'Wheel-thrown pottery',
      'tradition': 'Odisha clay craft',
      'verified': true,
    },
    {
      'name': 'Silver Filigree Pendant',
      'category': 'Jewellery',
      'description':
          'Fine silver filigree jewellery inspired by the detailed craft of Cuttack.',
      'price': 1899,
      'origin': 'Cuttack, Odisha',
      'material': 'Sterling silver',
      'technique': 'Tarakasi filigree',
      'tradition': 'Cuttack silver craft',
      'verified': true,
    },
    {
      'name': 'Pattachitra Story Panel',
      'category': 'Paintings',
      'description':
          'A hand-painted narrative panel inspired by Odisha temple traditions.',
      'price': 1599,
      'origin': 'Raghurajpur, Odisha',
      'material': 'Natural pigments on prepared cloth',
      'technique': 'Pattachitra painting',
      'tradition': 'Jagannath storytelling',
      'verified': true,
    },
  ];

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
            final List<Map<String, dynamic>> catalog = documents.isEmpty
                ? _demoProducts.toList()
                : documents.map((doc) => doc.data()).toList();

            final products = catalog.where(_matchesProduct).toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(context, catalog.length)
                      .animate()
                      .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
                      .slideY(begin: -0.06, end: 0),
                ),

                SliverToBoxAdapter(
                  child: _buildSearchSection()
                      .animate(delay: 100.ms)
                      .fadeIn(duration: 450.ms)
                      .slideY(begin: 0.05, end: 0),
                ),

                SliverToBoxAdapter(
                  child: _buildCategories()
                      .animate(delay: 160.ms)
                      .fadeIn(duration: 450.ms)
                      .slideX(begin: 0.05, end: 0),
                ),

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
                              data: product,
                              onTap: () {
                                _showProductDetails(context, product);
                              },
                            )
                                .animate(delay: Duration(milliseconds: 50 * (index % 8)))
                                .fadeIn(duration: 450.ms, curve: Curves.easeOutCubic)
                                .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
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
    final imageUrl = _imageForProduct(data);
    final artisanName = (data['artisanName'] ?? 'HeriTrace artisan').toString();
    final origin = (data['origin'] ?? 'India').toString();
    final material = (data['material'] ?? 'Traditional materials').toString();
    final technique = (data['technique'] ?? category).toString();
    final tradition = (data['tradition'] ?? 'Living heritage craft').toString();
    final verified = data['verified'] == true;

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
                _detailImage(imageUrl, data),
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
                const SizedBox(height: 24),
                _CraftTrace(
                  artisanName: artisanName,
                  origin: origin,
                  material: material,
                  technique: technique,
                  tradition: tradition,
                  verified: verified,
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

  Widget _detailImage(String imageUrl, Map<String, dynamic> data) {
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
          final fallbackUrl = _imageForProduct(data, ignoreStoredUrl: true);
          if (fallbackUrl != imageUrl) {
            return Image.network(
              fallbackUrl,
              width: double.infinity,
              height: 230,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _brokenDetailImage(),
            );
          }
          return _brokenDetailImage();
        },
      ),
    );
  }

  Widget _brokenDetailImage() {
    return Container(
      height: 230,
      color: const Color(0xFF21463B),
      child: const Icon(Icons.broken_image_outlined, size: 60, color: _accent),
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

/*
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _ProductCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = (data['name'] ?? 'Untitled Product').toString();
    final category = (data['category'] ?? 'Handicraft').toString();
    final description = (data['description'] ?? '').toString();
    final imageUrl = _MarketplaceScreenState._imageForProduct(data);
    final origin = (data['origin'] ?? '').toString();
    final verified = data['verified'] == true;

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
                  Positioned.fill(child: _productImage(imageUrl, data)),
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
                    if (origin.isNotEmpty || verified) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (origin.isNotEmpty)
                            Expanded(
                              child: Text(
                                '📍 $origin',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _MarketplaceScreenState._muted,
                                ),
                              ),
                            ),
                          if (verified)
                            const Icon(
                              Icons.verified_rounded,
                              size: 16,
                              color: _MarketplaceScreenState._accent,
                            ),
                        ],
                      ),
                    ],
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

  Widget _productImage(String imageUrl, Map<String, dynamic> data) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        final fallbackUrl = _MarketplaceScreenState._imageForProduct(
          data,
          ignoreStoredUrl: true,
        );
        if (fallbackUrl != imageUrl) {
          return Image.network(
            fallbackUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _brokenImage(),
          );
        }
        return _brokenImage();
      },
    );
  }

  Widget _brokenImage() {
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
*/

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _ProductCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = (data['name'] ?? 'Untitled Product').toString();
    final category = (data['category'] ?? 'Handicraft').toString();
    final description = (data['description'] ?? '').toString();
    final imageUrl = _MarketplaceScreenState._imageForProduct(data);
    final origin = (data['origin'] ?? '').toString();
    final verified = data['verified'] == true;

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
                  Positioned.fill(child: _productImage(imageUrl, data)),
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
                    if (origin.isNotEmpty || verified) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (origin.isNotEmpty)
                            Expanded(
                              child: Text(
                                '📍 $origin',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _MarketplaceScreenState._muted,
                                ),
                              ),
                            ),
                          if (verified)
                            const Icon(
                              Icons.verified_rounded,
                              size: 16,
                              color: _MarketplaceScreenState._accent,
                            ),
                        ],
                      ),
                    ],
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

  Widget _productImage(String imageUrl, Map<String, dynamic> data) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        final fallbackUrl = _MarketplaceScreenState._imageForProduct(
          data,
          ignoreStoredUrl: true,
        );
        if (fallbackUrl != imageUrl) {
          return Image.network(
            fallbackUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _brokenImage(),
          );
        }
        return _brokenImage();
      },
    );
  }

  Widget _brokenImage() {
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

class _CraftTrace extends StatelessWidget {
  const _CraftTrace({
    required this.artisanName,
    required this.origin,
    required this.material,
    required this.technique,
    required this.tradition,
    required this.verified,
  });

  final String artisanName;
  final String origin;
  final String material;
  final String technique;
  final String tradition;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Product', 'This piece'),
      ('Artisan', artisanName),
      ('Region', origin),
      ('Material', material),
      ('Technique', technique),
      ('Heritage story', tradition),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1513),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.route_rounded,
                color: _MarketplaceScreenState._accent,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'CRAFT TRACE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              if (verified)
                const Icon(
                  Icons.verified_rounded,
                  color: _MarketplaceScreenState._accent,
                  size: 19,
                ),
            ],
          ),
          const SizedBox(height: 14),
          ...steps.asMap().entries.map(
            (entry) => _TraceStep(
              label: entry.value.$1,
              value: entry.value.$2,
              isLast: entry.key == steps.length - 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _TraceStep extends StatelessWidget {
  const _TraceStep({
    required this.label,
    required this.value,
    required this.isLast,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 18,
          child: Column(
            children: [
              const Icon(Icons.circle, size: 8, color: Color(0xFFE0A95E)),
              if (!isLast)
                Container(width: 1, height: 24, color: const Color(0xFF42675A)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label\n',
                    style: const TextStyle(
                      color: Color(0xFFA7BBB4),
                      fontSize: 11,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
