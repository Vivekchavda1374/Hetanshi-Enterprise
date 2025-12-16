import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hetanshi_enterprise/models/order_model.dart';
import 'package:hetanshi_enterprise/services/firestore_service.dart';
import 'package:hetanshi_enterprise/widgets/app_drawer.dart';
import 'package:hetanshi_enterprise/widgets/summary_card.dart';
import 'package:hetanshi_enterprise/screens/order/create_order_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder<List<OrderModel>>(
        stream: firestoreService.getOrders(),
        builder: (context, orderSnapshot) {
          final orders = orderSnapshot.data ?? [];
          
          final totalOrders = orders.length;
          final totalRevenue = orders.fold(0.0, (sum, order) => sum + order.totalAmount);
          final recentOrders = orders.take(5).toList();

          return StreamBuilder<int>(
            stream: firestoreService.getPartyCount(),
            builder: (context, partySnapshot) {
              final activeParties = partySnapshot.data ?? 0;

              return StreamBuilder<int>(
                stream: firestoreService.getProductCount(),
                builder: (context, productSnapshot) {
                  final totalProducts = productSnapshot.data ?? 0;

                  return AnimationLimiter(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 375),
                          childAnimationBuilder: (widget) => SlideAnimation(
                            horizontalOffset: 50.0,
                            child: FadeInAnimation(
                              child: widget,
                            ),
                          ),
                          children: [
                            Text(
                              "Overview",
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                            ),
                            const SizedBox(height: 16),
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85, 
                              children: [
                                SummaryCard(
                                  title: 'Total Orders',
                                  value: totalOrders.toString(),
                                  icon: Icons.shopping_bag_outlined,
                                  color: const Color(0xFF6C63FF),
                                ),
                                SummaryCard(
                                  title: 'Total Revenue',
                                  value: '₹${NumberFormat.compactCurrency(symbol: '').format(totalRevenue)}',
                                  icon: Icons.currency_rupee,
                                  color: const Color(0xFF2EC4B6),
                                ),
                                SummaryCard(
                                  title: 'Active Parties',
                                  value: activeParties.toString(),
                                  icon: Icons.people_outline,
                                  color: const Color(0xFFFF9F1C),
                                ),
                                SummaryCard(
                                  title: 'Products',
                                  value: totalProducts.toString(),
                                  icon: Icons.inventory_2_outlined,
                                  color: const Color(0xFFFF4081),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Note: RevenueChart integration skipped for brevity, 
                            // assuming it needs complex data formatting. 
                            // Can be added if user specifically requests visual charts.
                            
                            Text(
                              "Recent Activity",
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                            ),
                            const SizedBox(height: 16),
                            if (recentOrders.isEmpty)
                                const Center(child: Text("No recent orders"))
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: recentOrders.length,
                                itemBuilder: (context, index) {
                                  final order = recentOrders[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.deepPurple.shade50,
                                        child: const Icon(Icons.receipt_long, color: Colors.deepPurple),
                                      ),
                                      title: Text('Order #${order.id.substring(0, 4)}...'), // Short ID
                                      subtitle: Text(
                                          '${DateFormat('hh:mm a').format(order.date)} • ₹${order.totalAmount.toStringAsFixed(0)}'),
                                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
               builder: (context) => const CreateOrderScreen(),
            ),
          );
        },
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Quick Order', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
