import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lunch_roulette_app/features/filter/providers/filter_state.dart';

const _storageKey = 'filter_state';

final filterProvider =
    StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      final distance = map['distance'] as int? ?? 1000;
      final categoryNames = (map['selectedCategories'] as List<dynamic>?)
              ?.cast<String>() ??
          [];
      final categories = categoryNames
          .map((name) {
            try {
              return FoodCategory.values.byName(name);
            } catch (_) {
              return null;
            }
          })
          .whereType<FoodCategory>()
          .toSet();
      state = FilterState(distance: distance, selectedCategories: categories);
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'distance': state.distance,
      'selectedCategories':
          state.selectedCategories.map((c) => c.name).toList(),
    };
    await prefs.setString(_storageKey, jsonEncode(map));
  }

  void setDistance(int distance) {
    state = state.copyWith(distance: distance);
    _save();
  }

  void toggleCategory(FoodCategory category) {
    final updated = Set<FoodCategory>.from(state.selectedCategories);
    if (updated.contains(category)) {
      updated.remove(category);
    } else {
      updated.add(category);
    }
    state = state.copyWith(selectedCategories: updated);
    _save();
  }

  void reset() {
    state = const FilterState();
    _save();
  }
}
