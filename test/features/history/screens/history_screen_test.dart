import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunch_roulette_app/features/history/screens/history_screen.dart';
import 'package:lunch_roulette_app/features/roulette/providers/roulette_history_provider.dart';
import 'package:lunch_roulette_app/models/restaurant.dart';

const _testRestaurant = Restaurant(
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

const _testRestaurant2 = Restaurant(
  id: '2',
  name: '좋은 식당',
  categoryName: '음식점 > 일식',
  phone: '02-9876-5432',
  addressName: '서울시 서초구',
  roadAddressName: '서울시 서초구 서초대로',
  latitude: 37.4900,
  longitude: 127.0100,
  distance: 1500,
  placeUrl: 'https://place.map.kakao.com/2',
);

void main() {
  group('HistoryScreen', () {
    testWidgets('히스토리가 비어있으면 빈 상태 메시지를 표시한다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HistoryScreen(),
          ),
        ),
      );

      expect(find.text('아직 룰렛 기록이 없습니다.'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('히스토리 항목이 있으면 목록을 표시한다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rouletteHistoryProvider.overrideWith((ref) {
              final notifier = RouletteHistoryNotifier();
              notifier.addEntry(_testRestaurant);
              notifier.addEntry(_testRestaurant2);
              return notifier;
            }),
          ],
          child: const MaterialApp(
            home: HistoryScreen(),
          ),
        ),
      );

      expect(find.text('맛있는 식당'), findsOneWidget);
      expect(find.text('좋은 식당'), findsOneWidget);
    });

    testWidgets('히스토리가 있으면 전체 삭제 버튼이 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rouletteHistoryProvider.overrideWith((ref) {
              final notifier = RouletteHistoryNotifier();
              notifier.addEntry(_testRestaurant);
              return notifier;
            }),
          ],
          child: const MaterialApp(
            home: HistoryScreen(),
          ),
        ),
      );

      expect(find.byIcon(Icons.delete_sweep), findsOneWidget);
    });

    testWidgets('히스토리가 비어있으면 전체 삭제 버튼이 숨겨진다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HistoryScreen(),
          ),
        ),
      );

      expect(find.byIcon(Icons.delete_sweep), findsNothing);
    });

    testWidgets('전체 삭제 버튼 탭 시 확인 다이얼로그가 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rouletteHistoryProvider.overrideWith((ref) {
              final notifier = RouletteHistoryNotifier();
              notifier.addEntry(_testRestaurant);
              return notifier;
            }),
          ],
          child: const MaterialApp(
            home: HistoryScreen(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete_sweep));
      await tester.pumpAndSettle();

      expect(find.text('전체 삭제'), findsOneWidget);
      expect(find.text('모든 히스토리를 삭제하시겠습니까?'), findsOneWidget);
      expect(find.text('취소'), findsOneWidget);
      expect(find.text('삭제'), findsOneWidget);
    });

    testWidgets('1km 이상 거리는 km로 표시한다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rouletteHistoryProvider.overrideWith((ref) {
              final notifier = RouletteHistoryNotifier();
              notifier.addEntry(_testRestaurant2);
              return notifier;
            }),
          ],
          child: const MaterialApp(
            home: HistoryScreen(),
          ),
        ),
      );

      expect(find.text('1.5km'), findsOneWidget);
    });

    testWidgets('1km 미만 거리는 m로 표시한다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rouletteHistoryProvider.overrideWith((ref) {
              final notifier = RouletteHistoryNotifier();
              notifier.addEntry(_testRestaurant);
              return notifier;
            }),
          ],
          child: const MaterialApp(
            home: HistoryScreen(),
          ),
        ),
      );

      expect(find.text('350m'), findsOneWidget);
    });

    testWidgets('AppBar 제목이 히스토리로 표시된다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HistoryScreen(),
          ),
        ),
      );

      expect(find.text('히스토리'), findsOneWidget);
    });
  });
}
