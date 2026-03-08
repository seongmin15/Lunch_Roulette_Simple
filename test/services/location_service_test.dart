import 'package:flutter_test/flutter_test.dart';
import 'package:lunch_roulette_app/services/location_service.dart';

void main() {
  late LocationService service;

  setUp(() {
    service = LocationService();
  });

  group('LocationService', () {
    test('인스턴스가 정상적으로 생성된다', () {
      expect(service, isA<LocationService>());
    });

    test('checkPermission 메서드가 존재한다', () {
      expect(service.checkPermission, isA<Function>());
    });

    test('requestPermission 메서드가 존재한다', () {
      expect(service.requestPermission, isA<Function>());
    });

    test('isLocationServiceEnabled 메서드가 존재한다', () {
      expect(service.isLocationServiceEnabled, isA<Function>());
    });

    test('getCurrentPosition 메서드가 존재한다', () {
      expect(service.getCurrentPosition, isA<Function>());
    });

    test('openAppSettings 메서드가 존재한다', () {
      expect(service.openAppSettings, isA<Function>());
    });

    test('openLocationSettings 메서드가 존재한다', () {
      expect(service.openLocationSettings, isA<Function>());
    });
  });
}
