import 'package:flutter/material.dart';

class SupportChatbot extends StatelessWidget {
  final String role;
  final bool compact;

  const SupportChatbot({
    super.key,
    required this.role,
    this.compact = false,
  });

  void _open(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _SupportChatSheet(role: role),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return FloatingActionButton(
        heroTag: 'support-chat-$role',
        onPressed: () => _open(context),
        backgroundColor: const Color(0xFFA24B2A),
        foregroundColor: Colors.white,
        tooltip: 'HeriGuide Help',
        elevation: 4,
        child: const Icon(Icons.support_agent_rounded, size: 24),
      );
    }

    return FloatingActionButton.extended(
      heroTag: 'support-chat-$role',
      onPressed: () => _open(context),
      backgroundColor: const Color(0xFFA24B2A),
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.support_agent_rounded),
      label: const Text('Help', style: TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _SupportChatSheet extends StatefulWidget {
  final String role;

  const _SupportChatSheet({required this.role});

  @override
  State<_SupportChatSheet> createState() => _SupportChatSheetState();
}

class _SupportChatSheetState extends State<_SupportChatSheet> {
  final _controller = TextEditingController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      false,
      'Hi! I’m HeriGuide. Choose a topic and I’ll point you to the right place.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ask(String text) {
    final normalized = text.toLowerCase();
    String reply;
    if (normalized.contains('order') || normalized.contains('track')) {
      reply =
          'Open My Orders to see payment, processing, shipping, and delivery status.';
    } else if (normalized.contains('auction') || normalized.contains('bid')) {
      reply = 'Open Rare Auctions to view live lots and place a bid.';
    } else if (normalized.contains('product') || normalized.contains('sell')) {
      reply = widget.role == 'artisan'
          ? 'Use Add Product to publish your craft with an image, price, and story.'
          : 'Browse the marketplace and use the heart or bag actions on any product.';
    } else if (normalized.contains('payment')) {
      reply =
          'Checkout uses Razorpay. If it fails, verify the payment backend is online.';
    } else if (normalized.contains('profile') ||
        normalized.contains('password')) {
      reply =
          'Open Profile & Settings to update details, change your password, or log out.';
    } else {
      reply =
          'Try asking about orders, auctions, products, payments, or your profile.';
    }

    setState(() {
      _messages
        ..add(_ChatMessage(true, text))
        ..add(_ChatMessage(false, reply));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFF1D2A24),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          children: [
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3B66A),
                child: Icon(Icons.auto_awesome, color: Color(0xFF1D2A24)),
              ),
              title: const Text(
                'HeriGuide Support',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: const Text(
                'Guided help for your current page',
                style: TextStyle(color: Color(0xFFC8D0C8), fontSize: 11),
              ),
              trailing: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
            const Divider(color: Color(0xFF3B5044), height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Align(
                    alignment: message.fromUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 310),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: message.fromUser
                            ? const Color(0xFFA24B2A)
                            : const Color(0xFF2A3B31),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        message.text,
                        style: const TextStyle(
                          color: Colors.white,
                          height: 1.35,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) _ask(value.trim());
                      },
                      decoration: InputDecoration(
                        hintText: 'Ask about orders, auctions...',
                        hintStyle: const TextStyle(color: Color(0xFFC8D0C8)),
                        filled: true,
                        fillColor: const Color(0xFF2A3B31),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () {
                      final value = _controller.text.trim();
                      if (value.isNotEmpty) _ask(value);
                    },
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final bool fromUser;
  final String text;

  const _ChatMessage(this.fromUser, this.text);
}
