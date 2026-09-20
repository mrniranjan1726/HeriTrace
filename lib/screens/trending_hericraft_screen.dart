import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TrendingHericraftScreen extends StatefulWidget {
  const TrendingHericraftScreen({super.key});

  @override
  State<TrendingHericraftScreen> createState() => _TrendingHericraftScreenState();
}

class _TrendingHericraftScreenState extends State<TrendingHericraftScreen> {
  static const Color _primaryTerracotta = Color(0xFF7A2012);
  static const Color _heirloomGold = Color(0xFFD4A056);
  static const Color _lightGoldWash = Color(0xFFFBF4EA);
  static const Color _pageBackground = Color(0xFFF5EFE6);
  static const Color _textPrimary = Color(0xFF1D2A24);
  static const Color _textSecondary = Color(0xFF6B746E);
  static const Color _cardBorder = Color(0xFFE8DFD3);
  static const Color _badgeGreen = Color(0xFF1E5638);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedSort = 'Popular';

  final List<String> _categories = [
    'All',
    'Textiles',
    'Woodcraft',
    'Decor',
    'Pottery',
    'Paintings',
  ];

  final List<Map<String, dynamic>> _trendingProducts = [
    {
      'id': 'trending_shirt_01',
      'name': 'Heritage Printed Resort Shirt',
      'category': 'Textiles',
      'origin': 'Jaipur, Rajasthan',
      'price': 1499.0,
      'originalPrice': 2499.0,
      'artisanShare': 'Artisan receives ₹1,100',
      'artisanShareNum': 1100.0,
      'popularity': 99,
      'artisanName': 'Jaipur Handblock Artisans, Rajasthan',
      'imageUrl': 'assets/images/heritage_shirt.png',
      'description':
          'Handcrafted premium resort-collar heritage shirt featuring authentic handblock lotus motifs and artisanal borders on pure breathable cotton. Tailored by generational Jaipuri artisans.',
      'verified': true,
      'artisanId': 'artisan_jaipur_01',
    },
    {
      'id': 'trending_box_02',
      'name': 'Carved Walnut Wood Box',
      'category': 'Woodcraft',
      'origin': 'Srinagar, Kashmir',
      'price': 899.0,
      'originalPrice': 1799.0,
      'artisanShare': 'Artisan receives ₹620',
      'artisanShareNum': 620.0,
      'popularity': 94,
      'artisanName': 'Kashmir Woodcraft Guild',
      'imageUrl':
          'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=600&q=80',
      'description':
          'Exquisite walnut wood box hand-carved with traditional Chinar leaf and rosette motifs by master woodcrafters of the Kashmir valley. Finished with natural organic wax.',
      'verified': true,
      'artisanId': 'artisan_kashmir_02',
    },
    {
      'id': 'trending_brass_03',
      'name': 'Handmade Peacock Brass Lamp',
      'category': 'Decor',
      'origin': 'Moradabad, UP',
      'price': 649.0,
      'originalPrice': 1299.0,
      'artisanShare': 'Artisan receives ₹480',
      'artisanShareNum': 480.0,
      'popularity': 91,
      'artisanName': 'Moradabad Metal Guild',
      'imageUrl':
          'https://images.unsplash.com/photo-1610701596007-11502861dcfa?auto=format&fit=crop&w=600&q=80',
      'description':
          'Traditional lost-wax bell metal brass lamp crowned with an auspicious dancing peacock. Hand-chiseled by generational brass metalworkers in Moradabad.',
      'verified': true,
      'artisanId': 'artisan_moradabad_03',
    },
    {
      'id': 'trending_pottery_04',
      'name': 'Jaipur Blue Ceramic Vase',
      'category': 'Pottery',
      'origin': 'Jaipur, Rajasthan',
      'price': 499.0,
      'originalPrice': 1199.0,
      'artisanShare': 'Artisan receives ₹350',
      'artisanShareNum': 350.0,
      'popularity': 88,
      'artisanName': 'Kripal Blue Pottery Studio',
      'imageUrl':
          'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=600&q=80',
      'description':
          'Authentic Jaipur blue pottery vase glazed with natural quartz stone powder and plant pigments, fired without clay in traditional wood kilns.',
      'verified': true,
      'artisanId': 'artisan_jaipur_04',
    },
    {
      'id': 'trending_painting_05',
      'name': 'Handmade Folk Art Painting',
      'category': 'Paintings',
      'origin': 'Madhubani, Bihar',
      'price': 999.0,
      'originalPrice': 1999.0,
      'artisanShare': 'Artisan receives ₹750',
      'artisanShareNum': 750.0,
      'popularity': 95,
      'artisanName': 'Mithila Craft Collective',
      'imageUrl':
          'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=600&q=80',
      'description':
          'Intricate Madhubani folk painting hand-drawn with bamboo twigs and natural mineral dyes depicting harmony in nature, fertility, and ancient folklore.',
      'verified': true,
      'artisanId': 'artisan_mithila_05',
    },
    {
      'id': 'trending_shawl_06',
      'name': 'Handloom Tussar Silk Shawl',
      'category': 'Textiles',
      'origin': 'Bhagalpur, Bihar',
      'price': 1499.0,
      'originalPrice': 2999.0,
      'artisanShare': 'Artisan receives ₹1,150',
      'artisanShareNum': 1150.0,
      'popularity': 97,
      'artisanName': 'Bhagalpur Silk Weavers',
      'imageUrl':
          'https://utkalikaodisha.com/wp-content/uploads/2023/01/TRI3D__Smb_3__silk_set172_srijla_front__2023-1-4-13-27-43__1200X1200_11zon.jpg',
      'description':
          'Pure wild Tussar silk woven on traditional village pit-looms with organic slub textures and natural golden sheen. Hand-dyed using forest extracts.',
      'verified': true,
      'artisanId': 'artisan_bhagalpur_06',
    },
    {
      'id': 'trending_saree_07',
      'name': 'Sambalpuri Ikat Silk Saree',
      'category': 'Textiles',
      'origin': 'Bargarh, Odisha',
      'price': 3499.0,
      'originalPrice': 5499.0,
      'artisanShare': 'Artisan receives ₹2,800',
      'artisanShareNum': 2800.0,
      'popularity': 98,
      'artisanName': 'Maa Samaleswari Handloom Guild',
      'imageUrl':
          'https://utkalikaodisha.com/wp-content/uploads/2023/01/TRI3D__Smb_3__silk_set172_srijla_front__2023-1-4-13-27-43__1200X1200_11zon.jpg',
      'description':
          'Legendary Bandha tie-and-dye weaving technique with intricate temple border motifs. Handcrafted over 14 days by master weavers in western Odisha.',
      'verified': true,
      'artisanId': 'artisan_odisha_07',
    },
    {
      'id': 'trending_dhokra_08',
      'name': 'Tribal Dhokra Bull Figurine',
      'category': 'Decor',
      'origin': 'Bastar, Chhattisgarh',
      'price': 799.0,
      'originalPrice': 1599.0,
      'artisanShare': 'Artisan receives ₹600',
      'artisanShareNum': 600.0,
      'popularity': 89,
      'artisanName': 'Bastar Tribal Crafts Guild',
      'imageUrl':
          'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=600&q=80',
      'description':
          '4000-year-old lost-wax bell metal casting technique representing tribal livestock veneration. Every single piece is unique and cast from a disposable wax mould.',
      'verified': true,
      'artisanId': 'artisan_bastar_08',
    },
  ];

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredAndSortedProducts() {
    List<Map<String, dynamic>> list = List.from(_trendingProducts);

    // 1. Filter by category
    if (_selectedCategory != 'All') {
      list = list.where((item) => item['category'] == _selectedCategory).toList();
    }

    // 2. Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((item) {
        final name = (item['name'] ?? '').toString().toLowerCase();
        final origin = (item['origin'] ?? '').toString().toLowerCase();
        final category = (item['category'] ?? '').toString().toLowerCase();
        final artisan = (item['artisanName'] ?? '').toString().toLowerCase();
        return name.contains(q) || origin.contains(q) || category.contains(q) || artisan.contains(q);
      }).toList();
    }

    // 3. Sort
    switch (_selectedSort) {
      case 'Price: Low to High':
        list.sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));
        break;
      case 'Price: High to Low':
        list.sort((a, b) => (b['price'] as double).compareTo(a['price'] as double));
        break;
      case 'Artisan Share':
        list.sort((a, b) => (b['artisanShareNum'] as double).compareTo(a['artisanShareNum'] as double));
        break;
      default: // Popular
        list.sort((a, b) => (b['popularity'] as int).compareTo(a['popularity'] as int));
        break;
    }

    return list;
  }

  Future<void> _addToCart(Map<String, dynamic> item) async {
    final user = _user;
    if (user == null) {
      _showToast('Please log in to add items to your cart.');
      return;
    }

    try {
      final artisanId = (item['artisanId'] ?? 'artisan_jaipur_01').toString();
      final productId = (item['id'] ?? 'product_item').toString();
      final cartDocId = '${artisanId}_$productId';

      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(cartDocId);

      final existing = await cartRef.get();
      if (existing.exists) {
        final currentQty = (existing.data()?['quantity'] as num?)?.toInt() ?? 1;
        await cartRef.update({
          'quantity': currentQty + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await cartRef.set({
          'productId': productId,
          'artisanId': artisanId,
          'name': item['name'] ?? 'Product',
          'category': item['category'] ?? 'Handicraft',
          'description': item['description'] ?? '',
          'price': (item['price'] as num).toDouble(),
          'imageUrl': item['imageUrl'] ?? '',
          'quantity': 1,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      _showToast('Added "${item['name']}" to Cart! 🛍️');
    } catch (e) {
      _showToast('Could not add to cart: $e');
    }
  }

  Future<void> _toggleWishlist(Map<String, dynamic> item) async {
    final user = _user;
    if (user == null) {
      _showToast('Please log in to save to your wishlist.');
      return;
    }

    try {
      final artisanId = (item['artisanId'] ?? 'artisan_jaipur_01').toString();
      final productId = (item['id'] ?? 'product_item').toString();
      final wishlistDocId = '${artisanId}_$productId';

      final wishlistRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wishlist')
          .doc(wishlistDocId);

      final existing = await wishlistRef.get();
      if (existing.exists) {
        await wishlistRef.delete();
        _showToast('Removed from Wishlist.');
      } else {
        await wishlistRef.set({
          'productId': productId,
          'artisanId': artisanId,
          'name': item['name'] ?? 'Product',
          'category': item['category'] ?? 'Handicraft',
          'description': item['description'] ?? '',
          'price': (item['price'] as num).toDouble(),
          'imageUrl': item['imageUrl'] ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
        _showToast('Saved to Wishlist ❤️');
      }
    } catch (e) {
      _showToast('Could not update wishlist: $e');
    }
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontWeight: FontWeight.w700)),
          backgroundColor: _primaryTerracotta,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
  }

  void _showProductDetails(Map<String, dynamic> item) {
    final name = (item['name'] ?? 'Handcrafted Product').toString();
    final category = (item['category'] ?? 'Handicraft').toString();
    final origin = (item['origin'] ?? 'India').toString();
    final artisanName = (item['artisanName'] ?? 'Master Artisan Studio').toString();
    final description = (item['description'] ?? '').toString();
    final price = (item['price'] as num).toDouble();
    final originalPrice = (item['originalPrice'] as num).toDouble();
    final artisanShare = (item['artisanShare'] ?? 'Artisan receives 80%').toString();
    final imageUrl = (item['imageUrl'] ?? '').toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          constraints: const BoxConstraints(maxHeight: 720),
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

                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 250,
                      child: imageUrl.startsWith('assets/')
                          ? Image.asset(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Image.network(
                                'https://heritrace.web.app/assets/images/heritage_shirt.png',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(color: Colors.grey.shade200),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _lightGoldWash,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _heirloomGold),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified, size: 13, color: _primaryTerracotta),
                            SizedBox(width: 4),
                            Text(
                              'Certified Authentic',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: _primaryTerracotta,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _pageBackground,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _textSecondary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 14, color: _textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            origin,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹${price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${originalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                          color: _textSecondary,
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
                            color: _badgeGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Transparent revenue banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFC8E6D9)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFFD3EEDF),
                          child: Icon(Icons.handyman, color: _badgeGreen, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                artisanShare,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: _badgeGreen,
                                ),
                              ),
                              Text(
                                'Studio: $artisanName • 100% fair pay',
                                style: const TextStyle(fontSize: 10, color: _textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Craft Story & Provenance',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(color: _textSecondary, height: 1.5, fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  // 7-Day Guarantee Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF7F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_user_outlined, color: _primaryTerracotta, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '7-Day Easy Return & Replacement Guarantee',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Doorstep reverse pickup • Replacement or full refund',
                                style: TextStyle(fontSize: 10, color: _textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
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
                            _toggleWishlist(item);
                          },
                          icon: const Icon(Icons.favorite_border, color: _textPrimary),
                          label: const Text('Wishlist', style: TextStyle(color: _textPrimary)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryTerracotta,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _addToCart(item);
                          },
                          icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                          label: const Text(
                            'Add to Cart',
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

  @override
  Widget build(BuildContext context) {
    final products = _getFilteredAndSortedProducts();

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _primaryTerracotta,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trending Hericrafts',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              'Most loved authentic Indian handicrafts',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFFE8C8A3),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _user == null
                ? null
                : FirebaseFirestore.instance
                    .collection('users')
                    .doc(_user!.uid)
                    .collection('cart')
                    .snapshots(),
            builder: (context, snapshot) {
              final cartCount = snapshot.data?.docs.length ?? 0;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                    onPressed: () => Navigator.pushNamed(context, '/customer-cart'),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: _heirloomGold,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(
                            color: Color(0xFF4A1208),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar & Sort Dropdown
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: _pageBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search trending crafts, origins...',
                        hintStyle: const TextStyle(fontSize: 12, color: _textSecondary),
                        prefixIcon: const Icon(Icons.search, size: 20, color: _textSecondary),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  initialValue: _selectedSort,
                  tooltip: 'Sort Items',
                  onSelected: (val) => setState(() => _selectedSort = val),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'Popular', child: Text('🔥 Most Popular')),
                    PopupMenuItem(value: 'Price: Low to High', child: Text('🏷️ Price: Low to High')),
                    PopupMenuItem(value: 'Price: High to Low', child: Text('💎 Price: High to Low')),
                    PopupMenuItem(value: 'Artisan Share', child: Text('🤝 Highest Artisan Share')),
                  ],
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: _pageBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sort_rounded, size: 18, color: _primaryTerracotta),
                        const SizedBox(width: 4),
                        Text(
                          _selectedSort == 'Popular' ? 'Sort' : _selectedSort,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Category Filter Pills
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return InkWell(
                    onTap: () => setState(() => _selectedCategory = cat),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? _primaryTerracotta : _pageBackground,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? _primaryTerracotta : _cardBorder,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : _textPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 3. Products Count & Active Filters Indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text(
                  '${products.length} ${products.length == 1 ? 'Handcraft' : 'Handcrafts'} Found',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
                const Spacer(),
                if (_selectedCategory != 'All' || _searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _selectedCategory = 'All';
                        _searchQuery = '';
                      });
                    },
                    child: const Text(
                      'Clear Filters',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _primaryTerracotta,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 4. Products Grid
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 54, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No handcrafted items match your criteria.',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textSecondary),
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _selectedCategory = 'All';
                              _searchQuery = '';
                            });
                          },
                          child: const Text('View All Trending Crafts'),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 30),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final item = products[index];
                      final name = (item['name'] ?? '').toString();
                      final origin = (item['origin'] ?? '').toString();
                      final price = (item['price'] as num).toDouble();
                      final originalPrice = (item['originalPrice'] as num).toDouble();
                      final artisanShare = (item['artisanShare'] ?? '').toString();
                      final imageUrl = (item['imageUrl'] ?? '').toString();

                      return InkWell(
                        onTap: () => _showProductDetails(item),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image + Origin Pill
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: imageUrl.startsWith('assets/')
                                            ? Image.asset(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, _, _) => Image.network(
                                                  'https://heritrace.web.app/assets/images/heritage_shirt.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, _, _) => Container(color: Colors.grey.shade200),
                                              ),
                                      ),
                                      Positioned(
                                        top: 6,
                                        left: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.65),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            origin,
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

                              // Info & Price
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: _textPrimary,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      artisanShare,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: _badgeGreen,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          '₹${price.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: _textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '₹${originalPrice.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            decoration: TextDecoration.lineThrough,
                                            color: _textSecondary,
                                          ),
                                        ),
                                        const Spacer(),
                                        InkWell(
                                          onTap: () => _addToCart(item),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: _lightGoldWash,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: _heirloomGold),
                                            ),
                                            child: const Icon(
                                              Icons.add_shopping_cart_rounded,
                                              size: 15,
                                              color: _primaryTerracotta,
                                            ),
                                          ),
                                        ),
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
}
