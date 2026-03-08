import 'package:flutter/material.dart';

import 'package:lunch_roulette_app/app/theme.dart';
import 'package:lunch_roulette_app/models/restaurant.dart';

class ResultCard extends StatelessWidget {
  final Restaurant restaurant;

  const ResultCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: accentGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withValues(alpha:0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              size: 32,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              '오늘의 점심은',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha:0.85),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              restaurant.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              restaurant.categoryName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha:0.85),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              restaurant.roadAddressName.isNotEmpty
                  ? restaurant.roadAddressName
                  : restaurant.addressName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha:0.75),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatDistance(restaurant.distance),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDistance(int meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
    return '${meters}m';
  }
}
