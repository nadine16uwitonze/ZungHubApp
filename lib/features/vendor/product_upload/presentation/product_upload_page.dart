import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import 'product_upload_providers.dart';

class ProductUploadPage extends ConsumerStatefulWidget {
  const ProductUploadPage({super.key});

  @override
  ConsumerState<ProductUploadPage> createState() => _ProductUploadPageState();
}

class _ProductUploadPageState extends ConsumerState<ProductUploadPage> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  String category = AppConstants.productCategories.first;

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final result = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (result != null) {
      ref.read(productUploadControllerProvider.notifier).selectImage(result);
    }
  }

  Future<void> submit() async {
    await ref.read(productUploadControllerProvider.notifier).submit(
          name: nameController.text,
          category: category,
          price: priceController.text,
        );
    if (!mounted) return;
    final state = ref.read(productUploadControllerProvider);
    if (state.completed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product published.')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productUploadControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Add product')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Product name'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: AppConstants.productCategories
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) => setState(() => category = value!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Price'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: state.isSubmitting ? null : pickImage,
            icon: const Icon(Icons.photo),
            label: const Text('Choose product image'),
          ),
          if (state.image != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FutureBuilder<List<int>>(
                future: state.image!.readAsBytes(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return Image.memory(
                    Uint8List.fromList(snapshot.data!),
                    height: 180,
                    fit: BoxFit.cover,
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
                : const Text('Publish product'),
          ),
        ],
      ),
    );
  }
}
