import 'package:flutter/material.dart';
import 'package:hetanshi_enterprise/widgets/app_drawer.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: 8,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final isCompleted = index % 3 != 0;
          return Card(
            child: ListTile(
              leading: Icon(
                Icons.shopping_bag,
                color: isCompleted ? Colors.green : Colors.orange,
              ),
              title: Text('Order #${1000 + index}'),
              subtitle: Text('Party Name ${index + 1}\n₹${(index + 1) * 500}'),
              isThreeLine: true,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    isCompleted ? 'Completed' : 'Pending',
                    style: TextStyle(
                      color: isCompleted ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('16/12/2025', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
              onTap: () {
                // TODO: View Order Details
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Create Order
        },
        child: const Icon(Icons.add_shopping_cart),
      ),
    );
  }
}
