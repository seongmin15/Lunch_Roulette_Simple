import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunch_roulette_app/features/roulette/screens/roulette_screen.dart';
import 'package:lunch_roulette_app/models/restaurant.dart';

const _testRestaurants = [
  Restaurant(
    id: '1',
    name: '맛있는 식당',
    categoryName: '음식점 > 한식',
    phone: '',
    addressName: '서울시 강남구',
    roadAddressName: '서울시 강남구 테헤란로',
    latitude: 37.5665,
    longitude: 126.9780,
    distance: 350,
    placeUrl: '',
  ),
  Restaurant(
    id: '2',
    name: '좋은 식당',
    categoryName: '음식점 > 일식',
    phone: '',
    addressName: '서울시 서초구',
    roadAddressName: '서울시 서초구 서초대로',
    latitude: 37.4900,
    longitude: 127.0100,
    distance: 500,
    placeUrl: '',
  ),
  Restaurant(
    id: '3',
    name: '훌륭한 식당',
    categoryName: '음식점 > 중식',
    phone: '',
    addressName: '서울시 마포구',
    roadAddressName: '서울시 마포구 월드컵로',
    latitude: 37.5500,
    longitude: 126.9100,
    distance: 800,
    placeUrl: '',
  ),
];

void main() {
  group('RouletteScreen', () {
    testWidgets('룰렛 화면이 올바르게 렌더링된다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RouletteScreen(restaurants: _testRestaurants),
          ),
        ),
      );

      expect(find.text('룰렛'), findsOneWidget);
      expect(find.text('돌리기'), findsOneWidget);
    });

    testWidgets('돌리기 버튼을 누르면 룰렛이 회전한다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RouletteScreen(restaurants: _testRestaurants),
          ),
        ),
      );

      await tester.tap(find.text('돌리기'));
      await tester.pump();

      // During spin, button should be disabled
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('룰렛이 멈추면 결과 카드와 다시 돌리기 버튼이 표시된다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RouletteScreen(restaurants: _testRestaurants),
          ),
        ),
      );

      await tester.tap(find.text('돌리기'));
      await tester.pumpAndSettle();

      expect(find.text('오늘의 점심은'), findsOneWidget);
      expect(find.text('다시 돌리기'), findsOneWidget);
    });

    testWidgets('룰렛이 멈추면 공유 버튼이 표시된다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RouletteScreen(restaurants: _testRestaurants),
          ),
        ),
      );

      // Before spin, no share button
      expect(find.byIcon(Icons.share), findsNothing);

      await tester.tap(find.text('돌리기'));
      await tester.pumpAndSettle();

      // After spin, share button appears
      expect(find.byIcon(Icons.share), findsOneWidget);
    });
  });
}
