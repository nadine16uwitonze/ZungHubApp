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
    this.images = const [],
    this.isSubmitting = false,
    this.error,
    this.completed = false,
  });

  final List<XFile> images;
  final bool isSubmitting;
  final Object? error;
  final bool completed;

  ProductUploadState copyWith({
    List<XFile>? images,
    bool? isSubmitting,
    Object? error,
    bool? completed,
  }) {
    return ProductUploadState(
      images: images ?? this.images,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      completed: completed ?? this.completed,
    );
  }
}

class ProductUploadController extends StateNotifier<ProductUploadState> {
  ProductUploadController(this._repository) : super(const ProductUploadState());

  final ProductRepository _repository;

  void selectImages(List<XFile> images) =>
      state = state.copyWith(images: images, error: null);

  Future<void> submit({
    required String name,
    required String category,
    required String price,
    required String description,
    required int stockQuantity,
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
      if (stockQuantity < 0) {
        throw const FormatException('Stock quantity cannot be negative.');
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
        description: description,
        price: normalizedPrice,
        stockQuantity: stockQuantity,
        images: state.images,
        location: GeoPoint(position.latitude, position.longitude),
      );
      state = state.copyWith(
        isSubmitting: false,
        completed: true,
        images: const [],
      );
    } catch (error) {
      state = state.copyWith(isSubmitting: false, error: error);
    }
  }
}

final productUploadControllerProvider =
    StateNotifierProvider<ProductUploadController, ProductUploadState>((ref) {
  return ProductUploadController(ref.watch(productRepositoryProvider));
});
