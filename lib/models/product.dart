class Product {
  final String id, name, description, category;
  final double price;
  final String? imageUrl;
  final String artisanName;
  final String origin;
  final String material;
  final String technique;
  final String tradition;
  final bool verified;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl,
    this.artisanName = '',
    this.origin = '',
    this.material = '',
    this.technique = '',
    this.tradition = '',
    this.verified = false,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'price': price,
    'category': category,
    'imageUrl': imageUrl,
    'artisanName': artisanName,
    'origin': origin,
    'material': material,
    'technique': technique,
    'tradition': tradition,
    'verified': verified,
  };

  factory Product.fromMap(String id, Map<String, dynamic> m) => Product(
    id: id,
    name: m['name'] ?? '',
    description: m['description'] ?? '',
    price: m['price'] is num
        ? (m['price'] as num).toDouble()
        : double.tryParse(m['price']?.toString() ?? '') ?? 0,
    category: m['category'] ?? 'Other',
    imageUrl: m['imageUrl'],
    artisanName: m['artisanName']?.toString() ?? '',
    origin: m['origin']?.toString() ?? '',
    material: m['material']?.toString() ?? '',
    technique: m['technique']?.toString() ?? '',
    tradition: m['tradition']?.toString() ?? '',
    verified: m['verified'] == true,
  );
}
