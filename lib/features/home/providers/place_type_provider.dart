import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PlaceType {
  restaurant('식당', 'FD6', '음식점'),
  cafe('카페', 'CE7', '카페');

  final String label;
  final String categoryGroupCode;
  final String query;
  const PlaceType(this.label, this.categoryGroupCode, this.query);
}

const _storageKey = 'place_type';

final placeTypeProvider =
    StateNotifierProvider<PlaceTypeNotifier, PlaceType>((ref) {
  return PlaceTypeNotifier();
});

class PlaceTypeNotifier extends StateNotifier<PlaceType> {
  PlaceTypeNotifier() : super(PlaceType.restaurant) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);
    if (saved != null) {
      try {
        state = PlaceType.values.byName(saved);
      } catch (_) {
        // Invalid value, keep default
      }
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, state.name);
  }

  void setType(PlaceType type) {
    state = type;
    _save();
  }
}
