import 'package:flutter/material.dart';
import 'package:hetanshi_enterprise/widgets/app_drawer.dart';
import 'package:hetanshi_enterprise/widgets/summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: const [
            SummaryCard(
              title: 'Total Orders',
              value: '120',
              icon: Icons.shopping_bag,
              color: Colors.blue,
            ),
            SummaryCard(
              title: 'Total Sales',
              value: '₹45k',
              icon: Icons.currency_rupee,
              color: Colors.green,
            ),
            SummaryCard(
              title: 'Active Parties',
              value: '25',
              icon: Icons.people,
              color: Colors.orange,
            ),
            SummaryCard(
              title: 'Total Products',
              value: '80',
              icon: Icons.inventory,
              color: Colors.purple,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to Create Order
        },
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
      ),
    );
  }
}
