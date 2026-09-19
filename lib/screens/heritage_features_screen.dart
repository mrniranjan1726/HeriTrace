import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HeritageFeaturesScreen extends StatefulWidget {
  const HeritageFeaturesScreen({super.key});

  @override
  State<HeritageFeaturesScreen> createState() => _HeritageFeaturesScreenState();
}

class _HeritageFeaturesScreenState extends State<HeritageFeaturesScreen> {
  static const _background = Color(0xFF081210);
  static const _surface = Color(0xFF11231E);
  static const _text = Color(0xFFF2FAF6);
  static const _muted = Color(0xFFA7BBB4);
  static const _accent = Color(0xFFE0A95E);

  int _selectedTab = 0;
  bool _loading = true;
  int _productCount = 0;
  int _auctionCount = 0;
  String _craft = 'Handcrafted heritage';
  String _location = 'India';

  final _tabs = const ['Heritage Identity', 'Trust & Archive', 'Discovery'];

  @override
  void initState() {
    super.initState();
    _loadSignals();
  }

  Future<void> _loadSignals() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final profile = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final data = profile.data() ?? {};
        _craft = (data['craft'] ?? data['specialization'] ?? _craft).toString();
        _location = (data['location'] ?? data['address'] ?? _location)
            .toString();
      }

      final products = await FirebaseFirestore.instance
          .collectionGroup('products')
          .limit(100)
          .get();
      final auctions = await FirebaseFirestore.instance
          .collection('auctions')
          .where('status', isEqualTo: 'live')
          .limit(100)
          .get();

      _productCount = products.docs.length;
      _auctionCount = auctions.docs.length;
    } on FirebaseException {
      // The feature hub remains usable when an optional signal is unavailable.
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  List<_Feature> get _features {
    if (_selectedTab == 0) {
      return [
        _Feature(
          'Craft DNA',
          'Your living craft identity',
          'Build a signature from material, region, story, and making style.',
          Icons.biotech_rounded,
          const Color(0xFF53D7B9),
          'Profile signal: $_craft · $_location',
          'Craft DNA is ready to evolve as you add products, stories, and techniques.',
        ),
        _Feature(
          'Craft Journey',
          'From raw material to heirloom',
          'A visual timeline that preserves every meaningful making milestone.',
          Icons.route_rounded,
          const Color(0xFFE6B866),
          'Journey workspace',
          'Materials → preparation → technique → finishing → provenance → buyer story',
        ),
        _Feature(
          'Technique Fingerprint',
          'Recognise the maker behind the work',
          'Capture repeatable technique signals so every piece feels traceable.',
          Icons.fingerprint_rounded,
          const Color(0xFF9C9BFF),
          'Fingerprint workspace',
          'Material grain, pattern rhythm, finishing style, and artisan notes are combined into a unique signature.',
        ),
      ];
    }

    if (_selectedTab == 1) {
      return [
        _Feature(
          'Heritage Provenance Chain',
          'Trust, recorded beautifully',
          'A tamper-aware story trail for origin, maker, material, and ownership.',
          Icons.link_rounded,
          const Color(0xFF63C9F5),
          'Chain workspace available',
          'Origin record → artisan record → craft record → marketplace record → buyer record',
        ),
        _Feature(
          'Heritage Risk Alert',
          'Protect endangered knowledge',
          'Surface fragile techniques, disappearing materials, and urgent documentation gaps.',
          Icons.crisis_alert_rounded,
          const Color(0xFFFF967F),
          'Preservation workspace',
          'Add a craft story or archive video to improve the heritage protection score for this tradition.',
        ),
        _Feature(
          'Living Craft Archive',
          'A memory that keeps moving',
          'Store short process stories, workshop moments, and voices from the maker community.',
          Icons.video_camera_back_rounded,
          const Color(0xFFE58BD8),
          'Archive workspace',
          'Connect a video, audio note, or photo sequence to make the craft discoverable for future generations.',
        ),
      ];
    }

    return [
      _Feature(
        'AI Artisan–Buyer Matchmaker',
        'Better matches, meaningful purchases',
        'Recommend products by craft affinity, story, material, and intent.',
        Icons.auto_awesome_rounded,
        const Color(0xFF70D6FF),
        'Catalog-based matching',
        'Recommendations are currently based on catalog and profile signals. Connect an AI provider before enabling automated scoring.',
      ),
      _Feature(
        'Virtual Craft Museum',
        'Walk through living heritage',
        'A digital gallery for collections, techniques, and artisan voices.',
        Icons.museum_rounded,
        const Color(0xFFF2C879),
        '$_productCount catalog items',
        'Explore the marketplace as a curated exhibition instead of a product list.',
      ),
      _Feature(
        'Rare Auction Intelligence',
        'Bid with context',
        'See active heritage auctions and understand the story behind every lot.',
        Icons.gavel_rounded,
        const Color(0xFFFFA66B),
        '$_auctionCount live auctions',
        'Open Rare Auctions to discover limited pieces and support living artisan traditions.',
      ),
    ];
  }

  void _openFeature(_Feature feature) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _muted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Icon(feature.icon, color: feature.color, size: 34),
              const SizedBox(height: 13),
              Text(
                feature.title,
                style: const TextStyle(
                  color: _text,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                feature.subtitle,
                style: TextStyle(
                  color: feature.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                feature.detail,
                style: const TextStyle(color: _muted, height: 1.6),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    if (feature.title == 'Rare Auction Intelligence') {
                      Navigator.pushNamed(this.context, '/customer-auctions');
                    } else if (feature.title == 'Virtual Craft Museum') {
                      Navigator.pushNamed(this.context, '/marketplace');
                    } else {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${feature.title} is ready for your next story or upload.',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Open experience'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _text,
        title: const Text('Heritage Intelligence'),
        actions: [
          IconButton(
            tooltip: 'Refresh heritage signals',
            onPressed: _loading
                ? null
                : () {
                    setState(() => _loading = true);
                    _loadSignals();
                  },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _hero(),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _tabs.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 9),
                            itemBuilder: (context, index) => ChoiceChip(
                              label: Text(_tabs[index]),
                              selected: _selectedTab == index,
                              onSelected: (_) =>
                                  setState(() => _selectedTab = index),
                              selectedColor: _accent,
                              backgroundColor: _surface,
                              labelStyle: TextStyle(
                                color: _selectedTab == index
                                    ? _background
                                    : _muted,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                              side: BorderSide(
                                color: _selectedTab == index
                                    ? _accent
                                    : const Color(0xFF29443B),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final columns = constraints.maxWidth >= 760
                                ? 3
                                : constraints.maxWidth >= 500
                                ? 2
                                : 1;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _features.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: columns == 1 ? 2.2 : 0.96,
                                  ),
                              itemBuilder: (context, index) =>
                                  _featureCard(_features[index]),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF143F35), Color(0xFF0D2A24)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFF2D6758)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -42,
            child: Icon(
              Icons.account_tree_rounded,
              size: 150,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'THE NEXT LAYER OF HERITAGE',
                style: TextStyle(
                  color: _accent,
                  fontSize: 10,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Make every craft\ntraceable, alive, and discoverable.',
                style: TextStyle(
                  color: _text,
                  fontSize: 27,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'A presentation-ready command center for stories, trust, preservation, and meaningful commerce.',
                style: TextStyle(color: _muted, height: 1.5),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: [
                  _signal(
                    '$_productCount products',
                    Icons.inventory_2_outlined,
                  ),
                  _signal('$_auctionCount live auctions', Icons.gavel_outlined),
                  _signal('Verified platform', Icons.verified_outlined),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _signal(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _accent, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: _text,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureCard(_Feature feature) {
    return InkWell(
      onTap: () => _openFeature(feature),
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF29443B)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: feature.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(feature.icon, color: feature.color),
                ),
                const Spacer(),
                Icon(Icons.arrow_outward_rounded, color: _muted, size: 18),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              feature.title,
              style: const TextStyle(
                color: _text,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              feature.subtitle,
              style: TextStyle(
                color: feature.color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              feature.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _muted, fontSize: 12, height: 1.45),
            ),
            const Spacer(),
            Text(
              feature.signal,
              style: const TextStyle(
                color: _text,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final String signal;
  final String detail;

  const _Feature(
    this.title,
    this.subtitle,
    this.description,
    this.icon,
    this.color,
    this.signal,
    this.detail,
  );
}
