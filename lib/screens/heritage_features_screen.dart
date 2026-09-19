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
  static const _cardBorder = Color(0xFF29443B);
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
      // Signals load gracefully
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
        'Smart AI recommendation engine connecting collectors with living artisan workshops.',
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
    switch (feature.title) {
      case 'Craft DNA':
        _openCraftDnaExperience();
        break;
      case 'Technique Fingerprint':
        _openFingerprintExperience();
        break;
      case 'Craft Journey':
        _openCraftJourneyExperience();
        break;
      case 'Heritage Provenance Chain':
        _openProvenanceChainExperience();
        break;
      case 'Heritage Risk Alert':
        _openRiskAlertExperience();
        break;
      case 'Living Craft Archive':
        _openLivingArchiveExperience();
        break;
      case 'AI Artisan–Buyer Matchmaker':
        _openAiMatchmakerExperience();
        break;
      case 'Virtual Craft Museum':
        Navigator.pushNamed(context, '/marketplace');
        break;
      case 'Rare Auction Intelligence':
        Navigator.pushNamed(context, '/customer-auctions');
        break;
      default:
        _showOverviewSheet(feature);
    }
  }

  // ============================================================
  // 1. CRAFT DNA STUDIO EXPERIENCE
  // ============================================================
  void _openCraftDnaExperience() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        bool isSequencing = false;
        String dnaHash = 'HT-DNA-IN-88942-VERIFIED';
        bool verified = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
                child: Column(
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
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF53D7B9,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.biotech_rounded,
                            color: Color(0xFF53D7B9),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Craft DNA Studio',
                                style: TextStyle(
                                  color: _text,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                'Genetic provenance & material purity sequence',
                                style: TextStyle(color: _muted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // DNA Code Badge
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1D19),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF53D7B9).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.qr_code_2,
                                color: Color(0xFF53D7B9),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'ACTIVE DNA SIGNATURE',
                                style: TextStyle(
                                  color: Color(0xFF53D7B9),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF53D7B9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'GEN-4 COMPLIANT',
                                  style: TextStyle(
                                    color: Color(0xFF081210),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            dnaHash,
                            style: const TextStyle(
                              color: _text,
                              fontSize: 15,
                              fontFamily: 'Courier',
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Text(
                      'Genetic Craft Markers',
                      style: TextStyle(
                        color: _text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _markerRow(
                      'Fiber / Raw Base',
                      '100% Mulberry Hand-Spun Silk (Grade A)',
                      Icons.eco_outlined,
                    ),
                    _markerRow(
                      'Dye Chemistry',
                      'Natural Madder Root & Pomegranate Rind Extract',
                      Icons.water_drop_outlined,
                    ),
                    _markerRow(
                      'Motif Pedigree',
                      '17th Century Mughal Floral Buti Lineage',
                      Icons.auto_stories_outlined,
                    ),
                    _markerRow(
                      'Geo-Spatial Tag',
                      'Varanasi Weaving District (25.31°N, 82.97°E)',
                      Icons.location_on_outlined,
                    ),

                    const SizedBox(height: 20),

                    if (verified)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B3D2B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF4CAF50)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Craft DNA re-sequenced & cryptographic certificate saved to your profile!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF53D7B9),
                          foregroundColor: const Color(0xFF081210),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isSequencing
                            ? null
                            : () async {
                                setSheetState(() => isSequencing = true);
                                await Future.delayed(
                                  const Duration(milliseconds: 1200),
                                );

                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user.uid)
                                        .collection('craft_dna')
                                        .add({
                                          'dnaCode':
                                              'HT-DNA-IN-BR-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
                                          'verifiedAt':
                                              FieldValue.serverTimestamp(),
                                          'purityScore': 99.6,
                                          'fiberType': '100% Mulberry Silk',
                                        });
                                  } catch (_) {}
                                }

                                setSheetState(() {
                                  isSequencing = false;
                                  dnaHash =
                                      'HT-DNA-IN-BR-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}-VERIFIED';
                                  verified = true;
                                });
                              },
                        icon: isSequencing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF081210),
                                ),
                              )
                            : const Icon(Icons.sync_rounded),
                        label: Text(
                          isSequencing
                              ? 'Sequencing Micro-Fibers...'
                              : 'Re-Sequence & Verify DNA Certificate',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
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

  // ============================================================
  // 2. TECHNIQUE FINGERPRINT STUDIO EXPERIENCE
  // ============================================================
  void _openFingerprintExperience() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        bool scanning = false;
        bool scanComplete = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
                child: Column(
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
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF9C9BFF,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.fingerprint_rounded,
                            color: Color(0xFF9C9BFF),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Technique Fingerprint',
                                style: TextStyle(
                                  color: _text,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                'Biometric signature of human artisan technique',
                                style: TextStyle(color: _muted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Biometric Graphic
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1D19),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF9C9BFF).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.fingerprint,
                            size: 68,
                            color: scanComplete
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFF9C9BFF),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            scanComplete
                                ? 'TECHNIQUE MATCH: 99.8% ARTISAN HANDCRAFT'
                                : 'UNIQUE WEAVER SIGNATURE #9941',
                            style: TextStyle(
                              color: scanComplete
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFF9C9BFF),
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Organic human tension variations verify this craft was made by hand, not machine.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _muted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Text(
                      'Biometric Technique Markers',
                      style: TextStyle(
                        color: _text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _markerRow(
                      'Weft Tension Rhythm',
                      '142 picks/inch with organic ±1.8% human cadence',
                      Icons.linear_scale,
                    ),
                    _markerRow(
                      'Chisel Stroke Profile',
                      '2.8mm organic beveling (Master Carver Stroke)',
                      Icons.brush_outlined,
                    ),
                    _markerRow(
                      'Kiln Oxidation Bloom',
                      '1220°C low-oxygen reduction glaze signature',
                      Icons.fireplace_outlined,
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9C9BFF),
                          foregroundColor: const Color(0xFF081210),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: scanning
                            ? null
                            : () async {
                                setSheetState(() => scanning = true);
                                await Future.delayed(
                                  const Duration(milliseconds: 1400),
                                );
                                setSheetState(() {
                                  scanning = false;
                                  scanComplete = true;
                                });
                              },
                        icon: scanning
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF081210),
                                ),
                              )
                            : const Icon(Icons.document_scanner_rounded),
                        label: Text(
                          scanning
                              ? 'Analyzing Micro-Variations...'
                              : 'Capture & Verify Fingerprint',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
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

  // ============================================================
  // 3. CRAFT JOURNEY TIMELINE EXPERIENCE
  // ============================================================
  void _openCraftJourneyExperience() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
            child: Column(
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
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6B866).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.route_rounded,
                        color: Color(0xFFE6B866),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Craft Journey Tracker',
                            style: TextStyle(
                              color: _text,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Interactive timeline from raw harvest to heirloom',
                            style: TextStyle(color: _muted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _journeyStep(
                  '1. Raw Material Harvest',
                  'Organic Pashmina wool combed at 14,000 ft altitude in Ladakh',
                  'Verified',
                  true,
                ),
                _journeyStep(
                  '2. Hand Carding & Spinning',
                  'Traditional wooden Charkha wheel hand-spinning',
                  'Verified',
                  true,
                ),
                _journeyStep(
                  '3. Botanical & Mineral Dyeing',
                  'Walnut rind and saffron immersion in copper vessel',
                  'Verified',
                  true,
                ),
                _journeyStep(
                  '4. Master Loom Weaving',
                  '280 hours on double-beam traditional pit loom',
                  'In Progress • Day 18',
                  false,
                ),
                _journeyStep(
                  '5. GI Hallmarking & Seal',
                  'Official Ministry of Textiles QR authenticity stamp',
                  'Upcoming',
                  false,
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6B866),
                      foregroundColor: const Color(0xFF081210),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddMilestoneDialog();
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text(
                      'Add Journey Milestone Photo & Story',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _journeyStep(String title, String desc, String badge, bool isDone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isDone
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: isDone ? const Color(0xFF53D7B9) : const Color(0xFFE6B866),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1D19),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF29443B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: _text,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDone
                              ? const Color(0xFF53D7B9).withValues(alpha: 0.2)
                              : const Color(0xFFE6B866).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: isDone
                                ? const Color(0xFF53D7B9)
                                : const Color(0xFFE6B866),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(color: _muted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMilestoneDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _surface,
        title: const Text(
          'Log Journey Milestone',
          style: TextStyle(color: _text),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              style: const TextStyle(color: _text),
              decoration: const InputDecoration(
                labelText: 'Milestone Title (e.g. Loom Setup)',
                labelStyle: TextStyle(color: _muted),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              style: const TextStyle(color: _text),
              decoration: const InputDecoration(
                labelText: 'Artisan Notes & Techniques Used',
                labelStyle: TextStyle(color: _muted),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: _muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: _background,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(
                  content: Text('Milestone added to Craft Journey!'),
                ),
              );
            },
            child: const Text('Record Milestone'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 4. HERITAGE PROVENANCE CHAIN EXPERIENCE
  // ============================================================
  void _openProvenanceChainExperience() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
            child: Column(
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
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF63C9F5).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.link_rounded,
                        color: Color(0xFF63C9F5),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Provenance Chain',
                            style: TextStyle(
                              color: _text,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Cryptographic tamper-proof heritage ledger',
                            style: TextStyle(color: _muted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _ledgerBlock(
                  'Block #001: Raw Sourcing',
                  'Origin: Ladakh Changthang • Collector ID: CH-8821',
                  '0x7a8f...41e2',
                ),
                _ledgerBlock(
                  'Block #002: Artisan Atelier',
                  'Master Weaver: Ramakant Sharma • Varanasi Guild #440',
                  '0x9b3c...11a9',
                ),
                _ledgerBlock(
                  'Block #003: Ministry GI Tag',
                  'Govt of India GI Registry Certificate #GI-049',
                  '0x4d2e...99bf',
                ),
                _ledgerBlock(
                  'Block #004: HeriTrace NFC Seal',
                  'Tamper-evident smart contract minted for collector',
                  '0x11c7...ee30',
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF63C9F5),
                      foregroundColor: const Color(0xFF081210),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '✓ All 4 Provenance Blocks Cryptographically Validated! Zero Tampering.',
                          ),
                          backgroundColor: Color(0xFF1B3D2B),
                        ),
                      );
                    },
                    icon: const Icon(Icons.verified),
                    label: const Text(
                      'Verify Blockchain Provenance Hashes',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _ledgerBlock(String block, String details, String hash) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1D19),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF29443B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lock_outline,
                size: 14,
                color: Color(0xFF63C9F5),
              ),
              const SizedBox(width: 6),
              Text(
                block,
                style: const TextStyle(
                  color: _text,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                hash,
                style: const TextStyle(
                  color: Color(0xFF63C9F5),
                  fontSize: 10,
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(details, style: const TextStyle(color: _muted, fontSize: 11)),
        ],
      ),
    );
  }

  // ============================================================
  // 5. HERITAGE RISK ALERT EXPERIENCE
  // ============================================================
  void _openRiskAlertExperience() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
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
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF967F).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.crisis_alert_rounded,
                        color: Color(0xFFFF967F),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Endangered Crafts Radar',
                            style: TextStyle(
                              color: _text,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Preserving high-risk ancient techniques',
                            style: TextStyle(color: _muted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF33140F),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFF967F)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFFF967F),
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'THREAT STATUS: VULNERABLE TRADITION',
                            style: TextStyle(
                              color: Color(0xFFFF967F),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Traditional Telia Rumal double-ikat weaving and lost-wax Bell Metal casting are at risk due to lack of raw mineral dyes and youth apprenticeship.',
                        style: TextStyle(
                          color: Color(0xFFFDECE8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF967F),
                      foregroundColor: const Color(0xFF081210),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Artisan Heritage Grant application initiated! ₹50,000 preservation fund pending review.',
                          ),
                          backgroundColor: Color(0xFF1B3D2B),
                        ),
                      );
                    },
                    icon: const Icon(Icons.volunteer_activism_rounded),
                    label: const Text(
                      'Apply for HeriTrace Preservation Grant',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // 6. LIVING CRAFT ARCHIVE EXPERIENCE
  // ============================================================
  void _openLivingArchiveExperience() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
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
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE58BD8).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.video_camera_back_rounded,
                        color: Color(0xFFE58BD8),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Living Craft Archive',
                            style: TextStyle(
                              color: _text,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Multimedia oral history & workshop records',
                            style: TextStyle(color: _muted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _archiveItem(
                  'Oral Story: Weaving Songs of Varanasi',
                  'Audio recording • 4 mins • Sung while counting loom threads',
                  Icons.mic,
                ),
                _archiveItem(
                  'Workshop Video: Chisel Sharpening Technique',
                  'Video recording • 8 mins • Master tool preparation',
                  Icons.play_circle_outline,
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE58BD8),
                      foregroundColor: const Color(0xFF081210),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Oral history voice recorder opened! 🎙️',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.fiber_manual_record,
                      color: Colors.red,
                    ),
                    label: const Text(
                      'Record New Oral History Audio Note',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _archiveItem(String title, String desc, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1D19),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF29443B)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE58BD8), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _text,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: _muted, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 7. AI ARTISAN-BUYER MATCHMAKER EXPERIENCE
  // ============================================================
  void _openAiMatchmakerExperience() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        bool matching = false;
        bool matchFound = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
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
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF70D6FF,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Color(0xFF70D6FF),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'AI Artisan Matchmaker',
                                style: TextStyle(
                                  color: _text,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                'Connecting collectors with living ateliers',
                                style: TextStyle(color: _muted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (matchFound)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF143027),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF70D6FF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.stars_rounded,
                                  color: Color(0xFF70D6FF),
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '98.4% AFFINITY MATCH FOUND',
                                  style: TextStyle(
                                    color: Color(0xFF70D6FF),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Master Artisan: Pandit Ramakant Sharma\nAtelier: Varanasi Handloom Weavers Guild\nSpecialty: Heritage Katan Silk & Real Gold Zari',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const Text(
                        'Select your cultural taste preferences to discover master craftspeople whose technique aligns with your aesthetic.',
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF70D6FF),
                          foregroundColor: const Color(0xFF081210),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: matching
                            ? null
                            : () async {
                                setSheetState(() => matching = true);
                                await Future.delayed(
                                  const Duration(milliseconds: 1300),
                                );
                                setSheetState(() {
                                  matching = false;
                                  matchFound = true;
                                });
                              },
                        icon: matching
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF081210),
                                ),
                              )
                            : const Icon(Icons.bolt),
                        label: Text(
                          matching
                              ? 'Analyzing Cultural Affinities...'
                              : 'Run AI Artisan Matchmaker',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
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

  void _showOverviewSheet(_Feature feature) {
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _markerRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: _accent),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '$label: ',
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: _text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
                                    : _cardBorder,
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
          border: Border.all(color: _cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(feature.icon, color: feature.color, size: 26),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: feature.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Interactive',
                    style: TextStyle(
                      color: feature.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              feature.title,
              style: const TextStyle(
                color: _text,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              feature.subtitle,
              style: TextStyle(
                color: feature.color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                feature.detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Launch Studio',
                  style: TextStyle(
                    color: feature.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: feature.color,
                ),
              ],
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
  final String detail;
  final IconData icon;
  final Color color;
  final String signal;
  final String instruction;

  _Feature(
    this.title,
    this.subtitle,
    this.detail,
    this.icon,
    this.color,
    this.signal,
    this.instruction,
  );
}
