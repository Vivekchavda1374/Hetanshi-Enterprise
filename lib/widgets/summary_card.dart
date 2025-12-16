import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color; // Kept for backwards compatibility but we override it generally

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Premium FMCG Style: White cards, Teal numbers, Gold accents
    const tealColor = Color(0xFF1FA2A6);
    const goldColor = Color(0xFFD4AF37);

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: goldColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: goldColor, size: 20),
                ),
                // Decorative dot or mini indicator could go here
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: tealColor,
                    fontSize: 28,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280), // Text Secondary
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
