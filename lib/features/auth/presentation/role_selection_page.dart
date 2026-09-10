import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/app_user.dart';
import 'auth_providers.dart';

class RoleSelectionPage extends ConsumerStatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  ConsumerState<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends ConsumerState<RoleSelectionPage> {
  final nameController = TextEditingController();
  UserRole role = UserRole.vendor;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your name.')),
      );
      return;
    }
    await ref
        .read(authControllerProvider.notifier)
        .saveRole(name: nameController.text, role: role);
    if (!mounted || ref.read(authControllerProvider).hasError) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Set up your account')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Your name'),
                ),
                const SizedBox(height: 20),
                const Text('I am joining as'),
                RadioGroup<UserRole>(
                  groupValue: role,
                  onChanged: (value) => setState(() => role = value!),
                  child: const Column(
                    children: [
                      RadioListTile<UserRole>(
                        value: UserRole.vendor,
                        title: Text('Vendor'),
                        subtitle: Text('List products and manage compliance.'),
                      ),
                      RadioListTile<UserRole>(
                        value: UserRole.customer,
                        title: Text('Customer'),
                        subtitle: Text('Discover local vendors and products.'),
                      ),
                    ],
                  ),
                ),
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
                      : const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
