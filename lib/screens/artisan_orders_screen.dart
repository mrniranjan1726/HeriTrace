import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ArtisanOrdersScreen extends StatelessWidget {
  const ArtisanOrdersScreen({super.key});

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final user = _user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to continue.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4EFE7),
      appBar: AppBar(
        title: const Text(
          'Customer Orders',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 21),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collectionGroup('orders')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ErrorState(
              message: 'Unable to load customer orders.',
              onRetry: () {},
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFA24B2A)),
            );
          }

          final allOrders = snapshot.data?.docs ?? [];

          // Only show orders containing this artisan's products.
          final artisanOrders = allOrders.where((doc) {
            return _containsArtisanProduct(doc.data(), user.uid);
          }).toList();

          artisanOrders.sort((a, b) {
            final aTime = a.data()['createdAt'];
            final bTime = b.data()['createdAt'];

            if (aTime is Timestamp && bTime is Timestamp) {
              return bTime.compareTo(aTime);
            }

            if (aTime is Timestamp) {
              return -1;
            }

            if (bTime is Timestamp) {
              return 1;
            }

            return 0;
          });

          if (artisanOrders.isEmpty) {
            return const _EmptyOrders();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future<void>.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              itemCount: artisanOrders.length,
              itemBuilder: (context, index) {
                final order = artisanOrders[index];

                return _ArtisanOrderCard(document: order, artisanId: user.uid);
              },
            ),
          );
        },
      ),
    );
  }

  bool _containsArtisanProduct(Map<String, dynamic> data, String artisanId) {
    final items = data['items'];

    if (items is! List) {
      return false;
    }

    for (final item in items) {
      if (item is Map) {
        final itemArtisanId = (item['artisanId'] ?? '').toString();

        if (itemArtisanId == artisanId) {
          return true;
        }
      }
    }

    return false;
  }
}

// ================================================================
// ORDER CARD
// ================================================================

