import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lunch_roulette_app/features/home/providers/restaurant_list_state.dart';
import 'package:lunch_roulette_app/services/restaurant_service.dart';

final restaurantServiceProvider = Provider<RestaurantService>((ref) {
  return RestaurantService(Dio());
});

final restaurantListProvider =
    StateNotifierProvider<RestaurantListNotifier, RestaurantListState>((ref) {
  final service = ref.watch(restaurantServiceProvider);
  return RestaurantListNotifier(service);
});

class RestaurantListNotifier extends StateNotifier<RestaurantListState> {
  final RestaurantService _service;

  RestaurantListNotifier(this._service)
      : super(const RestaurantListInitial());

  Future<void> fetchRestaurants({
    required double latitude,
    required double longitude,
  }) async {
    state = const RestaurantListLoading();

    try {
      final restaurants = await _service.searchNearbyRestaurants(
        latitude: latitude,
        longitude: longitude,
      );

      if (restaurants.isEmpty) {
        state = const RestaurantListEmpty();
      } else {
        state = RestaurantListLoaded(restaurants);
      }
    } catch (e) {
      state = RestaurantListError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> retry({
    required double latitude,
    required double longitude,
  }) =>
      fetchRestaurants(latitude: latitude, longitude: longitude);
}
