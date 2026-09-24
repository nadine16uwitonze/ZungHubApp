import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  const CartItem({
    required this.productId,
    required this.vendorId,
    required this.name,
    required this.quantity,
    required this.priceAtAdd,
  });

  final String productId;
  final String vendorId;
  final String name;
  final int quantity;
  final double priceAtAdd;

  CartItem copyWith({
    String? productId,
    String? vendorId,
    String? name,
    int? quantity,
    double? priceAtAdd,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      priceAtAdd: priceAtAdd ?? this.priceAtAdd,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'vendorId': vendorId,
        'name': name,
        'quantity': quantity,
        'priceAtAdd': priceAtAdd,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] as String? ?? '',
      vendorId: json['vendorId'] as String? ?? '',
      name: json['name'] as String? ?? 'Product',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      priceAtAdd: (json['priceAtAdd'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super(const []) {
    _load();
  }

  static const _storageKey = 'zunghub_cart';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      state = const [];
      return;
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      state = decoded
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      state = const [];
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(state.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }

  void addProduct(dynamic product) {
    final productId = product.id as String;
    final vendorId = product.vendorId as String;
    final name = product.name as String;
    final price = (product.price as num).toDouble();

    final existingIndex =
        state.indexWhere((item) => item.productId == productId);

    if (existingIndex >= 0) {
      final updated = [...state];
      updated[existingIndex] = updated[existingIndex].copyWith(
        quantity: updated[existingIndex].quantity + 1,
      );
      state = updated;
    } else {
      state = [
        ...state,
        CartItem(
          productId: productId,
          vendorId: vendorId,
          name: name,
          quantity: 1,
          priceAtAdd: price,
        ),
      ];
    }
    _persist();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    state = [
      for (final item in state)
        if (item.productId == productId)
          item.copyWith(quantity: quantity)
        else
          item,
    ];
    _persist();
  }

  void removeItem(String productId) {
    state = state.where((item) => item.productId != productId).toList();
    _persist();
  }

  void clear() {
    state = const [];
    _persist();
  }

  double get totalAmount => state.fold(
        0.0,
        (sum, item) => sum + (item.priceAtAdd * item.quantity),
      );
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
