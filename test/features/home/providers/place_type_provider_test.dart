import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lunch_roulette_app/features/home/providers/place_type_provider.dart';

void main() {
  late PlaceTypeNotifier notifier;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    notifier = PlaceTypeNotifier();
  });

  group('PlaceTypeNotifier', () {
    test('초기 상태는 restaurant이다', () {
      expect(notifier.state, PlaceType.restaurant);
    });

    test('setType으로 카페로 변경할 수 있다', () {
      notifier.setType(PlaceType.cafe);

      expect(notifier.state, PlaceType.cafe);
    });

    test('setType으로 식당으로 되돌릴 수 있다', () {
      notifier.setType(PlaceType.cafe);
      notifier.setType(PlaceType.restaurant);

      expect(notifier.state, PlaceType.restaurant);
    });
  });

  group('PlaceTypeNotifier 영속화', () {
    test('저장된 값이 있으면 로드하여 상태에 반영한다', () async {
      SharedPreferences.setMockInitialValues({
        'place_type': 'cafe',
      });

      final loaded = PlaceTypeNotifier();
      await Future<void>.delayed(Duration.zero);

      expect(loaded.state, PlaceType.cafe);
    });

    test('setType 호출 시 SharedPreferences에 저장된다', () async {
      notifier.setType(PlaceType.cafe);
      await Future<void>.delayed(Duration.zero);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('place_type'), 'cafe');
    });

    test('잘못된 저장 값은 무시하고 기본값을 유지한다', () async {
      SharedPreferences.setMockInitialValues({
        'place_type': 'invalid_value',
      });

      final loaded = PlaceTypeNotifier();
      await Future<void>.delayed(Duration.zero);

      expect(loaded.state, PlaceType.restaurant);
    });
  });

  group('PlaceType enum', () {
    test('restaurant는 올바른 값을 가진다', () {
      expect(PlaceType.restaurant.label, '식당');
      expect(PlaceType.restaurant.categoryGroupCode, 'FD6');
      expect(PlaceType.restaurant.query, '음식점');
    });

    test('cafe는 올바른 값을 가진다', () {
      expect(PlaceType.cafe.label, '카페');
      expect(PlaceType.cafe.categoryGroupCode, 'CE7');
      expect(PlaceType.cafe.query, '카페');
    });
  });
}
