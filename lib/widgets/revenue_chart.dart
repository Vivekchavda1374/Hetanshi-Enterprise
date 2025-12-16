import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hetanshi_enterprise/models/order_model.dart';
import 'package:intl/intl.dart';

class RevenueChart extends StatelessWidget {
  final List<OrderModel> orders;

  const RevenueChart({super.key, required this.orders});

  List<FlSpot> _getSpots() {
    // 1. Get last 7 days
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));
    
    // 2. Initialize map with 0.0 for all days
    Map<int, double> dailyRevenue = {};
    for (int i = 0; i < 7; i++) {
      dailyRevenue[i] = 0.0;
    }

    // 3. Aggregate revenue
    for (var order in orders) {
      if (order.date.isAfter(sevenDaysAgo)) { // Only consider recent orders
         // Calculate difference in days from 6 days ago (start of chart) to normalize x-axis to 0-6
         // logic: 
         // day 0 = 6 days ago
         // day 6 = today
         
         // Let's simplify: compare date day to today. 
         // Actually, simpler approach:
         // For each of the last 7 days, sum up orders.
      }
    }
    
    List<FlSpot> spots = [];
    
    for (int i = 0; i < 7; i++) {
        final dateOfInterest = sevenDaysAgo.add(Duration(days: i));
        // Find orders on this day (ignoring time)
        double sum = 0;
        for(var order in orders) {
             if (order.date.year == dateOfInterest.year && 
                 order.date.month == dateOfInterest.month && 
                 order.date.day == dateOfInterest.day) {
                 sum += order.totalAmount;
             }
        }
        spots.add(FlSpot(i.toDouble(), sum));
    }

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    // Colors
    const Color primaryColor = Color(0xFF1FA2A6);
    const Color secondaryColor = Color(0xFF6C63FF);

    final spots = _getSpots();
    // Calculate max Y for scaling
    double maxY = 0;
    for (var spot in spots) {
        if (spot.y > maxY) maxY = spot.y;
    }
    // Add some buffer
    maxY = maxY * 1.2; 
    if (maxY == 0) maxY = 1000;

    return AspectRatio(
      aspectRatio: 1.70,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(18),
          ),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            right: 18,
            left: 12,
            top: 24,
            bottom: 12,
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= 7) return const Text('');
                        
                        final now = DateTime.now();
                        final date = now.subtract(Duration(days: 6 - index));
                        
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                             DateFormat('E').format(date)[0], // M, T, W...
                             style: const TextStyle(
                               color: Color(0xff68737d),
                               fontWeight: FontWeight.bold,
                               fontSize: 12,
                             ),
                          ),
                        );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: maxY / 5,
                    getTitlesWidget: (value, meta) {
                       return Text(
                         _formatCurrency(value),
                         style: const TextStyle(
                           color: Color(0xff67727d),
                           fontWeight: FontWeight.bold,
                           fontSize: 10,
                         ),
                       );
                    },
                    reservedSize: 42,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d).withOpacity(0.1)),
              ),
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  gradient: const LinearGradient(
                    colors: [secondaryColor, primaryColor],
                  ),
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(
                    show: false,
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        secondaryColor.withOpacity(0.3),
                        primaryColor.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _formatCurrency(double value) {
      if (value >= 1000) {
          return '${(value / 1000).toStringAsFixed(1)}k';
      }
      return value.toInt().toString();
  }
}
