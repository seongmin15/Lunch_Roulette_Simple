import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:lunch_roulette_app/models/restaurant.dart';
import 'package:lunch_roulette_app/shared/utils/geo_utils.dart';

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
    final response = await _searchRaw(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      page: page,
      size: size,
      sort: sort,
      query: query,
      categoryGroupCode: categoryGroupCode,
    );

    final documents = response['documents'] as List<dynamic>? ?? [];
    return documents
        .map((doc) => Restaurant.fromJson(doc as Map<String, dynamic>))
        .toList();
  }

  /// Fetches all results for a single category code using auto-pagination.
  ///
  /// 1. Calls page=1 to get meta.is_end and meta.pageable_count
  /// 2. If is_end=false, fires parallel calls for remaining pages
  /// 3. Deduplicates by ID and sorts by distance
  Future<List<Restaurant>> searchAllByCategory({
    required double latitude,
    required double longitude,
    required String categoryGroupCode,
    required String query,
    int radius = 1000,
    int size = 15,
  }) async {
    // Step 1: fetch page 1 to get meta
    final firstResponse = await _searchRaw(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      page: 1,
      size: size,
      query: query,
      categoryGroupCode: categoryGroupCode,
    );

    final firstDocuments =
        firstResponse['documents'] as List<dynamic>? ?? [];
    final meta = firstResponse['meta'] as Map<String, dynamic>? ?? {};
    final isEnd = meta['is_end'] as bool? ?? true;
    final pageableCount = meta['pageable_count'] as int? ?? 0;

    final allDocuments = List<Map<String, dynamic>>.from(
      firstDocuments.cast<Map<String, dynamic>>(),
    );

    // Step 2: fetch remaining pages in parallel if needed
    if (!isEnd && pageableCount > size) {
      final totalPages = min((pageableCount / size).ceil(), 45);
      final futures = <Future<Map<String, dynamic>>>[];
      for (int page = 2; page <= totalPages; page++) {
        futures.add(_searchRaw(
          latitude: latitude,
          longitude: longitude,
          radius: radius,
          page: page,
          size: size,
          query: query,
          categoryGroupCode: categoryGroupCode,
        ));
      }

      final responses = await Future.wait(futures);
      for (final response in responses) {
        final documents = response['documents'] as List<dynamic>? ?? [];
        allDocuments.addAll(documents.cast<Map<String, dynamic>>());
      }
    }

    // Step 3: deduplicate by ID and sort by distance
    final seen = <String>{};
    final deduplicated = <Restaurant>[];
    for (final doc in allDocuments) {
      final restaurant = Restaurant.fromJson(doc);
      if (seen.add(restaurant.id)) {
        deduplicated.add(restaurant);
      }
    }

    deduplicated.sort((a, b) => a.distance.compareTo(b.distance));
    return deduplicated;
  }

  /// 2×2 그리드 분할 카테고리 검색으로 45건 제한을 우회한다.
  ///
  /// 1. boundingBox → 2×2 grid 분할
  /// 2. 4셀 병렬 호출 (내부 페이지네이션)
  /// 3. ID 중복 제거
  /// 4. Haversine으로 distance 계산
  /// 5. radius 원 밖 필터링 (사각형→원)
  /// 6. 거리순 정렬
  Future<List<Restaurant>> searchByCategoryGrid({
    required double latitude,
    required double longitude,
    required String categoryGroupCode,
    int radius = 1000,
    int size = 15,
  }) async {
    final bbox = GeoUtils.boundingBox(latitude, longitude, radius);
    final cells = GeoUtils.splitIntoGrid(
      minLat: bbox.minLat,
      minLng: bbox.minLng,
      maxLat: bbox.maxLat,
      maxLng: bbox.maxLng,
    );

    // 4셀 병렬 호출
    final cellResults = await Future.wait(
      cells.map((cell) => _paginateCell(
            categoryGroupCode: categoryGroupCode,
            rect: '${cell.x1},${cell.y1},${cell.x2},${cell.y2}',
            size: size,
          )),
    );

    // 결과 병합 및 ID 중복 제거
    final seen = <String>{};
    final deduplicated = <Restaurant>[];
    for (final docs in cellResults) {
      for (final doc in docs) {
        final restaurant = Restaurant.fromJson(doc);
        if (seen.add(restaurant.id)) {
          // Haversine으로 distance 계산
          final dist = GeoUtils.haversineDistance(
            latitude,
            longitude,
            restaurant.latitude,
            restaurant.longitude,
          );
          deduplicated.add(restaurant.copyWith(distance: dist));
        }
      }
    }

    // radius 원 밖 필터링 (사각형→원)
    final withinRadius =
        deduplicated.where((r) => r.distance <= radius).toList();

    // 거리순 정렬
    withinRadius.sort((a, b) => a.distance.compareTo(b.distance));
    return withinRadius;
  }

  /// 단일 셀에 대해 자동 페이지네이션으로 모든 결과를 수집한다.
  Future<List<Map<String, dynamic>>> _paginateCell({
    required String categoryGroupCode,
    required String rect,
    int size = 15,
  }) async {
    final firstResponse = await _categorySearchRaw(
      categoryGroupCode: categoryGroupCode,
      rect: rect,
      page: 1,
      size: size,
    );

    final firstDocs = firstResponse['documents'] as List<dynamic>? ?? [];
    final meta = firstResponse['meta'] as Map<String, dynamic>? ?? {};
    final isEnd = meta['is_end'] as bool? ?? true;
    final pageableCount = meta['pageable_count'] as int? ?? 0;

    final allDocs = List<Map<String, dynamic>>.from(
      firstDocs.cast<Map<String, dynamic>>(),
    );

    if (!isEnd && pageableCount > size) {
      final totalPages = min((pageableCount / size).ceil(), 3);
      final futures = <Future<Map<String, dynamic>>>[];
      for (int page = 2; page <= totalPages; page++) {
        futures.add(_categorySearchRaw(
          categoryGroupCode: categoryGroupCode,
          rect: rect,
          page: page,
          size: size,
        ));
      }

      final responses = await Future.wait(futures);
      for (final response in responses) {
        final docs = response['documents'] as List<dynamic>? ?? [];
        allDocs.addAll(docs.cast<Map<String, dynamic>>());
      }
    }

    return allDocs;
  }

  /// Category search endpoint 호출 (rect 파라미터 사용)
  Future<Map<String, dynamic>> _categorySearchRaw({
    required String categoryGroupCode,
    required String rect,
    required int page,
    required int size,
  }) async {
    final apiKey = dotenv.env['KAKAO_REST_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('KAKAO_REST_API_KEY가 설정되지 않았습니다.');
    }

    try {
      final response = await _dio.get(
        'https://dapi.kakao.com/v2/local/search/category.json',
        options: Options(
          headers: {'Authorization': 'KakaoAK $apiKey'},
        ),
        queryParameters: {
          'category_group_code': categoryGroupCode,
          'rect': rect,
          'page': page,
          'size': size,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Raw API call that returns the full response data including meta.
  Future<Map<String, dynamic>> _searchRaw({
    required double latitude,
    required double longitude,
    required int radius,
    required int page,
    required int size,
    String sort = 'distance',
    required String query,
    required String categoryGroupCode,
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

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// DioException을 사용자 친화적인 Exception으로 변환한다.
  Never _handleDioError(DioException e) {
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
