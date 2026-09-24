import 'package:flutter/material.dart';

class VerifyCodePage extends StatelessWidget {
  const VerifyCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email sign in')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('This app now uses email and password sign-in.'),
        ),
      ),
    );
  }
}
