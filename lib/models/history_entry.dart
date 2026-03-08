import 'package:lunch_roulette_app/models/restaurant.dart';

class HistoryEntry {
  final Restaurant restaurant;
  final DateTime selectedAt;

  const HistoryEntry({
    required this.restaurant,
    required this.selectedAt,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      restaurant: Restaurant.fromJson(json['restaurant'] as Map<String, dynamic>),
      selectedAt: DateTime.parse(json['selectedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurant': restaurant.toJson(),
      'selectedAt': selectedAt.toIso8601String(),
    };
  }
}
