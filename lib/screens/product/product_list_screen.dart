import 'package:flutter/material.dart';
import 'package:hetanshi_enterprise/models/product_model.dart';
import 'package:hetanshi_enterprise/services/firestore_service.dart';
import 'package:hetanshi_enterprise/screens/product/add_edit_product_screen.dart';
import 'package:hetanshi_enterprise/widgets/app_drawer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:convert';

import 'package:hetanshi_enterprise/utils/app_theme.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
         // AppTheme sets the default AppBar style (Blue bg, White text)
         // But here we were using transparent. Let's stick to standard opaque AppBar for consistency
         // per user request "AppBar Background: Blue (#2563EB)".
         // So standard AppBar is better.
        title: const Text('Products'),
      ),
      drawer: const AppDrawer(),
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

          // Group products by category
          Map<String, List<Product>> groupedProducts = {};
          for (var p in products) {
            String category = p.category.isEmpty ? 'Uncategorized' : p.category;
            if (!groupedProducts.containsKey(category)) {
              groupedProducts[category] = [];
            }
            groupedProducts[category]!.add(p);
          }

          // Sort categories
          final sortedCategories = groupedProducts.keys.toList()..sort();

          // Create flat list for ListView
          List<dynamic> flatList = [];
          for (var category in sortedCategories) {
            flatList.add(category); // Header
            flatList.addAll(groupedProducts[category]!); // Products
          }

          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: flatList.length,
              itemBuilder: (context, index) {
                final item = flatList[index];

                if (item is String) {
                  // Category Header
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  );
                } else if (item is Product) {
                  // Product Card
                  final product = item;
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundGrey,
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
                                      color: AppColors.textDisabled)
                                  : null,
                            ),
                            title: Text(product.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  product.description, 
                                  maxLines: 1, 
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.successGreen.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'MRP: ₹${product.mrp}',
                                        style: const TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('Rate: ₹${product.salesRate}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddEditProductScreen(product: product),
                                    ),
                                  );
                                } else if (value == 'delete') {
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
                                                    color: AppColors.errorRed))),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await firestoreService
                                        .deleteProduct(product.id);
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(children: [Icon(Icons.edit, size: 20, color: AppColors.primaryBlue), SizedBox(width: 8), Text('Edit')]),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(children: [Icon(Icons.delete, size: 20, color: AppColors.errorRed), SizedBox(width: 8), Text('Delete')]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
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
        backgroundColor: AppColors.secondaryTeal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
