import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hetanshi_enterprise/models/order_model.dart';
import 'package:hetanshi_enterprise/services/firestore_service.dart';
import 'package:hetanshi_enterprise/screens/order/create_order_screen.dart';
import 'package:hetanshi_enterprise/widgets/app_drawer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  Future<void> _shareOnWhatsApp(OrderModel order) async {
    // Construct the message
    StringBuffer message = StringBuffer();
    message.writeln('*Order Details - Hetanshi Enterprise*');
    message.writeln('Values marked with * are estimates.');
    message.writeln('--------------------------------');
    message.writeln('Party: *${order.partyName}*');
    message.writeln('Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(order.date)}');
    message.writeln('--------------------------------');
    message.writeln('Items:');
    
    for (var item in order.items) {
      message.writeln('${item.productName} x ${item.quantity} = ₹${item.amount}');
    }
    
    message.writeln('--------------------------------');
    message.writeln('*Total Amount: ₹${order.totalAmount}*');
    message.writeln('--------------------------------');
    message.writeln('Thank you for your business!');

    final url = "https://wa.me/?text=${Uri.encodeComponent(message.toString())}";
    
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder<List<OrderModel>>(
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
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF1FA2A6).withOpacity(0.1),
                            child: const Icon(Icons.receipt_long, color: Color(0xFF1FA2A6)),
                          ),
                          title: Text(order.partyName,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(DateFormat('dd MMM, hh:mm a').format(order.date)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('₹${order.totalAmount.toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.share, color: Colors.green),
                                        onPressed: () => _shareOnWhatsApp(order),
                                      ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: order.items.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${item.productName} (${item.quantity} x ${item.rate})',
                                            style: const TextStyle(fontSize: 14)),
                                        Text('₹${item.amount}',
                                            style: const TextStyle(fontWeight: FontWeight.w500)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateOrderScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
