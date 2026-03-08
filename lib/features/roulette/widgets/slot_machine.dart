import 'package:flutter/material.dart';

import 'package:lunch_roulette_app/models/restaurant.dart';

class SlotMachine extends StatelessWidget {
  final List<Restaurant> restaurants;
  final FixedExtentScrollController controller;

  const SlotMachine({
    super.key,
    required this.restaurants,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          SizedBox(
            height: 280,
            child: ListWheelScrollView.useDelegate(
              controller: controller,
              itemExtent: 64,
              perspective: 0.003,
              diameterRatio: 2.5,
              physics: const FixedExtentScrollPhysics(),
              childDelegate: ListWheelChildLoopingListDelegate(
                children: restaurants.map((r) => _SlotItem(restaurant: r)).toList(),
              ),
            ),
          ),
          // Center highlight bar
          Positioned(
            top: 280 / 2 - 32,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  color: theme.colorScheme.primary.withValues(alpha: 0.06),
                ),
              ),
            ),
          ),
          // Top gradient fade
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 80,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Color(0x00FFFFFF)],
                  ),
                ),
              ),
            ),
          ),
          // Bottom gradient fade
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 80,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.white, Color(0x00FFFFFF)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotItem extends StatelessWidget {
  final Restaurant restaurant;

  const _SlotItem({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              restaurant.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _categoryShort(restaurant.categoryName),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${restaurant.distance}m',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _categoryShort(String categoryName) {
    final parts = categoryName.split(' > ');
    return parts.length > 1 ? parts[1] : parts[0];
  }
}
