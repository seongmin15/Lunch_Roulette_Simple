import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunch_roulette_app/features/filter/providers/filter_provider.dart';
import 'package:lunch_roulette_app/features/filter/providers/filter_state.dart';
import 'package:lunch_roulette_app/features/filter/screens/filter_screen.dart';
import 'package:lunch_roulette_app/features/home/providers/place_type_provider.dart';

void main() {
  Widget createTestWidget({
    FilterState? initialState,
    PlaceType placeType = PlaceType.restaurant,
  }) {
    return ProviderScope(
      overrides: [
        if (initialState != null)
          filterProvider.overrideWith((_) {
            final notifier = FilterNotifier();
            if (initialState.distance != 1000) {
              notifier.setDistance(initialState.distance);
            }
            for (final category in initialState.selectedCategories) {
              notifier.toggleCategory(category);
            }
            return notifier;
          }),
        placeTypeProvider.overrideWith((_) {
          final notifier = PlaceTypeNotifier();
          if (placeType != PlaceType.restaurant) {
            notifier.setType(placeType);
          }
          return notifier;
        }),
      ],
      child: const MaterialApp(
        home: FilterScreen(),
      ),
    );
  }

  group('FilterScreen', () {
    testWidgets('필터 화면이 올바르게 렌더링된다', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('필터 설정'), findsOneWidget);
      expect(find.text('검색 반경'), findsOneWidget);
      expect(find.text('음식 카테고리'), findsOneWidget);
      expect(find.text('적용'), findsOneWidget);
    });

    testWidgets('카테고리 칩이 7개 표시된다 (카페 제외)', (tester) async {
      await tester.pumpWidget(createTestWidget());

      for (final category in FoodCategory.values) {
        expect(find.text(category.label), findsOneWidget);
      }
      expect(FoodCategory.values.length, 7);
    });

    testWidgets('초기화 버튼이 기본값일 때 비활성화된다', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final resetButton = tester.widget<TextButton>(find.widgetWithText(TextButton, '초기화'));
      expect(resetButton.onPressed, isNull);
    });

    testWidgets('필터 변경 시 초기화 버튼이 활성화된다', (tester) async {
      await tester.pumpWidget(createTestWidget(
        initialState: const FilterState(distance: 500),
      ));

      final resetButton = tester.widget<TextButton>(find.widgetWithText(TextButton, '초기화'));
      expect(resetButton.onPressed, isNotNull);
    });

    testWidgets('적용 버튼을 누르면 화면이 닫힌다', (tester) async {
      var popped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FilterScreen(),
                      ),
                    ).then((_) => popped = true);
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('필터 설정'), findsOneWidget);

      await tester.tap(find.text('적용'));
      await tester.pumpAndSettle();

      expect(popped, true);
    });

    testWidgets('카페 모드에서 음식 카테고리 섹션이 숨겨진다', (tester) async {
      await tester.pumpWidget(createTestWidget(
        placeType: PlaceType.cafe,
      ));

      expect(find.text('필터 설정'), findsOneWidget);
      expect(find.text('검색 반경'), findsOneWidget);
      expect(find.text('음식 카테고리'), findsNothing);
    });

    testWidgets('식당 모드에서 음식 카테고리 섹션이 표시된다', (tester) async {
      await tester.pumpWidget(createTestWidget(
        placeType: PlaceType.restaurant,
      ));

      expect(find.text('음식 카테고리'), findsOneWidget);
    });
  });
}
