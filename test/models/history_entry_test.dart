import 'package:flutter_test/flutter_test.dart';

import 'package:lunch_roulette_app/models/history_entry.dart';
import 'package:lunch_roulette_app/models/restaurant.dart';

void main() {
  const restaurant = Restaurant(
    id: '1',
    name: '맛있는 식당',
    categoryName: '음식점 > 한식',
    phone: '02-1234-5678',
    addressName: '서울시 강남구',
    roadAddressName: '서울시 강남구 테헤란로',
    latitude: 37.5665,
    longitude: 126.9780,
    distance: 350,
    placeUrl: 'https://place.map.kakao.com/1',
  );

  group('HistoryEntry', () {
    test('toJson이 올바르게 직렬화한다', () {
      final entry = HistoryEntry(
        restaurant: restaurant,
        selectedAt: DateTime(2026, 3, 8, 12, 30),
      );

      final json = entry.toJson();

      expect(json['restaurant'], isA<Map<String, dynamic>>());
      expect(json['selectedAt'], '2026-03-08T12:30:00.000');
      expect((json['restaurant'] as Map)['name'], '맛있는 식당');
    });

    test('fromJson이 올바르게 역직렬화한다', () {
      final json = {
        'restaurant': restaurant.toJson(),
        'selectedAt': '2026-03-08T12:30:00.000',
      };

      final entry = HistoryEntry.fromJson(json);

      expect(entry.restaurant.name, '맛있는 식당');
      expect(entry.restaurant.id, '1');
      expect(entry.selectedAt, DateTime(2026, 3, 8, 12, 30));
    });

    test('toJson → fromJson 라운드트립이 동일한 결과를 반환한다', () {
      final original = HistoryEntry(
        restaurant: restaurant,
        selectedAt: DateTime(2026, 3, 8, 14, 0, 30),
      );

      final restored = HistoryEntry.fromJson(original.toJson());

      expect(restored.restaurant.id, original.restaurant.id);
      expect(restored.restaurant.name, original.restaurant.name);
      expect(restored.selectedAt, original.selectedAt);
    });
  });
}
