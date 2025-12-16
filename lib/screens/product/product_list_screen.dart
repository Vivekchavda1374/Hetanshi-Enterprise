import 'package:flutter/material.dart';
import 'package:hetanshi_enterprise/widgets/app_drawer.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: 10,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: ListTile(
                title: Text(
                  'Product Item ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Row(
                  children: [
                    Text('MRP: ₹${(index + 1) * 120}', style: TextStyle(color: Colors.grey[500], decoration: TextDecoration.lineThrough)),
                    const SizedBox(width: 10),
                    Text(
                      'Rate: ₹${(index + 1) * 100}',
                      style: const TextStyle(color: Color(0xFF1FA2A6), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF6B7280)),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFDC2626)),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add Product
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
