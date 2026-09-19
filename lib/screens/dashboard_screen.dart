import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../widgets/support_chatbot.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _ink = Color(0xFF17201D);
  static const _green = Color(0xFFA24B2A);
  static const _cream = Color(0xFFF7F4ED);
  static const _terracotta = Color(0xFFC76845);

  final _searchController = TextEditingController();
  String _query = '';
  String _category = 'All';
  final Set<String> _saved = {};

  final _categories = const [
    ('All', Icons.apps_rounded),
    ('Monuments', Icons.account_balance_rounded),
    ('Living traditions', Icons.music_note_rounded),
    ('Art & craft', Icons.palette_rounded),
    ('Food', Icons.restaurant_rounded),
  ];

  final _places = const [
    _HeritagePlace(
      name: 'Konark Sun Temple',
      location: 'Puri, Odisha',
      category: 'Monuments',
      period: '13th century',
      image:
          'https://images.unsplash.com/photo-1600100397608-f010f8e7c7a9?auto=format&fit=crop&w=1200&q=85',
      description:
          'A stone chariot of the sun, where geometry, devotion and craft meet.',
      color: Color(0xFFE9C998),
    ),
    _HeritagePlace(
      name: 'Pattachitra stories',
      location: 'Raghurajpur, Odisha',
      category: 'Art & craft',
      period: 'Living tradition',
      image:
          'https://images.unsplash.com/photo-1577083288073-40892c0860a4?auto=format&fit=crop&w=1200&q=85',
      description:
          'Hand-painted narratives carried from one generation of chitrakars to the next.',
      color: Color(0xFFEBC7B8),
    ),
    _HeritagePlace(
      name: 'Odissi',
      location: 'Bhubaneswar, Odisha',
      category: 'Living traditions',
      period: 'Classical dance',
      image:
          'https://upload.wikimedia.org/wikipedia/commons/e/e7/Odissi_Performance_DS.jpg',
      description:
          'A lyrical language of sculptures, rhythm and expressive storytelling, performed through tribhangi and abhinaya.',
      color: Color(0xFFD5E2D0),
    ),
    _HeritagePlace(
      name: 'Rath Yatra',
      location: 'Puri, Odisha',
      category: 'Living traditions',
      period: 'Annual festival',
      image:
          'https://images.unsplash.com/photo-1604608672516-f1b9b1a3e34b?auto=format&fit=crop&w=1200&q=85',
      description:
          'A city moves with its deities in one of India’s most loved celebrations.',
      color: Color(0xFFF2D5A4),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_HeritagePlace> get _filteredPlaces {
    return _places.where((place) {
      final matchesCategory = _category == 'All' || place.category == _category;
      final haystack = '${place.name} ${place.location} ${place.category}'
          .toLowerCase();
      return matchesCategory && haystack.contains(_query.toLowerCase());
    }).toList();
  }

  String get _displayName {
    final email = FirebaseAuth.instance.currentUser?.email ?? 'explorer';
    final name = email.split('@').first;
    return name.isEmpty
        ? 'Explorer'
        : name[0].toUpperCase() + name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      floatingActionButton: const SupportChatbot(role: 'artisan'),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildHero(context)),
            SliverToBoxAdapter(child: _buildStats()),
            SliverToBoxAdapter(child: _buildSectionIntro()),
            SliverToBoxAdapter(child: _buildFilters()),
            _buildPlaceGrid(),
            SliverToBoxAdapter(child: _buildStoryBanner()),
            SliverToBoxAdapter(child: _buildFooterActions(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        return Container(
          color: _cream.withValues(alpha: .96),
          padding: EdgeInsets.fromLTRB(
            compact ? 18 : 42,
            20,
            compact ? 18 : 42,
            14,
          ),
          child: Row(
            children: [
              _brand(),
              if (!compact) ...[
                const SizedBox(width: 46),
                _navLabel('Discover', selected: true),
                _navLabel('Stories'),
                _navLabel('Map'),
                _navLabel('Events'),
              ],
              const Spacer(),
              IconButton(
                tooltip: 'Search heritage',
                onPressed: () => _focusSearch(),
                icon: const Icon(Icons.search_rounded),
              ),
              IconButton(
                tooltip: 'Saved heritage',
                onPressed: () => _showSaved(context),
                icon: Badge(
                  isLabelVisible: _saved.isNotEmpty,
                  label: Text('${_saved.length}'),
                  child: const Icon(Icons.bookmark_border_rounded),
                ),
              ),
              if (!compact)
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/business'),
                  child: const Text('Craft studio'),
                )
              else
                IconButton(
                  tooltip: 'Open craft studio',
                  onPressed: () => Navigator.pushNamed(context, '/business'),
                  icon: const Icon(Icons.storefront_outlined),
                ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Open profile',
                onPressed: () =>
                    Navigator.pushNamed(context, '/artisan-profile'),
                icon: CircleAvatar(
                  radius: 18,
                  backgroundColor: _green,
                  child: Text(
                    _displayName[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _brand() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 21),
        ),
        const SizedBox(width: 10),
        const Text(
          'HeriTrace',
          style: TextStyle(
            color: _ink,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -.5,
          ),
        ),
      ],
    );
  }

  Widget _navLabel(String label, {bool selected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 26),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? _green : _ink.withValues(alpha: .58),
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 800;
          return ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Container(
              height: compact ? 500 : 420,
              color: const Color(0xFF173B31),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1600100397608-f010f8e7c7a9?auto=format&fit=crop&w=1800&q=90',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x33173B31), Color(0xEE173B31)],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(compact ? 28 : 52),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 670),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _eyebrow('ODISHA / INDIA'),
                            const SizedBox(height: 14),
                            Text(
                              'Discover.\nPreserve. Connect.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: compact ? 42 : 62,
                                height: .98,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -2.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Stories, places and living traditions that connect us to our roots.',
                              style: TextStyle(
                                color: Color(0xFFE6F1EC),
                                fontSize: 16,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 25),
                            Wrap(
                              spacing: 12,
                              runSpacing: 10,
                              children: [
                                FilledButton.icon(
                                  onPressed: () => _focusSearch(),
                                  icon: const Icon(Icons.explore_outlined),
                                  label: const Text('Explore heritage'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFE8B77A),
                                    foregroundColor: _ink,
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => _showMap(context),
                                  icon: const Icon(Icons.map_outlined),
                                  label: const Text('Discover on map'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: .05, end: 0);
        },
      ),
    );
  }

  Widget _eyebrow(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFE8B77A),
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 8),
      child: Wrap(
        spacing: 0,
        runSpacing: 14,
        children: const [
          _Stat(value: '120+', label: 'Heritage sites'),
          _Stat(value: '48', label: 'Cultural stories'),
          _Stat(value: '12', label: 'Regions mapped'),
          _Stat(value: '860+', label: 'Contributors'),
        ],
      ),
    );
  }

  Widget _buildSectionIntro() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 38, 20, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore the extraordinary',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.8,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Start with a place, a craft, or a story from Odisha.',
                  style: TextStyle(color: Color(0xFF65736D), fontSize: 15),
                ),
              ],
            ),
          ),
          Text(
            '${_filteredPlaces.length} discoveries',
            style: const TextStyle(
              color: _terracotta,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              hintText: 'Search places, stories, crafts...',
              prefixIcon: Icon(Icons.search_rounded),
              suffixIcon: Icon(Icons.tune_rounded),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 43,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = _categories[index];
                final selected = item.$1 == _category;
                return FilterChip(
                  selected: selected,
                  onSelected: (_) => setState(() => _category = item.$1),
                  avatar: Icon(item.$2, size: 17),
                  label: Text(item.$1),
                  selectedColor: _green,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : _ink,
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.crossAxisExtent > 1000
              ? 4
              : constraints.crossAxisExtent > 620
              ? 2
              : 1;
          return SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _placeCard(context, _filteredPlaces[index], index),
              childCount: _filteredPlaces.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisExtent: 380,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
          );
        },
      ),
    );
  }

  Widget _placeCard(BuildContext context, _HeritagePlace place, int index) {
    final saved = _saved.contains(place.name);
    return Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          color: Colors.white,
          child: InkWell(
            onTap: () => _showPlace(context, place),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 215,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        place.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: place.color,
                          child: const Icon(Icons.landscape_rounded, size: 48),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: IconButton.filledTonal(
                          tooltip: saved ? 'Remove bookmark' : 'Save heritage',
                          onPressed: () => setState(() {
                            saved
                                ? _saved.remove(place.name)
                                : _saved.add(place.name);
                          }),
                          icon: Icon(
                            saved ? Icons.bookmark : Icons.bookmark_border,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: .9),
                            foregroundColor: _green,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: place.color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            place.category,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.place_outlined,
                            size: 15,
                            color: _terracotta,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            place.location,
                            style: const TextStyle(
                              color: Color(0xFF65736D),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        place.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF65736D),
                          height: 1.35,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: (index * 70).ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: .06, end: 0);
  }

  Widget _buildStoryBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 42, 20, 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFA24B2A), Color(0xFF74331F)],
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 20,
        children: [
          const SizedBox(
            width: 540,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STORIES THAT TIME COULDN’T ERASE',
                  style: TextStyle(
                    color: Color(0xFFE8B77A),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Meet the people keeping heritage alive.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Listen to oral histories, discover local makers and add a story from your community.',
                  style: TextStyle(color: Color(0xFFC5DED3), height: 1.4),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () => _showComingSoon('Heritage stories'),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Read the stories'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/heritage-features'),
              icon: const Icon(Icons.auto_awesome_outlined),
              label: const Text('Identify heritage with AI'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showComingSoon('Contribute Heritage'),
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Contribute a story'),
            ),
          ),
        ],
      ),
    );
  }

  void _focusSearch() {
    FocusScope.of(context).requestFocus(FocusNode());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 18,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: TextField(
          autofocus: true,
          onChanged: (value) => setState(() => _query = value),
          decoration: const InputDecoration(
            hintText: 'Search heritage...',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
      ),
    );
  }

  void _showPlace(BuildContext context, _HeritagePlace place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _PlaceSheet(place: place, saved: _saved.contains(place.name)),
    );
  }

  void _showSaved(BuildContext context) {
    final names = _saved.isEmpty ? 'No saved places yet.' : _saved.join('\n');
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Your saved heritage'),
        content: Text(names),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMap(BuildContext context) =>
      _showComingSoon('Interactive heritage map');

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is ready to connect to your live data.'),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Row(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFC76845),
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 9),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF65736D),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeritagePlace {
  const _HeritagePlace({
    required this.name,
    required this.location,
    required this.category,
    required this.period,
    required this.image,
    required this.description,
    required this.color,
  });
  final String name;
  final String location;
  final String category;
  final String period;
  final String image;
  final String description;
  final Color color;
}

class _PlaceSheet extends StatelessWidget {
  const _PlaceSheet({required this.place, required this.saved});
  final _HeritagePlace place;
  final bool saved;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              place.category.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFC76845),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              place.name,
              style: const TextStyle(
                color: Color(0xFF17201D),
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${place.location}  ·  ${place.period}',
              style: const TextStyle(color: Color(0xFF65736D)),
            ),
            const SizedBox(height: 15),
            Text(
              place.description,
              style: const TextStyle(color: Color(0xFF65736D), height: 1.45),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('Explore story'),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.outlined(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
