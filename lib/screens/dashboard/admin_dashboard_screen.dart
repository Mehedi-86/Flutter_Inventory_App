import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/services/dashboard_service.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/category_pie_chart.dart';
import 'dashboard_screen.dart';
import '../alerts/low_stock_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final DashboardService _dashboardService = DashboardService.instance;

  // REMOVED initState, dispose, and _refreshData methods. They are no longer needed.

  Widget _buildMetricCard(Stream<dynamic> stream, String title, IconData icon, Color iconColor) {
    return StreamBuilder<dynamic>(
      stream: stream,
      builder: (context, snapshot) {
        String value = '...';
        if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
          value = snapshot.data.toString();
        } else if (snapshot.hasError) {
          value = 'Error';
        }
        return MetricCard(title: title, value: value, icon: icon, iconColor: iconColor);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminContent = Container(
      color: Colors.grey.shade100,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            alignment: WrapAlignment.center,
            children: [
              _buildMetricCard(_dashboardService.getTotalProductCount(), 'Total Products', Icons.inventory_2_outlined, Colors.deepPurple),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LowStockScreen()),
                  );
                },
                child: _buildMetricCard(_dashboardService.getLowStockCount(), 'Low on Stock', Icons.warning_amber_rounded, Colors.orange),
              ),
              _buildMetricCard(_dashboardService.getTotalInventoryValue(), 'Inventory Value', Icons.attach_money_rounded, Colors.green),
            ],
          ),
          const SizedBox(height: 20),
          const SizedBox(
            height: 400,
            child: CategoryPieChart(),
          ),
        ],
      ),
    );

    return DashboardScreen(
      title: 'Admin Dashboard',
      body: adminContent,
      userRole: UserRole.admin,
    );
  }
}

