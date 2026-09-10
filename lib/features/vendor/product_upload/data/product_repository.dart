import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../domain/product.dart';

class ProductRepository {
  ProductRepository(this._firestore, this._storage, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
  final _uuid = const Uuid();

  Future<String> uploadImage(XFile image, String productId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw StateError('You must be signed in.');
    final reference = _storage.ref('products/$userId/$productId.jpg');
    await reference.putData(
      await image.readAsBytes(),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return reference.getDownloadURL();
  }

  Future<void> createProduct({
    required String name,
    required String category,
    required double price,
    required XFile? image,
    required GeoPoint location,
  }) async {
    final vendorId = _auth.currentUser?.uid;
    if (vendorId == null) throw StateError('You must be signed in.');
    final productId = _uuid.v4();
    final imageUrl = image == null ? '' : await uploadImage(image, productId);
    final product = Product(
      id: productId,
      vendorId: vendorId,
      name: name.trim(),
      category: category,
      price: price,
      imageUrl: imageUrl,
      location: location,
      stockStatus: 'in_stock',
      createdAt: DateTime.now(),
    );
    await _firestore
        .collection('products')
        .doc(productId)
        .set(product.toJson());
  }
}
