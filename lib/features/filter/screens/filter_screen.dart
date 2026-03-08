import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lunch_roulette_app/features/filter/providers/filter_provider.dart';
import 'package:lunch_roulette_app/features/filter/providers/filter_state.dart';

class FilterScreen extends ConsumerWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);
    final theme = Theme.of(context);

    return Scaffold(
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
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('적용'),
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
          min: 500,
          max: 3000,
          divisions: 5,
          label: _formatDistance(distance),
          onChanged: (value) {
            ref.read(filterProvider.notifier).setDistance(value.round());
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('500m', style: Theme.of(context).textTheme.bodySmall),
            Text(
              _formatDistance(distance),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text('3km', style: Theme.of(context).textTheme.bodySmall),
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
