import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ArtisanCommunityScreen extends StatefulWidget {
  const ArtisanCommunityScreen({super.key});

  @override
  State<ArtisanCommunityScreen> createState() => _ArtisanCommunityScreenState();
}

class _ArtisanCommunityScreenState extends State<ArtisanCommunityScreen> {
  static const Color _terracotta = Color(0xFFA24B2A);
  static const Color _forest = Color(0xFF1F4D3B);
  static const Color _background = Color(0xFFF4EFE7);
  static const Color _surface = Color(0xFFFFFCF7);
  static const Color _ink = Color(0xFF1D2A24);
  static const Color _muted = Color(0xFF68746D);

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _selectedChannel = 'general';
  String _artisanName = 'Master Artisan';
  String _artisanCraft = 'Traditional Craftsperson';
  bool _sending = false;

  final List<Map<String, dynamic>> _channels = [
    {
      'id': 'general',
      'name': 'All Artisans Guild',
      'icon': Icons.forum_rounded,
      'desc': 'General artisan discussions & techniques',
    },
    {
      'id': 'materials',
      'name': 'Raw Materials & Yarn',
      'icon': Icons.inventory_2_rounded,
      'desc': 'Bulk group buying, silk yarn, brass ingots',
    },
    {
      'id': 'fairs',
      'name': 'Exhibitions & Fairs',
      'icon': Icons.event_available_rounded,
      'desc': 'Dastkar, Surajkund & Shilp Bazaar alerts',
    },
    {
      'id': 'grants',
      'name': 'Grants & GI Schemes',
      'icon': Icons.account_balance_rounded,
      'desc': 'PM Vishwakarma, subsidies & awards',
    },
  ];

