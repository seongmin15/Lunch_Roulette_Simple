import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lunch_roulette_app/features/home/providers/location_provider.dart';
import 'package:lunch_roulette_app/features/home/providers/location_state.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('점심 룰렛'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: switch (locationState) {
            LocationInitial() => const Text('점심 룰렛 앱에 오신 것을 환영합니다!'),
            LocationLoading() => const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('위치를 확인하고 있습니다...'),
                ],
              ),
            LocationLoaded(:final latitude, :final longitude) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 48, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(
                    '현재 위치',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('위도: ${latitude.toStringAsFixed(6)}'),
                  Text('경도: ${longitude.toStringAsFixed(6)}'),
                ],
              ),
            LocationPermissionDenied() => Column(
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
            LocationPermissionPermanentlyDenied() => Column(
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
                      ref.read(locationProvider.notifier).openAppSettings();
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('설정 열기'),
                  ),
                ],
              ),
            LocationServiceDisabled() => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.gps_off, size: 48, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text('GPS가 꺼져 있습니다.\n위치 서비스를 활성화해 주세요.',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      ref.read(locationProvider.notifier).openLocationSettings();
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('위치 설정 열기'),
                  ),
                ],
              ),
            LocationError(:final message) => Column(
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
          },
        ),
      ),
    );
  }
}
