import 'package:cloud_firestore/cloud_firestore.dart';

class Auction {
  const Auction({
    required this.id,
    required this.title,
    required this.description,
    required this.startingPrice,
    required this.currentBid,
    required this.bidCount,
    required this.endsAt,
    required this.status,
  });

  final String id;
  final String title;
  final String description;
  final double startingPrice;
  final double currentBid;
  final int bidCount;
  final DateTime endsAt;
  final String status;

  bool get isOpen => status == 'open' && endsAt.isAfter(DateTime.now());

  factory Auction.fromMap(String id, Map<String, dynamic> data) {
    final endValue = data['endsAt'];
    final endsAt = endValue is Timestamp
        ? endValue.toDate()
        : DateTime.tryParse(endValue?.toString() ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);

    return Auction(
      id: id,
      title: data['title']?.toString() ?? 'Untitled auction',
      description: data['description']?.toString() ?? '',
      startingPrice: _asDouble(data['startingPrice']),
      currentBid: _asDouble(data['currentBid'] ?? data['startingPrice']),
      bidCount: (data['bidCount'] as num?)?.toInt() ?? 0,
      endsAt: endsAt,
      status: data['status']?.toString() ?? 'open',
    );
  }

  static double _asDouble(dynamic value) {
    return value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
  }
}
