import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunch_roulette_app/features/restaurant_detail/screens/restaurant_detail_screen.dart';
import 'package:lunch_roulette_app/models/restaurant.dart';

void main() {
  const restaurant = Restaurant(
    id: '1',
    name: '맛있는 한식당',
    categoryName: '음식점 > 한식 > 한정식',
    phone: '02-1234-5678',
    addressName: '서울시 강남구 역삼동 123',
    roadAddressName: '서울시 강남구 테헤란로 123',
    latitude: 37.5665,
    longitude: 126.9780,
    distance: 350,
    placeUrl: 'https://place.map.kakao.com/1',
  );

  group('RestaurantDetailScreen', () {
    testWidgets('식당 상세 정보를 올바르게 표시한다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RestaurantDetailScreen(restaurant: restaurant),
        ),
      );

      expect(find.text('식당 상세'), findsOneWidget);
      expect(find.text('맛있는 한식당'), findsOneWidget);
      expect(find.text('음식점 > 한식 > 한정식'), findsOneWidget);
      expect(find.text('서울시 강남구 테헤란로 123'), findsOneWidget);
      expect(find.text('(지번) 서울시 강남구 역삼동 123'), findsOneWidget);
      expect(find.text('350m'), findsOneWidget);
      expect(find.text('02-1234-5678'), findsOneWidget);
    });

    testWidgets('길찾기 버튼이 표시된다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RestaurantDetailScreen(restaurant: restaurant),
        ),
      );

      expect(find.text('길찾기'), findsOneWidget);
    });

    testWidgets('전화번호가 있으면 전화하기 버튼이 표시된다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RestaurantDetailScreen(restaurant: restaurant),
        ),
      );

      expect(find.text('전화하기'), findsOneWidget);
    });

    testWidgets('전화번호가 없으면 전화하기 버튼이 숨겨진다', (tester) async {
      const noPhoneRestaurant = Restaurant(
        id: '2',
        name: '전화없는 식당',
        categoryName: '음식점',
        phone: '',
        addressName: '서울시',
        roadAddressName: '서울시 어딘가',
        latitude: 37.5,
        longitude: 127.0,
        distance: 500,
        placeUrl: '',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: RestaurantDetailScreen(restaurant: noPhoneRestaurant),
        ),
      );

      expect(find.text('전화하기'), findsNothing);
    });

    testWidgets('카카오맵 URL이 있으면 카카오맵 버튼이 표시된다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RestaurantDetailScreen(restaurant: restaurant),
        ),
      );

      expect(find.text('카카오맵에서 보기'), findsOneWidget);
    });

    testWidgets('1km 이상 거리는 km로 표시한다', (tester) async {
      const farRestaurant = Restaurant(
        id: '3',
        name: '먼 식당',
        categoryName: '음식점',
        phone: '',
        addressName: '서울시',
        roadAddressName: '서울시 먼곳',
        latitude: 37.5,
        longitude: 127.0,
        distance: 1800,
        placeUrl: '',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: RestaurantDetailScreen(restaurant: farRestaurant),
        ),
      );

      expect(find.text('1.8km'), findsOneWidget);
    });
  });
}
