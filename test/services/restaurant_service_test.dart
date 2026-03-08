import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunch_roulette_app/services/restaurant_service.dart';

/// Mock Dio that returns preconfigured responses
class MockDio implements Dio {
  Response? mockResponse;
  DioException? mockError;
  final List<Map<String, dynamic>> capturedQueryParams = [];
  final Map<String, List<Response>> responsesByQueryAndPage = {};

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not mocked');

  void setResponseForPage(String query, int page, Response response) {
    final key = '${query}_$page';
    responsesByQueryAndPage[key] = [response];
  }

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
      final page = queryParameters['page'] as int?;
      if (query != null && page != null) {
        final key = '${query}_$page';
        if (responsesByQueryAndPage.containsKey(key)) {
          return responsesByQueryAndPage[key]!.first as Response<T>;
        }
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
        data: {'documents': [], 'meta': {'is_end': true}},
      );

      await service.searchNearbyRestaurants(
        latitude: 37.5665,
        longitude: 126.9780,
      );

      // Default parameters are used (radius=2000, page=1, size=15, sort=distance)
      expect(mockDio.capturedQueryParams.last['category_group_code'], 'FD6');
    });

    test('categoryGroupCode 파라미터를 전달할 수 있다', () async {
      mockDio.mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {'documents': [], 'meta': {'is_end': true}},
      );

      await service.searchNearbyRestaurants(
        latitude: 37.5665,
        longitude: 126.9780,
        categoryGroupCode: 'CE7',
      );

      expect(mockDio.capturedQueryParams.last['category_group_code'], 'CE7');
    });

    test('커스텀 파라미터를 전달할 수 있다', () async {
      mockDio.mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {'documents': [], 'meta': {'is_end': true}},
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
        data: {'documents': [], 'meta': {'is_end': true}},
      );

      await service.searchNearbyRestaurants(
        latitude: 37.5665,
        longitude: 126.9780,
        query: '한식',
      );

      expect(mockDio.capturedQueryParams.last['query'], '한식');
    });
  });

  group('RestaurantService.searchAllByCategory', () {
    test('단일 페이지(is_end=true)일 때 1회만 호출한다', () async {
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
          'meta': {
            'total_count': 1,
            'pageable_count': 1,
            'is_end': true,
          },
        },
      );

      final result = await service.searchAllByCategory(
        latitude: 37.5665,
        longitude: 126.9780,
        categoryGroupCode: 'FD6',
        query: '음식점',
      );

      expect(mockDio.capturedQueryParams.length, 1);
      expect(result.length, 1);
      expect(result[0].name, '식당1');
    });

    test('다중 페이지(is_end=false)일 때 나머지 페이지를 병렬 호출한다', () async {
      // Page 1: is_end=false, pageable_count=30 → ceil(30/15) = 2 pages total
      mockDio.setResponseForPage('음식점', 1, Response(
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
          'meta': {
            'total_count': 30,
            'pageable_count': 30,
            'is_end': false,
          },
        },
      ));

      mockDio.setResponseForPage('음식점', 2, Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'documents': [
            {
              'id': '2',
              'place_name': '식당2',
              'category_name': '음식점',
              'phone': '',
              'address_name': '서울',
              'road_address_name': '서울',
              'y': '37.5',
              'x': '127.0',
              'distance': '200',
              'place_url': '',
            },
          ],
          'meta': {
            'total_count': 30,
            'pageable_count': 30,
            'is_end': true,
          },
        },
      ));

      final result = await service.searchAllByCategory(
        latitude: 37.5665,
        longitude: 126.9780,
        categoryGroupCode: 'FD6',
        query: '음식점',
      );

      // page 1 + page 2 = 2 calls
      expect(mockDio.capturedQueryParams.length, 2);
      expect(result.length, 2);
      expect(result[0].name, '식당1'); // distance 100
      expect(result[1].name, '식당2'); // distance 200
    });

    test('중복 식당을 ID 기준으로 제거한다', () async {
      // Both pages return id='1'
      mockDio.setResponseForPage('음식점', 1, Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'documents': [
            {
              'id': '1',
              'place_name': '식당A',
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
          'meta': {
            'pageable_count': 30,
            'is_end': false,
          },
        },
      ));

      mockDio.setResponseForPage('음식점', 2, Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'documents': [
            {
              'id': '1',
              'place_name': '식당A',
              'category_name': '음식점',
              'phone': '',
              'address_name': '서울',
              'road_address_name': '서울',
              'y': '37.5',
              'x': '127.0',
              'distance': '100',
              'place_url': '',
            },
            {
              'id': '2',
              'place_name': '식당B',
              'category_name': '음식점',
              'phone': '',
              'address_name': '서울',
              'road_address_name': '서울',
              'y': '37.5',
              'x': '127.0',
              'distance': '200',
              'place_url': '',
            },
          ],
          'meta': {
            'pageable_count': 30,
            'is_end': true,
          },
        },
      ));

      final result = await service.searchAllByCategory(
        latitude: 37.5665,
        longitude: 126.9780,
        categoryGroupCode: 'FD6',
        query: '음식점',
      );

      // 3 total docs - 1 duplicate = 2 unique
      expect(result.length, 2);
      expect(result[0].id, '1');
      expect(result[1].id, '2');
    });

    test('결과를 거리 순으로 정렬한다', () async {
      mockDio.mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'documents': [
            {
              'id': '1',
              'place_name': '먼 식당',
              'category_name': '음식점',
              'phone': '',
              'address_name': '서울',
              'road_address_name': '서울',
              'y': '37.5',
              'x': '127.0',
              'distance': '500',
              'place_url': '',
            },
            {
              'id': '2',
              'place_name': '가까운 식당',
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
          'meta': {
            'pageable_count': 2,
            'is_end': true,
          },
        },
      );

      final result = await service.searchAllByCategory(
        latitude: 37.5665,
        longitude: 126.9780,
        categoryGroupCode: 'FD6',
        query: '음식점',
      );

      expect(result[0].name, '가까운 식당');
      expect(result[1].name, '먼 식당');
    });

    test('카페 카테고리 코드(CE7)를 올바르게 전달한다', () async {
      mockDio.mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'documents': [
            {
              'id': '1',
              'place_name': '스타벅스',
              'category_name': '카페',
              'phone': '',
              'address_name': '서울',
              'road_address_name': '서울',
              'y': '37.5',
              'x': '127.0',
              'distance': '100',
              'place_url': '',
            },
          ],
          'meta': {
            'pageable_count': 1,
            'is_end': true,
          },
        },
      );

      await service.searchAllByCategory(
        latitude: 37.5665,
        longitude: 126.9780,
        categoryGroupCode: 'CE7',
        query: '카페',
      );

      expect(mockDio.capturedQueryParams.first['category_group_code'], 'CE7');
      expect(mockDio.capturedQueryParams.first['query'], '카페');
    });

    test('에러 발생 시 예외를 전파한다', () async {
      mockDio.mockError = DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionError,
      );

      expect(
        () => service.searchAllByCategory(
          latitude: 37.5665,
          longitude: 126.9780,
          categoryGroupCode: 'FD6',
          query: '음식점',
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
  });
}
