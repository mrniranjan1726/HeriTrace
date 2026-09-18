import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomerOrdersScreen extends StatelessWidget {
  const CustomerOrdersScreen({super.key});

  CollectionReference<Map<String, dynamic>> get _orders {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return FirebaseFirestore.instance.collection('_invalid');
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('orders');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Orders',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: const Center(child: Text('Please login to view your orders.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 21),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _orders.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ErrorState(
              message: 'Unable to load your orders.',
              onRetry: () {},
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final documents = snapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return const _EmptyOrders();
          }

          final orders = [...documents];

          orders.sort((a, b) {
            final aData = a.data();
            final bData = b.data();

            final aTime = aData['createdAt'];
            final bTime = bData['createdAt'];

            if (aTime is Timestamp && bTime is Timestamp) {
              return bTime.compareTo(aTime);
            }

            if (aTime is Timestamp) return -1;
            if (bTime is Timestamp) return 1;

            return 0;
          });

          return RefreshIndicator(
            onRefresh: () async {
              await Future<void>.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final document = orders[index];

                return _OrderCard(orderId: document.id, data: document.data());
              },
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> data;

  const _OrderCard({required this.orderId, required this.data});

  @override
  Widget build(BuildContext context) {
    final items = _getItems();
    final status = (data['status'] ?? 'pending').toString().toLowerCase();

    final total = _getTotal();

    final createdAt = data['createdAt'];
    DateTime? date;

    if (createdAt is Timestamp) {
      date = createdAt.toDate();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          _showOrderDetails(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4F0),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Color(0xFF176B5B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        Text(
                          '#${_shortOrderId(orderId)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: status),
                ],
              ),

              const SizedBox(height: 16),

              const Divider(height: 1),

              const SizedBox(height: 14),

              Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 19,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '₹${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF176B5B),
                    ),
                  ),
                ],
              ),

              if (date != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 17,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(date),
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _showOrderDetails(context);
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getItems() {
    final rawItems = data['items'];

    if (rawItems is! List) {
      return [];
    }

    return rawItems
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  double _getTotal() {
    final value = data['total'];

    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }

  String _shortOrderId(String id) {
    if (id.length <= 10) {
      return id;
    }

    return id.substring(0, 10).toUpperCase();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/$year • $hour:$minute $period';
  }

  void _showOrderDetails(BuildContext context) {
    final items = _getItems();
    final status = (data['status'] ?? 'pending').toString().toLowerCase();
    final total = _getTotal();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: const BoxConstraints(maxHeight: 650),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Order Details',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _StatusBadge(status: status),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Order #${_shortOrderId(orderId)}',
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Items',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: items.isEmpty
                        ? const Center(
                            child: Text('No item details available.'),
                          )
                        : ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, _) {
                              return const SizedBox(height: 10);
                            },
                            itemBuilder: (context, index) {
                              final item = items[index];

                              return _OrderItem(item: item);
                            },
                          ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '₹${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
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
          ),
        );
      },
    );
  }
}

class _OrderItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const _OrderItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final name = (item['name'] ?? 'Product').toString();
    final category = (item['category'] ?? 'Handicraft').toString();

    final price = _number(item['price']);
    final quantity = _number(item['quantity']).toInt();

    final imageUrl = (item['imageUrl'] ?? '').toString();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE7EBE8)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _ProductImage(imageUrl: imageUrl),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  category,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),

                const SizedBox(height: 7),

                Text(
                  '₹${price.toStringAsFixed(2)} × $quantity',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Text(
            '₹${(price * quantity).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  double _number(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _ProductImage extends StatelessWidget {
  final String imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF4F0),
          borderRadius: BorderRadius.circular(13),
        ),
        child: const Icon(
          Icons.image_outlined,
          color: Color(0xFF176B5B),
          size: 30,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Image.network(
        imageUrl,
        width: 68,
        height: 68,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Container(
            width: 68,
            height: 68,
            color: const Color(0xFFEAF4F0),
            child: const Icon(
              Icons.image_not_supported_outlined,
              color: Color(0xFF176B5B),
            ),
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;
    IconData icon;
    String label;

    switch (status) {
      case 'confirmed':
        background = const Color(0xFFE7F5EC);
        foreground = const Color(0xFF237A43);
        icon = Icons.check_circle_outline;
        label = 'Confirmed';
        break;

      case 'processing':
        background = const Color(0xFFFFF3DC);
        foreground = const Color(0xFF9A6700);
        icon = Icons.sync;
        label = 'Processing';
        break;

      case 'shipped':
        background = const Color(0xFFE8F0FF);
        foreground = const Color(0xFF315EAA);
        icon = Icons.local_shipping_outlined;
        label = 'Shipped';
        break;

      case 'delivered':
        background = const Color(0xFFE6F5ED);
        foreground = const Color(0xFF217548);
        icon = Icons.done_all;
        label = 'Delivered';
        break;

      case 'cancelled':
      case 'canceled':
        background = const Color(0xFFFFE8E8);
        foreground = const Color(0xFFB3261E);
        icon = Icons.cancel_outlined;
        label = 'Cancelled';
        break;

      default:
        background = const Color(0xFFFFF1DE);
        foreground = const Color(0xFF9A5B00);
        icon = Icons.schedule_outlined;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
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
                color: const Color(0xFFEAF4F0),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 45,
                color: Color(0xFF176B5B),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'No orders yet',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your orders will appear here after you purchase products from artisans.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Browse Marketplace'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 55, color: Colors.redAccent),

            const SizedBox(height: 15),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 18),

            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
