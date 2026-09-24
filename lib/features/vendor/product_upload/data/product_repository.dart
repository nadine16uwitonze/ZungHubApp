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

  Future<List<String>> uploadImages(
      List<XFile> images, String productId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw StateError('You must be signed in.');

    final futures = images.asMap().entries.map((entry) async {
      final index = entry.key;
      final image = entry.value;
      final fileName = '${productId}_$index.${image.name.split('.').last}';
      final reference = _storage.ref('products/$userId/$fileName');
      await reference.putData(
        await image.readAsBytes(),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return reference.getDownloadURL();
    });

    return Future.wait(futures);
  }

  Stream<List<Product>> vendorProducts(String vendorId) {
    return _firestore
        .collection('products')
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  Stream<List<Product>> allProducts() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  Future<Product?> getProduct(String productId) async {
    final snapshot =
        await _firestore.collection('products').doc(productId).get();
    if (!snapshot.exists) return null;
    return Product.fromFirestore(snapshot.id, snapshot.data() ?? {});
  }

  Future<void> createProduct({
    required String name,
    required String category,
    required String description,
    required double price,
    required int stockQuantity,
    required List<XFile> images,
    required GeoPoint location,
  }) async {
    final vendorId = _auth.currentUser?.uid;
    if (vendorId == null) throw StateError('You must be signed in.');
    final productId = _uuid.v4();
    final uploadedImageUrls = images.isEmpty
        ? const <String>[]
        : await uploadImages(images, productId);
    final product = Product(
      id: productId,
      vendorId: vendorId,
      name: name.trim(),
      category: category,
      price: price,
      description: description.trim(),
      stockQuantity: stockQuantity,
      imageUrls: uploadedImageUrls,
      location: location,
      stockStatus: stockQuantity > 0 ? 'in_stock' : 'out_of_stock',
      createdAt: DateTime.now(),
    );
    await _firestore
        .collection('products')
        .doc(productId)
        .set(product.toJson());
  }

  Future<void> updateProduct(Product product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .update(product.toJson());
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }
}
