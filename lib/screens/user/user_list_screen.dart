import 'package:flutter/material.dart';
import 'package:hetanshi_enterprise/widgets/app_drawer.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: Text('User ${index + 1}'),
              subtitle: Text(index == 0 ? 'Admin' : 'Salesman'),
              trailing: Switch(
                value: true,
                onChanged: (val) {},
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add User
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
