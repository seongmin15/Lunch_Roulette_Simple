import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lunch_roulette_app/models/history_entry.dart';
import 'package:lunch_roulette_app/models/restaurant.dart';

const _storageKey = 'roulette_history';

final rouletteHistoryProvider =
    StateNotifierProvider<RouletteHistoryNotifier, List<HistoryEntry>>((ref) {
  return RouletteHistoryNotifier();
});

class RouletteHistoryNotifier extends StateNotifier<List<HistoryEntry>> {
  static const int maxEntries = 10;

  RouletteHistoryNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final list = jsonDecode(jsonString) as List<dynamic>;
      state = list
          .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  void addEntry(Restaurant restaurant) {
    final entry = HistoryEntry(
      restaurant: restaurant,
      selectedAt: DateTime.now(),
    );
    state = [entry, ...state].take(maxEntries).toList();
    _save();
  }

  void removeAt(int index) {
    final updated = [...state];
    updated.removeAt(index);
    state = updated;
    _save();
  }

  void clear() {
    state = [];
    _save();
  }
}
