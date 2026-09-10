import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final phoneController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final phoneNumber = phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your phone number.')),
      );
      return;
    }
    await ref.read(authControllerProvider.notifier).sendCode(phoneNumber);
    if (mounted && !ref.read(authControllerProvider).hasError) {
      context.push('/verify');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.storefront, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to ZungHub',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in with your phone number to connect with your local marketplace.',
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      hintText: '+263 77 123 4567',
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (authState.hasError)
                    Text(
                      authState.error.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  FilledButton(
                    onPressed: authState.isLoading ? null : submit,
                    child: authState.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Send code'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
