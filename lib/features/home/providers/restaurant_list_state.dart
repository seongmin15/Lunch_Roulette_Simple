import 'package:lunch_roulette_app/models/restaurant.dart';

sealed class RestaurantListState {
  const RestaurantListState();
}

class RestaurantListInitial extends RestaurantListState {
  const RestaurantListInitial();
}

class RestaurantListLoading extends RestaurantListState {
  const RestaurantListLoading();
}

class RestaurantListLoaded extends RestaurantListState {
  final List<Restaurant> restaurants;

  const RestaurantListLoaded(this.restaurants);
}

class RestaurantListEmpty extends RestaurantListState {
  const RestaurantListEmpty();
}

class RestaurantListError extends RestaurantListState {
  final String message;

  const RestaurantListError(this.message);
}
