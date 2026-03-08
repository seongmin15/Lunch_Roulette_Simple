import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunch_roulette_app/features/home/widgets/restaurant_list_card.dart';
import 'package:lunch_roulette_app/models/restaurant.dart';

void main() {
  group('RestaurantListCard', () {
    testWidgets('식당 정보를 올바르게 표시한다', (tester) async {
      const restaurant = Restaurant(
        id: '1',
        name: '맛있는 한식당',
        categoryName: '음식점 > 한식 > 한정식',
        phone: '02-1234-5678',
        addressName: '서울시 강남구 역삼동',
        roadAddressName: '서울시 강남구 테헤란로 123',
        latitude: 37.5665,
        longitude: 126.9780,
        distance: 350,
        placeUrl: 'https://place.map.kakao.com/1',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RestaurantListCard(restaurant: restaurant),
          ),
        ),
      );

      expect(find.text('맛있는 한식당'), findsOneWidget);
      expect(find.text('음식점 > 한식 > 한정식'), findsOneWidget);
      expect(find.text('서울시 강남구 테헤란로 123'), findsOneWidget);
      expect(find.text('350m'), findsOneWidget);
    });

    testWidgets('도로명 주소가 없으면 지번 주소를 표시한다', (tester) async {
      const restaurant = Restaurant(
        id: '2',
        name: '골목 식당',
        categoryName: '음식점 > 분식',
        phone: '',
        addressName: '서울시 마포구 상수동 123',
        roadAddressName: '',
        latitude: 37.5500,
        longitude: 126.9200,
        distance: 800,
        placeUrl: '',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RestaurantListCard(restaurant: restaurant),
          ),
        ),
      );

      expect(find.text('서울시 마포구 상수동 123'), findsOneWidget);
    });

    testWidgets('1km 이상 거리는 km 단위로 표시한다', (tester) async {
      const restaurant = Restaurant(
        id: '3',
        name: '먼 식당',
        categoryName: '음식점',
        phone: '',
        addressName: '서울시',
        roadAddressName: '서울시 어딘가',
        latitude: 37.5000,
        longitude: 127.0000,
        distance: 1500,
        placeUrl: '',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RestaurantListCard(restaurant: restaurant),
          ),
        ),
      );

      expect(find.text('1.5km'), findsOneWidget);
    });
  });
}
