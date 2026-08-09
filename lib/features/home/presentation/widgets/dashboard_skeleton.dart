import 'package:flutter/material.dart';

import '../../../../core/widgets/shimmer_box.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 48, height: 48, borderRadius: 16),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(width: 90, height: 12),
                    SizedBox(height: 8),
                    ShimmerBox(width: 140, height: 16),
                  ],
                ),
              ),
              const ShimmerBox(width: 44, height: 44, borderRadius: 14),
            ],
          ),
          const SizedBox(height: 24),
          ShimmerBox(width: double.infinity, height: 190, borderRadius: 28),
          const SizedBox(height: 20),
          ShimmerBox(width: double.infinity, height: 96, borderRadius: 24),
          const SizedBox(height: 28),
          const ShimmerBox(width: 160, height: 16),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(child: ShimmerBox(height: 100, borderRadius: 20)),
              SizedBox(width: 12),
              Expanded(child: ShimmerBox(height: 100, borderRadius: 20)),
            ],
          ),
          const SizedBox(height: 28),
          const ShimmerBox(width: 180, height: 16),
          const SizedBox(height: 14),
          for (var i = 0; i < 3; i++) ...[
            ShimmerBox(width: double.infinity, height: 70, borderRadius: 18),
            if (i != 2) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
