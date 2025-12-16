import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hetanshi_enterprise/models/product_model.dart';
import 'package:hetanshi_enterprise/utils/app_theme.dart';
import 'package:hetanshi_enterprise/utils/toast_utils.dart';
import 'package:hetanshi_enterprise/services/firestore_service.dart';
import 'package:hetanshi_enterprise/screens/product/add_edit_product_screen.dart';
import 'package:hetanshi_enterprise/widgets/modern_background.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
               Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditProductScreen(product: product),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.errorRed),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Product'),
                  content: const Text('Are you sure you want to delete this product?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete', style: TextStyle(color: AppColors.errorRed))),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  await firestoreService.deleteProduct(product.id);
                  if (context.mounted) {
                     ToastUtils.showSuccess(context, 'Product deleted');
                     Navigator.pop(context); // Close detail screen
                  }
                } catch (e) {
                  if (context.mounted) {
                     ToastUtils.showError(context, 'Error deleting: $e');
                  }
                }
              }
            },
          ),
        ],
      ),
      body: ModernBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Center(
                child: Hero(
                  tag: 'product_image_${product.id}',
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      image: product.imageUrl.isNotEmpty
                          ? DecorationImage(
                              image: product.imageUrl.startsWith('http')
                                  ? NetworkImage(product.imageUrl)
                                  : MemoryImage(base64Decode(product.imageUrl)) as ImageProvider,
                              fit: BoxFit.contain,
                            )
                          : null,
                    ),
                    child: product.imageUrl.isEmpty
                        ? const Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.textDisabled)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Product Name and Category
              Text(
                product.name,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
                ),
                child: Text(
                  product.category.isEmpty ? 'Uncategorized' : product.category,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Price Details Card
              Card(
                elevation: 2,
                color: Colors.white.withOpacity(0.9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPriceItem(
                        context,
                        "MRP",
                        product.mrp,
                        AppColors.textSecondary,
                      ),
                      Container(height: 40, width: 1, color: Colors.grey[300]),
                      _buildPriceItem(
                        context,
                        "Sales Rate",
                        product.salesRate,
                        AppColors.successGreen,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Description
              Text(
                "Description",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  product.description.isEmpty ? "No description available." : product.description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceItem(BuildContext context, String label, double amount, Color color, {bool isBold = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
