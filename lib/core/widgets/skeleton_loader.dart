import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white, // Shimmer needs a solid color to draw over
          shape: shape,
          borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double height;
  
  const SkeletonCard({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SkeletonLoader(width: 120, height: 24, borderRadius: 12),
              const SizedBox(height: 16),
              const SkeletonLoader(width: double.infinity, height: 16, borderRadius: 8),
              const SizedBox(height: 8),
              const SkeletonLoader(width: 200, height: 16, borderRadius: 8),
              if (height > 100) ...[
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerRight,
                  child: SkeletonLoader(width: 48, height: 48, shape: BoxShape.circle),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
