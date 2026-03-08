sealed class LocationState {
  const LocationState();
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationLoaded extends LocationState {
  final double latitude;
  final double longitude;

  const LocationLoaded({required this.latitude, required this.longitude});
}

class LocationPermissionDenied extends LocationState {
  const LocationPermissionDenied();
}

class LocationPermissionPermanentlyDenied extends LocationState {
  const LocationPermissionPermanentlyDenied();
}

class LocationServiceDisabled extends LocationState {
  const LocationServiceDisabled();
}

class LocationError extends LocationState {
  final String message;

  const LocationError(this.message);
}
