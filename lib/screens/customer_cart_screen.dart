import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/razorpay_service.dart';
import '../services/api_config.dart';

class CustomerCartScreen extends StatefulWidget {
  const CustomerCartScreen({super.key});

  @override
  State<CustomerCartScreen> createState() => _CustomerCartScreenState();
}

class _CustomerCartScreenState extends State<CustomerCartScreen> {
  bool _isProcessingPayment = false;

  String get _backendBaseUrl => ApiConfig.baseUrl;

  User? get _currentUser {
    return FirebaseAuth.instance.currentUser;
  }

  CollectionReference<Map<String, dynamic>> get _cartRef {
    final uid = _currentUser?.uid;

    if (uid == null) {
      throw Exception('User is not logged in.');
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart');
  }

  CollectionReference<Map<String, dynamic>> get _addressesRef {
    final uid = _currentUser?.uid;

    if (uid == null) {
      throw Exception('User is not logged in.');
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('addresses');
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Cart')),
        body: const Center(child: Text('Please login to view your cart.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _cartRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load cart.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return _buildEmptyCart();
          }

          return _buildCart(context, docs);
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 90,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Add some beautiful artisan products to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCart(
    BuildContext context,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    double total = 0;

    for (final doc in docs) {
      final data = doc.data();

      final price = _toDouble(data['price']);
      final quantity = _toInt(data['quantity']);

      total += price * quantity;
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];

              return _CartItemCard(
                document: doc,
                onDelete: () => _removeCartItem(doc.id),
                onQuantityChanged: (quantity) {
                  _updateQuantity(doc.id, quantity);
                },
              );
            },
          ),
        ),

        _CartSummary(
          total: total,
          isProcessing: _isProcessingPayment,
          onCheckout: () {
            _startCheckout(docs, total);
          },
        ),
      ],
    );
  }

  Future<void> _startCheckout(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> cartDocs,
    double total,
  ) async {
    if (_isProcessingPayment) {
      return;
    }

    if (cartDocs.isEmpty || total <= 0) {
      _showMessage('Your cart is empty.', isError: true);
      return;
    }

    final user = _currentUser;

    if (user == null) {
      _showMessage('Please login first.', isError: true);
      return;
    }

    final address = await _selectDeliveryAddress();

    if (address == null) {
      return;
    }

    final shouldContinue = await _showOrderConfirmation(total, address);

    if (!shouldContinue) {
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final orderReceipt = 'HT_${DateTime.now().millisecondsSinceEpoch}';

      final createOrderResponse = await http.post(
        Uri.parse('$_backendBaseUrl/payments/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': total,
          'receipt': orderReceipt,
          'notes': {'customer_id': user.uid, 'project': 'HeriTrace'},
        }),
      );

      if (createOrderResponse.statusCode != 200) {
        throw Exception(_extractBackendError(createOrderResponse.body));
      }

      final responseData =
          jsonDecode(createOrderResponse.body) as Map<String, dynamic>;

      if (responseData['success'] != true) {
        throw Exception(
          responseData['detail']?.toString() ??
              'Unable to create payment order.',
        );
      }

      final keyId = responseData['key_id']?.toString();

      final razorpayOrderId = responseData['order_id']?.toString();

      final amountPaise = _toInt(responseData['amount']);

      if (keyId == null ||
          keyId.isEmpty ||
          razorpayOrderId == null ||
          razorpayOrderId.isEmpty ||
          amountPaise <= 0) {
        throw Exception('Invalid Razorpay order response from server.');
      }

      final paymentResult = await openRazorpayCheckout(
        keyId: keyId,
        amountPaise: amountPaise,
        orderId: razorpayOrderId,
        name: 'HeriTrace',
        description: 'Artisan products from HeriTrace',
        email: user.email,
        phone: null,
      );

      if (!mounted) {
        return;
      }

      if (paymentResult.cancelled) {
        _showMessage('Payment cancelled.');
        return;
      }

      if (!paymentResult.success) {
        _showMessage(
          paymentResult.errorMessage ?? 'Payment failed.',
          isError: true,
        );
        return;
      }

      if (paymentResult.paymentId == null ||
          paymentResult.orderId == null ||
          paymentResult.signature == null) {
        throw Exception('Razorpay returned an incomplete payment response.');
      }

      final verified = await _verifyPayment(
        orderId: paymentResult.orderId!,
        paymentId: paymentResult.paymentId!,
        signature: paymentResult.signature!,
      );

      if (!verified) {
        throw Exception('Payment verification failed.');
      }

      await _saveVerifiedOrder(
        cartDocs: cartDocs,
        total: total,
        address: address,
        paymentId: paymentResult.paymentId!,
        razorpayOrderId: paymentResult.orderId!,
      );

      if (!mounted) {
        return;
      }

      _showPaymentSuccess();
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(e.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  Future<bool> _verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final response = await http.post(
      Uri.parse('$_backendBaseUrl/payments/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      }),
    );

    if (response.statusCode != 200) {
      return false;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return data['success'] == true && data['verified'] == true;
  }

  Future<void> _saveVerifiedOrder({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> cartDocs,
    required double total,
    required Map<String, dynamic> address,
    required String paymentId,
    required String razorpayOrderId,
  }) async {
    final user = _currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final firestore = FirebaseFirestore.instance;

    final orderRef = firestore
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .doc();

    final items = cartDocs.map((doc) {
      final data = doc.data();

      return {
        'productId': data['productId'] ?? doc.id,
        'artisanId': data['artisanId'],
        'name': data['name'] ?? 'Artisan Product',
        'category': data['category'] ?? 'Handicraft',
        'price': _toDouble(data['price']),
        'quantity': _toInt(data['quantity']),
        'imageUrl': data['imageUrl'],
      };
    }).toList();

    await orderRef.set({
      'orderId': orderRef.id,
      'customerId': user.uid,
      'customerEmail': user.email,

      'items': items,

      'total': total,

      'status': 'pending',

      'paymentStatus': 'paid',
      'paymentMethod': 'razorpay',

      'paymentId': paymentId,
      'razorpayOrderId': razorpayOrderId,

      'deliveryAddress': {
        'name': address['name'],
        'phone': address['phone'],
        'house': address['house'],
        'street': address['street'],
        'city': address['city'],
        'state': address['state'],
        'pincode': address['pincode'],
        'landmark': address['landmark'],
      },

      'createdAt': FieldValue.serverTimestamp(),

      'paidAt': FieldValue.serverTimestamp(),
    });

    final batch = firestore.batch();

    for (final doc in cartDocs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<Map<String, dynamic>?> _selectDeliveryAddress() async {
    final addressesSnapshot = await _addressesRef
        .orderBy('createdAt', descending: false)
        .get();

    if (!mounted) {
      return null;
    }

    final addresses = addressesSnapshot.docs;

    if (addresses.isEmpty) {
      return _showAddressForm();
    }

    String? selectedId;

    for (final doc in addresses) {
      final data = doc.data();

      if (data['isDefault'] == true) {
        selectedId = doc.id;
        break;
      }
    }

    selectedId ??= addresses.first.id;

    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Delivery Address',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 400),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: addresses.length,
                        itemBuilder: (context, index) {
                          final doc = addresses[index];

                          final data = doc.data();

                          final selected = selectedId == doc.id;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setSheetState(() {
                                  selectedId = doc.id;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Radio<String>(
                                      value: doc.id,
                                      groupValue: selectedId,
                                      onChanged: (value) {
                                        setSheetState(() {
                                          selectedId = value;
                                        });
                                      },
                                    ),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  data['name']?.toString() ??
                                                      '',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),

                                              if (data['isDefault'] == true)
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                    color: Colors.green
                                                        .withOpacity(0.12),
                                                  ),
                                                  child: const Text(
                                                    'Default',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),

                                          const SizedBox(height: 4),

                                          Text(data['phone']?.toString() ?? ''),

                                          const SizedBox(height: 4),

                                          Text(_formatAddress(data)),

                                          const SizedBox(height: 8),

                                          Wrap(
                                            spacing: 6,
                                            children: [
                                              TextButton.icon(
                                                onPressed: () async {
                                                  final updated =
                                                      await _showAddressForm(
                                                        existing: data,
                                                        documentId: doc.id,
                                                      );

                                                  if (updated != null) {
                                                    if (mounted) {
                                                      Navigator.pop(context);
                                                    }
                                                  }
                                                },
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                  size: 18,
                                                ),
                                                label: const Text('Edit'),
                                              ),

                                              TextButton.icon(
                                                onPressed: () async {
                                                  await _deleteAddress(doc.id);

                                                  if (!mounted) {
                                                    return;
                                                  }

                                                  setSheetState(() {});
                                                },
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  size: 18,
                                                ),
                                                label: const Text('Delete'),
                                              ),

                                              if (data['isDefault'] != true)
                                                TextButton(
                                                  onPressed: () async {
                                                    await _setDefaultAddress(
                                                      doc.id,
                                                    );

                                                    if (!mounted) {
                                                      return;
                                                    }

                                                    setSheetState(() {});
                                                  },
                                                  child: const Text(
                                                    'Set default',
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
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final result = await _showAddressForm();

                          if (result != null && mounted) {
                            Navigator.pop(context, result);
                          }
                        },
                        icon: const Icon(Icons.add_location_alt_outlined),
                        label: const Text('Add New Address'),
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedId == null
                            ? null
                            : () {
                                final selected = addresses.firstWhere(
                                  (doc) => doc.id == selectedId,
                                );

                                Navigator.pop(context, selected.data());
                              },
                        child: const Text('Deliver to this address'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _showAddressForm({
    Map<String, dynamic>? existing,
    String? documentId,
  }) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return _AddressFormSheet(existing: existing);
      },
    );

    if (result == null) {
      return null;
    }

    if (documentId == null) {
      await _addressesRef.add({
        ...result,
        'isDefault': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await _addressesRef.doc(documentId).update({
        ...result,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    final savedAddress = Map<String, dynamic>.from(result);

    savedAddress['isDefault'] = existing?['isDefault'] == true;
    savedAddress['_id'] = documentId;

    return savedAddress;
  }

  Future<void> _deleteAddress(String addressId) async {
    await _addressesRef.doc(addressId).delete();
  }

  Future<void> _setDefaultAddress(String addressId) async {
    final snapshot = await _addressesRef.get();

    final batch = FirebaseFirestore.instance.batch();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isDefault': doc.id == addressId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<bool> _showOrderConfirmation(
    double total,
    Map<String, dynamic> address,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delivery address',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(_formatAddress(address)),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₹${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Text('You will be redirected to Razorpay secure checkout.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Pay Securely'),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  String _formatAddress(Map<String, dynamic> data) {
    final parts = <String>[];

    void addPart(dynamic value) {
      final text = value?.toString().trim() ?? '';

      if (text.isNotEmpty) {
        parts.add(text);
      }
    }

    addPart(data['house']);
    addPart(data['street']);
    addPart(data['landmark']);
    addPart(data['city']);
    addPart(data['state']);
    addPart(data['pincode']);

    return parts.join(', ');
  }

  Future<void> _removeCartItem(String id) async {
    try {
      await _cartRef.doc(id).delete();

      _showMessage('Item removed from cart.');
    } catch (e) {
      _showMessage('Unable to remove item.', isError: true);
    }
  }

  Future<void> _updateQuantity(String id, int quantity) async {
    if (quantity <= 0) {
      await _removeCartItem(id);
      return;
    }

    try {
      await _cartRef.doc(id).update({'quantity': quantity});
    } catch (e) {
      _showMessage('Unable to update quantity.', isError: true);
    }
  }

  String _extractBackendError(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;

      return data['detail']?.toString() ?? 'Server returned an error.';
    } catch (_) {
      return 'Server returned an error.';
    }
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  void _showPaymentSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
          title: const Text('Payment Successful'),
          content: const Text(
            'Your order has been placed successfully.\n\n'
            'You can view your order from My Orders.',
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Continue Shopping'),
              ),
            ),
          ],
        );
      },
    );
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
          backgroundColor: isError ? Colors.red : null,
        ),
      );
  }
}

class _CartItemCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> document;

  final VoidCallback onDelete;

  final ValueChanged<int> onQuantityChanged;

  const _CartItemCard({
    required this.document,
    required this.onDelete,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final data = document.data();

    final name = data['name']?.toString() ?? 'Product';

    final category = data['category']?.toString() ?? 'Handicraft';

    final price = _toDouble(data['price']);

    final quantity = _toInt(data['quantity']);

    final imageUrl = data['imageUrl']?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductImage(imageUrl: imageUrl),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(category, style: TextStyle(color: Colors.grey.shade600)),

                  const SizedBox(height: 8),

                  Text(
                    '₹${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      IconButton(
                        onPressed: quantity > 1
                            ? () => onQuantityChanged(quantity - 1)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),

                      Text(
                        '$quantity',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      IconButton(
                        onPressed: () => onQuantityChanged(quantity + 1),
                        icon: const Icon(Icons.add_circle_outline),
                      ),

                      const Spacer(),

                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
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

    return int.tryParse(value?.toString() ?? '') ?? 1;
  }
}

class _ProductImage extends StatelessWidget {
  final String? imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.grey.shade100,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported_outlined, size: 35);
              },
            )
          : const Icon(Icons.image_outlined, size: 35),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final double total;
  final bool isProcessing;
  final VoidCallback onCheckout;

  const _CartSummary({
    required this.total,
    required this.isProcessing,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, -3),
              color: Colors.black.withOpacity(0.08),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isProcessing ? null : onCheckout,
                icon: isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.lock_outline),
                label: Text(
                  isProcessing ? 'Processing Payment...' : 'Pay Securely',
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Secure payment powered by Razorpay',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressFormSheet extends StatefulWidget {
  final Map<String, dynamic>? existing;

  const _AddressFormSheet({this.existing});

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;

  late final TextEditingController _phoneController;

  late final TextEditingController _houseController;

  late final TextEditingController _streetController;

  late final TextEditingController _cityController;

  late final TextEditingController _stateController;

  late final TextEditingController _pincodeController;

  late final TextEditingController _landmarkController;

  @override
  void initState() {
    super.initState();

    final data = widget.existing ?? {};

    _nameController = TextEditingController(
      text: data['name']?.toString() ?? '',
    );

    _phoneController = TextEditingController(
      text: data['phone']?.toString() ?? '',
    );

    _houseController = TextEditingController(
      text: data['house']?.toString() ?? '',
    );

    _streetController = TextEditingController(
      text: data['street']?.toString() ?? '',
    );

    _cityController = TextEditingController(
      text: data['city']?.toString() ?? '',
    );

    _stateController = TextEditingController(
      text: data['state']?.toString() ?? '',
    );

    _pincodeController = TextEditingController(
      text: data['pincode']?.toString() ?? '',
    );

    _landmarkController = TextEditingController(
      text: data['landmark']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _houseController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _landmarkController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isEditing ? 'Update Address' : 'Add New Address',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                _field(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  requiredField: true,
                ),

                _field(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  requiredField: true,
                ),

                _field(
                  controller: _houseController,
                  label: 'House / Flat / Building',
                  icon: Icons.home_outlined,
                  requiredField: true,
                ),

                _field(
                  controller: _streetController,
                  label: 'Street / Area',
                  icon: Icons.location_on_outlined,
                  requiredField: true,
                ),

                Row(
                  children: [
                    Expanded(
                      child: _field(
                        controller: _cityController,
                        label: 'City',
                        icon: Icons.location_city_outlined,
                        requiredField: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _field(
                        controller: _stateController,
                        label: 'State',
                        icon: Icons.map_outlined,
                        requiredField: true,
                      ),
                    ),
                  ],
                ),

                _field(
                  controller: _pincodeController,
                  label: 'PIN Code',
                  icon: Icons.pin_drop_outlined,
                  keyboardType: TextInputType.number,
                  requiredField: true,
                ),

                _field(
                  controller: _landmarkController,
                  label: 'Landmark',
                  icon: Icons.place_outlined,
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(isEditing ? 'Update Address' : 'Save Address'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool requiredField = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: requiredField
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }

                return null;
              }
            : null,
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.pop(context, {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'house': _houseController.text.trim(),
      'street': _streetController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'pincode': _pincodeController.text.trim(),
      'landmark': _landmarkController.text.trim(),
    });
  }
}
