import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/pages/login_page.dart';
import '../../auth/providers/auth_provider.dart';

// TODO: Comprehensive Dashboard Card Details
// This section requires detailed implementation of dashboard metrics
// Key requirements:
// 1. Fetch real-time data from backend
// 2. Implement dynamic card generation
// 3. Add drill-down capabilities for each metric
// 4. Ensure responsive design across devices

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  static const List<DashboardCard> _dashboardCards = [
    DashboardCard(
      title: 'Pending Payments',
      icon: Icons.pending_outlined,
      color: AppColors.warning,
      value: '₹1,25,000',
      subtitle: '12 Invoices Overdue',
    ),
    DashboardCard(
      title: 'Total Sales',
      icon: Icons.monetization_on_outlined,
      color: AppColors.success,
      value: '₹15,45,000',
      subtitle: 'This Financial Year',
    ),
    DashboardCard(
      title: 'Total Orders',
      icon: Icons.shopping_cart_outlined,
      color: AppColors.primary,
      value: '87',
      subtitle: 'Invoices Generated',
    ),
    DashboardCard(
      title: 'Outstanding Payments',
      icon: Icons.payment_outlined,
      color: AppColors.error,
      value: '₹3,50,000',
      subtitle: '8 Customers Pending',
    ),
  ];

  void _logout() {
    ref.read(authProvider.notifier).signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobileBuilder: _buildMobileDashboard,
        tabletBuilder: _buildDesktopDashboard,
        desktopBuilder: _buildDesktopDashboard,
      ),
    );
  }

  static Widget _buildMobileDashboard(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _dashboardCards.map((card) => 
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildDashboardCard(card),
        )
      ).toList(),
    );
  }

  static Widget _buildDesktopDashboard(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: _dashboardCards.length,
      itemBuilder: (context, index) => _buildDashboardCard(_dashboardCards[index]),
    );
  }

  static Widget _buildDashboardCard(DashboardCard card) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          // Roadmap for Detailed View Implementation:
          // 1. Create a new DetailedDashboardView widget
          // 2. Implement context-specific data retrieval
          //    - Fetch relevant data based on card type
          //    - Use Riverpod for state management
          // 3. Design responsive layout for details
          //    - Mobile: Bottom sheet or full-screen modal
          //    - Tablet/Desktop: Side panel or modal dialog
          // 4. Include interactive elements:
          //    - Date range selection
          //    - Filterable data views
          //    - Export options (PDF, CSV)
          // 5. Add visualizations:
          //    - Line charts for trends
          //    - Pie charts for distribution
          //    - Comparative analytics
          // 
          // Considerations:
          // - Optimize performance for large datasets
          // - Implement caching mechanisms
          // - Ensure responsive and adaptive design
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    card.icon,
                    color: card.color,
                    size: 40,
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.value,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    card.subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardCard {
  final String title;
  final IconData icon;
  final Color color;
  final String value;
  final String subtitle;

  const DashboardCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.value,
    required this.subtitle,
  });
}
