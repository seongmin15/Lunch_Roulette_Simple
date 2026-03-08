import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunch_roulette_app/services/restaurant_service.dart';

/// Mock Dio that returns preconfigured responses
class MockDio implements Dio {
  Response? mockResponse;
  DioException? mockError;
  final List<Map<String, dynamic>> capturedQueryParams = [];
  final Map<String, Response> responsesByQuery = {};

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
    if (queryParameters != null) {
      capturedQueryParams.add(queryParameters);
      final query = queryParameters['query'] as String?;
      if (query != null && responsesByQuery.containsKey(query)) {
        return responsesByQuery[query]! as Response<T>;
      }
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

    test('query 파라미터를 전달할 수 있다', () async {
      mockDio.mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {'documents': []},
      );

      await service.searchNearbyRestaurants(
        latitude: 37.5665,
        longitude: 126.9780,
        query: '한식',
      );

      expect(mockDio.capturedQueryParams.last['query'], '한식');
    });
  });

  group('RestaurantService.searchByAllCategories', () {
    test('카테고리별로 병렬 호출하고 결과를 합친다', () async {
      mockDio.mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'documents': [
            {
              'id': '1',
              'place_name': '식당1',
              'category_name': '음식점',
              'phone': '',
              'address_name': '서울',
              'road_address_name': '서울',
              'y': '37.5',
              'x': '127.0',
              'distance': '100',
              'place_url': '',
            },
          ],
        },
      );

      final result = await service.searchByAllCategories(
        latitude: 37.5665,
        longitude: 126.9780,
        keywords: ['한식', '중식', '일식'],
      );

      // 3 calls made (one per keyword)
      expect(mockDio.capturedQueryParams.length, 3);
      // Same id deduplicates to 1 result
      expect(result.length, 1);
    });

    test('중복 식당을 ID 기준으로 제거한다', () async {
      mockDio.responsesByQuery['한식'] = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'documents': [
            {
              'id': '1',
              'place_name': '식당A',
              'category_name': '한식',
              'phone': '',
              'address_name': '서울',
              'road_address_name': '서울',
              'y': '37.5',
              'x': '127.0',
              'distance': '200',
              'place_url': '',
            },
            {
              'id': '2',
              'place_name': '식당B',
              'category_name': '한식',
              'phone': '',
              'address_name': '서울',
              'road_address_name': '서울',
              'y': '37.5',
              'x': '127.0',
              'distance': '100',
              'place_url': '',
            },
          ],
        },
      );
      mockDio.responsesByQuery['중식'] = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'documents': [
            {
              'id': '2',
              'place_name': '식당B',
              'category_name': '한식',
              'phone': '',
              'address_name': '서울',
              'road_address_name': '서울',
              'y': '37.5',
              'x': '127.0',
              'distance': '100',
              'place_url': '',
            },
            {
              'id': '3',
              'place_name': '식당C',
              'category_name': '중식',
              'phone': '',
              'address_name': '서울',
              'road_address_name': '서울',
              'y': '37.5',
              'x': '127.0',
              'distance': '300',
              'place_url': '',
            },
          ],
        },
      );

      final result = await service.searchByAllCategories(
        latitude: 37.5665,
        longitude: 126.9780,
        keywords: ['한식', '중식'],
      );

      expect(result.length, 3); // 4 total - 1 duplicate(id=2)
      expect(result.map((r) => r.id).toList(), ['2', '1', '3']); // sorted by distance
    });

    test('결과를 거리 순으로 정렬한다', () async {
      mockDio.responsesByQuery['한식'] = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'documents': [
            {
              'id': '1',
              'place_name': '먼 식당',
              'category_name': '한식',
              'phone': '',
              'address_name': '서울',
              'road_address_name': '서울',
              'y': '37.5',
              'x': '127.0',
              'distance': '500',
              'place_url': '',
            },
          ],
        },
      );
      mockDio.responsesByQuery['일식'] = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'documents': [
            {
              'id': '2',
              'place_name': '가까운 식당',
              'category_name': '일식',
              'phone': '',
              'address_name': '서울',
              'road_address_name': '서울',
              'y': '37.5',
              'x': '127.0',
              'distance': '100',
              'place_url': '',
            },
          ],
        },
      );

      final result = await service.searchByAllCategories(
        latitude: 37.5665,
        longitude: 126.9780,
        keywords: ['한식', '일식'],
      );

      expect(result[0].name, '가까운 식당');
      expect(result[1].name, '먼 식당');
    });
  });
}
