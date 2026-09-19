import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'add_product_screen.dart';
import 'pricing_screen.dart';
import 'image_studio_screen.dart';
import 'marketplace_screen.dart';
import 'artisan_orders_screen.dart';
import 'artisan_profile_screen.dart';
import 'artisan_auctions_screen.dart';

class ArtisanHubScreen extends StatelessWidget {
  const ArtisanHubScreen({super.key});

  static const Color _terracotta = Color(0xFFA24B2A);
  static const Color _forest = Color(0xFF1F4D3B);
  static const Color _gold = Color(0xFFD39A3F);
  static const Color _cream = Color(0xFFF4EFE7);
  static const Color _surface = Color(0xFFFFFCF7);
  static const Color _ink = Color(0xFF1D2A24);
  static const Color _muted = Color(0xFF68746D);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final artisanName = user?.displayName ?? 'Master Artisan';
    final email = user?.email ?? 'artisan@heritrace.in';

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: _terracotta.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.widgets_rounded,
                color: _terracotta,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Artisan Atelier Hub',
              style: TextStyle(
                color: _ink,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          // 1. Artisan Identity Banner
          _buildArtisanProfileCard(context, artisanName, email),

          const SizedBox(height: 22),

          // 2. Creation & Pricing Suite
          _buildSectionHeader('Craft Creation & Pricing', 'AI-assisted listing & fair-trade wages'),
          const SizedBox(height: 10),
          _buildHubTile(
            context: context,
            icon: Icons.add_circle_rounded,
            title: 'Publish New Masterpiece',
            subtitle: 'AI cultural storytelling, image studio & specs',
            color: _terracotta,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddProductScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _buildHubTile(
            context: context,
            icon: Icons.balance_rounded,
            title: 'Fair Price Calculator',
            subtitle: 'Living wage standards, raw materials & craft hours',
            color: _forest,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PricingScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _buildHubTile(
            context: context,
            icon: Icons.auto_fix_high_rounded,
            title: 'AI Photo Studio',
            subtitle: 'Virtual lighting, heirloom backdrop & enhancer',
            color: const Color(0xFF7A3E65),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ImageStudioScreen()),
            ),
          ),

          const SizedBox(height: 22),

          // 3. Heritage & Provenance Tech
          _buildSectionHeader('Heritage Genetics & Authenticity', 'GI certification & craft integrity'),
          const SizedBox(height: 10),
          _buildHubTile(
            context: context,
            icon: Icons.biotech_rounded,
            title: 'Craft DNA & Material Genetics',
            subtitle: 'Natural dyes, organic fibers & regional provenance',
            color: const Color(0xFF00897B),
            onTap: () => Navigator.pushNamed(context, '/heritage-features'),
          ),
          const SizedBox(height: 10),
          _buildHubTile(
            context: context,
            icon: Icons.fingerprint_rounded,
            title: 'Technique Fingerprint',
            subtitle: 'Biometric handloom weave & chisel signatures',
            color: const Color(0xFF5E35B1),
            onTap: () => Navigator.pushNamed(context, '/heritage-features'),
          ),
          const SizedBox(height: 10),
          _buildHubTile(
            context: context,
            icon: Icons.newspaper_rounded,
            title: 'Heritage News Gazette',
            subtitle: 'GI policies, export grants, exhibitions & trends',
            color: const Color(0xFFC2185B),
            onTap: () => Navigator.pushNamed(context, '/heritage-news'),
          ),

          const SizedBox(height: 22),

          // 4. Sales, Auctions & Orders
          _buildSectionHeader('Sales & Patron Fulfillment', 'Orders, live bidding & customer showcase'),
          const SizedBox(height: 10),
          _buildHubTile(
            context: context,
            icon: Icons.gavel_rounded,
            title: 'Rare Craft Auctions',
            subtitle: 'Launch real-time bidding rooms with reserve prices',
            color: _gold,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ArtisanAuctionsScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _buildHubTile(
            context: context,
            icon: Icons.inventory_2_rounded,
            title: 'Patron Orders & Shipping',
            subtitle: 'Track crafting, packaging & courier dispatch',
            color: const Color(0xFF0277BD),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ArtisanOrdersScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _buildHubTile(
            context: context,
            icon: Icons.storefront_rounded,
            title: 'Customer Marketplace View',
            subtitle: 'Preview your crafts as global patrons see them',
            color: const Color(0xFF37474F),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
            ),
          ),

          const SizedBox(height: 22),

          // 5. Profile & Settings
          _buildSectionHeader('Atelier Account', 'Credentials & verification'),
          const SizedBox(height: 10),
          _buildHubTile(
            context: context,
            icon: Icons.badge_rounded,
            title: 'Artisan Profile & GI Verification',
            subtitle: 'Government credentials, workshop bio & awards',
            color: _forest,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ArtisanProfileScreen()),
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFC62828),
              side: const BorderSide(color: Color(0xFFEF9A9A)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text(
              'Sign Out from HeriTrace Atelier',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtisanProfileCard(BuildContext context, String name, String email) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6DDD2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: _terracotta.withValues(alpha: 0.15),
            child: const Icon(
              Icons.account_circle_rounded,
              size: 42,
              color: _terracotta,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified_rounded,
                      color: _gold,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _forest.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Certified Heritage Artisan Guild',
                    style: TextStyle(
                      color: _forest,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ArtisanProfileScreen()),
            ),
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: _muted),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms);
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            color: _muted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHubTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEBE3D9)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFB0BEC5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
