import 'package:flutter/material.dart';

class AsyncErrorView extends StatelessWidget {
  const AsyncErrorView({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Something went wrong: $error'));
  }
}
