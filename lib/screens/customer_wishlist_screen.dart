import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomerWishlistScreen extends StatelessWidget {
  const CustomerWishlistScreen({super.key});

  String _money(dynamic value) {
    final price = value is num
        ? value.toDouble()
        : double.tryParse(value.toString()) ?? 0;

    return '₹${price.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view your wishlist.')),
      );
    }

    final wishlistRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wishlist');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Wishlist',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: wishlistRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load wishlist.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data?.docs ?? [];

          if (products.isEmpty) {
            return _emptyWishlist();
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 330,
              mainAxisExtent: 355,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _WishlistCard(
                document: products[index],
                money: _money,
                onRemove: () {
                  _removeFromWishlist(products[index].id, wishlistRef);
                },
                onAddToCart: () {
                  _addToCart(products[index], context);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _emptyWishlist() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 105,
              height: 105,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEEE),
                borderRadius: BorderRadius.circular(55),
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 52,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your wishlist is empty',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Save your favourite handmade products here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeFromWishlist(
    String documentId,
    CollectionReference<Map<String, dynamic>> wishlistRef,
  ) async {
    try {
      await wishlistRef.doc(documentId).delete();
    } catch (e) {
      debugPrint('Wishlist delete error: $e');
    }
  }

  Future<void> _addToCart(
    QueryDocumentSnapshot<Map<String, dynamic>> wishlistDoc,
    BuildContext context,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final data = wishlistDoc.data();

      final productId = data['productId']?.toString() ?? '';

      final artisanId = data['artisanId']?.toString() ?? '';

      final cartId = '${artisanId}_$productId';

      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(cartId);

      final existing = await cartRef.get();

      if (existing.exists) {
        final existingData = existing.data() ?? {};

        final quantity = existingData['quantity'] is num
            ? (existingData['quantity'] as num).toInt()
            : 1;

        await cartRef.update({
          'quantity': quantity + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await cartRef.set({
          'productId': productId,
          'artisanId': artisanId,
          'name': data['name'] ?? 'Handmade Product',
          'category': data['category'] ?? 'Handicraft',
          'description': data['description'] ?? '',
          'price': data['price'] ?? 0,
          'imageUrl': data['imageUrl'] ?? '',
          'quantity': 1,
          'addedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to cart 🛒'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not add to cart: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _WishlistCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> document;
  final String Function(dynamic) money;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  const _WishlistCard({
    required this.document,
    required this.money,
    required this.onRemove,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final data = document.data();

    final name = data['name']?.toString() ?? 'Handmade Product';

    final category = data['category']?.toString() ?? 'Handicraft';

    final imageUrl = data['imageUrl']?.toString() ?? '';

    final price = data['price'] ?? 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFD9D0C4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _ProductImage(imageUrl: imageUrl),
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: 'Remove',
                    onPressed: onRemove,
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 21,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      color: Color(0xFFA24B2A),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          money(price),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFA24B2A),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 40,
                        child: FilledButton.icon(
                          onPressed: onAddToCart,
                          icon: const Icon(
                            Icons.shopping_cart_outlined,
                            size: 17,
                          ),
                          label: const Text('Cart'),
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
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        height: 185,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _placeholder();
        },
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: 185,
      color: const Color(0xFFE8F4F0),
      child: const Center(
        child: Icon(
          Icons.handyman_outlined,
          size: 58,
          color: Color(0xFFA24B2A),
        ),
      ),
    );
  }
}
