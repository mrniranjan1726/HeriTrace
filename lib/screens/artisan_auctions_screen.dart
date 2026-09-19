import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/auction.dart';
import '../services/firebase_service.dart';

class ArtisanAuctionsScreen extends StatefulWidget {
  const ArtisanAuctionsScreen({super.key});

  @override
  State<ArtisanAuctionsScreen> createState() => _ArtisanAuctionsScreenState();
}

class _ArtisanAuctionsScreenState extends State<ArtisanAuctionsScreen> {
  final _service = FirebaseService();
  final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  Future<void> _showCreateAuction() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CreateAuctionSheet(service: _service),
    );
    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Auction published successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rare Craft Auctions'),
        actions: [
          FilledButton.icon(
            onPressed: _showCreateAuction,
            icon: const Icon(Icons.add),
            label: const Text('Create auction'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: StreamBuilder<List<Auction>>(
        stream: _service.artisanAuctions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load auctions: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final auctions = snapshot.data!;
          if (auctions.isEmpty) {
            return _EmptyState(onCreate: _showCreateAuction);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: auctions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _AuctionCard(
              auction: auctions[index],
              currency: _currency,
              onClose: auctions[index].isOpen
                  ? () => _closeAuction(auctions[index])
                  : null,
            ),
          );
        },
      ),
    );
  }

  Future<void> _closeAuction(Auction auction) async {
    try {
      await _service.closeAuction(auction.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Auction closed.')));
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
  }
}

class _AuctionCard extends StatelessWidget {
  const _AuctionCard({
    required this.auction,
    required this.currency,
    required this.onClose,
  });

  final Auction auction;
  final NumberFormat currency;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final open = auction.isOpen;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    auction.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Chip(
                  label: Text(open ? 'LIVE' : 'CLOSED'),
                  avatar: Icon(
                    open ? Icons.circle : Icons.check,
                    size: 12,
                    color: open ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            if (auction.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                auction.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 18),
            Wrap(
              spacing: 28,
              runSpacing: 12,
              children: [
                _Metric(
                  label: 'Current bid',
                  value: currency.format(auction.currentBid),
                ),
                _Metric(
                  label: 'Starting bid',
                  value: currency.format(auction.startingPrice),
                ),
                _Metric(label: 'Bids', value: '${auction.bidCount}'),
                _Metric(
                  label: open ? 'Ends' : 'Ended',
                  value: DateFormat('d MMM, h:mm a').format(auction.endsAt),
                ),
              ],
            ),
            if (onClose != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onClose,
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('Close auction'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.gavel_outlined,
              size: 56,
              color: Color(0xFFA24B2A),
            ),
            const SizedBox(height: 14),
            const Text(
              'Turn a rare craft into an exciting auction.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create an auction and let collectors bid for your work.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create your first auction'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateAuctionSheet extends StatefulWidget {
  const _CreateAuctionSheet({required this.service});
  final FirebaseService service;

  @override
  State<_CreateAuctionSheet> createState() => _CreateAuctionSheetState();
}

class _CreateAuctionSheetState extends State<_CreateAuctionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  DateTime _endsAt = DateTime.now().add(const Duration(days: 7));
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, bottom + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create rare craft auction',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Auction title'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a title'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Craft story or description',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Starting bid (₹)',
                ),
                validator: (value) {
                  final price = double.tryParse(value?.trim() ?? '');
                  return price == null || price <= 0
                      ? 'Enter a valid amount'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: const Text('Auction ends'),
                subtitle: Text(
                  DateFormat('d MMM yyyy, h:mm a').format(_endsAt),
                ),
                onTap: _chooseEndDate,
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Publish auction'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _chooseEndDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _endsAt,
    );
    if (date == null || !mounted) return;
    setState(() => _endsAt = DateTime(date.year, date.month, date.day, 23, 59));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.service.createAuction(
        title: _title.text,
        description: _description.text,
        startingPrice: double.parse(_price.text.trim()),
        endsAt: _endsAt,
      );
      if (mounted) Navigator.pop(context, true);
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }
}
