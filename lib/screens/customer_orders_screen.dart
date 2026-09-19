import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({super.key});

  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  static const Color _background = Color(0xFFF5EFE6);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _headerStart = Color(0xFF7A2012);
  static const Color _text = Color(0xFF1D2A24);
  static const Color _muted = Color(0xFF6B746E);
  static const Color _border = Color(0xFFE8DFD3);

  String _selectedFilter = 'All';

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
        backgroundColor: _background,
        appBar: AppBar(
          backgroundColor: _background,
          title: const Text(
            'My Orders',
            style: TextStyle(fontWeight: FontWeight.w700, color: _text),
          ),
        ),
        body: const Center(
          child: Text(
            'Please login to view your orders.',
            style: TextStyle(color: _muted),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: _headerStart.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: _headerStart,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'My Heritage Orders',
              style: TextStyle(
                color: _text,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. Status Filter Pills
          _buildFilterBar(),

          // 2. Orders Stream List
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _orders.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _ErrorState(
                    message: 'Unable to load your orders.',
                    onRetry: () {},
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: _headerStart),
                  );
                }

                final documents = snapshot.data?.docs ?? [];

                if (documents.isEmpty) {
                  return const _EmptyOrders();
                }

                final allOrders = [...documents];

                allOrders.sort((a, b) {
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

                final filteredOrders = allOrders.where((doc) {
                  if (_selectedFilter == 'All') return true;
                  final status = (doc.data()['status'] ?? 'pending')
                      .toString()
                      .toLowerCase();
                  if (_selectedFilter == 'Pending' && (status == 'pending' || status == 'confirmed')) return true;
                  if (_selectedFilter == 'Crafting' && status == 'processing') return true;
                  if (_selectedFilter == 'Shipped' && status == 'shipped') return true;
                  if (_selectedFilter == 'Delivered' && status == 'delivered') return true;
                  return false;
                }).toList();

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.filter_list_off_rounded, size: 40, color: _muted),
                          const SizedBox(height: 12),
                          Text(
                            'No $_selectedFilter orders found',
                            style: const TextStyle(fontWeight: FontWeight.w800, color: _text),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: _headerStart,
                  onRefresh: () async {
                    await Future<void>.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final document = filteredOrders[index];
                      return _OrderCard(
                        orderId: document.id,
                        data: document.data(),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['All', 'Pending', 'Crafting', 'Shipped', 'Delivered'];
    return Container(
      height: 42,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return InkWell(
            onTap: () => setState(() => _selectedFilter = filter),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? _headerStart : _surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? _headerStart : _border,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? _headerStart.withValues(alpha: 0.22)
                        : Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : _text,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
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

  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _headerStart = Color(0xFF7A2012);
  static const Color _text = Color(0xFF1D2A24);
  static const Color _muted = Color(0xFF6B746E);
  static const Color _border = Color(0xFFE8DFD3);

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

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showOrderDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _headerStart.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: _headerStart,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Handcrafted Commission',
                          style: TextStyle(fontSize: 11, color: _muted, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '#${_shortOrderId(orderId)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: _text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: status),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(height: 1, color: _border),
              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 17,
                    color: _muted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${items.length} ${items.length == 1 ? 'artisan craft' : 'artisan crafts'}',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: _text, fontSize: 13),
                    ),
                  ),
                  Text(
                    '₹${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: _headerStart,
                    ),
                  ),
                ],
              ),

              if (date != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 15,
                      color: _muted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(date),
                      style: const TextStyle(fontSize: 12, color: _muted),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _headerStart,
                      side: const BorderSide(color: _headerStart),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _showOrderDetails(context),
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text(
                      'View Tracking & Details',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                    ),
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

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Order Tracking & Receipt',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: _text,
                          ),
                        ),
                      ),
                      _StatusBadge(status: status),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Order #${_shortOrderId(orderId)} · Direct Artisan Payment',
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),

                  const SizedBox(height: 18),

                  _OrderStatusTimeline(status: status),

                  const SizedBox(height: 18),

                  const Text(
                    'Handcrafted Items',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _text),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: items.isEmpty
                        ? const Center(
                            child: Text('No item details available.', style: TextStyle(color: _muted)),
                          )
                        : ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
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
                      color: const Color(0xFFFAF7F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _border),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Total Direct Revenue to Artisan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _text,
                            ),
                          ),
                        ),
                        Text(
                          '₹${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: _headerStart,
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

class _OrderStatusTimeline extends StatelessWidget {
  final String status;

  static const Color _headerStart = Color(0xFF7A2012);

  const _OrderStatusTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    const stages = [
      'pending',
      'confirmed',
      'processing',
      'shipped',
      'delivered',
    ];
    final activeIndex = status == 'cancelled' ? -1 : stages.indexOf(status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Artisan Loom & Delivery Progress',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1D2A24)),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(stages.length, (index) {
            final active = activeIndex >= index;
            return Expanded(
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: active
                          ? _headerStart
                          : const Color(0xFFD9D0C4),
                      shape: BoxShape.circle,
                    ),
                    child: active
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  if (index < stages.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: activeIndex > index
                            ? _headerStart
                            : const Color(0xFFD9D0C4),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 7),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: stages
              .map(
                (stage) => Text(
                  _stageTitle(stage),
                  style: const TextStyle(fontSize: 9.5, color: Color(0xFF6B746E), fontWeight: FontWeight.w600),
                ),
              )
              .toList(),
        ),
        if (status == 'cancelled')
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'This order was cancelled.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  String _stageTitle(String stage) {
    switch (stage) {
      case 'processing':
        return 'Crafting';
      case 'confirmed':
        return 'Confirmed';
      case 'shipped':
        return 'Dispatched';
      case 'delivered':
        return 'Delivered';
      default:
        return 'Pending';
    }
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
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8DFD3)),
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
                    fontSize: 14,
                    color: Color(0xFF1D2A24),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  category,
                  style: const TextStyle(color: Color(0xFF6B746E), fontSize: 11),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${price.toStringAsFixed(2)} × $quantity',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7A2012),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '₹${(price * quantity).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1D2A24)),
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
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFF2E6DA),
          borderRadius: BorderRadius.circular(13),
        ),
        child: const Icon(
          Icons.image_outlined,
          color: Color(0xFF7A2012),
          size: 28,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Image.network(
        imageUrl,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Container(
            width: 64,
            height: 64,
            color: const Color(0xFFF2E6DA),
            child: const Icon(
              Icons.image_not_supported_outlined,
              color: Color(0xFF7A2012),
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
        foreground = const Color(0xFF1E5638);
        icon = Icons.check_circle_outline;
        label = 'Confirmed';
        break;

      case 'processing':
        background = const Color(0xFFFFF3DC);
        foreground = const Color(0xFF9A6700);
        icon = Icons.sync;
        label = 'Crafting';
        break;

      case 'shipped':
        background = const Color(0xFFE8F0FF);
        foreground = const Color(0xFF1976D2);
        icon = Icons.local_shipping_outlined;
        label = 'Dispatched';
        break;

      case 'delivered':
        background = const Color(0xFFE6F5ED);
        foreground = const Color(0xFF1E5638);
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF7A2012).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 40,
                color: Color(0xFF7A2012),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No heritage orders yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1D2A24)),
            ),
            const SizedBox(height: 8),
            const Text(
              'When you purchase direct handcrafted pieces from master artisans, your commissions and tracking will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B746E), height: 1.5, fontSize: 13),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            OutlinedButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}
