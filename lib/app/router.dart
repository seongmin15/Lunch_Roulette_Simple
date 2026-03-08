import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lunch_roulette_app/features/filter/screens/filter_screen.dart';
import 'package:lunch_roulette_app/features/history/screens/history_screen.dart';
import 'package:lunch_roulette_app/features/home/screens/home_screen.dart';
import 'package:lunch_roulette_app/features/restaurant_detail/screens/restaurant_detail_screen.dart';
import 'package:lunch_roulette_app/features/roulette/screens/roulette_screen.dart';
import 'package:lunch_roulette_app/models/restaurant.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/filter',
      builder: (context, state) => const FilterScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/roulette',
      builder: (context, state) => RouletteScreen(
        restaurants: state.extra as List<Restaurant>,
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/restaurant-detail',
      builder: (context, state) => RestaurantDetailScreen(
        restaurant: state.extra as Restaurant,
      ),
    ),
  ],
);

class _ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _ScaffoldWithNavBar({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: '히스토리',
          ),
        ],
      ),
    );
  }
}
