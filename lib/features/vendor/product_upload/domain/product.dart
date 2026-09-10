import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  const Product({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.location,
    required this.stockStatus,
    required this.createdAt,
  });

  final String id;
  final String vendorId;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final GeoPoint location;
  final String stockStatus;
  final DateTime createdAt;

  factory Product.fromFirestore(String id, Map<String, Object?> data) {
    final createdAt = data['createdAt'];
    return Product(
      id: id,
      vendorId: data['vendorId'] as String? ?? '',
      name: data['name'] as String? ?? 'Unnamed product',
      category: data['category'] as String? ?? 'Other',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      imageUrl: data['imageUrl'] as String? ?? '',
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
        'imageUrl': imageUrl,
        'location': location,
        'stockStatus': stockStatus,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
