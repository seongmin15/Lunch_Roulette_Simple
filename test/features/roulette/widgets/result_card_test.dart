import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunch_roulette_app/features/roulette/widgets/result_card.dart';
import 'package:lunch_roulette_app/models/restaurant.dart';

void main() {
  group('ResultCard', () {
    testWidgets('선택된 식당 정보를 올바르게 표시한다', (tester) async {
      const restaurant = Restaurant(
        id: '1',
        name: '맛있는 한식당',
        categoryName: '음식점 > 한식',
        phone: '02-1234-5678',
        addressName: '서울시 강남구 역삼동',
        roadAddressName: '서울시 강남구 테헤란로 123',
        latitude: 37.5665,
        longitude: 126.9780,
        distance: 350,
        placeUrl: '',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ResultCard(restaurant: restaurant)),
        ),
      );

      expect(find.text('오늘의 점심은'), findsOneWidget);
      expect(find.text('맛있는 한식당'), findsOneWidget);
      expect(find.text('음식점 > 한식'), findsOneWidget);
      expect(find.text('서울시 강남구 테헤란로 123'), findsOneWidget);
      expect(find.text('350m'), findsOneWidget);
    });

    testWidgets('1km 이상 거리는 km로 표시한다', (tester) async {
      const restaurant = Restaurant(
        id: '2',
        name: '먼 식당',
        categoryName: '음식점',
        phone: '',
        addressName: '서울시',
        roadAddressName: '서울시 어딘가',
        latitude: 37.5,
        longitude: 127.0,
        distance: 2500,
        placeUrl: '',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ResultCard(restaurant: restaurant)),
        ),
      );

      expect(find.text('2.5km'), findsOneWidget);
    });
  });
}
