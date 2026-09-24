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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isCreatingAccount = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email and password.')),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email address.')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password must be at least 6 characters.')),
      );
      return;
    }

    if (isCreatingAccount) {
      await ref
          .read(authControllerProvider.notifier)
          .createAccount(email: email, password: password);
    } else {
      await ref
          .read(authControllerProvider.notifier)
          .login(email: email, password: password);
    }

    if (!mounted) return;

    final authState = ref.read(authControllerProvider);
    if (authState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Unable to sign in. Please check your email and password and try again.'),
        ),
      );
      return;
    }

    context.go('/role');
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
                  Text(
                    isCreatingAccount
                        ? 'Create your account to start selling or shopping locally.'
                        : 'Sign in with your email and password to continue.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      hintText: 'you@example.com',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Minimum 6 characters',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: authState.isLoading ? null : submit,
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            isCreatingAccount ? 'Create account' : 'Login',
                          ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => setState(() {
                      isCreatingAccount = !isCreatingAccount;
                    }),
                    child: Text(
                      isCreatingAccount
                          ? 'Already have an account? Login'
                          : 'Need an account? Create one',
                    ),
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
