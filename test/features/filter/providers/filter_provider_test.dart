import 'package:flutter_test/flutter_test.dart';

import 'package:lunch_roulette_app/features/filter/providers/filter_provider.dart';
import 'package:lunch_roulette_app/features/filter/providers/filter_state.dart';

void main() {
  late FilterNotifier notifier;

  setUp(() {
    notifier = FilterNotifier();
  });

  group('FilterNotifier', () {
    test('초기 상태는 기본값이다 (distance=1000, selectedCategories=empty)', () {
      expect(notifier.state.distance, 1000);
      expect(notifier.state.selectedCategories, isEmpty);
      expect(notifier.state.isDefault, true);
    });

    test('setDistance로 거리를 변경한다', () {
      notifier.setDistance(2000);

      expect(notifier.state.distance, 2000);
      expect(notifier.state.selectedCategories, isEmpty);
      expect(notifier.state.isDefault, false);
    });

    test('toggleCategory로 카테고리를 추가한다', () {
      notifier.toggleCategory(FoodCategory.korean);

      expect(notifier.state.selectedCategories, {FoodCategory.korean});
      expect(notifier.state.isDefault, false);
    });

    test('toggleCategory로 이미 선택된 카테고리를 해제한다', () {
      notifier.toggleCategory(FoodCategory.korean);
      notifier.toggleCategory(FoodCategory.korean);

      expect(notifier.state.selectedCategories, isEmpty);
      expect(notifier.state.isDefault, true);
    });

    test('여러 카테고리를 동시에 선택할 수 있다', () {
      notifier.toggleCategory(FoodCategory.korean);
      notifier.toggleCategory(FoodCategory.japanese);
      notifier.toggleCategory(FoodCategory.chinese);

      expect(notifier.state.selectedCategories, {
        FoodCategory.korean,
        FoodCategory.japanese,
        FoodCategory.chinese,
      });
    });

    test('reset으로 기본값으로 초기화한다', () {
      notifier.setDistance(2000);
      notifier.toggleCategory(FoodCategory.korean);

      notifier.reset();

      expect(notifier.state.distance, 1000);
      expect(notifier.state.selectedCategories, isEmpty);
      expect(notifier.state.isDefault, true);
    });
  });

  group('FilterState', () {
    test('copyWith으로 부분 업데이트가 가능하다', () {
      const state = FilterState(
        distance: 1500,
        selectedCategories: {FoodCategory.korean},
      );
      final updated = state.copyWith(distance: 2000);

      expect(updated.distance, 2000);
      expect(updated.selectedCategories, {FoodCategory.korean});
    });

    test('isDefault는 기본값일 때만 true이다', () {
      expect(const FilterState().isDefault, true);
      expect(const FilterState(distance: 500).isDefault, false);
      expect(
        const FilterState(selectedCategories: {FoodCategory.korean}).isDefault,
        false,
      );
    });
  });
}
