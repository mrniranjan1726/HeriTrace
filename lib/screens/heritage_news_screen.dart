import 'package:flutter/material.dart';

class HeritageNewsScreen extends StatefulWidget {
  const HeritageNewsScreen({super.key});

  @override
  State<HeritageNewsScreen> createState() => _HeritageNewsScreenState();
}

class _HeritageNewsScreenState extends State<HeritageNewsScreen> {
  static const Color _terracotta = Color(0xFFA24B2A);
  static const Color _forest = Color(0xFF1F4D3B);
  static const Color _background = Color(0xFFF4EFE7);
  static const Color _surface = Color(0xFFFFFCF7);
  static const Color _ink = Color(0xFF1D2A24);
  static const Color _muted = Color(0xFF68746D);

  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'GI Tag Updates',
    'Govt Schemes & Grants',
    'Craft Expos & Fairs',
    'UNESCO Heritage',
  ];

  final List<Map<String, dynamic>> _newsArticles = [
    {
      'title':
          'Ministry of Textiles Expands PM Vishwakarma Fund for Handloom Weavers',
      'category': 'Govt Schemes & Grants',
      'summary':
          'New collateral-free loans up to ₹3 Lakhs at 5% interest rate made available along with ₹15,000 tool-kit incentives for master weavers and terracotta artisans across 18 craft trades.',
      'source': 'PIB New Delhi',
      'date': 'Today • 2 hours ago',
      'tag': 'BREAKING SCHEME',
      'tagColor': Color(0xFF2E7D32),
      'readTime': '3 min read',
      'imageUrl':
          'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?auto=format&fit=crop&w=800&q=80',
    },
    {
      'title':
          'Surajkund International Crafts Mela 2026: Artisan Stall Allotment Open',
      'category': 'Craft Expos & Fairs',
      'summary':
          'Over 1,200 master craftspersons from across 28 states and 40 countries to showcase indigenous traditions. Verified HeriTrace GI artisans get direct priority fast-track entry.',
      'source': 'Haryana Tourism & Craft Council',
      'date': 'Yesterday',
      'tag': 'EVENT ALERT',
      'tagColor': Color(0xFFD32F2F),
      'readTime': '4 min read',
      'imageUrl':
          'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=800&q=80',
    },
    {
      'title':
          'Kashmir Pashmina GI Tag Gets Next-Gen Micro-RFID & QR Security Labels',
      'category': 'GI Tag Updates',
      'summary':
          'The Craft Development Institute in Srinagar has inaugurated new forensic microscopic laser-testing tags that guarantee 100% pure authentic hand-spun Pashmina and block machine fakes.',
      'source': 'Kashmir Handicrafts Directorate',
      'date': '2 days ago',
      'tag': 'GI TAG NEWS',
      'tagColor': Color(0xFF1976D2),
      'readTime': '5 min read',
      'imageUrl':
          'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=800&q=80',
    },
    {
      'title':
          'UNESCO Inscribes Bastar Dhokra Lost-Wax Bell Metal Craft to Cultural Register',
      'category': 'UNESCO Heritage',
      'summary':
          'Ancient 4,000-year-old bronze sculpting tradition practiced by tribal master artisans in Chhattisgarh gains international recognition, triggering a 45% surge in international collector demand.',
      'source': 'UNESCO World Heritage Bureau',
      'date': '3 days ago',
      'tag': 'GLOBAL ACCLAIM',
      'tagColor': Color(0xFF7B1FA2),
      'readTime': '6 min read',
      'imageUrl':
          'https://images.unsplash.com/photo-1610701596007-11502861dcfa?auto=format&fit=crop&w=800&q=80',
    },
    {
      'title':
          'Jaipur Blue Pottery Craftsmen Open Direct-to-Consumer Cooperative at Dilli Haat',
      'category': 'Craft Expos & Fairs',
      'summary':
          'Over 60 potter families from Sanganer and Kot Jewar showcase lead-free hand-painted ceramics without middleman commission, increasing artisan net revenues by 3x.',
      'source': 'Dastkar Craft Society',
      'date': '5 days ago',
      'tag': 'MARKETPLACE',
      'tagColor': Color(0xFFF57C00),
      'readTime': '4 min read',
      'imageUrl':
          'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=800&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredNews = _selectedCategory == 'All'
        ? _newsArticles
        : _newsArticles
              .where((a) => a['category'] == _selectedCategory)
              .toList();

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _surface,
        foregroundColor: _ink,
        elevation: 0.5,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Heritage Daily & Cultural News',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _ink,
              ),
            ),
            Text(
              'Real-time Indian craft gazette, GI updates & exhibitions',
              style: TextStyle(fontSize: 10, color: _muted),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
        children: [
          // Featured Breaking News Hero Card
          _buildFeaturedHeroCard(),

          const SizedBox(height: 18),

          // Category Chips
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  selectedColor: _terracotta,
                  backgroundColor: _surface,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : _ink,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // News Article Cards
          for (final article in filteredNews) _buildArticleCard(article),
        ],
      ),
    );
  }

  Widget _buildFeaturedHeroCard() {
    final featured = _newsArticles.first;

    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5DDD1), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                featured['imageUrl'] as String,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 180,
                  color: const Color(0xFF2C3E50),
                  child: const Center(
                    child: Icon(Icons.newspaper, color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: featured['tagColor'] as Color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    featured['tag'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      featured['source'] as String,
                      style: const TextStyle(
                        color: _terracotta,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(color: _muted)),
                    const SizedBox(width: 8),
                    Text(
                      featured['date'] as String,
                      style: const TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  featured['title'] as String,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: _ink,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  featured['summary'] as String,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _forest,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _openArticleDetail(featured),
                  icon: const Icon(Icons.menu_book_rounded, size: 16),
                  label: const Text(
                    'Read Full Gazette Report',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E0D5), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openArticleDetail(article),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  article['imageUrl'] as String,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 90,
                    height: 90,
                    color: const Color(0xFFE0E0E0),
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (article['tagColor'] as Color).withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        article['tag'] as String,
                        style: TextStyle(
                          color: article['tagColor'] as Color,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article['title'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          article['source'] as String,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          article['readTime'] as String,
                          style: const TextStyle(
                            color: _forest,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
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
  }

  void _openArticleDetail(Map<String, dynamic> article) {
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
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _muted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    article['imageUrl'] as String,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  article['title'] as String,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      article['source'] as String,
                      style: const TextStyle(
                        color: _terracotta,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('•'),
                    const SizedBox(width: 8),
                    Text(
                      article['date'] as String,
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  article['summary'] as String,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Impact on Artisans & Consumers:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'This development accelerates direct craft exports, eliminates predatory intermediaries, and ensures certified fair royalties reach master weaver families.',
                  style: TextStyle(color: _muted, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _terracotta,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Article bookmarked to your cultural library! 🔖',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Bookmark Article',
                      style: TextStyle(fontWeight: FontWeight.w800),
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
}
