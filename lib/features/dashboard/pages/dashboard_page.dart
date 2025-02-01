import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../payment/providers/payment_reminder_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  void _setupWhatsAppApi() {
    // TODO: Implement actual WhatsApp API setup logic
    // This could involve:
    // 1. Authenticating with WhatsApp Business API
    // 2. Setting up webhook or API credentials
    // 3. Configuring message templates
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('WhatsApp API setup is a work in progress'),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Trigger payment reminder check on dashboard load
    ref
        .read(paymentReminderControllerProvider.notifier)
        .checkAndSendReminders();
  }

  void _showWhatsAppSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('WhatsApp API Setup'),
        content: const Text('Do you want to configure WhatsApp integration?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _setupWhatsAppApi,
            child: const Text('Setup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showWhatsAppSetupDialog,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Reminders',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _showWhatsAppSetupDialog,
                    child: const Text('Configure WhatsApp API'),
                  ),
                ],
              ),
            ),
          ),
          // Add more dashboard widgets here
        ],
      ),
    );
  }
}
