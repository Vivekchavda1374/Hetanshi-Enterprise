import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hetanshi_enterprise/widgets/app_drawer.dart';
import 'package:hetanshi_enterprise/widgets/summary_card.dart';
import 'package:hetanshi_enterprise/widgets/revenue_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: AnimationLimiter(
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
                  children: const [
                    SummaryCard(
                      title: 'Total Orders',
                      value: '120',
                      icon: Icons.shopping_bag_outlined,
                      color: Color(0xFF6C63FF),
                    ),
                    SummaryCard(
                      title: 'Total Revenue',
                      value: '₹45k',
                      icon: Icons.currency_rupee,
                      color: Color(0xFF2EC4B6),
                    ),
                    SummaryCard(
                      title: 'Active Parties',
                      value: '25',
                      icon: Icons.people_outline,
                      color: Color(0xFFFF9F1C),
                    ),
                    SummaryCard(
                      title: 'Products',
                      value: '80',
                      icon: Icons.inventory_2_outlined,
                      color: Color(0xFFFF4081),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  "Revenue Analytics",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                ),
                const SizedBox(height: 16),
                const RevenueChart(),
                const SizedBox(height: 24),
                Text(
                  "Recent Activity",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (context, index) {
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
                        title: Text('Order #${1234 + index}'),
                        subtitle: Text('2 mins ago • ₹${(index + 1) * 150}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: New transaction
        },
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Quick Order', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
