import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lunch_roulette_app/models/history_entry.dart';
import 'package:lunch_roulette_app/models/restaurant.dart';

final rouletteHistoryProvider =
    StateNotifierProvider<RouletteHistoryNotifier, List<HistoryEntry>>((ref) {
  return RouletteHistoryNotifier();
});

class RouletteHistoryNotifier extends StateNotifier<List<HistoryEntry>> {
  static const int maxEntries = 10;

  RouletteHistoryNotifier() : super([]);

  void addEntry(Restaurant restaurant) {
    final entry = HistoryEntry(
      restaurant: restaurant,
      selectedAt: DateTime.now(),
    );
    state = [entry, ...state].take(maxEntries).toList();
  }

  void removeAt(int index) {
    final updated = [...state];
    updated.removeAt(index);
    state = updated;
  }

  void clear() {
    state = [];
  }
}
