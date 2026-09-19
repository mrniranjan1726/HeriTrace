import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const _ink = Color(0xFF1D2A24);
  static const _muted = Color(0xFF68746D);
  static const _cream = Color(0xFFF4EFE7);
  static const _surface = Color(0xFFFFFCF7);
  static const _terracotta = Color(0xFFA24B2A);
  static const _forest = Color(0xFF1F4D3B);
  static const _gold = Color(0xFFD39A3F);

  void _openLogin(BuildContext context, {bool register = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LoginScreen(initialRegister: register)),
    );
  }

  void _openMobileMenu(BuildContext context) {
    final pageContext = context;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.auto_awesome_outlined, color: _terracotta),
                title: const Text('Our mission', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Why HeriTrace exists'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(pageContext).pushNamed('/about');
                },
              ),
              ListTile(
                leading: const Icon(Icons.handshake_outlined, color: _forest),
                title: const Text('For artisans', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Join our maker community'),
                onTap: () {
                  Navigator.pop(context);
                  _openLogin(pageContext, register: true);
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _openLogin(pageContext, register: true);
                  },
                  child: const Text('Get Started'),
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
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      backgroundColor: _cream,
      body: SelectionArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header(context, wide)),
            SliverToBoxAdapter(child: _hero(context, wide)),
            SliverToBoxAdapter(child: _trustBar()),
            SliverToBoxAdapter(child: _collection(context, wide)),
            SliverToBoxAdapter(child: _story(context, wide)),
            SliverToBoxAdapter(child: _footer(context)),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
  Widget _header(BuildContext context, bool wide) {
    return Container(
      color: _cream,
      padding: EdgeInsets.symmetric(horizontal: wide ? 64 : 22, vertical: 18),
      child: Row(
        children: [
          const _BrandMark()
              .animate()
              .fadeIn(duration: 450.ms)
              .slideX(begin: -0.15, end: 0, curve: Curves.easeOutCubic),
          const Spacer(),
          if (wide) ...[
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/about'),
              child: const Text('Our mission'),
            ).animate().fadeIn(delay: 150.ms),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/about'),
              child: const Text('For artisans'),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(width: 14),
            OutlinedButton(
              onPressed: () => _openLogin(context),
              child: const Text('Sign in'),
            ).animate().fadeIn(delay: 250.ms).scale(begin: const Offset(0.9, 0.9)),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: () => _openLogin(context, register: true),
              child: const Text('Join HeriTrace'),
            )
                .animate()
                .fadeIn(delay: 300.ms)
                .scale(begin: const Offset(0.9, 0.9))
                .shimmer(delay: 1400.ms, duration: 1800.ms),
          ] else ...[
            IconButton(
              tooltip: 'Open menu',
              onPressed: () => _openMobileMenu(context),
              icon: const Icon(Icons.menu_rounded),
            ),
            IconButton(
              tooltip: 'Sign in',
              onPressed: () => _openLogin(context),
              icon: const Icon(Icons.login_outlined),
            ),
            const SizedBox(width: 4),
            FilledButton(
              onPressed: () => _openLogin(context, register: true),
              child: const Text('Join'),
            ).animate().fadeIn().scale(),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // HERO SECTION
  // ============================================================
  Widget _hero(BuildContext context, bool wide) {
    return Stack(
      children: [
        // Ambient background glowing blobs
        Positioned(
          top: -60,
          right: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _gold.withValues(alpha: 0.12),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.15, 1.15),
                duration: 4000.ms,
                curve: Curves.easeInOut,
              ),
        ),
        Positioned(
          bottom: 20,
          left: -40,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _terracotta.withValues(alpha: 0.08),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(1, 1),
                end: const Offset(1.2, 1.2),
                duration: 3500.ms,
                curve: Curves.easeInOut,
              ),
        ),

        // Main Hero content
        Container(
          padding: EdgeInsets.fromLTRB(wide ? 64 : 22, 46, wide ? 64 : 22, 70),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_cream, Color(0xFFF8E9D7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _heroCopy(context)),
                    const SizedBox(width: 60),
                    Expanded(child: _heroVisual()),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heroCopy(context),
                    const SizedBox(height: 48),
                    _heroVisual(),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _heroCopy(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Eyebrow badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _gold.withValues(alpha: .20),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _gold.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars, color: _terracotta, size: 15)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(0.85, 0.85), end: const Offset(1.2, 1.2)),
              const SizedBox(width: 7),
              const Text(
                'AI-POWERED HERITAGE COMMERCE',
                style: TextStyle(
                  color: _forest,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic)
            .shimmer(delay: 900.ms, duration: 1600.ms),

        const SizedBox(height: 22),

        // Main headline
        const Text(
          'Every craft has a story.\nMake sure it never gets lost.',
          style: TextStyle(
            color: _ink,
            fontSize: 52,
            height: 1.04,
            fontWeight: FontWeight.w900,
            letterSpacing: -2,
          ),
        )
            .animate()
            .fadeIn(delay: 120.ms, duration: 600.ms)
            .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),

        const SizedBox(height: 22),

        // Subtitle
        const Text(
          'Discover authentic Indian crafts, meet verified artisans, and experience AI-curated provenance with secure direct payments.',
          style: TextStyle(color: _muted, fontSize: 18, height: 1.55),
        )
            .animate()
            .fadeIn(delay: 240.ms, duration: 600.ms)
            .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

        const SizedBox(height: 34),

        // Action Buttons
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            FilledButton.icon(
              onPressed: () => _openLogin(context, register: true),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Explore Crafts'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                elevation: 4,
                shadowColor: _terracotta.withValues(alpha: 0.4),
              ),
            )
                .animate()
                .fadeIn(delay: 320.ms, duration: 500.ms)
                .scale(begin: const Offset(0.9, 0.9))
                .shimmer(delay: 1500.ms, duration: 2000.ms),

            OutlinedButton(
              onPressed: () => _openLogin(context, register: true),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: const Text('Meet the Artisans'),
            )
                .animate()
                .fadeIn(delay: 380.ms, duration: 500.ms)
                .slideX(begin: 0.1, end: 0),
          ],
        ),

        const SizedBox(height: 20),

        TextButton.icon(
          onPressed: () => Navigator.of(context).pushNamed('/about'),
          icon: const Icon(Icons.arrow_downward, size: 17),
          label: const Text('Read our mission & story'),
        ).animate().fadeIn(delay: 450.ms),
      ],
    );
  }

  Widget _heroVisual() {
    return AspectRatio(
      aspectRatio: 1.08,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main Image Card
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1D2A24).withValues(alpha: 0.16),
                    blurRadius: 36,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.network(
                  'https://images.unsplash.com/photo-1577083552431-6e5fd01aa342?auto=format&fit=crop&w=1000&q=85',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: _forest,
                    child: const Icon(Icons.auto_awesome, color: _gold, size: 72),
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 800.ms)
              .scale(begin: const Offset(0.93, 0.93), end: const Offset(1, 1), curve: Curves.easeOutCubic),

          // Top floating badge: Live Auctions
          Positioned(
            left: 20,
            top: 22,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 6)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.4, 1.4)),
                  const SizedBox(width: 8),
                  const Text(
                    'Live Craft Auctions Active',
                    style: TextStyle(color: _forest, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 350.ms)
                .slideY(begin: -0.2, end: 0, curve: Curves.easeOutBack),
          ),

          // Bottom Left Floating Stat
          Positioned(
            left: -18,
            bottom: 26,
            child: _floatingStat('12k+', 'artisan stories')
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: -10, duration: 2500.ms, curve: Curves.easeInOut),
          ),

          // Top Right Floating Stat
          Positioned(
            right: -14,
            top: 80,
            child: _floatingStat('100%', 'traceable origin')
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: 10, duration: 2800.ms, curve: Curves.easeInOut),
          ),
        ],
      ),
    );
  }

  Widget _floatingStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: _terracotta,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TRUST BAR
  // ============================================================
  Widget _trustBar() {
    const items = [
      (Icons.handshake_outlined, 'Direct from Artisans'),
      (Icons.public, 'Heritage Kept Alive'),
      (Icons.verified_outlined, 'GI & Authenticity Traceable'),
      (Icons.favorite_border, 'Fair Wages Verified'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      color: _forest,
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        runSpacing: 18,
        spacing: 28,
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return _TrustItem(icon: item.$1, text: item.$2)
              .animate()
              .fadeIn(delay: (100 * i).ms, duration: 500.ms)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
        }).toList(),
      ),
    );
  }

  // ============================================================
  // CRAFT COLLECTION SHOWCASE
  // ============================================================
  Widget _collection(BuildContext context, bool wide) {
    const products = [
      (
        'Handwoven Stories',
        'Textiles & Sarees',
        'https://images.unsplash.com/photo-1610701596007-11502861dcfa?auto=format&fit=crop&w=700&q=80',
      ),
      (
        'Earth & Fire',
        'Terracotta & Pottery',
        'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?auto=format&fit=crop&w=700&q=80',
      ),
      (
        'Made to be Worn',
        'Filigree & Silver',
        'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?auto=format&fit=crop&w=700&q=80',
      ),
      (
        'Carved by Hand',
        'Sandalwood & Teak',
        'https://images.unsplash.com/photo-1549490349-8643362247b5?auto=format&fit=crop&w=700&q=80',
      ),
      (
        'Colour in Every Stroke',
        'Madhubani & Pattachitra',
        'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?auto=format&fit=crop&w=700&q=80',
      ),
      (
        'Spaces with Soul',
        'Brassware & Decor',
        'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=700&q=80',
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(wide ? 64 : 22, 72, wide ? 64 : 22, 78),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'A world of craft',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Find something with a past — and an enduring future.',
                      style: TextStyle(color: _muted, fontSize: 17),
                    ),
                  ],
                ),
              ),
              if (wide)
                FilledButton.icon(
                  onPressed: () => _openLogin(context, register: true),
                  icon: const Icon(Icons.grid_view_rounded, size: 18),
                  label: const Text('View All Categories'),
                ).animate().fadeIn().scale(),
            ],
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth >= 850
                  ? 3
                  : constraints.maxWidth >= 520
                  ? 2
                  : 1;
              final width = (constraints.maxWidth - ((count - 1) * 18)) / count;
              return Wrap(
                spacing: 18,
                runSpacing: 18,
                children: products.asMap().entries.map((entry) {
                  final i = entry.key;
                  final product = entry.value;
                  return SizedBox(
                    width: width,
                    child: _collectionCard(product, context)
                        .animate()
                        .fadeIn(delay: (70 * i).ms, duration: 450.ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _collectionCard((String, String, String) product, BuildContext context) {
    return InkWell(
      onTap: () => _openLogin(context, register: true),
      borderRadius: BorderRadius.circular(22),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFFE4DCD0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 230,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.$3,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFFE7D9C9),
                      child: const Icon(Icons.image_outlined, size: 42),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.$1,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          product.$2,
                          style: const TextStyle(
                            color: _terracotta,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _terracotta.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_outward, color: _terracotta, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STORY SECTION
  // ============================================================
  Widget _story(BuildContext context, bool wide) {
    return Container(
      padding: EdgeInsets.all(wide ? 64 : 22),
      color: const Color(0xFFE8E0D4),
      child: wide
          ? Row(
              children: [
                Expanded(child: _storyImage()),
                const SizedBox(width: 70),
                Expanded(child: _storyCopy(context)),
              ],
            )
          : Column(
              children: [
                _storyImage(),
                const SizedBox(height: 35),
                _storyCopy(context),
              ],
            ),
    );
  }

  Widget _storyImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: AspectRatio(
        aspectRatio: 1.15,
        child: Image.network(
          'https://images.unsplash.com/photo-1528698827591-e19ccd7bc23d?auto=format&fit=crop&w=1000&q=85',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: _gold,
            child: const Icon(Icons.people_alt_outlined, size: 62, color: _surface),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), curve: Curves.easeOutCubic);
  }

  Widget _storyCopy(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _terracotta.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'OUR ETHOS',
            style: TextStyle(
              color: _terracotta,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ).animate().fadeIn().slideX(begin: -0.1),
        const SizedBox(height: 14),
        const Text(
          'A fairer future for\ntraditional craft.',
          style: TextStyle(
            color: _ink,
            fontSize: 42,
            height: 1.08,
            fontWeight: FontWeight.w900,
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
        const SizedBox(height: 18),
        const Text(
          'HeriTrace gives independent makers the AI tools, digital cataloging, fair pricing insights, and direct market access they need to thrive on their own terms.',
          style: TextStyle(color: _muted, fontSize: 17, height: 1.55),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: () => _openLogin(context, register: true),
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Meet the Maker Community'),
        ).animate().fadeIn(delay: 300.ms).scale(),
      ],
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================
  Widget _footer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 38),
      color: _ink,
      child: Column(
        children: [
          const _BrandMark(light: true),
          const SizedBox(height: 14),
          const Text(
            'Preserving heritage. Empowering makers.',
            style: TextStyle(color: Color(0xFFB9C4BD), fontSize: 14),
          ),
          const SizedBox(height: 26),
          FilledButton.tonal(
            onPressed: () => _openLogin(context, register: true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              foregroundColor: Colors.white,
            ),
            child: const Text('Start your HeriTrace journey'),
          ),
          const SizedBox(height: 26),
          const Text(
            '© 2026 HeriTrace · Crafted for Indian Heritage',
            style: TextStyle(color: Color(0xFF7F9087), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.light = false});

  final bool light;

  @override
  Widget build(BuildContext context) {
    final color = light ? Colors.white : const Color(0xFF1D2A24);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFA24B2A),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA24B2A).withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .rotate(duration: 4500.ms, curve: Curves.easeInOut),
        ),
        const SizedBox(width: 10),
        Text(
          'HeriTrace',
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -.6,
          ),
        ),
      ],
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFFE6C68B), size: 22),
        const SizedBox(width: 9),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