class _ArtisanOrderCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> document;
  final String artisanId;

  const _ArtisanOrderCard({required this.document, required this.artisanId});

  @override
  Widget build(BuildContext context) {
    final data = document.data();

    final orderId = (data['orderId'] ?? document.id).toString();

    final customerId = (data['customerId'] ?? 'Customer').toString();

    final status = (data['status'] ?? 'pending').toString().toLowerCase();

    final items = _artisanItems();

    final artisanTotal = _calculateTotal(items);

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
          _showOrderDetails(context, data, items, status);
        },
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2E6DA),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: Color(0xFFA24B2A),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          '#${_shortId(orderId)}',
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

              const SizedBox(height: 15),

              const Divider(height: 1),

              const SizedBox(height: 14),

              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 19,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Customer: ${_shortCustomerId(customerId)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 19,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${items.length} ${items.length == 1 ? 'product' : 'products'}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
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

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Your Order Value',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      '₹${artisanTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFA24B2A),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _showOrderDetails(context, data, items, status);
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Manage Order'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _artisanItems() {
    final rawItems = document.data()['items'];

    if (rawItems is! List) {
      return [];
    }

    return rawItems
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((item) => (item['artisanId'] ?? '').toString() == artisanId)
        .toList();
  }

  double _calculateTotal(List<Map<String, dynamic>> items) {
    double total = 0;

    for (final item in items) {
      final price = _toDouble(item['price']);

      final quantity = _toInt(item['quantity']);

      total += price * quantity;
    }

    return total;
  }

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

  String _shortId(String id) {
    if (id.length <= 10) {
      return id.toUpperCase();
    }

    return id.substring(0, 10).toUpperCase();
  }

  String _shortCustomerId(String id) {
    if (id.length <= 12) {
      return id;
    }

    return '${id.substring(0, 6)}...';
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

    return '$day/$month/$year • '
        '$hour:$minute $period';
  }

  void _showOrderDetails(
    BuildContext context,
    Map<String, dynamic> data,
    List<Map<String, dynamic>> items,
    String currentStatus,
  ) {
    final orderId = (data['orderId'] ?? document.id).toString();

    final customerId = (data['customerId'] ?? 'Customer').toString();

    final total = _calculateTotal(items);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String selectedStatus = currentStatus;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: const BoxConstraints(maxHeight: 720),
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
                              'Manage Order',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          _StatusBadge(status: selectedStatus),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Order #${_shortId(orderId)}',
                        style: const TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7F5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              color: Color(0xFFA24B2A),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Customer',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    customerId,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'Products',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Expanded(
                        child: items.isEmpty
                            ? const Center(child: Text('No products found.'))
                            : ListView.separated(
                                itemCount: items.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 9),
                                itemBuilder: (context, index) {
                                  return _OrderProduct(item: items[index]);
                                },
                              ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2E6DA),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Text(
                              '₹${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFA24B2A),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        'Update Order Status',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        initialValue: _validStatus(selectedStatus),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.sync),
                          filled: true,
                          fillColor: const Color(0xFFF4EFE7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'pending',
                            child: Text('Pending'),
                          ),
                          DropdownMenuItem(
                            value: 'confirmed',
                            child: Text('Confirmed'),
                          ),
                          DropdownMenuItem(
                            value: 'processing',
                            child: Text('Processing'),
                          ),
                          DropdownMenuItem(
                            value: 'shipped',
                            child: Text('Shipped'),
                          ),
                          DropdownMenuItem(
                            value: 'delivered',
                            child: Text('Delivered'),
                          ),
                          DropdownMenuItem(
                            value: 'cancelled',
                            child: Text('Cancelled'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setModalState(() {
                            selectedStatus = value;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () async {
                            await _updateStatus(context, selectedStatus);
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Update Status'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _validStatus(String status) {
    const statuses = [
      'pending',
      'confirmed',
      'processing',
      'shipped',
      'delivered',
      'cancelled',
    ];

    if (statuses.contains(status)) {
      return status;
    }

    return 'pending';
  }

  Future<void> _updateStatus(BuildContext context, String status) async {
    try {
      await document.reference.update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Order status updated to ${_statusLabel(status)}.'),
              backgroundColor: const Color(0xFFA24B2A),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Could not update order status.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }
}

// ================================================================
// ORDER PRODUCT
// ================================================================

class _OrderProduct extends StatelessWidget {
  final Map<String, dynamic> item;

  const _OrderProduct({required this.item});

  @override
  Widget build(BuildContext context) {
    final name = (item['name'] ?? 'Product').toString();

    final category = (item['category'] ?? 'Handicraft').toString();

    final imageUrl = (item['imageUrl'] ?? '').toString();

    final price = _toDouble(item['price']);

    final quantity = _toInt(item['quantity']);

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE4E9E6)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: SizedBox(
              width: 58,
              height: 58,
              child: imageUrl.isEmpty
                  ? Container(
                      color: const Color(0xFFF2E6DA),
                      child: const Icon(
                        Icons.image_outlined,
                        color: Color(0xFFA24B2A),
                      ),
                    )
                  : imageUrl.startsWith('assets/')
                      ? Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Image.network(
                            'https://heritrace.web.app/assets/images/heritage_shirt.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: const Color(0xFFF2E6DA),
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                color: Color(0xFFA24B2A),
                              ),
                            ),
                          ),
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) {
                            return Container(
                              color: const Color(0xFFF2E6DA),
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                color: Color(0xFFA24B2A),
                              ),
                            );
                          },
                        ),
            ),
          ),

          const SizedBox(width: 11),

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
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  category,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),

                const SizedBox(height: 5),

                Text(
                  '₹${price.toStringAsFixed(0)} × $quantity',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '₹${(price * quantity).toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

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
}

// ================================================================
// STATUS BADGE
// ================================================================

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
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// EMPTY STATE
// ================================================================

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
                color: const Color(0xFFF2E6DA),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 45,
                color: Color(0xFFA24B2A),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No Customer Orders',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 8),

            const Text(
              'Orders containing your artisan products will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// ERROR STATE
// ================================================================

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
            const Icon(
              Icons.cloud_off_outlined,
              size: 55,
              color: Colors.redAccent,
            ),

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
