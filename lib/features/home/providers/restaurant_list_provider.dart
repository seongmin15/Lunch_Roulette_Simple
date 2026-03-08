import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lunch_roulette_app/features/filter/providers/filter_provider.dart';
import 'package:lunch_roulette_app/features/filter/providers/filter_state.dart';
import 'package:lunch_roulette_app/features/home/providers/location_provider.dart';
import 'package:lunch_roulette_app/features/home/providers/location_state.dart';
import 'package:lunch_roulette_app/features/home/providers/restaurant_list_state.dart';
import 'package:lunch_roulette_app/models/restaurant.dart';
import 'package:lunch_roulette_app/services/restaurant_service.dart';

final restaurantServiceProvider = Provider<RestaurantService>((ref) {
  return RestaurantService(Dio());
});

final restaurantListProvider =
    StateNotifierProvider<RestaurantListNotifier, RestaurantListState>((ref) {
  final service = ref.watch(restaurantServiceProvider);
  final notifier = RestaurantListNotifier(service);

  // Provider 생성 시 이미 위치가 로드된 상태라면 즉시 fetch
  final currentLocation = ref.read(locationProvider);
  if (currentLocation is LocationLoaded) {
    final filter = ref.read(filterProvider);
    Future.microtask(() {
      notifier.fetchRestaurants(
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
        radius: filter.distance,
      );
    });
  }

  ref.listen<LocationState>(locationProvider, (_, location) {
    if (location is LocationLoaded) {
      final filter = ref.read(filterProvider);
      notifier.fetchRestaurants(
        latitude: location.latitude,
        longitude: location.longitude,
        radius: filter.distance,
      );
    }
  });

  ref.listen<FilterState>(filterProvider, (prev, next) {
    if (prev?.distance == next.distance) return;
    final location = ref.read(locationProvider);
    if (location is LocationLoaded) {
      notifier.fetchRestaurants(
        latitude: location.latitude,
        longitude: location.longitude,
        radius: next.distance,
      );
    }
  });

  return notifier;
});

final filteredRestaurantsProvider = Provider<RestaurantListState>((ref) {
  final state = ref.watch(restaurantListProvider);
  final filter = ref.watch(filterProvider);

  if (state is! RestaurantListLoaded) return state;
  if (filter.selectedCategories.isEmpty) return state;

  final filtered = state.restaurants.where((r) {
    return filter.selectedCategories.any(
      (c) => r.categoryName.contains(c.keyword),
    );
  }).toList();

  if (filtered.isEmpty) return const RestaurantListEmpty();
  return RestaurantListLoaded(filtered);
});

class _CacheEntry {
  final List<Restaurant> restaurants;
  final DateTime cachedAt;

  _CacheEntry(this.restaurants, this.cachedAt);

  bool get isExpired =>
      DateTime.now().difference(cachedAt).inMinutes >= RestaurantListNotifier.cacheTtlMinutes;
}

class RestaurantListNotifier extends StateNotifier<RestaurantListState> {
  final RestaurantService _service;
  static const int cacheTtlMinutes = 10;

  final Map<String, _CacheEntry> _cache = {};

  RestaurantListNotifier(this._service)
      : super(const RestaurantListInitial());

  String _cacheKey(double latitude, double longitude, int radius) =>
      '${latitude.toStringAsFixed(4)}_${longitude.toStringAsFixed(4)}_$radius';

  Future<void> fetchRestaurants({
    required double latitude,
    required double longitude,
    int radius = 1000,
    bool forceRefresh = false,
  }) async {
    final key = _cacheKey(latitude, longitude, radius);

    if (!forceRefresh) {
      final cached = _cache[key];
      if (cached != null && !cached.isExpired) {
        if (cached.restaurants.isEmpty) {
          state = const RestaurantListEmpty();
        } else {
          state = RestaurantListLoaded(cached.restaurants);
        }
        return;
      }
    }

    state = const RestaurantListLoading();

    try {
      final keywordToCategoryCode = {
        for (final c in FoodCategory.values)
          c.keyword: c.categoryGroupCode,
      };
      final restaurants = await _service.searchByAllCategories(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        keywordToCategoryCode: keywordToCategoryCode,
      );

      _cache[key] = _CacheEntry(restaurants, DateTime.now());

      if (restaurants.isEmpty) {
        state = const RestaurantListEmpty();
      } else {
        state = RestaurantListLoaded(restaurants);
      }
    } catch (e) {
      state = RestaurantListError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void clearCache() {
    _cache.clear();
  }

  Future<void> retry({
    required double latitude,
    required double longitude,
    int radius = 1000,
  }) =>
      fetchRestaurants(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        forceRefresh: true,
      );
}
