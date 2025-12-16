import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hetanshi_enterprise/models/order_model.dart';
import 'package:hetanshi_enterprise/services/firestore_service.dart';
import 'package:hetanshi_enterprise/widgets/app_drawer.dart';
import 'package:intl/intl.dart';
import 'package:hetanshi_enterprise/utils/app_theme.dart';
import 'package:hetanshi_enterprise/widgets/modern_background.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      drawer: const AppDrawer(),
      body: ModernBackground(
        child: StreamBuilder<List<OrderModel>>(
          stream: firestoreService.getOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final orders = snapshot.data ?? [];

            if (orders.isEmpty) {
              return const Center(child: Text('No history found'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  color: AppColors.cardWhite.withOpacity(0.9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.textDisabled.withOpacity(0.1),
                      child: const Icon(Icons.history, color: AppColors.textDisabled),
                    ),
                    title: Text(order.partyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(order.date), style: const TextStyle(color: AppColors.textSecondary)),
                    trailing: Text(
                      '₹${order.totalAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.secondaryTeal,
                      ),
                    ),
                    onTap: () {
                      // Show details dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Order Details', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Party: ${order.partyName}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text('Date: ${DateFormat('dd MMM yyyy').format(order.date)}', style: const TextStyle(color: AppColors.textSecondary)),
                                const Divider(),
                                const SizedBox(height: 8),
                                const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Flexible(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: order.items.length,
                                    itemBuilder: (context, i) {
                                      final item = order.items[i];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('${item.productName} (x${item.quantity})'),
                                            Text('₹${item.amount}'),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text('₹${order.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryBlue)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
