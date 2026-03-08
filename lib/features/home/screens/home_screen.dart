import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lunch_roulette_app/app/theme.dart';
import 'package:lunch_roulette_app/features/filter/providers/filter_provider.dart';
import 'package:lunch_roulette_app/features/home/providers/location_provider.dart';
import 'package:lunch_roulette_app/features/home/providers/location_state.dart';
import 'package:lunch_roulette_app/features/home/providers/restaurant_list_provider.dart';
import 'package:lunch_roulette_app/features/home/providers/restaurant_list_state.dart';
import 'package:lunch_roulette_app/features/home/widgets/restaurant_list_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(locationProvider.notifier).fetchLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final filter = ref.watch(filterProvider);

    return Container(
      decoration: const BoxDecoration(gradient: appGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('점심 룰렛'),
          actions: [
            IconButton(
              icon: Badge(
                isLabelVisible: !filter.isDefault,
                child: const Icon(Icons.tune),
              ),
              onPressed: () => context.push('/filter'),
            ),
          ],
        ),
        body: switch (locationState) {
        LocationInitial() => const Center(
            child: Text('점심 룰렛 앱에 오신 것을 환영합니다!'),
          ),
        LocationLoading() => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('위치를 확인하고 있습니다...'),
              ],
            ),
          ),
        LocationLoaded(:final latitude, :final longitude) =>
          _RestaurantListBody(latitude: latitude, longitude: longitude),
        LocationPermissionDenied() => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('주변 식당을 찾기 위해\n위치 권한이 필요합니다.',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      ref.read(locationProvider.notifier).fetchLocation();
                    },
                    icon: const Icon(Icons.my_location),
                    label: const Text('위치 권한 허용'),
                  ),
                ],
              ),
            ),
          ),
        LocationPermissionPermanentlyDenied() => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_disabled,
                      size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('위치 권한이 영구적으로 거부되었습니다.\n설정에서 권한을 허용해 주세요.',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      ref
                          .read(locationProvider.notifier)
                          .openAppSettings();
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('설정 열기'),
                  ),
                ],
              ),
            ),
          ),
        LocationServiceDisabled() => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.gps_off, size: 48, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text('GPS가 꺼져 있습니다.\n위치 서비스를 활성화해 주세요.',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      ref
                          .read(locationProvider.notifier)
                          .openLocationSettings();
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('위치 설정 열기'),
                  ),
                ],
              ),
            ),
          ),
        LocationError(:final message) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      ref.read(locationProvider.notifier).retry();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          ),
      },
      ),
    );
  }
}

class _RestaurantListBody extends ConsumerWidget {
  final double latitude;
  final double longitude;

  const _RestaurantListBody({
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantState = ref.watch(filteredRestaurantsProvider);
    final filter = ref.watch(filterProvider);

    return switch (restaurantState) {
      RestaurantListInitial() || RestaurantListLoading() => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('주변 식당을 검색하고 있습니다...'),
            ],
          ),
        ),
      RestaurantListLoaded(:final restaurants) => Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref
                    .read(restaurantListProvider.notifier)
                    .fetchRestaurants(
                        latitude: latitude,
                        longitude: longitude,
                        radius: filter.distance,
                        forceRefresh: true),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) =>
                      RestaurantListCard(restaurant: restaurants[index]),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: accentGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3D5AF1).withValues(alpha:0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FilledButton.icon(
                      onPressed: () =>
                          context.push('/roulette', extra: restaurants),
                      icon: const Icon(Icons.casino),
                      label: Text('룰렛 돌리기 (${restaurants.length}곳)'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      RestaurantListEmpty() => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.restaurant, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('주변에 식당이 없습니다.',
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    ref
                        .read(restaurantListProvider.notifier)
                        .fetchRestaurants(
                            latitude: latitude,
                            longitude: longitude,
                            radius: filter.distance);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 검색'),
                ),
              ],
            ),
          ),
        ),
      RestaurantListError(:final message) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    ref
                        .read(restaurantListProvider.notifier)
                        .fetchRestaurants(
                            latitude: latitude,
                            longitude: longitude,
                            radius: filter.distance);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
    };
  }
}
