import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../providers/cart_provider.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final addressController = TextEditingController();
  String deliveryType = 'delivery';

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  Future<void> submitOrder() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      context.go('/login');
      return;
    }

    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;

    final uuid = const Uuid();
    final orderGroupId = uuid.v4();
    final grouped = <String, List<CartItem>>{};

    for (final item in cart) {
      grouped.putIfAbsent(item.vendorId, () => []).add(item);
    }

    final firestore = FirebaseFirestore.instance;

    for (final entry in grouped.entries) {
      final vendorId = entry.key;
      final items = entry.value;
      final totalAmount = items.fold<double>(
        0,
        (sum, item) => sum + (item.priceAtAdd * item.quantity),
      );

      await firestore.collection('orders').add({
        'orderGroupId': orderGroupId,
        'vendorId': vendorId,
        'customerId': currentUser.uid,
        'items': items
            .map((item) => {
                  'productId': item.productId,
                  'name': item.name,
                  'qty': item.quantity,
                  'price': item.priceAtAdd,
                })
            .toList(),
        'status': 'Pending',
        'totalAmount': totalAmount,
        'deliveryType': deliveryType,
        'address': addressController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    ref.read(cartProvider.notifier).clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order placed successfully.')),
    );
    context.go('/orders');
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final total = cart.fold<double>(
        0, (sum, item) => sum + (item.priceAtAdd * item.quantity));

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Delivery option'),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'delivery', label: Text('Delivery')),
                ButtonSegment(value: 'pickup', label: Text('Pickup')),
              ],
              selected: {deliveryType},
              onSelectionChanged: (value) =>
                  setState(() => deliveryType = value.first),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: addressController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Delivery or pickup details',
                hintText: 'Street, landmark, or pickup note',
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order summary',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ...cart.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text('${item.name} x${item.quantity}')),
                            Text(
                                '\$${(item.priceAtAdd * item.quantity).toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Expanded(child: Text('Total')),
                        Text('\$${total.toStringAsFixed(2)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: submitOrder,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Place order'),
            ),
          ],
        ),
      ),
    );
  }
}
