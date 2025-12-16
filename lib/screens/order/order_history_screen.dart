import 'package:flutter/material.dart';
import 'package:hetanshi_enterprise/widgets/app_drawer.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: 15,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.history_edu, color: Colors.grey),
              title: Text('Order #${2000 - index}'),
              subtitle: Text('Party Name\n₹${(index + 1) * 250}'),
              isThreeLine: true,
              trailing: const Text(
                'Delivered',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
