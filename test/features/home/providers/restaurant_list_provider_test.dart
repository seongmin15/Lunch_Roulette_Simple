import 'package:flutter_test/flutter_test.dart';

import 'package:lunch_roulette_app/features/home/providers/restaurant_list_provider.dart';
import 'package:lunch_roulette_app/features/home/providers/restaurant_list_state.dart';
import 'package:lunch_roulette_app/models/restaurant.dart';
import 'package:lunch_roulette_app/services/restaurant_service.dart';

class MockRestaurantService implements RestaurantService {
  List<Restaurant>? mockResult;
  Exception? mockError;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not mocked');

  @override
  Future<List<Restaurant>> searchNearbyRestaurants({
    required double latitude,
    required double longitude,
    int radius = 2000,
    int page = 1,
    int size = 15,
    String sort = 'distance',
  }) async {
    if (mockError != null) {
      throw mockError!;
    }
    return mockResult ?? [];
  }
}

void main() {
  late MockRestaurantService mockService;
  late RestaurantListNotifier notifier;

  setUp(() {
    mockService = MockRestaurantService();
    notifier = RestaurantListNotifier(mockService);
  });

  group('RestaurantListNotifier', () {
    test('초기 상태는 RestaurantListInitial이다', () {
      expect(notifier.state, isA<RestaurantListInitial>());
    });

    test('식당 검색 성공 시 RestaurantListLoaded를 반환한다', () async {
      mockService.mockResult = [
        const Restaurant(
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
        ),
        const Restaurant(
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
        ),
      ];

      await notifier.fetchRestaurants(latitude: 37.5665, longitude: 126.9780);

      expect(notifier.state, isA<RestaurantListLoaded>());
      final state = notifier.state as RestaurantListLoaded;
      expect(state.restaurants.length, 2);
      expect(state.restaurants[0].name, '맛있는 식당');
      expect(state.restaurants[1].name, '좋은 식당');
    });

    test('식당 검색 결과가 비어있으면 RestaurantListEmpty를 반환한다', () async {
      mockService.mockResult = [];

      await notifier.fetchRestaurants(latitude: 37.5665, longitude: 126.9780);

      expect(notifier.state, isA<RestaurantListEmpty>());
    });

    test('식당 검색 실패 시 RestaurantListError를 반환한다', () async {
      mockService.mockError = Exception('네트워크 연결을 확인해 주세요.');

      await notifier.fetchRestaurants(latitude: 37.5665, longitude: 126.9780);

      expect(notifier.state, isA<RestaurantListError>());
      final state = notifier.state as RestaurantListError;
      expect(state.message, contains('네트워크 연결을 확인해 주세요'));
    });

    test('fetchRestaurants 호출 시 로딩 상태를 거친다', () async {
      final states = <RestaurantListState>[];
      mockService.mockResult = [];

      notifier.addListener((state) {
        states.add(state);
      });

      await notifier.fetchRestaurants(latitude: 37.5665, longitude: 126.9780);

      // addListener fires with current state first (Initial), then Loading, then Empty
      expect(states, contains(isA<RestaurantListLoading>()));
    });

    test('retry는 fetchRestaurants를 재호출한다', () async {
      mockService.mockResult = [
        const Restaurant(
          id: '1',
          name: '재시도 식당',
          categoryName: '음식점',
          phone: '',
          addressName: '서울시',
          roadAddressName: '서울시 테헤란로',
          latitude: 37.5665,
          longitude: 126.9780,
          distance: 100,
          placeUrl: '',
        ),
      ];

      await notifier.retry(latitude: 37.5665, longitude: 126.9780);

      expect(notifier.state, isA<RestaurantListLoaded>());
      final state = notifier.state as RestaurantListLoaded;
      expect(state.restaurants[0].name, '재시도 식당');
    });
  });
}
