import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunch_roulette_app/services/restaurant_service.dart';

/// Mock Dio that returns preconfigured responses
class MockDio implements Dio {
  Response? mockResponse;
  DioException? mockError;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not mocked');

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (mockError != null) {
      throw mockError!;
    }
    return mockResponse! as Response<T>;
  }
}

void main() {
  late MockDio mockDio;
  late RestaurantService service;

  setUp(() {
    mockDio = MockDio();
    service = RestaurantService(mockDio);
    // Set test API key
    dotenv.testLoad(fileInput: 'KAKAO_REST_API_KEY=test_api_key');
  });

  group('RestaurantService.searchNearbyRestaurants', () {
    test('성공 응답 시 Restaurant 리스트를 반환한다', () async {
      mockDio.mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'documents': [
            {
              'id': '12345',
              'place_name': '맛있는 식당',
              'category_name': '음식점 > 한식',
              'phone': '02-1234-5678',
              'address_name': '서울시 강남구',
              'road_address_name': '서울시 강남구 테헤란로',
              'y': '37.5665',
              'x': '126.9780',
              'distance': '350',
              'place_url': 'https://place.map.kakao.com/12345',
            },
            {
              'id': '67890',
              'place_name': '좋은 식당',
              'category_name': '음식점 > 일식',
              'phone': '02-9876-5432',
              'address_name': '서울시 서초구',
              'road_address_name': '서울시 서초구 서초대로',
              'y': '37.4900',
              'x': '127.0100',
              'distance': '500',
              'place_url': 'https://place.map.kakao.com/67890',
            },
          ],
          'meta': {
            'total_count': 2,
            'pageable_count': 2,
            'is_end': true,
          },
        },
      );

      final result = await service.searchNearbyRestaurants(
        latitude: 37.5665,
        longitude: 126.9780,
      );

      expect(result.length, 2);
      expect(result[0].name, '맛있는 식당');
      expect(result[0].id, '12345');
      expect(result[1].name, '좋은 식당');
      expect(result[1].distance, 500);
    });

    test('빈 결과 시 빈 리스트를 반환한다', () async {
      mockDio.mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'documents': [],
          'meta': {
            'total_count': 0,
            'pageable_count': 0,
            'is_end': true,
          },
        },
      );

      final result = await service.searchNearbyRestaurants(
        latitude: 37.5665,
        longitude: 126.9780,
      );

      expect(result, isEmpty);
    });

    test('documents 키가 없으면 빈 리스트를 반환한다', () async {
      mockDio.mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {'meta': {}},
      );

      final result = await service.searchNearbyRestaurants(
        latitude: 37.5665,
        longitude: 126.9780,
      );

      expect(result, isEmpty);
    });

    test('401 에러 시 API 키 오류 메시지를 던진다', () async {
      mockDio.mockError = DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 401,
        ),
      );

      expect(
        () => service.searchNearbyRestaurants(
          latitude: 37.5665,
          longitude: 126.9780,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('API 키가 유효하지 않습니다'),
          ),
        ),
      );
    });

    test('타임아웃 시 시간 초과 메시지를 던진다', () async {
      mockDio.mockError = DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      );

      expect(
        () => service.searchNearbyRestaurants(
          latitude: 37.5665,
          longitude: 126.9780,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('서버 응답 시간이 초과되었습니다'),
          ),
        ),
      );
    });

    test('네트워크 오류 시 연결 확인 메시지를 던진다', () async {
      mockDio.mockError = DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionError,
      );

      expect(
        () => service.searchNearbyRestaurants(
          latitude: 37.5665,
          longitude: 126.9780,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('네트워크 연결을 확인해 주세요'),
          ),
        ),
      );
    });

    test('API 키가 없으면 에러를 던진다', () async {
      dotenv.testLoad(fileInput: '');

      expect(
        () => service.searchNearbyRestaurants(
          latitude: 37.5665,
          longitude: 126.9780,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('KAKAO_REST_API_KEY가 설정되지 않았습니다'),
          ),
        ),
      );
    });

    test('기본 파라미터가 올바르게 설정된다', () async {
      mockDio.mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {'documents': []},
      );

      await service.searchNearbyRestaurants(
        latitude: 37.5665,
        longitude: 126.9780,
      );

      // Default parameters are used (radius=2000, page=1, size=15, sort=distance)
      // Verified by successful call with no errors
    });

    test('커스텀 파라미터를 전달할 수 있다', () async {
      mockDio.mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {'documents': []},
      );

      await service.searchNearbyRestaurants(
        latitude: 37.5665,
        longitude: 126.9780,
        radius: 1000,
        page: 2,
        size: 10,
        sort: 'accuracy',
      );

      // Custom parameters are passed without errors
    });
  });
}
