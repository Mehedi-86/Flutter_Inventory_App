import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart'; // Import AuthService
import '../screens/auth/login_screen.dart'; // Import LoginScreen for navigation
import '../screens/products/product_list_screen.dart'; // <-- IMPORT THE NEW SCREEN
import '../screens/history/transaction_history_screen.dart'; // <-- IMPORT THE NEW SCREEN
import '../screens/users/manage_users_screen.dart'; // <-- 1. IMPORT THE NEW SCREEN
import '../screens/analytics/inventory_recommendations_screen.dart';
import '../screens/analytics/sales_forecast_screen.dart';
import '../screens/analytics/abc_analysis_screen.dart';

class AppSidebar extends StatelessWidget {
  final UserRole userRole;

  const AppSidebar({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              userRole == UserRole.admin ? 'Admin User' : 'Staff User',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              userRole == UserRole.admin ? 'admin@app.com' : 'staff@app.com',
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
            ),
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              // AZROF-NOTE: We may want to prevent re-navigating if already on the dashboard.
              Navigator.pop(context);
            },
          ),
        
          // Replace your old "Products" ListTile with this one.
          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text('Products'),
            onTap: () {
              // First, close the drawer so it's not open in the background.
              Navigator.pop(context);
              // Then, navigate to the new ProductListScreen.
              Navigator.of(context).push(
                MaterialPageRoute(
                  // 2. We pass the current user's role to the screen so it knows
                  // which UI variations to display (e.g., show/hide delete button).
                  builder: (context) => ProductListScreen(userRole: userRole),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Transaction History'),
            onTap: () {
              // First, close the drawer.
              Navigator.pop(context);
              // Then, navigate to the new TransactionHistoryScreen.
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const TransactionHistoryScreen()),
              );
            },
          ),
          const Divider(),
          // Analytics Section
          if (userRole == UserRole.admin) ...[
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Analytics'),
              subtitle: const Text('Advanced insights'),
              onTap: () {
                Navigator.pop(context);
                _showAnalyticsBottomSheet(context);
              },
            ),
          ],
          // --- UPDATE THIS NAVIGATION ---
          if (userRole == UserRole.admin)
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Manage Users'),
              onTap: () {
                // First, close the drawer.
                Navigator.pop(context);
                // Then, navigate to the new ManageUsersScreen.
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const ManageUsersScreen()),
                );
              },
            ),
          // --- UPDATED: LOGOUT BUTTON LOGIC ---
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              // AZROF-NOTE: This is the implementation for logging the user out.
              // MUBIN-NOTE: This shows how the UI calls the service layer to perform an action.
              await AuthService.instance.logout();
              
              if (context.mounted) {
                // Navigate back to the login screen and remove all previous routes.
                // This is important so the user can't press the back button to get
                // back into the dashboard after logging out.
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false, // This predicate removes all routes.
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAnalyticsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Analytics & Reports',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.recommend, color: Colors.blue),
              title: const Text('Inventory Recommendations'),
              subtitle: const Text('AI-powered reorder suggestions'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const InventoryRecommendationsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up, color: Colors.green),
              title: const Text('Sales Forecast'),
              subtitle: const Text('30-day sales predictions'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SalesForecastScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.category, color: Colors.orange),
              title: const Text('ABC Analysis'),
              subtitle: const Text('Product classification by value'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AbcAnalysisScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

