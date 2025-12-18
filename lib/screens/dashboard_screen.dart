import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hetanshi_enterprise/models/order_model.dart';
import 'package:hetanshi_enterprise/services/firestore_service.dart';
import 'package:hetanshi_enterprise/services/notification_service.dart';
import 'package:hetanshi_enterprise/widgets/app_drawer.dart';
import 'package:hetanshi_enterprise/widgets/summary_card.dart';
import 'package:hetanshi_enterprise/widgets/revenue_chart.dart';
import 'package:hetanshi_enterprise/screens/expense/expense_list_screen.dart';
import 'package:hetanshi_enterprise/screens/order/create_order_screen.dart';
import 'package:hetanshi_enterprise/screens/notification_list_screen.dart';
import 'package:hetanshi_enterprise/services/auth_manager.dart';
import 'package:intl/intl.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:hetanshi_enterprise/widgets/modern_background.dart';
import 'package:hetanshi_enterprise/utils/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize Notification Service when Dashboard loads
    NotificationService().initialize(context);
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    // Check Auth Status
    final isAdmin = AuthManager.instance.isAdmin;

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      drawer: const AppDrawer(),
      body: ModernBackground(
        // Apply modern background
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Custom Curved Header
              _buildHeader(context),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: StreamBuilder<List<OrderModel>>(
                  stream: firestoreService.getOrders(
                    userId: AuthManager.instance.isUser
                        ? AuthManager.instance.currentUser!.id
                        : null,
                  ),
                  builder: (context, orderSnapshot) {
                    final orders = orderSnapshot.data ?? [];

                    final totalOrders = orders.length;
                    final totalRevenue = orders.fold(
                        0.0, (sum, order) => sum + order.totalAmount);
                    final recentOrders = orders.take(5).toList();

                    return StreamBuilder<int>(
                      stream: firestoreService.getPartyCount(),
                      builder: (context, partySnapshot) {
                        final activeParties = partySnapshot.data ?? 0;

                        return StreamBuilder<int>(
                          stream: firestoreService.getProductCount(),
                          builder: (context, productSnapshot) {
                            final totalProducts = productSnapshot.data ?? 0;

                            return StreamBuilder<double>(
                              stream: firestoreService.getTotalExpenses(),
                              builder: (context, expenseSnapshot) {
                                final totalExpenses =
                                    expenseSnapshot.data ?? 0.0;
                                final netProfit = totalRevenue - totalExpenses;

                                return AnimationLimiter(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children:
                                        AnimationConfiguration.toStaggeredList(
                                      duration:
                                          const Duration(milliseconds: 375),
                                      childAnimationBuilder: (widget) =>
                                          SlideAnimation(
                                        verticalOffset: 50.0,
                                        child: FadeInAnimation(
                                          child: widget,
                                        ),
                                      ),
                                      children: [
                                        GridView.count(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                          childAspectRatio: 1.1,
                                          children: [
                                            // 1. Net Profit (Admin Only)
                                            if (isAdmin)
                                              SummaryCard(
                                                title: 'Net Profit',
                                                value:
                                                    '₹${NumberFormat.compactCurrency(symbol: '').format(netProfit)}',
                                                icon: Icons.monetization_on,
                                                color: netProfit >= 0
                                                    ? AppColors.successGreen
                                                    : AppColors.dangerRed,
                                              ),
                                            // 2. Revenue (Admin Only)
                                            if (isAdmin)
                                              SummaryCard(
                                                title: 'Revenue',
                                                value:
                                                    '₹${NumberFormat.compactCurrency(symbol: '').format(totalRevenue)}',
                                                icon: Icons.currency_rupee,
                                                color: AppColors.primaryBlue,
                                              ),
                                            // 3. Expenses (Admin Only)
                                            if (isAdmin)
                                              InkWell(
                                                onTap: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            const ExpenseListScreen())),
                                                child: SummaryCard(
                                                  title: 'Expenses',
                                                  value:
                                                      '₹${NumberFormat.compactCurrency(symbol: '').format(totalExpenses)}',
                                                  icon: Icons.money_off,
                                                  color: AppColors.dangerRed,
                                                ),
                                              ),
                                            // 4. Orders (Visible to All)
                                            if (isAdmin ||
                                                AuthManager.instance.isUser)
                                              SummaryCard(
                                                title: 'Orders',
                                                value: totalOrders.toString(),
                                                icon:
                                                    Icons.shopping_bag_outlined,
                                                color: AppColors.secondaryTeal,
                                              ),
                                            // Show Products count instead of Profits/Revenue for Guests if needed to fill grid,
                                            // OR just let the grid readjust.
                                            // For Guest, let's show Products and Parties in the grid if Admin items are hidden,
                                            // to avoid an empty looking dashboard.
                                            if (!isAdmin &&
                                                !AuthManager
                                                    .instance.isUser) ...[
                                              SummaryCard(
                                                title: 'Products',
                                                value: totalProducts.toString(),
                                                icon:
                                                    Icons.inventory_2_outlined,
                                                color: AppColors.warningOrange,
                                              ),
                                              SummaryCard(
                                                title: 'Parties',
                                                value: activeParties.toString(),
                                                icon: Icons.people_outline,
                                                color: AppColors.infoSkyBlue,
                                              ),
                                            ]
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        // Row for Product/Party counts (Admin: Secondary Info, Guest: Already in Grid)
                                        if (isAdmin)
                                          SizedBox(
                                            height: 160,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: SummaryCard(
                                                    title: 'Parties',
                                                    value: activeParties
                                                        .toString(),
                                                    icon: Icons.people_outline,
                                                    color:
                                                        AppColors.infoSkyBlue,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: SummaryCard(
                                                    title: 'Products',
                                                    value: totalProducts
                                                        .toString(),
                                                    icon: Icons
                                                        .inventory_2_outlined,
                                                    color:
                                                        AppColors.warningOrange,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        // Revenue Trends (Admin Only)
                                        if (isAdmin) ...[
                                          const SizedBox(height: 24),
                                          Text(
                                            "Revenue Trends",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 16),
                                          RevenueChart(orders: orders),
                                        ],

                                        if (isAdmin ||
                                            AuthManager.instance.isUser) ...[
                                          const SizedBox(height: 24),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Recent Activity",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator
                                                    .pushReplacementNamed(
                                                        context, '/orders'),
                                                child: const Text('View All',
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .primaryBlue)),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          if (recentOrders.isEmpty)
                                            const Center(
                                                child: Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: Text("No recent orders"),
                                            ))
                                          else
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: recentOrders.length,
                                              itemBuilder: (context, index) {
                                                final order =
                                                    recentOrders[index];
                                                return Card(
                                                  margin: const EdgeInsets.only(
                                                      bottom: 12),
                                                  elevation: 1,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: ListTile(
                                                    leading: CircleAvatar(
                                                      backgroundColor: AppColors
                                                          .secondaryTeal
                                                          .withOpacity(0.1),
                                                      child: const Icon(
                                                          Icons.receipt_long,
                                                          color: AppColors
                                                              .secondaryTeal),
                                                    ),
                                                    title: Text(order.partyName,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    subtitle: Text(
                                                        '${DateFormat('dd MMM, hh:mm a').format(order.date)}',
                                                        style: const TextStyle(
                                                            color: AppColors
                                                                .textSecondary)),
                                                  ),
                                                );
                                              },
                                            ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Hide Quick Order FAB for Guests (and show for Admin/User)
      floatingActionButton: (isAdmin || AuthManager.instance.isUser)
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateOrderScreen(),
                  ),
                );
              },
              backgroundColor: AppColors.secondaryTeal,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Quick Order',
                  style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20,
          30), // Top padding adjusted for custom SafeArea manual handling if needed, but here we are in body
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
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationListScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.backgroundGrey,
                  child: Icon(Icons.person,
                      color: AppColors.primaryBlue, size: 30),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Back,",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    "Hetanshi Enterprise",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
