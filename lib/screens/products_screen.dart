import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/firebase_service.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text(
          '“${product.name}” will be removed from your catalog. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    try {
      await FirebaseService().deleteProduct(product.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully.')),
      );
    } on Exception catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: FirebaseService().products(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Could not load products: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final products = snapshot.data!;
        if (products.isEmpty) {
          return const Center(
            child: Text('No products yet. Add your first product.'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                leading: _ProductImage(product: product),
                title: Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  '${product.category}  •  ₹${product.price.toStringAsFixed(0)}',
                ),
                trailing: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onPressed: () => _confirmDelete(context, product),
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: const Text('Delete'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});

  final Product product;

  String get _imageUrl {
    final storedUrl = product.imageUrl?.trim() ?? '';
    if (storedUrl.isNotEmpty) return storedUrl;

    final name = product.name.toLowerCase();
    final category = product.category.toLowerCase();

    if (name.contains('shirt') ||
        name.contains('kurta') ||
        name.contains('dress') ||
        category.contains('apparel')) {
      return 'assets/images/heritage_shirt.png';
    }

    if (name.contains('saree') ||
        name.contains('ikat') ||
        category.contains('textile')) {
      return 'https://utkalikaodisha.com/wp-content/uploads/2023/01/TRI3D__Smb_3__silk_set172_srijla_front__2023-1-4-13-27-43__1200X1200_11zon.jpg';
    }
    if (name.contains('basket') || category.contains('bamboo')) {
      return 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=500&q=82';
    }
    if (name.contains('pot') ||
        name.contains('ceramic') ||
        category.contains('pottery')) {
      return 'https://images.unsplash.com/photo-1610701596007-11502861dcfa?auto=format&fit=crop&w=500&q=82';
    }
    if (category.contains('jewellery') || category.contains('jewelry')) {
      return 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?auto=format&fit=crop&w=500&q=82';
    }
    return 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=500&q=82';
  }

  @override
  Widget build(BuildContext context) {
    final url = _imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: url.startsWith('assets/')
          ? Image.asset(
              url,
              width: 58,
              height: 58,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Image.network(
                'https://heritrace.web.app/assets/images/heritage_shirt.png',
                width: 58,
                height: 58,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(),
              ),
            )
          : Image.network(
              url,
              width: 58,
              height: 58,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _fallback(),
            ),
    );
  }

  Widget _fallback() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EFEC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.handyman_outlined, color: Color(0xFFA24B2A)),
    );
  }
}
