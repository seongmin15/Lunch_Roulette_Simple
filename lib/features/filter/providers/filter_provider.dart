import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lunch_roulette_app/features/filter/providers/filter_state.dart';

final filterProvider =
    StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());

  void setDistance(int distance) {
    state = state.copyWith(distance: distance);
  }

  void setPriceRange(PriceRange priceRange) {
    state = state.copyWith(priceRange: priceRange);
  }

  void reset() {
    state = const FilterState();
  }
}
