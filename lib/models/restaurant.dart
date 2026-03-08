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
      name: json['place_name'] as String? ?? json['name'] as String? ?? '',
      categoryName: json['category_name'] as String? ?? json['categoryName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      addressName: json['address_name'] as String? ?? json['addressName'] as String? ?? '',
      roadAddressName: json['road_address_name'] as String? ?? json['roadAddressName'] as String? ?? '',
      latitude: _parseDouble(json['y'] ?? json['latitude']),
      longitude: _parseDouble(json['x'] ?? json['longitude']),
      distance: _parseInt(json['distance']),
      placeUrl: json['place_url'] as String? ?? json['placeUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryName': categoryName,
      'phone': phone,
      'addressName': addressName,
      'roadAddressName': roadAddressName,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'placeUrl': placeUrl,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}
