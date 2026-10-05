import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import 'skeleton_loader.dart';

// Doctor Card Skeleton
class DoctorCardSkeleton extends StatelessWidget {
  const DoctorCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonLoader(width: 60, height: 60, borderRadius: 12),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonLoader(width: double.infinity, height: 16, borderRadius: 8),
                    const SizedBox(height: 8),
                    SkeletonLoader(width: MediaQuery.of(context).size.width * 0.4, height: 12, borderRadius: 6),
                    const SizedBox(height: 8),
                    SkeletonLoader(width: MediaQuery.of(context).size.width * 0.3, height: 12, borderRadius: 6),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: SkeletonLoader(width: double.infinity, height: 40, borderRadius: 8)),
              const SizedBox(width: 12),
              Expanded(child: SkeletonLoader(width: double.infinity, height: 40, borderRadius: 8)),
            ],
          ),
        ],
      ),
    );
  }
}

// Appointment Card Skeleton
class AppointmentCardSkeleton extends StatelessWidget {
  const AppointmentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonLoader(width: 50, height: 50, borderRadius: 25),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonLoader(width: double.infinity, height: 14, borderRadius: 7),
                    const SizedBox(height: 8),
                    SkeletonLoader(width: MediaQuery.of(context).size.width * 0.5, height: 12, borderRadius: 6),
                  ],
                ),
              ),
              const SkeletonLoader(width: 60, height: 24, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(width: MediaQuery.of(context).size.width * 0.3, height: 12, borderRadius: 6),
              SkeletonLoader(width: MediaQuery.of(context).size.width * 0.25, height: 12, borderRadius: 6),
            ],
          ),
        ],
      ),
    );
  }
}

// Stats Card Skeleton
class StatsCardSkeleton extends StatelessWidget {
  const StatsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SkeletonLoader(width: 32, height: 32, borderRadius: 16),
          const SizedBox(height: 12),
          const SkeletonLoader(width: 60, height: 24, borderRadius: 12),
          const SizedBox(height: 4),
          SkeletonLoader(width: MediaQuery.of(context).size.width * 0.15, height: 12, borderRadius: 6),
        ],
      ),
    );
  }
}

// Generic List Skeleton
class ListSkeleton extends StatelessWidget {
  final Widget itemSkeleton;
  final int itemCount;

  const ListSkeleton({
    super.key,
    required this.itemSkeleton,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) => itemSkeleton,
    );
  }
}
