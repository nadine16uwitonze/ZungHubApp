import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomerOrdersPage extends StatelessWidget {
  const CustomerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view your orders.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('customerId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No orders yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final items =
                  (data['items'] as List? ?? []).cast<Map<String, dynamic>>();
              final status = data['status'] as String? ?? 'Pending';
              final total = (data['totalAmount'] as num?)?.toDouble() ?? 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Order #${index + 1}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Chip(label: Text(status)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...items.map(
                        (item) => Text(
                          '${item['name']} x${item['qty']} • \$${(item['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Total: \$${total.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
