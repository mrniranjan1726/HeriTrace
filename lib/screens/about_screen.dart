import 'package:flutter/material.dart';

import 'login_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 850;
    return Scaffold(
      backgroundColor: _cream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: _cream,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: const _BrandMark(),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Home'),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(right: 18),
                child: FilledButton(
                  onPressed: () => _openLogin(context, register: true),
                  child: const Text('Join HeriTrace'),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(child: _intro(wide)),
          SliverToBoxAdapter(child: _mission(wide)),
          SliverToBoxAdapter(child: _values(wide)),
          SliverToBoxAdapter(child: _team(wide)),
          SliverToBoxAdapter(child: _footer()),
        ],
      ),
    );
  }

  Widget _intro(bool wide) {
    return Container(
      padding: EdgeInsets.fromLTRB(wide ? 64 : 22, 58, wide ? 64 : 22, 70),
      color: _forest,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              const Text(
                'ABOUT HERITRACE',
                style: TextStyle(
                  color: _gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Keeping heritage\nin motion.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  height: 1.02,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'HeriTrace is a digital home for traditional makers — connecting their hands, stories and skills with people who value meaningful work.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFD8E2DB),
                  fontSize: 18,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mission(bool wide) {
    return Container(
      padding: EdgeInsets.all(wide ? 64 : 22),
      color: _surface,
      child: wide
          ? Row(
              children: [
                Expanded(child: _missionCopy()),
                const SizedBox(width: 70),
                Expanded(child: _missionImage()),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _missionCopy(),
                const SizedBox(height: 30),
                _missionImage(),
              ],
            ),
    );
  }

  Widget _missionCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OUR MISSION',
          style: TextStyle(
            color: _terracotta,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'Make traditional craft a thriving future.',
          style: TextStyle(
            color: _ink,
            fontSize: 38,
            height: 1.08,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'We believe the people who carry culture forward should have the tools and recognition to build a good life from their work.',
          style: TextStyle(color: _muted, fontSize: 17, height: 1.6),
        ),
        const SizedBox(height: 18),
        const Text(
          'That means fairer access to customers, a stronger digital presence and a marketplace where every product can be traced back to the person who made it.',
          style: TextStyle(color: _muted, fontSize: 17, height: 1.6),
        ),
      ],
    );
  }

  Widget _missionImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: AspectRatio(
        aspectRatio: 1.25,
        child: Image.network(
          'https://images.unsplash.com/photo-1452860606245-08bea0c7d33c?auto=format&fit=crop&w=1000&q=85',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: const Color(0xFFE8D4B8),
            child: const Icon(
              Icons.handyman_outlined,
              color: _terracotta,
              size: 70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _values(bool wide) {
    const values = [
      (
        Icons.favorite_border,
        'People first',
        'The maker is at the centre of every decision.',
      ),
      (
        Icons.auto_awesome_outlined,
        'Living heritage',
        'Tradition grows when it is shared and supported.',
      ),
      (
        Icons.visibility_outlined,
        'Radical clarity',
        'We make the journey from hands to home visible.',
      ),
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(wide ? 64 : 22, 65, wide ? 64 : 22, 65),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What guides us',
            style: TextStyle(
              color: _ink,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth >= 800 ? 3 : 1;
              final width = (constraints.maxWidth - (count - 1) * 18) / count;
              return Wrap(
                spacing: 18,
                runSpacing: 18,
                children: values
                    .map(
                      (value) =>
                          SizedBox(width: width, child: _valueCard(value)),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _valueCard((IconData, String, String) value) {
    return Card(
      color: _surface,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(value.$1, color: _terracotta, size: 30),
            const SizedBox(height: 20),
            Text(
              value.$2,
              style: const TextStyle(
                color: _ink,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value.$3,
              style: const TextStyle(color: _muted, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _team(bool wide) {
    const members = [
      ('Team member 1', 'Co-founder & community', null),
      ('Team member 2', 'Product & technology', null),
      ('Team member 3', 'Craft partnerships', null),
      ('Team member 4', 'Brand & storytelling', null),
      ('Team member 5', 'Operations & growth', null),
      ('Team member 6', 'Artisan success', null),
    ];
    return Container(
      padding: EdgeInsets.fromLTRB(wide ? 64 : 22, 65, wide ? 64 : 22, 75),
      color: const Color(0xFFE8E0D4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'The people behind HeriTrace',
            style: TextStyle(
              color: _ink,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Our team photos and bios will go here — send them whenever you are ready.',
            style: TextStyle(color: _muted, fontSize: 16),
          ),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth >= 800 ? 3 : 1;
              final width = (constraints.maxWidth - (count - 1) * 18) / count;
              return Wrap(
                spacing: 18,
                runSpacing: 18,
                children: members
                    .map(
                      (member) =>
                          SizedBox(width: width, child: _memberCard(member)),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _memberCard((String, String, String?) member) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: _surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 220,
            width: double.infinity,
            color: const Color(0xFFD7C5AF),
            child: const Icon(
              Icons.person_outline,
              color: _terracotta,
              size: 62,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.$1,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  member.$2,
                  style: const TextStyle(
                    color: _terracotta,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Container(
      padding: const EdgeInsets.all(30),
      color: _ink,
      child: const Center(
        child: Text(
          'Preserving heritage. Empowering makers.',
          style: TextStyle(color: Color(0xFFB9C4BD)),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
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
        const Text(
          'HeriTrace',
          style: TextStyle(
            color: Color(0xFF1D2A24),
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
