import 'package:flutter/material.dart';

class GovernmentDashboardPage extends StatelessWidget {
  const GovernmentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Government compliance hub')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Business guidance',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text(
              'A single place for vendors to understand the rules, permits, and taxes that apply to their business.'),
          const SizedBox(height: 20),
          const _GuidanceCard(
            icon: Icons.rule,
            title: 'Rules and regulations',
            text:
                'Keep trading areas clean, display prices clearly, and follow the operating conditions for your location.',
          ),
          const _GuidanceCard(
            icon: Icons.assignment_turned_in_outlined,
            title: 'Permits and licences',
            text:
                'Check which permit your product and trading location require before you start selling.',
          ),
          const _GuidanceCard(
            icon: Icons.receipt_long_outlined,
            title: 'Tax basics',
            text:
                'Keep sales records, separate business money, and confirm your registration and filing obligations with the relevant tax authority.',
          ),
          const _GuidanceCard(
            icon: Icons.notifications_active_outlined,
            title: 'Updates for vendors',
            text:
                'Important notices and changes to local requirements can be published here by government administrators.',
          ),
        ],
      ),
    );
  }
}

class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard(
      {required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, size: 30),
        title: Text(title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(text),
        ),
      ),
    );
  }
}
