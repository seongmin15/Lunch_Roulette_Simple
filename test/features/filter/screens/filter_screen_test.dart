import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunch_roulette_app/features/filter/providers/filter_provider.dart';
import 'package:lunch_roulette_app/features/filter/providers/filter_state.dart';
import 'package:lunch_roulette_app/features/filter/screens/filter_screen.dart';

void main() {
  Widget createTestWidget({FilterState? initialState}) {
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

    testWidgets('카테고리 칩이 모두 표시된다', (tester) async {
      await tester.pumpWidget(createTestWidget());

      for (final category in FoodCategory.values) {
        expect(find.text(category.label), findsOneWidget);
      }
    });

    testWidgets('초기화 버튼이 기본값일 때 비활성화된다', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final resetButton = tester.widget<TextButton>(find.widgetWithText(TextButton, '초기화'));
      expect(resetButton.onPressed, isNull);
    });

    testWidgets('필터 변경 시 초기화 버튼이 활성화된다', (tester) async {
      await tester.pumpWidget(createTestWidget(
        initialState: const FilterState(distance: 2000),
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
  });
}