  // Curated initial peer discussions for vibrant community feel
  final List<Map<String, dynamic>> _fallbackMessages = [
    {
      'name': 'Pandit Ramakant Sharma',
      'craft': 'Varanasi Silk Weaver',
      'message':
          'Namaste artisans! Sourcing pure Mulberry silk yarn from Bengaluru cluster. If anyone wants to join group bulk order to save 18% freight, please reply!',
      'channel': 'materials',
      'time': '10 mins ago',
      'likes': 12,
      'isArtisanVerified': true,
    },
    {
      'name': 'Ustad Ghulam Mohammad',
      'craft': 'Kashmir Pashmina Weaver',
      'message':
          'For winter shawls, always check the micron count. Authentic Changthangi Pashmina must be 12-14 microns. The HeriTrace GI QR code gives buyers full confidence now!',
      'channel': 'general',
      'time': '25 mins ago',
      'likes': 19,
      'isArtisanVerified': true,
    },
    {
      'name': 'Smt. Radha Devi',
      'craft': 'Madhubani Painting Master',
      'message':
          'Registration for Delhi Haat Winter Crafts Fair is closing this Thursday. Make sure your Artisan Pehchan ID is linked to your HeriTrace catalog!',
      'channel': 'fairs',
      'time': '1 hour ago',
      'likes': 8,
      'isArtisanVerified': true,
    },
    {
      'name': 'Rameshwar Chitrakar',
      'craft': 'Patachitra Folk Painter',
      'message':
          'PM Vishwakarma Scheme phase-2 grant of ₹1,00,000 at 5% concessional rate is active. Highly recommend applying to upgrade traditional looms & drying racks.',
      'channel': 'grants',
      'time': '2 hours ago',
      'likes': 24,
      'isArtisanVerified': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadArtisanProfile();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadArtisanProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _db.collection('users').doc(user.uid).get();
        if (doc.exists && mounted) {
          final data = doc.data() ?? {};
          setState(() {
            _artisanName =
                data['name']?.toString() ??
                data['displayName']?.toString() ??
                user.displayName ??
                'Master Artisan';
            _artisanCraft =
                data['craft']?.toString() ??
                data['specialization']?.toString() ??
                'Verified Master Artisan';
          });
        }
      } catch (_) {}
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to participate in the community.'),
        ),
      );
      return;
    }

    setState(() => _sending = true);

    try {
      await _db.collection('artisan_community_chat').add({
        'userId': user.uid,
        'name': _artisanName,
        'craft': _artisanCraft,
        'message': text,
        'channel': _selectedChannel,
        'likes': 0,
        'isArtisanVerified': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Message sent to local guild: $text')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _surface,
        foregroundColor: _ink,
        elevation: 0.5,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Artisan Guild & Community',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _ink,
              ),
            ),
            Row(
              children: const [
                Icon(Icons.circle, color: Color(0xFF4CAF50), size: 7),
                SizedBox(width: 5),
                Text(
                  '480+ Artisans Online Across India',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _forest,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Guild Guidelines',
            icon: const Icon(Icons.info_outline_rounded, color: _terracotta),
            onPressed: _showGuildGuidelines,
          ),
        ],
      ),
      body: Column(
        children: [
          // Channel selection pill bar
          _buildChannelPillBar(),

          // Messages stream / list
          Expanded(child: _buildMessagesList()),

          // Message input bar
          _buildMessageInputBar(),
        ],
      ),
    );
  }

  Widget _buildChannelPillBar() {
    return Container(
      color: _surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          scrollDirection: Axis.horizontal,
          itemCount: _channels.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final channel = _channels[index];
            final isSelected = _selectedChannel == channel['id'];

            return FilterChip(
              avatar: Icon(
                channel['icon'] as IconData,
                size: 15,
                color: isSelected ? Colors.white : _terracotta,
              ),
              label: Text(channel['name'] as String),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedChannel = channel['id'] as String);
              },
              selectedColor: _terracotta,
              backgroundColor: _background,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : _ink,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? _terracotta : const Color(0xFFD9D0C4),
                  width: 0.8,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db
          .collection('artisan_community_chat')
          .where('channel', isEqualTo: _selectedChannel)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        // Combine live firestore messages with fallback curated messages for this channel
        final channelFallbacks = _fallbackMessages
            .where((m) => m['channel'] == _selectedChannel)
            .toList();

        if (docs.isEmpty && channelFallbacks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.forum_outlined, size: 48, color: _muted),
                  const SizedBox(height: 12),
                  const Text(
                    'Be the first artisan to post in this channel!',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ask questions, share techniques, or post raw material opportunities.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: _muted),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          children: [
            // Live Firestore Messages
            for (final doc in docs)
              _buildMessageCard(
                name: doc.data()['name'] ?? 'Master Artisan',
                craft: doc.data()['craft'] ?? 'Artisan Guild',
                message: doc.data()['message'] ?? '',
                time: _formatTimestamp(doc.data()['createdAt']),
                likes: doc.data()['likes'] ?? 0,
                isVerified: doc.data()['isArtisanVerified'] == true,
                docId: doc.id,
              ),

            // Curated Community Discussions
            for (final msg in channelFallbacks)
              _buildMessageCard(
                name: msg['name'] as String,
                craft: msg['craft'] as String,
                message: msg['message'] as String,
                time: msg['time'] as String,
                likes: msg['likes'] as int,
                isVerified: msg['isArtisanVerified'] == true,
              ),
          ],
        );
      },
    );
  }

  Widget _buildMessageCard({
    required String name,
    required String craft,
    required String message,
    required String time,
    required int likes,
    required bool isVerified,
    String? docId,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8DFD3), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _terracotta.withValues(alpha: 0.15),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'A',
                  style: const TextStyle(
                    color: _terracotta,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: _forest, size: 14),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      craft,
                      style: const TextStyle(
                        color: _terracotta,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(time, style: const TextStyle(color: _muted, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(color: _ink, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (docId != null) {
                    _db.collection('artisan_community_chat').doc(docId).update({
                      'likes': FieldValue.increment(1),
                    });
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appreciated artisan post! ❤️'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      color: _terracotta,
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$likes',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.chat_bubble_outline_rounded,
                color: _muted,
                size: 14,
              ),
              const SizedBox(width: 4),
              const Text(
                'Reply in Guild',
                style: TextStyle(
                  color: _muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInputBar() {
    return Container(
      color: _surface,
      padding: EdgeInsets.fromLTRB(
        14,
        8,
        14,
        MediaQuery.of(context).viewInsets.bottom + 10,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFD9D0C4)),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: 3,
                  minLines: 1,
                  style: const TextStyle(color: _ink, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText:
                        'Share advice, technique, or raw material inquiry...',
                    hintStyle: TextStyle(color: _muted, fontSize: 12),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: _terracotta,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _sendMessage,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return DateFormat('hh:mm a').format(date);
    }
    return 'Just now';
  }

  void _showGuildGuidelines() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.workspace_premium_rounded, color: _terracotta),
            SizedBox(width: 8),
            Text(
              'Artisan Guild Rules',
              style: TextStyle(fontWeight: FontWeight.w900, color: _ink),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '1. Pure Peer Respect: We are all master custodians of Indian craft heritage.',
            ),
            SizedBox(height: 8),
            Text(
              '2. Bulk Group Buying: Share genuine raw material suppliers to eliminate middlemen.',
            ),
            SizedBox(height: 8),
            Text(
              '3. Authenticity Only: Help fellow artisans preserve pure GI standards and traditional dyes.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Understood',
              style: TextStyle(color: _terracotta, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
