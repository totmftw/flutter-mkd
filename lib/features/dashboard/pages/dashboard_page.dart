import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  final Logger _logger = Logger('DashboardPage');

  void _setupWhatsAppAPI() async {
    try {
      // Ensure the widget is still mounted before showing any UI
      if (!mounted) return;

      // TODO: Implement actual WhatsApp API setup logic
      // Potential steps:
      // 1. Validate API credentials
      // 2. Configure WhatsApp Business API or third-party service
      // 3. Test connection and messaging capabilities
      // 4. Store and manage API configuration securely
      
      _logger.info('Initiating WhatsApp API setup');
      
      // Simulated setup process
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WhatsApp API setup initiated'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e, stackTrace) {
      _logger.severe('WhatsApp API setup failed', e, stackTrace);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('WhatsApp API setup failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Trigger payment reminder check on dashboard load
    ref
        .read(paymentReminderControllerProvider.notifier)
        .checkAndSendReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.whatsapp),
            tooltip: 'Setup WhatsApp API',
            onPressed: _setupWhatsAppAPI,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement logout logic
              ref.read(authProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDashboardMetrics(),
          const SizedBox(height: 20),
          _buildPaymentFollowups(),
        ],
      ),
    );
  }

  Widget _buildDashboardMetrics() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Metrics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MetricTile(label: 'Total Sales', value: '₹1,25,000'),
                _MetricTile(label: 'Pending Invoices', value: '₹45,000'),
                _MetricTile(label: 'Overdue', value: '₹15,000'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentFollowups() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Follow-ups',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // TODO: Implement actual payment follow-up list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Customer ${index + 1}'),
                  subtitle: const Text('Invoice due in 7 days'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement reminder sending logic
                    },
                    child: const Text('Send Reminder'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;

  const _MetricTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
