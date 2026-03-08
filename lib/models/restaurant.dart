class Restaurant {
  final String id;
  final String name;
  final String categoryName;
  final String phone;
  final String addressName;
  final String roadAddressName;
  final double latitude;
  final double longitude;
  final int distance;
  final String placeUrl;

  const Restaurant({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.phone,
    required this.addressName,
    required this.roadAddressName,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.placeUrl,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String? ?? '',
      name: json['place_name'] as String? ?? '',
      categoryName: json['category_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      addressName: json['address_name'] as String? ?? '',
      roadAddressName: json['road_address_name'] as String? ?? '',
      latitude: double.tryParse(json['y']?.toString() ?? '') ?? 0.0,
      longitude: double.tryParse(json['x']?.toString() ?? '') ?? 0.0,
      distance: int.tryParse(json['distance']?.toString() ?? '') ?? 0,
      placeUrl: json['place_url'] as String? ?? '',
    );
  }
}
