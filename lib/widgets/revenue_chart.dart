import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RevenueChart extends StatelessWidget {
  const RevenueChart({super.key});

  @override
  Widget build(BuildContext context) {
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
            mainData(),
          ),
        ),
      ),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.shade100,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey.shade100,
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
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(2.6, 2),
            FlSpot(4.9, 5),
            FlSpot(6.8, 3.1),
            FlSpot(8, 4),
            FlSpot(9.5, 3),
            FlSpot(11, 4),
          ],
          isCurved: true,
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1FA2A6), // Deep Teal
              Color(0xFFD4AF37), // Gold
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1FA2A6).withOpacity(0.1),
                const Color(0xFFD4AF37).withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 12,
      color: Colors.grey[400],
    );
    Widget text;
    switch (value.toInt()) {
      case 2:
        text = Text('MAR', style: style);
        break;
      case 5:
        text = Text('JUN', style: style);
        break;
      case 8:
        text = Text('SEP', style: style);
        break;
      default:
        text = Text('', style: style);
        break;
    }

    return text;
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 12,
      color: Colors.grey[400],
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = '10k';
        break;
      case 3:
        text = '30k';
        break;
      case 5:
        text = '50k';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }
}
