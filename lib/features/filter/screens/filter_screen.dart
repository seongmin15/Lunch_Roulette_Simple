import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lunch_roulette_app/app/theme.dart';
import 'package:lunch_roulette_app/features/filter/providers/filter_provider.dart';
import 'package:lunch_roulette_app/features/filter/providers/filter_state.dart';
import 'package:lunch_roulette_app/features/home/providers/place_type_provider.dart';

class FilterScreen extends ConsumerWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);
    final placeType = ref.watch(placeTypeProvider);
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(gradient: appGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('필터 설정'),
          actions: [
            TextButton(
              onPressed: filter.isDefault
                  ? null
                  : () => ref.read(filterProvider.notifier).reset(),
              child: const Text('초기화'),
            ),
          ],
        ),
        body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('검색 반경', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _DistanceSlider(distance: filter.distance),
          if (placeType == PlaceType.restaurant) ...[
            const SizedBox(height: 24),
            Text('음식 카테고리', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              '원하는 카테고리를 선택하세요. 미선택 시 전체 표시됩니다.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            _CategorySelector(selectedCategories: filter.selectedCategories),
          ],
        ],
      ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: accentGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3D5AF1).withValues(alpha:0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: const Text('적용'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DistanceSlider extends ConsumerWidget {
  final int distance;

  const _DistanceSlider({required this.distance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Slider(
          value: distance.toDouble(),
          min: 100,
          max: 1000,
          divisions: 9,
          label: _formatDistance(distance),
          onChanged: (value) {
            ref.read(filterProvider.notifier).setDistance(value.round());
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('100m', style: Theme.of(context).textTheme.bodySmall),
            Text(
              _formatDistance(distance),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text('1km', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  String _formatDistance(int meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
    return '${meters}m';
  }
}

class _CategorySelector extends ConsumerWidget {
  final Set<FoodCategory> selectedCategories;

  const _CategorySelector({required this.selectedCategories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: FoodCategory.values.map((category) {
        return FilterChip(
          label: Text(category.label),
          selected: selectedCategories.contains(category),
          onSelected: (_) {
            ref.read(filterProvider.notifier).toggleCategory(category);
          },
        );
      }).toList(),
    );
  }
}
