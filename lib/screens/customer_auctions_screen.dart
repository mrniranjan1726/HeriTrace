import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/auction.dart';
import '../services/firebase_service.dart';

class CustomerAuctionsScreen extends StatelessWidget {
  const CustomerAuctionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rare Craft Auctions')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('auctions').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load auctions: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final auctions =
              snapshot.data!.docs
                  .map((doc) => Auction.fromMap(doc.id, doc.data()))
                  .where((auction) => auction.isOpen)
                  .toList()
                ..sort((a, b) => a.endsAt.compareTo(b.endsAt));

          if (auctions.isEmpty) {
            return const Center(
              child: Text('No live auctions are available right now.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: auctions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _CustomerAuctionCard(auction: auctions[index]),
          );
        },
      ),
    );
  }
}

class _CustomerAuctionCard extends StatelessWidget {
  const _CustomerAuctionCard({required this.auction});

  final Auction auction;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.gavel, color: Color(0xFF176B5B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    auction.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Chip(label: Text('LIVE')),
              ],
            ),
            if (auction.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(auction.description),
            ],
            const SizedBox(height: 14),
            Text(
              'Current bid: ${currency.format(auction.currentBid)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '${auction.bidCount} bids • Ends ${DateFormat('d MMM, h:mm a').format(auction.endsAt)}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => _showBidDialog(context),
              icon: const Icon(Icons.trending_up),
              label: const Text('Place a bid'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBidDialog(BuildContext context) async {
    final amount = await showDialog<double>(
      context: context,
      builder: (_) => _BidDialog(auction: auction),
    );
    if (amount == null || !context.mounted) return;

    try {
      await FirebaseService().placeBid(auction: auction, amount: amount);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your bid was placed successfully.')),
        );
      }
    } on Exception catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
  }
}

class _BidDialog extends StatefulWidget {
  const _BidDialog({required this.auction});

  final Auction auction;

  @override
  State<_BidDialog> createState() => _BidDialogState();
}

class _BidDialogState extends State<_BidDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: (widget.auction.currentBid + 100).toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auction = widget.auction;
    return AlertDialog(
      title: Text('Bid on ${auction.title}'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Your bid (₹)'),
          validator: (value) {
            final bid = double.tryParse(value?.trim() ?? '');
            if (bid == null || bid <= auction.currentBid) {
              return 'Enter more than ₹${auction.currentBid.toStringAsFixed(0)}';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, double.parse(_controller.text.trim()));
            }
          },
          child: const Text('Submit bid'),
        ),
      ],
    );
  }
}
