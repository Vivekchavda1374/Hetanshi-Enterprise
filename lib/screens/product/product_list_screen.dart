import 'package:flutter/material.dart';
import 'package:hetanshi_enterprise/models/product_model.dart';
import 'package:hetanshi_enterprise/services/firestore_service.dart';
import 'package:hetanshi_enterprise/screens/product/add_edit_product_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:convert';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<Product>>(
        stream: firestoreService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              image: product.imageUrl.isNotEmpty
                                  ? DecorationImage(
                                      image: product.imageUrl.startsWith('http')
                                          ? NetworkImage(product.imageUrl)
                                          : MemoryImage(base64Decode(product.imageUrl)) as ImageProvider,
                                      fit: BoxFit.cover)
                                  : null,
                            ),
                            child: product.imageUrl.isEmpty
                                ? const Icon(Icons.inventory_2_outlined,
                                    color: Colors.grey)
                                : null,
                          ),
                          title: Text(product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('MRP: ₹${product.mrp} | Rate: ₹${product.salesRate}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddEditProductScreen(product: product),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Product'),
                                      content: const Text(
                                          'Are you sure you want to delete this product?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel')),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Delete',
                                                style: TextStyle(
                                                    color: Colors.red))),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await firestoreService
                                        .deleteProduct(product.id);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditProductScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
