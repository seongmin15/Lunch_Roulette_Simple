import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:lunch_roulette_app/models/restaurant.dart';

class RestaurantService {
  final Dio _dio;

  RestaurantService(this._dio);

  Future<List<Restaurant>> searchNearbyRestaurants({
    required double latitude,
    required double longitude,
    int radius = 2000,
    int page = 1,
    int size = 15,
    String sort = 'distance',
    String query = '식당',
    String categoryGroupCode = 'FD6',
  }) async {
    final apiKey = dotenv.env['KAKAO_REST_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('KAKAO_REST_API_KEY가 설정되지 않았습니다.');
    }

    try {
      final response = await _dio.get(
        'https://dapi.kakao.com/v2/local/search/keyword.json',
        options: Options(
          headers: {'Authorization': 'KakaoAK $apiKey'},
        ),
        queryParameters: {
          'query': query,
          'category_group_code': categoryGroupCode,
          'x': longitude.toString(),
          'y': latitude.toString(),
          'radius': radius,
          'page': page,
          'size': size,
          'sort': sort,
        },
      );

      final documents = response.data['documents'] as List<dynamic>? ?? [];
      return documents
          .map((doc) => Restaurant.fromJson(doc as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw Exception('서버 응답 시간이 초과되었습니다. 다시 시도해 주세요.');
        case DioExceptionType.connectionError:
          throw Exception('네트워크 연결을 확인해 주세요.');
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          if (statusCode == 401) {
            throw Exception('API 키가 유효하지 않습니다.');
          }
          throw Exception('서버 오류가 발생했습니다. (코드: $statusCode)');
        default:
          throw Exception('식당 검색 중 오류가 발생했습니다.');
      }
    }
  }

  Future<List<Restaurant>> searchByAllCategories({
    required double latitude,
    required double longitude,
    required Map<String, String> keywordToCategoryCode,
    int radius = 2000,
  }) async {
    final results = await Future.wait(
      keywordToCategoryCode.entries.map((entry) => searchNearbyRestaurants(
            latitude: latitude,
            longitude: longitude,
            radius: radius,
            query: entry.key,
            categoryGroupCode: entry.value,
          )),
    );

    final seen = <String>{};
    final deduplicated = <Restaurant>[];
    for (final list in results) {
      for (final restaurant in list) {
        if (seen.add(restaurant.id)) {
          deduplicated.add(restaurant);
        }
      }
    }

    deduplicated.sort((a, b) => a.distance.compareTo(b.distance));
    return deduplicated;
  }
}
