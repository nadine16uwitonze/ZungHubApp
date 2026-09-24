import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  const Product({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.stockQuantity,
    this.imageUrls = const [],
    required this.location,
    required this.stockStatus,
    required this.createdAt,
  });

  final String id;
  final String vendorId;
  final String name;
  final String category;
  final double price;
  final String description;
  final int stockQuantity;
  final List<String> imageUrls;
  final GeoPoint location;
  final String stockStatus;
  final DateTime createdAt;

  String get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  factory Product.fromFirestore(String id, Map<String, Object?> data) {
    final createdAt = data['createdAt'];
    final imageUrls = data['imageUrls'] is List
        ? (data['imageUrls'] as List).whereType<String>().toList()
        : const <String>[];

    return Product(
      id: id,
      vendorId: data['vendorId'] as String? ?? '',
      name: data['name'] as String? ?? 'Unnamed product',
      category: data['category'] as String? ?? 'Other',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      description: data['description'] as String? ?? '',
      stockQuantity: (data['stockQuantity'] as num?)?.toInt() ?? 0,
      imageUrls: imageUrls,
      location: data['location'] as GeoPoint? ?? const GeoPoint(0, 0),
      stockStatus: data['stockStatus'] as String? ?? 'in_stock',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }

  Map<String, Object?> toJson() => {
        'vendorId': vendorId,
        'name': name,
        'category': category,
        'price': price,
        'description': description,
        'stockQuantity': stockQuantity,
        'imageUrls': imageUrls,
        'location': location,
        'stockStatus': stockStatus,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
