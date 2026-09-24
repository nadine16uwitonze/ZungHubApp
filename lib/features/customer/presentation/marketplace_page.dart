import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/cart_provider.dart';
import '../../vendor/product_upload/domain/product.dart';

class MarketplacePage extends ConsumerStatefulWidget {
  const MarketplacePage({super.key});

  @override
  ConsumerState<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends ConsumerState<MarketplacePage> {
  String searchTerm = '';
  String selectedCategory = 'All';

  Stream<List<Product>> get products => FirebaseFirestore.instance
      .collection('products')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Product.fromFirestore(doc.id, doc.data()))
          .toList());

  void addToCart(Product product) {
    if (FirebaseAuth.instance.currentUser == null) {
      context.push('/login');
      return;
    }
    ref.read(cartProvider.notifier).addProduct(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} added to cart.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = FirebaseAuth.instance.currentUser != null;
    final cartItems = ref.watch(cartProvider);
    final categories = <String>[
      'All',
      ...ProductCategory.values.map((e) => e.label)
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ZungHub marketplace'),
        actions: [
          if (signedIn)
            Badge(
              label: Text('${cartItems.length}'),
              child: IconButton(
                onPressed: () => context.push('/cart'),
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
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
              child: Text('Could not load products: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredProducts = snapshot.data!.where((product) {
            final priceMatches =
                product.name.toLowerCase().contains(searchTerm.toLowerCase());
            final categoryMatches = selectedCategory == 'All' ||
                product.category == selectedCategory;
            return priceMatches && categoryMatches;
          }).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _MarketplaceHeader(
                  signedIn: signedIn,
                  searchTerm: searchTerm,
                  selectedCategory: selectedCategory,
                  categories: categories,
                  onSearchChanged: (value) =>
                      setState(() => searchTerm = value),
                  onCategoryChanged: (value) =>
                      setState(() => selectedCategory = value ?? 'All'),
                ),
              ),
              if (filteredProducts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.storefront_outlined, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'No products listed yet',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Local vendors will appear here as soon as they add their first product.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      mainAxisExtent: 350,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _ProductCard(
                        product: product,
                        onAddToCart: () => addToCart(product),
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

enum ProductCategory {
  all('All'),
  food('Food'),
  clothing('Clothing'),
  household('Household'),
  services('Services'),
  other('Other');

  const ProductCategory(this.label);
  final String label;
}

class _MarketplaceHeader extends StatelessWidget {
  const _MarketplaceHeader({
    required this.signedIn,
    required this.searchTerm,
    required this.selectedCategory,
    required this.categories,
    required this.onSearchChanged,
    required this.onCategoryChanged,
  });

  final bool signedIn;
  final String searchTerm;
  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find what your neighborhood makes.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            signedIn
                ? 'Browse local products and place an order when you are ready.'
                : 'Browse local products freely. Sign in when you want to purchase.',
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: onSearchChanged,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search products',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                final selected = category == selectedCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  onSelected: (_) => onCategoryChanged(category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onAddToCart});

  final Product product;
  final VoidCallback onAddToCart;

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
            child: Text(
              product.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '${product.category} • \$${product.price.toStringAsFixed(2)}',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
            child: FilledButton.icon(
              onPressed: onAddToCart,
              icon: const Icon(Icons.add_shopping_cart_outlined),
              label: const Text('Add to cart'),
            ),
          ),
        ],
      ),
    );
  }
}
