import 'package:flutter/material.dart';
import 'package:hetanshi_enterprise/models/product_model.dart';
import 'package:hetanshi_enterprise/services/firestore_service.dart';
import 'package:hetanshi_enterprise/screens/product/add_edit_product_screen.dart';
import 'package:hetanshi_enterprise/screens/product/product_detail_screen.dart';
import 'package:hetanshi_enterprise/widgets/app_drawer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:convert';

import 'package:hetanshi_enterprise/utils/app_theme.dart';
import 'package:hetanshi_enterprise/widgets/modern_background.dart';
import 'package:hetanshi_enterprise/services/auth_manager.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Make sure this is imported for styling
import 'package:hetanshi_enterprise/models/product_model.dart';
import 'package:hetanshi_enterprise/services/firestore_service.dart';
import 'package:hetanshi_enterprise/screens/product/add_edit_product_screen.dart';
import 'package:hetanshi_enterprise/screens/product/product_detail_screen.dart';
import 'package:hetanshi_enterprise/widgets/app_drawer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:convert';

import 'package:hetanshi_enterprise/utils/app_theme.dart';
import 'package:hetanshi_enterprise/widgets/modern_background.dart';
import 'package:hetanshi_enterprise/screens/order/create_order_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text('Products'),
      ),
      drawer: const AppDrawer(),
      body: ModernBackground(
        child: StreamBuilder<List<Product>>(
          stream: firestoreService.getProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final allProducts = snapshot.data ?? [];

            // 1. Extract all categories from ALL products (for the filter chips)
            final Set<String> allCategories = {'All'};
            for (var p in allProducts) {
              if (p.category.isNotEmpty) {
                allCategories.add(p.category);
              } else {
                allCategories.add('Uncategorized');
              }
            }
            final sortedAllCategories = allCategories.toList()..sort();

            // 2. Filter products based on search and selected category
            final filteredProducts = allProducts.where((product) {
              final matchesSearch = product.name
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
              // Use default category if empty
              final prodCategory =
                  product.category.isEmpty ? 'Uncategorized' : product.category;
              final matchesCategory = _selectedCategory == 'All' ||
                  prodCategory == _selectedCategory;

              return matchesSearch && matchesCategory;
            }).toList();

            // 3. Group FILTERED products
            Map<String, List<Product>> groupedProducts = {};
            for (var p in filteredProducts) {
              String category =
                  p.category.isEmpty ? 'Uncategorized' : p.category;
              if (!groupedProducts.containsKey(category)) {
                groupedProducts[category] = [];
              }
              groupedProducts[category]!.add(p);
            }

            final sortedCategories = groupedProducts.keys.toList()..sort();

            List<Widget> slivers = [];

            // --- Search and Filter Section (Pinned or BoxAdapter) ---
            slivers.add(
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: const Icon(Icons.search,
                              color: AppColors.textSecondary),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: AppColors.textSecondary),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                                color: AppColors.primaryBlue, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Category Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: sortedAllCategories.map((category) {
                            final isSelected = _selectedCategory == category;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(category),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory =
                                        selected ? category : 'All';
                                  });
                                },
                                selectedColor: AppColors.primaryBlue,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected
                                        ? Colors.transparent
                                        : Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

            if (filteredProducts.isEmpty) {
              slivers.add(
                const SliverFillRemaining(
                  child: Center(
                    child: Text('No products found matching filters'),
                  ),
                ),
              );
            } else {
              for (var category in sortedCategories) {
                // Add Header Sliver
                slivers.add(
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryTeal,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );

                // Add Grid Sliver for this category
                final categoryProducts = groupedProducts[category]!;
                slivers.add(
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = categoryProducts[index];
                          // Just a simple animation wrapper now, simpler logic
                          return AnimationConfiguration.staggeredGrid(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            columnCount: 2,
                            child: ScaleAnimation(
                              child: FadeInAnimation(
                                child: _buildProductCard(context, product),
                              ),
                            ),
                          );
                        },
                        childCount: categoryProducts.length,
                      ),
                    ),
                  ),
                );
              }
            }

            // Add bottom padding
            slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 80)));

            return AnimationLimiter(
              child: CustomScrollView(
                slivers: slivers,
              ),
            );
          },
        ),
      ),
      floatingActionButton: AuthManager.instance.isAdmin
          ? FloatingActionButton(
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
            )
          : null,
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardWhite.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            Expanded(
              child: Hero(
                tag: 'product_image_${product.id}',
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    color: Colors.white,
                    image: product.imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: product.imageUrl.startsWith('http')
                                ? NetworkImage(product.imageUrl)
                                : MemoryImage(base64Decode(product.imageUrl))
                                    as ImageProvider,
                            fit: BoxFit.contain,
                          )
                        : null,
                  ),
                  child: product.imageUrl.isEmpty
                      ? const Center(
                          child: Icon(Icons.inventory_2_outlined,
                              size: 40, color: AppColors.textDisabled))
                      : null,
                ),
              ),
            ),

            // Info Section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'MRP: ₹${product.mrp}',
                    style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${product.salesRate.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      // Stock Display
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: product.stock > 0
                              ? AppColors.successGreen.withOpacity(0.1)
                              : AppColors.errorRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.stock > 0
                              ? 'Stock: ${product.stock}'
                              : 'Out of Stock',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: product.stock > 0
                                ? AppColors.successGreen
                                : AppColors.errorRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Order Button
                  if (AuthManager.instance.isUser)
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: product.stock > 0
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateOrderScreen(
                                      initialProduct: product,
                                    ),
                                  ),
                                );
                              }
                            : null, // Disable if out of stock
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryTeal,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: const Text('Order'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
