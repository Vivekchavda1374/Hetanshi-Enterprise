import 'package:flutter/material.dart';
import 'package:hetanshi_enterprise/screens/order/order_history_screen.dart';
import 'package:hetanshi_enterprise/screens/expense/expense_list_screen.dart';
import 'package:hetanshi_enterprise/utils/app_theme.dart';
import 'package:hetanshi_enterprise/services/auth_manager.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = AuthManager.instance.isAdmin;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Hetanshi Enterprise',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  isAdmin
                      ? 'Admin'
                      : (AuthManager.instance.isUser
                          ? (AuthManager.instance.currentUser?.name ?? 'User')
                          : 'Guest'),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Products'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/products');
            },
          ),
          if (isAdmin)
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Parties'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/parties');
              },
            ),
          // Orders (Visible for Admin OR User)
          if (isAdmin || AuthManager.instance.isUser)
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: Text(isAdmin ? 'All Orders' : 'My Orders'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/orders');
              },
            ),
          if (isAdmin) ...[
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Order History'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/history');
              },
            ),
            ListTile(
              leading: const Icon(Icons.money_off, color: AppColors.dangerRed),
              title: const Text('Expenses'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ExpenseListScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Manage Users'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/users');
              },
            ),
          ],
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              AuthManager.instance.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
      