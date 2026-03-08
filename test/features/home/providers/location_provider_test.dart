import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import 'package:lunch_roulette_app/features/home/providers/location_provider.dart';
import 'package:lunch_roulette_app/features/home/providers/location_state.dart';
import 'package:lunch_roulette_app/services/location_service.dart';

/// Mock LocationService for testing
class MockLocationService extends LocationService {
  ph.PermissionStatus _permissionStatus = ph.PermissionStatus.granted;
  bool _serviceEnabled = true;
  Position? _position;
  Exception? _exception;

  void setPermissionStatus(ph.PermissionStatus status) {
    _permissionStatus = status;
  }

  void setServiceEnabled(bool enabled) {
    _serviceEnabled = enabled;
  }

  void setPosition(Position position) {
    _position = position;
  }

  void setException(Exception? exception) {
    _exception = exception;
  }

  @override
  Future<ph.PermissionStatus> checkPermission() async {
    return _permissionStatus;
  }

  @override
  Future<ph.PermissionStatus> requestPermission() async {
    return _permissionStatus;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return _serviceEnabled;
  }

  @override
  Future<Position> getCurrentPosition() async {
    if (_exception != null) {
      throw _exception!;
    }
    return _position!;
  }

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;
}

Position _createPosition({
  required double latitude,
  required double longitude,
}) {
  return Position(
    latitude: latitude,
    longitude: longitude,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
}

void main() {
  late MockLocationService mockService;
  late LocationNotifier notifier;

  setUp(() {
    mockService = MockLocationService();
    notifier = LocationNotifier(mockService);
  });

  group('LocationNotifier', () {
    test('초기 상태는 LocationInitial이다', () {
      expect(notifier.state, isA<LocationInitial>());
    });

    test('fetchLocation 성공 시 LocationLoaded 상태가 된다', () async {
      mockService.setPosition(
        _createPosition(latitude: 37.5665, longitude: 126.9780),
      );

      await notifier.fetchLocation();

      final state = notifier.state;
      expect(state, isA<LocationLoaded>());
      expect((state as LocationLoaded).latitude, 37.5665);
      expect(state.longitude, 126.9780);
    });

    test('GPS 서비스 비활성화 시 LocationServiceDisabled 상태가 된다', () async {
      mockService.setServiceEnabled(false);

      await notifier.fetchLocation();

      expect(notifier.state, isA<LocationServiceDisabled>());
    });

    test('권한 거부 시 LocationPermissionDenied 상태가 된다', () async {
      mockService.setPermissionStatus(ph.PermissionStatus.denied);

      await notifier.fetchLocation();

      expect(notifier.state, isA<LocationPermissionDenied>());
    });

    test('권한 영구 거부 시 LocationPermissionPermanentlyDenied 상태가 된다', () async {
      mockService
          .setPermissionStatus(ph.PermissionStatus.permanentlyDenied);

      await notifier.fetchLocation();

      expect(notifier.state, isA<LocationPermissionPermanentlyDenied>());
    });

    test('타임아웃 시 LocationError 상태가 된다', () async {
      mockService.setException(TimeoutException('timeout'));

      await notifier.fetchLocation();

      final state = notifier.state;
      expect(state, isA<LocationError>());
      expect(
        (state as LocationError).message,
        contains('시간이 초과'),
      );
    });

    test('기타 예외 시 LocationError 상태가 된다', () async {
      mockService.setException(Exception('unknown error'));

      await notifier.fetchLocation();

      final state = notifier.state;
      expect(state, isA<LocationError>());
      expect((state as LocationError).message, contains('오류'));
    });

    test('fetchLocation 호출 시 LocationLoading을 거친다', () async {
      final states = <LocationState>[];
      notifier.addListener((state) {
        states.add(state);
      });

      mockService.setPosition(
        _createPosition(latitude: 37.5665, longitude: 126.9780),
      );

      await notifier.fetchLocation();

      // addListener fires immediately with current state (LocationInitial),
      // then LocationLoading, then LocationLoaded
      expect(states, hasLength(3));
      expect(states[0], isA<LocationInitial>());
      expect(states[1], isA<LocationLoading>());
      expect(states[2], isA<LocationLoaded>());
    });

    test('retry는 fetchLocation을 다시 호출한다', () async {
      mockService.setException(Exception('error'));
      await notifier.fetchLocation();
      expect(notifier.state, isA<LocationError>());

      // Fix the error and retry
      mockService.setException(null);
      mockService.setPosition(
        _createPosition(latitude: 37.5665, longitude: 126.9780),
      );

      await notifier.retry();
      expect(notifier.state, isA<LocationLoaded>());
    });
  });
}
