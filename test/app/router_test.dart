import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lunch_roulette_app/app/app.dart';
import 'package:lunch_roulette_app/app/router.dart';
import 'package:lunch_roulette_app/models/restaurant.dart';

const _testRestaurant = Restaurant(
  id: '1',
  name: '테스트 식당',
  categoryName: '음식점 > 한식',
  phone: '02-1234-5678',
  addressName: '서울시 강남구',
  roadAddressName: '서울시 강남구 테헤란로',
  latitude: 37.5665,
  longitude: 126.9780,
  distance: 350,
  placeUrl: 'https://place.map.kakao.com/1',
);

/// NavigationBar 내부의 특정 라벨을 찾는 헬퍼
Finder findNavDestination(String label) {
  return find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppRouter', () {
    testWidgets('하단 네비게이션 바가 표시된다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: App()),
      );
      await tester.pump();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(findNavDestination('홈'), findsOneWidget);
      expect(findNavDestination('히스토리'), findsOneWidget);
    });

    testWidgets('홈 탭이 초기 선택 상태이다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: App()),
      );
      await tester.pump();

      expect(find.text('점심 룰렛'), findsOneWidget);
    });

    testWidgets('히스토리 탭을 탭하면 히스토리 화면으로 전환된다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: App()),
      );
      await tester.pump();

      await tester.tap(findNavDestination('히스토리'));
      await tester.pump();
      await tester.pump();

      expect(find.text('아직 룰렛 기록이 없습니다.'), findsOneWidget);
    });

    testWidgets('히스토리에서 홈 탭으로 돌아올 수 있다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: App()),
      );
      await tester.pump();

      await tester.tap(findNavDestination('히스토리'));
      await tester.pump();
      await tester.pump();

      await tester.tap(findNavDestination('홈'));
      await tester.pump();
      await tester.pump();

      expect(find.text('점심 룰렛'), findsOneWidget);
    });

    testWidgets('탭 전환 시 하단 네비게이션 바가 유지된다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: App()),
      );
      await tester.pump();

      await tester.tap(findNavDestination('히스토리'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(findNavDestination('홈'), findsOneWidget);
      expect(findNavDestination('히스토리'), findsOneWidget);
    });

    testWidgets('식당 상세 화면으로 데이터가 전달된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );
      await tester.pump();

      appRouter.push('/restaurant-detail', extra: _testRestaurant);
      await tester.pump();
      await tester.pump();

      expect(find.text('테스트 식당'), findsOneWidget);
      expect(find.text('식당 상세'), findsOneWidget);
    });
  });
}
