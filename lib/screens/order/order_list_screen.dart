import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hetanshi_enterprise/models/order_model.dart';
import 'package:hetanshi_enterprise/services/firestore_service.dart';
import 'package:hetanshi_enterprise/screens/order/create_order_screen.dart';
import 'package:hetanshi_enterprise/widgets/app_drawer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:hetanshi_enterprise/utils/app_theme.dart';
import 'package:hetanshi_enterprise/widgets/modern_background.dart';
import 'package:hetanshi_enterprise/services/auth_manager.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  Future<void> _confirmDeleteOrder(BuildContext context, String orderId) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: const Text(
            'Are you sure you want to delete this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              try {
                await FirestoreService().deleteOrder(orderId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting order: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _shareOnWhatsApp(OrderModel order) async {
    // Construct the message
    StringBuffer message = StringBuffer();
    message.writeln('*Order Details - Hetanshi Enterprise*');
    message.writeln('Values marked with * are estimates.');
    message.writeln('--------------------------------');
    message.writeln('Party: *${order.partyName}*');
    message.writeln(
        'Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(order.date)}');
    message.writeln('--------------------------------');
    message.writeln('Items:');

    for (var item in order.items) {
      message
          .writeln('${item.productName} x ${item.quantity} = ₹${item.amount}');
    }

    message.writeln('--------------------------------');
    message.writeln('*Total Amount: ₹${order.totalAmount}*');
    message.writeln('--------------------------------');
    message.writeln('Thank you for your business!');

    final url =
        "https://wa.me/?text=${Uri.encodeComponent(message.toString())}";

    try {
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Could not launch WhatsApp");
      }
    } catch (e) {
      debugPrint("Error launching WhatsApp: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      drawer: const AppDrawer(),
      body: ModernBackground(
        child: Column(
          children: [
            // Custom Header matching Dashboard
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                          ),
                        ),
                        // You can add search or filter icons here if needed
                        const SizedBox(width: 48), // Balancing space
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shopping_bag_outlined,
                              color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          "Orders",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: StreamBuilder<List<OrderModel>>(
                stream: firestoreService.getOrders(
                  userId: AuthManager.instance.isUser
                      ? AuthManager.instance.currentUser!.id
                      : null,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final orders = snapshot.data ?? [];

                  if (orders.isEmpty) {
                    return const Center(child: Text('No orders found'));
                  }

                  return AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 1,
                                color: AppColors.cardWhite.withOpacity(0.9),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: ExpansionTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.secondaryTeal
                                        .withOpacity(0.1),
                                    child: const Icon(Icons.receipt_long,
                                        color: AppColors.secondaryTeal),
                                  ),
                                  title: Text(order.partyName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                      DateFormat('dd MMM, hh:mm a')
                                          .format(order.date),
                                      style: const TextStyle(
                                          color: AppColors.textSecondary)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                          '₹${order.totalAmount.toStringAsFixed(0)}',
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: AppColors.textPrimary)),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.share,
                                            color: AppColors.successGreen),
                                        onPressed: () =>
                                            _shareOnWhatsApp(order),
                                      ),
                                      if (AuthManager.instance.isAdmin)
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () => _confirmDeleteOrder(
                                              context, order.id),
                                        ),
                                    ],
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: order.items.map((item) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    '${item.productName} (${item.quantity} x ${item.rate})',
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: AppColors
                                                            .textSecondary)),
                                                Text('₹${item.amount}',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColors
                                                            .textPrimary)),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
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
            ),
          ],
        ),
      ),
      floatingActionButton:
          (AuthManager.instance.isAdmin || AuthManager.instance.isUser)
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateOrderScreen(),
                      ),
                    );
                  },
                  backgroundColor: AppColors.secondaryTeal,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
    );
  }
}
