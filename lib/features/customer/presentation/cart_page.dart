import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/cart_provider.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final total = cart.fold<double>(
        0, (sum, item) => sum + (item.priceAtAdd * item.quantity));

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cart')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_cart_outlined, size: 56),
                const SizedBox(height: 16),
                const Text('Your cart is empty'),
                const SizedBox(height: 8),
                const Text('Add a few local favorites to get started.'),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Browse products'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: cart.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = cart[index];
                  final subtotal = item.priceAtAdd * item.quantity;
                  return Card(
                    child: ListTile(
                      title: Text(item.name),
                      subtitle:
                          Text('Price \$${item.priceAtAdd.toStringAsFixed(2)}'),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${subtotal.toStringAsFixed(2)}'),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => ref
                                    .read(cartProvider.notifier)
                                    .updateQuantity(
                                        item.productId, item.quantity - 1),
                                icon: const Icon(Icons.remove),
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                onPressed: () => ref
                                    .read(cartProvider.notifier)
                                    .updateQuantity(
                                        item.productId, item.quantity + 1),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total: \$${total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        if (FirebaseAuth.instance.currentUser == null) {
                          context.push('/login');
                          return;
                        }
                        context.push('/checkout');
                      },
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
