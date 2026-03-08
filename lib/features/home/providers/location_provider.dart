import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import 'package:lunch_roulette_app/features/home/providers/location_state.dart';
import 'package:lunch_roulette_app/services/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  final service = ref.watch(locationServiceProvider);
  return LocationNotifier(service);
});

class LocationNotifier extends StateNotifier<LocationState> {
  final LocationService _service;

  LocationNotifier(this._service) : super(const LocationInitial());

  Future<void> fetchLocation() async {
    state = const LocationLoading();

    try {
      final serviceEnabled = await _service.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = const LocationServiceDisabled();
        return;
      }

      var status = await _service.checkPermission();

      if (status == ph.PermissionStatus.denied) {
        status = await _service.requestPermission();
      }

      if (status == ph.PermissionStatus.denied) {
        state = const LocationPermissionDenied();
        return;
      }

      if (status == ph.PermissionStatus.permanentlyDenied) {
        state = const LocationPermissionPermanentlyDenied();
        return;
      }

      final position = await _service.getCurrentPosition();
      state = LocationLoaded(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on TimeoutException {
      state = const LocationError('위치 조회 시간이 초과되었습니다. 다시 시도해 주세요.');
    } catch (e) {
      state = LocationError('위치를 가져오는 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> retry() => fetchLocation();

  Future<void> openAppSettings() => _service.openAppSettings();

  Future<void> openLocationSettings() => _service.openLocationSettings();
}
