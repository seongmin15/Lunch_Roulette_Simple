import 'package:go_router/go_router.dart';
import 'package:lunch_roulette_app/features/filter/screens/filter_screen.dart';
import 'package:lunch_roulette_app/features/history/screens/history_screen.dart';
import 'package:lunch_roulette_app/features/home/screens/home_screen.dart';
import 'package:lunch_roulette_app/features/restaurant_detail/screens/restaurant_detail_screen.dart';
import 'package:lunch_roulette_app/features/roulette/screens/roulette_screen.dart';
import 'package:lunch_roulette_app/models/restaurant.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/filter',
      builder: (context, state) => const FilterScreen(),
    ),
    GoRoute(
      path: '/roulette',
      builder: (context, state) => RouletteScreen(
        restaurants: state.extra as List<Restaurant>,
      ),
    ),
    GoRoute(
      path: '/restaurant-detail',
      builder: (context, state) => RestaurantDetailScreen(
        restaurant: state.extra as Restaurant,
      ),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
  ],
);
