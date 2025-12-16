import 'package:flutter/material.dart';
import 'package:hetanshi_enterprise/utils/app_theme.dart';

class ModernBackground extends StatelessWidget {
  final Widget child;

  const ModernBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Gradient Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE0F2FE), // Very light sky blue
                Color(0xFFF8FAFC), // White/Grey
              ],
              stops: [0.0, 0.3],
            ),
          ),
        ),
        
        // Decorative Shape 1 (Top Left Blob)
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Decorative Shape 2 (Center Right Blob)
        Positioned(
          top: 200,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.secondaryTeal.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Main Content
        SafeArea(child: child),
      ],
    );
  }
}
