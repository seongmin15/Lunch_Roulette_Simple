import 'package:flutter_test/flutter_test.dart';
import 'package:lunch_roulette_app/models/restaurant.dart';

void main() {
  group('Restaurant.fromJson', () {
    test('카카오 API 응답을 올바르게 파싱한다', () {
      final json = {
        'id': '12345',
        'place_name': '맛있는 식당',
        'category_name': '음식점 > 한식 > 한정식',
        'phone': '02-1234-5678',
        'address_name': '서울시 강남구 역삼동 123',
        'road_address_name': '서울시 강남구 테헤란로 123',
        'y': '37.5665',
        'x': '126.9780',
        'distance': '350',
        'place_url': 'https://place.map.kakao.com/12345',
      };

      final restaurant = Restaurant.fromJson(json);

      expect(restaurant.id, '12345');
      expect(restaurant.name, '맛있는 식당');
      expect(restaurant.categoryName, '음식점 > 한식 > 한정식');
      expect(restaurant.phone, '02-1234-5678');
      expect(restaurant.addressName, '서울시 강남구 역삼동 123');
      expect(restaurant.roadAddressName, '서울시 강남구 테헤란로 123');
      expect(restaurant.latitude, 37.5665);
      expect(restaurant.longitude, 126.9780);
      expect(restaurant.distance, 350);
      expect(restaurant.placeUrl, 'https://place.map.kakao.com/12345');
    });

    test('누락된 필드는 기본값으로 처리한다', () {
      final json = <String, dynamic>{};

      final restaurant = Restaurant.fromJson(json);

      expect(restaurant.id, '');
      expect(restaurant.name, '');
      expect(restaurant.categoryName, '');
      expect(restaurant.phone, '');
      expect(restaurant.addressName, '');
      expect(restaurant.roadAddressName, '');
      expect(restaurant.latitude, 0.0);
      expect(restaurant.longitude, 0.0);
      expect(restaurant.distance, 0);
      expect(restaurant.placeUrl, '');
    });

    test('distance 문자열을 int로 변환한다', () {
      final json = {
        'id': '1',
        'place_name': '테스트',
        'distance': '1500',
      };

      final restaurant = Restaurant.fromJson(json);

      expect(restaurant.distance, 1500);
    });

    test('잘못된 숫자 문자열은 기본값 0으로 처리한다', () {
      final json = {
        'id': '1',
        'place_name': '테스트',
        'y': 'invalid',
        'x': 'invalid',
        'distance': 'invalid',
      };

      final restaurant = Restaurant.fromJson(json);

      expect(restaurant.latitude, 0.0);
      expect(restaurant.longitude, 0.0);
      expect(restaurant.distance, 0);
    });

    test('숫자 타입 좌표도 올바르게 처리한다', () {
      final json = {
        'id': '1',
        'place_name': '테스트',
        'y': 37.5665,
        'x': 126.978,
        'distance': 500,
      };

      final restaurant = Restaurant.fromJson(json);

      expect(restaurant.latitude, 37.5665);
      expect(restaurant.longitude, 126.978);
      expect(restaurant.distance, 500);
    });
  });

  group('Restaurant.toJson', () {
    test('모든 필드를 올바르게 직렬화한다', () {
      const restaurant = Restaurant(
        id: '12345',
        name: '맛있는 식당',
        categoryName: '음식점 > 한식',
        phone: '02-1234-5678',
        addressName: '서울시 강남구 역삼동 123',
        roadAddressName: '서울시 강남구 테헤란로 123',
        latitude: 37.5665,
        longitude: 126.9780,
        distance: 350,
        placeUrl: 'https://place.map.kakao.com/12345',
      );

      final json = restaurant.toJson();

      expect(json['id'], '12345');
      expect(json['name'], '맛있는 식당');
      expect(json['categoryName'], '음식점 > 한식');
      expect(json['phone'], '02-1234-5678');
      expect(json['addressName'], '서울시 강남구 역삼동 123');
      expect(json['roadAddressName'], '서울시 강남구 테헤란로 123');
      expect(json['latitude'], 37.5665);
      expect(json['longitude'], 126.9780);
      expect(json['distance'], 350);
      expect(json['placeUrl'], 'https://place.map.kakao.com/12345');
    });

    test('toJson → fromJson 라운드트립이 동일한 결과를 반환한다', () {
      const original = Restaurant(
        id: '999',
        name: '라운드트립 식당',
        categoryName: '음식점 > 일식',
        phone: '02-9999-9999',
        addressName: '서울시 서초구',
        roadAddressName: '서울시 서초구 서초대로',
        latitude: 37.49,
        longitude: 127.01,
        distance: 800,
        placeUrl: 'https://place.map.kakao.com/999',
      );

      final restored = Restaurant.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.categoryName, original.categoryName);
      expect(restored.phone, original.phone);
      expect(restored.addressName, original.addressName);
      expect(restored.roadAddressName, original.roadAddressName);
      expect(restored.latitude, original.latitude);
      expect(restored.longitude, original.longitude);
      expect(restored.distance, original.distance);
      expect(restored.placeUrl, original.placeUrl);
    });
  });
}
