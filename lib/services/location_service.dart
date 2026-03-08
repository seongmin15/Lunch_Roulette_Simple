import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

class LocationService {
  Future<permission_handler.PermissionStatus> checkPermission() {
    return permission_handler.Permission.locationWhenInUse.status;
  }

  Future<permission_handler.PermissionStatus> requestPermission() {
    return permission_handler.Permission.locationWhenInUse.request();
  }

  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<Position> getCurrentPosition() {
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  Future<bool> openAppSettings() {
    return permission_handler.openAppSettings();
  }

  Future<bool> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }
}
