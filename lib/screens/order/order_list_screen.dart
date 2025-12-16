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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Party Name ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      '₹${(index + 1) * 500}',
                      style: const TextStyle(color: Color(0xFF1FA2A6), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text('16/12/2025', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      const Spacer(),
                      itemStatus(isCompleted),
                    ],
                  ),
                ),
                onTap: () {},
              ),
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

  Widget itemStatus(bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFF22C55E).withOpacity(0.1) : const Color(0xFFD4AF37).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isCompleted ? 'Completed' : 'Pending',
        style: TextStyle(
          color: isCompleted ? const Color(0xFF22C55E) : const Color(0xFFD4AF37),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
