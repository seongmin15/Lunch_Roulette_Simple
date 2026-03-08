import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lunch_roulette_app/features/roulette/providers/roulette_history_provider.dart';
import 'package:lunch_roulette_app/models/restaurant.dart';

const _testRestaurant1 = Restaurant(
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
  distance: 500,
  placeUrl: 'https://place.map.kakao.com/2',
);

void main() {
  late RouletteHistoryNotifier notifier;

  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    notifier = RouletteHistoryNotifier();
  });

  group('RouletteHistoryNotifier', () {
    test('초기 상태는 빈 리스트이다', () {
      expect(notifier.state, isEmpty);
    });

    test('addEntry로 히스토리를 추가한다', () {
      notifier.addEntry(_testRestaurant1);

      expect(notifier.state.length, 1);
      expect(notifier.state[0].restaurant.name, '맛있는 식당');
    });

    test('최신 항목이 리스트 앞에 추가된다', () {
      notifier.addEntry(_testRestaurant1);
      notifier.addEntry(_testRestaurant2);

      expect(notifier.state[0].restaurant.name, '좋은 식당');
      expect(notifier.state[1].restaurant.name, '맛있는 식당');
    });

    test('10건을 초과하면 오래된 항목이 삭제된다', () {
      for (var i = 0; i < 12; i++) {
        notifier.addEntry(Restaurant(
          id: '$i',
          name: '식당 $i',
          categoryName: '음식점',
          phone: '',
          addressName: '',
          roadAddressName: '',
          latitude: 0,
          longitude: 0,
          distance: 0,
          placeUrl: '',
        ));
      }

      expect(notifier.state.length, 10);
      expect(notifier.state[0].restaurant.name, '식당 11');
    });

    test('removeAt으로 특정 항목을 삭제한다', () {
      notifier.addEntry(_testRestaurant1);
      notifier.addEntry(_testRestaurant2);

      notifier.removeAt(0);

      expect(notifier.state.length, 1);
      expect(notifier.state[0].restaurant.name, '맛있는 식당');
    });

    test('clear로 전체 히스토리를 삭제한다', () {
      notifier.addEntry(_testRestaurant1);
      notifier.addEntry(_testRestaurant2);

      notifier.clear();

      expect(notifier.state, isEmpty);
    });
  });
}
