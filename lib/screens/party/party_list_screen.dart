import 'package:flutter/material.dart';
import 'package:hetanshi_enterprise/widgets/app_drawer.dart';

class PartyListScreen extends StatelessWidget {
  const PartyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parties'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: 8,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text('Party Name ${index + 1}'),
              subtitle: Text('+91 987654321$index'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: View Party Details
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add Party
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
