import 'package:flutter_test/flutter_test.dart';

import 'package:lunch_roulette_app/features/filter/providers/filter_provider.dart';
import 'package:lunch_roulette_app/features/filter/providers/filter_state.dart';

void main() {
  late FilterNotifier notifier;

  setUp(() {
    notifier = FilterNotifier();
  });

  group('FilterNotifier', () {
    test('초기 상태는 기본값이다 (distance=1000, priceRange=all)', () {
      expect(notifier.state.distance, 1000);
      expect(notifier.state.priceRange, PriceRange.all);
      expect(notifier.state.isDefault, true);
    });

    test('setDistance로 거리를 변경한다', () {
      notifier.setDistance(2000);

      expect(notifier.state.distance, 2000);
      expect(notifier.state.priceRange, PriceRange.all);
      expect(notifier.state.isDefault, false);
    });

    test('setPriceRange로 가격대를 변경한다', () {
      notifier.setPriceRange(PriceRange.cheap);

      expect(notifier.state.priceRange, PriceRange.cheap);
      expect(notifier.state.distance, 1000);
      expect(notifier.state.isDefault, false);
    });

    test('reset으로 기본값으로 초기화한다', () {
      notifier.setDistance(2000);
      notifier.setPriceRange(PriceRange.expensive);

      notifier.reset();

      expect(notifier.state.distance, 1000);
      expect(notifier.state.priceRange, PriceRange.all);
      expect(notifier.state.isDefault, true);
    });

    test('거리와 가격대를 동시에 변경할 수 있다', () {
      notifier.setDistance(500);
      notifier.setPriceRange(PriceRange.moderate);

      expect(notifier.state.distance, 500);
      expect(notifier.state.priceRange, PriceRange.moderate);
    });
  });

  group('FilterState', () {
    test('copyWith으로 부분 업데이트가 가능하다', () {
      const state = FilterState(distance: 1500, priceRange: PriceRange.cheap);
      final updated = state.copyWith(distance: 2000);

      expect(updated.distance, 2000);
      expect(updated.priceRange, PriceRange.cheap);
    });

    test('isDefault는 기본값일 때만 true이다', () {
      expect(const FilterState().isDefault, true);
      expect(const FilterState(distance: 500).isDefault, false);
      expect(
          const FilterState(priceRange: PriceRange.cheap).isDefault, false);
    });
  });
}
