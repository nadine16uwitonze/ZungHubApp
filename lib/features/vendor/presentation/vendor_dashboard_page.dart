import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../product_upload/data/product_repository.dart';
import '../product_upload/domain/product.dart';

class VendorDashboardPage extends ConsumerWidget {
  const VendorDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(
            child: Text('Please sign in to view your vendor dashboard.')),
      );
    }

    final repository = ProductRepository(
      FirebaseFirestore.instance,
      FirebaseStorage.instance,
      FirebaseAuth.instance,
    );

    final productStream = repository.vendorProducts(userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor dashboard'),
        actions: [
          IconButton(
            onPressed: () => context.push('/cart'),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: productStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!;
          final pendingOrders = 0;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                _StatsRow(
                  totalProducts: products.length,
                  pendingOrders: pendingOrders,
                  todayRevenue: 0.0,
                ),
                const SizedBox(height: 16),
                if (products.isEmpty)
                  _EmptyProductState(
                    onAddProduct: () => context.push('/vendor/products/new'),
                  )
                else
                  ...products.map(
                    (product) => _ProductListTile(
                      product: product,
                      onEdit: () =>
                          context.push('/vendor/products/new?id=${product.id}'),
                      onDelete: () async {
                        await repository.deleteProduct(product.id);
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/vendor/products/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add product'),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.totalProducts,
    required this.pendingOrders,
    required this.todayRevenue,
  });

  final int totalProducts;
  final int pendingOrders;
  final double todayRevenue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(label: 'Products', value: '$totalProducts'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(label: 'Pending', value: '$pendingOrders'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
              label: 'Revenue', value: '\$${todayRevenue.toStringAsFixed(2)}'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

class _EmptyProductState extends StatelessWidget {
  const _EmptyProductState({required this.onAddProduct});

  final VoidCallback onAddProduct;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront_outlined, size: 52),
            const SizedBox(height: 12),
            Text('No products yet',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
                'Add your first product to start selling in your community.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAddProduct,
              icon: const Icon(Icons.add),
              label: const Text('Add product'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductListTile extends StatelessWidget {
  const _ProductListTile({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: product.imageUrl.isEmpty
            ? const Icon(Icons.fastfood_outlined)
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(product.imageUrl,
                    width: 52, height: 52, fit: BoxFit.cover),
              ),
        title: Text(product.name),
        subtitle: Text(
            '${product.category} • \$${product.price.toStringAsFixed(2)} • ${product.stockQuantity} in stock'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
