import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../vendor/product_upload/domain/product.dart';

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key});

  Stream<List<Product>> get products => FirebaseFirestore.instance
      .collection('products')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Product.fromFirestore(doc.id, doc.data()))
          .toList());

  void purchase(BuildContext context, Product product) {
    if (FirebaseAuth.instance.currentUser == null) {
      context.push('/login');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order started for ${product.name}.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = FirebaseAuth.instance.currentUser != null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZungHub marketplace'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/government'),
            icon: const Icon(Icons.policy_outlined),
            label: const Text('Rules & tax'),
          ),
          if (!signedIn)
            TextButton.icon(
              onPressed: () => context.push('/login'),
              icon: const Icon(Icons.login),
              label: const Text('Sign in'),
            ),
          if (signedIn)
            IconButton(
              tooltip: 'Sign out',
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: products,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Could not load products: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _MarketplaceHeader(signedIn: signedIn)),
              if (products.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child:
                      Center(child: Text('No products have been listed yet.')),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      mainAxisExtent: 330,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _ProductCard(
                        product: product,
                        onPurchase: () => purchase(context, product),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MarketplaceHeader extends StatelessWidget {
  const _MarketplaceHeader({required this.signedIn});

  final bool signedIn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Find what your neighborhood makes.',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(signedIn
              ? 'Browse local products and place an order when you are ready.'
              : 'Browse local products freely. Sign in when you want to purchase.'),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onPurchase});

  final Product product;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: product.imageUrl.isEmpty
                ? const ColoredBox(
                    color: Color(0xffe4f0eb),
                    child: Icon(Icons.storefront, size: 52),
                  )
                : Image.network(product.imageUrl, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Text(product.name,
                style: Theme.of(context).textTheme.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
                '${product.category}  |  \$${product.price.toStringAsFixed(2)}'),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: FilledButton.icon(
              onPressed: onPurchase,
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Purchase'),
            ),
          ),
        ],
      ),
    );
  }
}
