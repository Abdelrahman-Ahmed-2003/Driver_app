// =================================== Shimmer Card ===================================
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerTripCard extends StatelessWidget {
  const ShimmerTripCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: colorScheme.surfaceVariant,
          highlightColor: colorScheme.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 100,
                height: 15,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}