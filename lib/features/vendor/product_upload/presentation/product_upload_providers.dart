import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../data/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
    FirebaseAuth.instance,
  );
});

class ProductUploadState {
  const ProductUploadState({
    this.image,
    this.isSubmitting = false,
    this.error,
    this.completed = false,
  });

  final XFile? image;
  final bool isSubmitting;
  final Object? error;
  final bool completed;

  ProductUploadState copyWith({
    XFile? image,
    bool? isSubmitting,
    Object? error,
    bool? completed,
  }) {
    return ProductUploadState(
      image: image ?? this.image,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      completed: completed ?? this.completed,
    );
  }
}

class ProductUploadController extends StateNotifier<ProductUploadState> {
  ProductUploadController(this._repository) : super(const ProductUploadState());

  final ProductRepository _repository;

  void selectImage(XFile image) =>
      state = state.copyWith(image: image, error: null);

  Future<void> submit({
    required String name,
    required String category,
    required String price,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null, completed: false);
    try {
      final normalizedName = name.trim();
      final normalizedPrice = double.tryParse(price.trim());
      if (normalizedName.isEmpty) {
        throw const FormatException('Enter a product name.');
      }
      if (normalizedPrice == null || normalizedPrice <= 0) {
        throw const FormatException('Enter a valid price greater than zero.');
      }
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError(
          'Location permission is required to publish a product.',
        );
      }
      final position = await Geolocator.getCurrentPosition();
      await _repository.createProduct(
        name: name,
        category: category,
        price: normalizedPrice,
        image: state.image,
        location: GeoPoint(position.latitude, position.longitude),
      );
      state = state.copyWith(isSubmitting: false, completed: true);
    } catch (error) {
      state = state.copyWith(isSubmitting: false, error: error);
    }
  }
}

final productUploadControllerProvider =
    StateNotifierProvider<ProductUploadController, ProductUploadState>((ref) {
  return ProductUploadController(ref.watch(productRepositoryProvider));
});
