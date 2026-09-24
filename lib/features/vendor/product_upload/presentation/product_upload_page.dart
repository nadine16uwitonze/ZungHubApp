import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import 'product_upload_providers.dart';

class ProductUploadPage extends ConsumerStatefulWidget {
  const ProductUploadPage({this.productId, super.key});

  final String? productId;

  @override
  ConsumerState<ProductUploadPage> createState() => _ProductUploadPageState();
}

class _ProductUploadPageState extends ConsumerState<ProductUploadPage> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController(text: '10');
  String category = AppConstants.productCategories.first;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  Future<void> pickImages() async {
    final result = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (result.isNotEmpty) {
      ref.read(productUploadControllerProvider.notifier).selectImages(result);
    }
  }

  Future<void> submit() async {
    await ref.read(productUploadControllerProvider.notifier).submit(
          name: nameController.text,
          category: category,
          price: priceController.text,
          description: descriptionController.text,
          stockQuantity: int.tryParse(stockController.text) ?? 0,
        );
    if (!mounted) return;
    final state = ref.read(productUploadControllerProvider);
    if (state.completed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.productId == null
                ? 'Product published.'
                : 'Product updated.',
          ),
        ),
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productUploadControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId == null ? 'Add product' : 'Edit product'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Product name'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: AppConstants.productCategories
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) => setState(() => category = value ?? category),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Price'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: stockController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Stock quantity'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: state.isSubmitting ? null : pickImages,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Add product photos'),
          ),
          if (state.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final image = state.images[index];
                  return FutureBuilder<Uint8List>(
                    future: image.readAsBytes(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox(
                          width: 120,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          snapshot.data!,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Text(
            'Your current GPS location will be captured when you publish.',
          ),
          const SizedBox(height: 12),
          if (state.error != null)
            Text(
              state.error.toString(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          FilledButton(
            onPressed: state.isSubmitting ? null : submit,
            child: state.isSubmitting
                ? const CircularProgressIndicator()
                : Text(widget.productId == null
                    ? 'Publish product'
                    : 'Save changes'),
          ),
        ],
      ),
    );
  }
}
