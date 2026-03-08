import 'package:lunch_roulette_app/models/restaurant.dart';

class HistoryEntry {
  final Restaurant restaurant;
  final DateTime selectedAt;

  const HistoryEntry({
    required this.restaurant,
    required this.selectedAt,
  });
}
