import 'package:go_router/go_router.dart';
import 'package:lunch_roulette_app/features/filter/screens/filter_screen.dart';
import 'package:lunch_roulette_app/features/home/screens/home_screen.dart';

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
  ],
);
