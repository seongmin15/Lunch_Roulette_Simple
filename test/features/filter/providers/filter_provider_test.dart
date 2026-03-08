import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lunch_roulette_app/features/filter/providers/filter_provider.dart';
import 'package:lunch_roulette_app/features/filter/providers/filter_state.dart';

void main() {
  late FilterNotifier notifier;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
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

  group('FilterNotifier 영속화', () {
    test('저장된 필터 값이 있으면 로드하여 상태에 반영한다', () async {
      SharedPreferences.setMockInitialValues({
        'filter_state':
            '{"distance":800,"selectedCategories":["korean","japanese"]}',
      });

      final loaded = FilterNotifier();
      // _load()는 비동기이므로 완료를 기다린다
      await Future<void>.delayed(Duration.zero);

      expect(loaded.state.distance, 800);
      expect(loaded.state.selectedCategories, {
        FoodCategory.korean,
        FoodCategory.japanese,
      });
    });

    test('setDistance 호출 시 SharedPreferences에 저장된다', () async {
      notifier.setDistance(2000);
      await Future<void>.delayed(Duration.zero);

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('filter_state');
      expect(saved, isNotNull);
      expect(saved, contains('"distance":2000'));
    });

    test('toggleCategory 호출 시 SharedPreferences에 저장된다', () async {
      notifier.toggleCategory(FoodCategory.japanese);
      await Future<void>.delayed(Duration.zero);

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('filter_state');
      expect(saved, isNotNull);
      expect(saved, contains('"japanese"'));
    });

    test('reset 호출 시 SharedPreferences에 기본값이 저장된다', () async {
      notifier.setDistance(2000);
      notifier.toggleCategory(FoodCategory.korean);
      notifier.reset();
      await Future<void>.delayed(Duration.zero);

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('filter_state');
      expect(saved, isNotNull);
      expect(saved, contains('"distance":1000'));
      expect(saved, contains('"selectedCategories":[]'));
    });

    test('잘못된 카테고리 이름은 무시한다', () async {
      SharedPreferences.setMockInitialValues({
        'filter_state':
            '{"distance":1000,"selectedCategories":["korean","invalid_category"]}',
      });

      final loaded = FilterNotifier();
      await Future<void>.delayed(Duration.zero);

      expect(loaded.state.selectedCategories, {FoodCategory.korean});
    });

    test('이전에 저장된 cafe 카테고리는 무시된다', () async {
      SharedPreferences.setMockInitialValues({
        'filter_state':
            '{"distance":1000,"selectedCategories":["korean","cafe"]}',
      });

      final loaded = FilterNotifier();
      await Future<void>.delayed(Duration.zero);

      // cafe is no longer a valid FoodCategory, should be ignored
      expect(loaded.state.selectedCategories, {FoodCategory.korean});
    });
  });

  group('FilterState', () {
    test('copyWith으로 부분 업데이트가 가능하다', () {
      const state = FilterState(
        distance: 800,
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
