import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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
              children: const [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person),
                ),
                SizedBox(height: 10),
                Text(
                  'Hetanshi Enterprise',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  'user@example.com',
                  style: TextStyle(color: Colors.white70),
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
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Parties'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/parties');
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Orders'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/orders');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Order History'),
            onTap: () {
               Navigator.pushReplacementNamed(context, '/history');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Users'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/users');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
               Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
