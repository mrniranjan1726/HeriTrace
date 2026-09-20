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
                  final docData = doc.data();
                  final status = (docData['status'] ?? 'pending')
                      .toString()
                      .toLowerCase();
                  final returnStatus = docData['returnStatus'];
                  if (_selectedFilter == 'Pending' && (status == 'pending' || status == 'confirmed')) return true;
                  if (_selectedFilter == 'Crafting' && status == 'processing') return true;
                  if (_selectedFilter == 'Shipped' && status == 'shipped') return true;
                  if (_selectedFilter == 'Delivered' && status == 'delivered') return true;
                  if (_selectedFilter == 'Returns' &&
                      (returnStatus != null ||
                          status.contains('return') ||
                          status.contains('exchange') ||
                          status.contains('replace'))) {
                    return true;
                  }
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
    final filters = ['All', 'Pending', 'Crafting', 'Shipped', 'Delivered', 'Returns'];
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
    final returnStatus = data['returnStatus']?.toString().toLowerCase();
    final returnType = (data['returnType'] ?? 'return').toString().toLowerCase();
    final returnReason = (data['returnReason'] ?? '').toString();

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
                  _StatusBadge(
                    status: status,
                    returnStatus: returnStatus,
                    returnType: returnType,
                  ),
                ],
              ),

              if (returnStatus != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8EC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF0D5B5)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        returnType == 'exchange'
                            ? Icons.swap_horiz_rounded
                            : returnType == 'replace'
                                ? Icons.replay_rounded
                                : Icons.assignment_return_outlined,
                        size: 18,
                        color: const Color(0xFF9A5B00),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getReturnSummaryText(returnStatus, returnType),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF7A4500),
                              ),
                            ),
                            if (returnReason.isNotEmpty)
                              Text(
                                'Reason: $returnReason',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF8D5B1B),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

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
                  if (returnStatus == null &&
                      (status == 'delivered' || status == 'shipped' || status == 'confirmed')) ...[
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF8C530A),
                        side: const BorderSide(color: Color(0xFFE8C288)),
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _showReturnExchangeModal(context),
                      icon: const Icon(Icons.sync_alt, size: 14),
                      label: const Text(
                        'Return / Replace',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ] else if (returnStatus == 'requested') ...[
                    TextButton.icon(
                      onPressed: () => _cancelReturnRequest(context),
                      icon: const Icon(Icons.close, size: 14, color: Color(0xFFB3261E)),
                      label: const Text(
                        'Cancel Request',
                        style: TextStyle(
                          color: Color(0xFFB3261E),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
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
    final returnStatus = data['returnStatus']?.toString().toLowerCase();
    final returnType = (data['returnType'] ?? 'return').toString().toLowerCase();
    final returnReason = (data['returnReason'] ?? '').toString();
    final returnNotes = (data['returnNotes'] ?? '').toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: const BoxConstraints(maxHeight: 680),
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
                      _StatusBadge(
                        status: status,
                        returnStatus: returnStatus,
                        returnType: returnType,
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Order #${_shortOrderId(orderId)} · Direct Artisan Payment',
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),

                  const SizedBox(height: 18),

                  _OrderStatusTimeline(
                    status: status,
                    returnStatus: returnStatus,
                    returnType: returnType,
                  ),

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

                  if (returnStatus != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8EC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFF0D5B5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                returnType == 'exchange'
                                    ? Icons.swap_horiz_rounded
                                    : returnType == 'replace'
                                        ? Icons.replay_rounded
                                        : Icons.assignment_return_outlined,
                                size: 18,
                                color: const Color(0xFF9A5B00),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getReturnSummaryText(returnStatus, returnType),
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF7A4500),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (returnReason.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Reason: $returnReason',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5C3700),
                              ),
                            ),
                          ],
                          if (returnNotes.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Notes: $returnNotes',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B4208),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ] else if (status == 'delivered' || status == 'shipped' || status == 'confirmed') ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF8C530A),
                          side: const BorderSide(color: Color(0xFFE8C288)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showReturnExchangeModal(context);
                        },
                        icon: const Icon(Icons.sync_alt, size: 18),
                        label: const Text(
                          'Return, Exchange or Replace Item',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showReturnExchangeModal(BuildContext context) {
    String selectedType = 'exchange';
    String selectedReason = 'Size / fit does not match';
    final notesController = TextEditingController();
    bool isSubmitting = false;

    final reasonsByType = {
      'exchange': [
        'Size / fit does not match',
        'Prefer a different color / shade',
        'Different weaving style preferred',
        'Ordered incorrect size by mistake',
      ],
      'replace': [
        'Damaged or defective craft',
        'Item broken / chipped in transit',
        'Missing artisanal tag / accessories',
        'Defective stitching or fabric flaw',
      ],
      'return': [
        'Quality not as expected',
        'Item differs from photos / description',
        'Handcraft variation exceeds expectation',
        'Wrong item delivered',
        'Arrived too late for occasion',
      ],
    };

    final address = (data['deliveryAddress'] ?? 'Your registered delivery address').toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (builderCtx, setModalState) {
            final activeReasons = reasonsByType[selectedType] ?? reasonsByType['exchange']!;
            if (!activeReasons.contains(selectedReason)) {
              selectedReason = activeReasons.first;
            }

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(modalContext).size.height * 0.88,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(modalContext).viewInsets.bottom + 16,
                    left: 20,
                    right: 20,
                    top: 14,
                  ),
                  child: SingleChildScrollView(
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
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3DC),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.sync_alt,
                                color: Color(0xFF9A5B00),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Return, Exchange or Replace',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: _text,
                                    ),
                                  ),
                                  Text(
                                    'HeriTrace 7-Day Artisan Guarantee',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _muted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(modalContext),
                              icon: const Icon(Icons.close, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          '1. Choose Resolution',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: _text,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildActionOption(
                              label: 'Exchange',
                              subtitle: 'Different size',
                              icon: Icons.swap_horiz_rounded,
                              isSelected: selectedType == 'exchange',
                              onTap: () => setModalState(() => selectedType = 'exchange'),
                            ),
                            const SizedBox(width: 8),
                            _buildActionOption(
                              label: 'Replace',
                              subtitle: 'Damaged piece',
                              icon: Icons.replay_rounded,
                              isSelected: selectedType == 'replace',
                              onTap: () => setModalState(() => selectedType = 'replace'),
                            ),
                            const SizedBox(width: 8),
                            _buildActionOption(
                              label: 'Return',
                              subtitle: 'Full refund',
                              icon: Icons.assignment_return_outlined,
                              isSelected: selectedType == 'return',
                              onTap: () => setModalState(() => selectedType = 'return'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          '2. Reason for Request',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: _text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...activeReasons.map((reason) {
                          final isSelected = selectedReason == reason;
                          return InkWell(
                            onTap: () => setModalState(() => selectedReason = reason),
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    size: 19,
                                    color: isSelected ? _headerStart : Colors.grey,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      reason,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: isSelected ? _text : const Color(0xFF4A4A4A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 14),
                        const Text(
                          '3. Notes & Instructions (Optional)',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: _text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: notesController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: selectedType == 'exchange'
                                ? 'Specify your desired size (e.g. Need M instead of L)...'
                                : selectedType == 'replace'
                                    ? 'Describe the damage or defect...'
                                    : 'Any additional notes for the pickup agent...',
                            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                            filled: true,
                            fillColor: const Color(0xFFF9F6F0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE8DFD3)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE8DFD3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: _headerStart, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F9F7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD4E8DC)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.local_shipping_outlined, color: Color(0xFF1E5638), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Doorstep Reverse Pickup',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1E5638),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Courier pickup from $address within 2 business days. 100% free pickup.',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF335C45),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _headerStart,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 2,
                            ),
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    setModalState(() => isSubmitting = true);
                                    try {
                                      final user = FirebaseAuth.instance.currentUser;
                                      if (user != null) {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(user.uid)
                                            .collection('orders')
                                            .doc(orderId)
                                            .update({
                                              'returnStatus': 'requested',
                                              'returnType': selectedType,
                                              'returnReason': selectedReason,
                                              'returnNotes': notesController.text.trim(),
                                              'returnRequestedAt': FieldValue.serverTimestamp(),
                                            });
                                      }
                                      if (modalContext.mounted) {
                                        Navigator.pop(modalContext);
                                      }
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${selectedType[0].toUpperCase()}${selectedType.substring(1)} request submitted! Pickup will be arranged shortly.',
                                            ),
                                            backgroundColor: const Color(0xFF1E5638),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      setModalState(() => isSubmitting = false);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Failed to submit request: $e'),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      }
                                    }
                                  },
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Submit ${selectedType[0].toUpperCase()}${selectedType.substring(1)} Request',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13.5,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionOption({
    required String label,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFF4EB) : const Color(0xFFF9F7F4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _headerStart : const Color(0xFFE8DFD3),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: isSelected ? _headerStart : _muted),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? _headerStart : _text,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: _muted,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _cancelReturnRequest(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Cancel Return Request?'),
        content: const Text(
          'Are you sure you want to cancel this return/exchange request? Your order will remain in its original delivered status.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Keep Request'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB3261E)),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('orders')
                      .doc(orderId)
                      .update({
                        'returnStatus': FieldValue.delete(),
                        'returnType': FieldValue.delete(),
                        'returnReason': FieldValue.delete(),
                        'returnNotes': FieldValue.delete(),
                        'returnRequestedAt': FieldValue.delete(),
                      });
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Return request cancelled.'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getReturnSummaryText(String status, String type) {
    final typeName = type[0].toUpperCase() + type.substring(1);
    switch (status) {
      case 'requested':
        return '$typeName Requested • Pickup Scheduled';
      case 'approved':
        return '$typeName Approved • Reverse Pickup In Progress';
      case 'picked_up':
        return 'Item Picked Up • Inspection in Progress';
      case 'completed':
        return type == 'return' ? 'Refund Credited • Return Complete' : '$typeName Delivered';
      case 'declined':
        return '$typeName Declined by Artisan';
      default:
        return '$typeName Status: $status';
    }
  }
}

class _OrderStatusTimeline extends StatelessWidget {
  final String status;
  final String? returnStatus;
  final String? returnType;

  static const Color _headerStart = Color(0xFF7A2012);

  const _OrderStatusTimeline({
    required this.status,
    this.returnStatus,
    this.returnType,
  });

  @override
  Widget build(BuildContext context) {
    if (returnStatus != null) {
      final type = returnType ?? 'return';
      final typeCapitalized = type == 'exchange'
          ? 'Exchange'
          : type == 'replace'
              ? 'Replacement'
              : 'Return & Refund';

      const returnStages = [
        'requested',
        'approved',
        'picked_up',
        'completed',
      ];

      final activeReturnIndex = returnStatus == 'declined'
          ? -1
          : returnStages.indexOf(returnStatus!);

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8EC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0D5B5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  type == 'exchange'
                      ? Icons.swap_horiz_rounded
                      : type == 'replace'
                          ? Icons.replay_rounded
                          : Icons.assignment_return_outlined,
                  size: 16,
                  color: const Color(0xFF9A5B00),
                ),
                const SizedBox(width: 6),
                Text(
                  '$typeCapitalized Tracking',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7A4500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(returnStages.length, (index) {
                final active = activeReturnIndex >= index;
                return Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFF9A5B00)
                              : const Color(0xFFE2D6C6),
                          shape: BoxShape.circle,
                        ),
                        child: active
                            ? const Icon(Icons.check, size: 12, color: Colors.white)
                            : null,
                      ),
                      if (index < returnStages.length - 1)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: activeReturnIndex > index
                                ? const Color(0xFF9A5B00)
                                : const Color(0xFFE2D6C6),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: returnStages
                  .map(
                    (stage) => Text(
                      _returnStageTitle(stage, type),
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF7A5C33),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (returnStatus == 'declined')
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'This request was declined by the artisan.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      );
    }

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

  String _returnStageTitle(String stage, String type) {
    switch (stage) {
      case 'requested':
        return 'Requested';
      case 'approved':
        return 'Approved';
      case 'picked_up':
        return 'Picked Up';
      case 'completed':
        return type == 'return' ? 'Refunded' : 'Delivered';
      default:
        return stage;
    }
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
      child: imageUrl.startsWith('assets/')
          ? Image.asset(
              imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Image.network(
                'https://heritrace.web.app/assets/images/heritage_shirt.png',
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 64,
                  height: 64,
                  color: const Color(0xFFF2E6DA),
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Color(0xFF7A2012),
                  ),
                ),
              ),
            )
          : Image.network(
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
  final String? returnStatus;
  final String? returnType;

  const _StatusBadge({
    required this.status,
    this.returnStatus,
    this.returnType,
  });

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;
    IconData icon;
    String label;

    if (returnStatus != null) {
      final type = returnType ?? 'return';
      final typeName = type == 'exchange'
          ? 'Exchange'
          : type == 'replace'
              ? 'Replacement'
              : 'Return';

      switch (returnStatus) {
        case 'requested':
          background = const Color(0xFFFFF3DC);
          foreground = const Color(0xFF9A6700);
          icon = Icons.sync;
          label = '$typeName Requested';
          break;
        case 'approved':
          background = const Color(0xFFE8F0FF);
          foreground = const Color(0xFF1976D2);
          icon = Icons.local_shipping_outlined;
          label = '$typeName Approved';
          break;
        case 'picked_up':
          background = const Color(0xFFEDE7F6);
          foreground = const Color(0xFF5E35B1);
          icon = Icons.inventory_2_outlined;
          label = '$typeName Picked Up';
          break;
        case 'completed':
          background = const Color(0xFFE6F5ED);
          foreground = const Color(0xFF1E5638);
          icon = Icons.check_circle_outline;
          label = type == 'return' ? 'Refund Credited' : '$typeName Completed';
          break;
        case 'declined':
          background = const Color(0xFFFFE8E8);
          foreground = const Color(0xFFB3261E);
          icon = Icons.cancel_outlined;
          label = '$typeName Declined';
          break;
        default:
          background = const Color(0xFFFFF3DC);
          foreground = const Color(0xFF9A6700);
          icon = Icons.sync;
          label = '$typeName $returnStatus';
      }
    } else {
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
