import 'package:flutter/material.dart';

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
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.auto_awesome_outlined),
                title: const Text('Our mission'),
                subtitle: const Text('Why HeriTrace exists'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(pageContext).pushNamed('/about');
                },
              ),
              ListTile(
                leading: const Icon(Icons.handshake_outlined),
                title: const Text('For artisans'),
                subtitle: const Text('Join our maker community'),
                onTap: () {
                  Navigator.pop(context);
                  _openLogin(pageContext, register: true);
                },
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

  Widget _header(BuildContext context, bool wide) {
    return Container(
      color: _cream,
      padding: EdgeInsets.symmetric(horizontal: wide ? 64 : 22, vertical: 18),
      child: Row(
        children: [
          const _BrandMark(),
          const Spacer(),
          if (wide) ...[
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/about'),
              child: const Text('Our mission'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/about'),
              child: const Text('For artisans'),
            ),
            const SizedBox(width: 14),
            OutlinedButton(
              onPressed: () => _openLogin(context),
              child: const Text('Sign in'),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: () => _openLogin(context, register: true),
              child: const Text('Join HeriTrace'),
            ),
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
            const SizedBox(width: 2),
            FilledButton(
              onPressed: () => _openLogin(context, register: true),
              child: const Text('Join'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _hero(BuildContext context, bool wide) {
    return Container(
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
                const SizedBox(height: 42),
                _heroVisual(),
              ],
            ),
    );
  }

  Widget _heroCopy(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: _gold.withValues(alpha: .16),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            'CRAFTED WITH PURPOSE',
            style: TextStyle(
              color: _forest,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Every craft has a story.\nMake sure it never gets lost.',
          style: TextStyle(
            color: _ink,
            fontSize: 52,
            height: 1.02,
            fontWeight: FontWeight.w800,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Discover authentic Indian crafts, meet the artisans behind them, and preserve the stories, skills and traditions that make every piece unique.',
          style: TextStyle(color: _muted, fontSize: 18, height: 1.55),
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () => _openLogin(context, register: true),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Explore crafts'),
            ),
            OutlinedButton(
              onPressed: () => _openLogin(context, register: true),
              child: const Text('Meet the artisans'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        TextButton.icon(
          onPressed: () => Navigator.of(context).pushNamed('/about'),
          icon: const Icon(Icons.arrow_downward),
          label: const Text('Read our mission'),
        ),
      ],
    );
  }

  Widget _heroVisual() {
    return AspectRatio(
      aspectRatio: 1.08,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
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
          Positioned(
            left: -18,
            bottom: 24,
            child: _floatingStat('12k+', 'artisan stories'),
          ),
          Positioned(
            right: -14,
            top: 22,
            child: _floatingStat('100%', 'human made'),
          ),
        ],
      ),
    );
  }

  Widget _floatingStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: _terracotta,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _trustBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      color: _forest,
      child: const Wrap(
        alignment: WrapAlignment.spaceEvenly,
        runSpacing: 18,
        spacing: 28,
        children: [
          _TrustItem(
            icon: Icons.handshake_outlined,
            text: 'Direct from artisans',
          ),
          _TrustItem(icon: Icons.public, text: 'Heritage, kept alive'),
          _TrustItem(
            icon: Icons.verified_outlined,
            text: 'Authentic & traceable',
          ),
          _TrustItem(
            icon: Icons.favorite_border,
            text: 'Every purchase matters',
          ),
        ],
      ),
    );
  }

  Widget _collection(BuildContext context, bool wide) {
    const products = [
      (
        'Handwoven stories',
        'Textiles',
        'https://images.unsplash.com/photo-1610701596007-11502861dcfa?auto=format&fit=crop&w=700&q=80',
      ),
      (
        'Earth & fire',
        'Pottery',
        'https://images.unsplash.com/photo-1610701596007-11502861dcfa?auto=format&fit=crop&w=700&q=80',
      ),
      (
        'Made to be worn',
        'Jewellery',
        'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?auto=format&fit=crop&w=700&q=80',
      ),
      (
        'Carved by hand',
        'Woodwork',
        'https://images.unsplash.com/photo-1549490349-8643362247b5?auto=format&fit=crop&w=700&q=80',
      ),
      (
        'Colour in every stroke',
        'Paintings',
        'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?auto=format&fit=crop&w=700&q=80',
      ),
      (
        'Spaces with soul',
        'Home decor',
        'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=700&q=80',
      ),
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(wide ? 64 : 22, 72, wide ? 64 : 22, 78),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'A world of craft',
            style: TextStyle(
              color: _ink,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Find something with a past — and a future.',
            style: TextStyle(color: _muted, fontSize: 17),
          ),
          const SizedBox(height: 28),
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
                children: products
                    .map(
                      (product) => SizedBox(
                        width: width,
                        child: _collectionCard(product),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _collectionCard((String, String, String) product) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 230,
            width: double.infinity,
            child: Image.network(
              product.$3,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFFE7D9C9),
                child: const Icon(Icons.image_outlined, size: 42),
              ),
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
                const Icon(Icons.arrow_outward, color: _terracotta),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
      borderRadius: BorderRadius.circular(24),
      child: AspectRatio(
        aspectRatio: 1.15,
        child: Image.network(
          'https://images.unsplash.com/photo-1528698827591-e19ccd7bc23d?auto=format&fit=crop&w=1000&q=85',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: _gold,
            child: const Icon(
              Icons.people_alt_outlined,
              size: 62,
              color: _surface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _storyCopy(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Our mission.',
          style: TextStyle(
            color: _terracotta,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'A fairer future for\ntraditional craft.',
          style: TextStyle(
            color: _ink,
            fontSize: 38,
            height: 1.08,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'HeriTrace gives independent makers the tools, visibility and direct connection they need to build a sustainable business on their own terms.',
          style: TextStyle(color: _muted, fontSize: 16, height: 1.55),
        ),
        const SizedBox(height: 25),
        TextButton.icon(
          onPressed: () => _openLogin(context, register: true),
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Meet the community'),
        ),
      ],
    );
  }

  Widget _footer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 42, 24, 35),
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
          TextButton(
            onPressed: () => _openLogin(context, register: true),
            child: const Text('Start your HeriTrace journey'),
          ),
          const SizedBox(height: 22),
          const Text(
            '© 2026 HeriTrace',
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
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFA24B2A),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 19),
        ),
        const SizedBox(width: 10),
        Text(
          'HeriTrace',
          style: TextStyle(
            color: color,
            fontSize: 21,
            fontWeight: FontWeight.w800,
            letterSpacing: -.5,
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
        Icon(icon, color: const Color(0xFFE6C68B), size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
