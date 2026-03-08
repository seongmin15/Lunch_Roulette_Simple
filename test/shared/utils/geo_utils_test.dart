import 'package:flutter_test/flutter_test.dart';
import 'package:lunch_roulette_app/shared/utils/geo_utils.dart';

void main() {
  group('GeoUtils.haversineDistance', () {
    test('동일 좌표 간 거리는 0이다', () {
      final distance = GeoUtils.haversineDistance(37.5665, 126.978, 37.5665, 126.978);
      expect(distance, 0);
    });

    test('서울시청-강남역 간 거리를 정확히 계산한다 (약 8.9km)', () {
      // 서울시청: 37.5665, 126.978
      // 강남역: 37.4979, 127.0276
      final distance = GeoUtils.haversineDistance(
        37.5665, 126.978, 37.4979, 127.0276,
      );
      // 약 8.9km, 오차 범위 ±500m
      expect(distance, greaterThan(8400));
      expect(distance, lessThan(9400));
    });

    test('짧은 거리(1km 이내)도 정확히 계산한다', () {
      // 약 111m 차이 (위도 0.001도)
      final distance = GeoUtils.haversineDistance(
        37.5665, 126.978, 37.5675, 126.978,
      );
      expect(distance, greaterThan(100));
      expect(distance, lessThan(120));
    });
  });

  group('GeoUtils.boundingBox', () {
    test('1000m 반경 바운딩 박스를 올바르게 생성한다', () {
      final bbox = GeoUtils.boundingBox(37.5665, 126.978, 1000);

      expect(bbox.minLat, lessThan(37.5665));
      expect(bbox.maxLat, greaterThan(37.5665));
      expect(bbox.minLng, lessThan(126.978));
      expect(bbox.maxLng, greaterThan(126.978));

      // 대칭 확인
      expect(
        (37.5665 - bbox.minLat).abs(),
        closeTo((bbox.maxLat - 37.5665).abs(), 0.0001),
      );
    });

    test('반경이 클수록 바운딩 박스도 커진다', () {
      final small = GeoUtils.boundingBox(37.5665, 126.978, 500);
      final large = GeoUtils.boundingBox(37.5665, 126.978, 2000);

      expect(large.maxLat - large.minLat, greaterThan(small.maxLat - small.minLat));
      expect(large.maxLng - large.minLng, greaterThan(small.maxLng - small.minLng));
    });

    test('바운딩 박스 꼭짓점까지 거리가 반경과 유사하다', () {
      final bbox = GeoUtils.boundingBox(37.5665, 126.978, 1000);

      // 위쪽 중심까지 거리
      final topDist = GeoUtils.haversineDistance(
        37.5665, 126.978, bbox.maxLat, 126.978,
      );
      expect(topDist, closeTo(1000, 50));
    });
  });

  group('GeoUtils.splitIntoGrid', () {
    test('2×2 그리드는 4개 셀을 반환한다', () {
      final cells = GeoUtils.splitIntoGrid(
        minLat: 37.0,
        minLng: 126.0,
        maxLat: 38.0,
        maxLng: 127.0,
      );

      expect(cells.length, 4);
    });

    test('셀이 전체 영역을 빈틈없이 커버한다', () {
      final cells = GeoUtils.splitIntoGrid(
        minLat: 37.0,
        minLng: 126.0,
        maxLat: 38.0,
        maxLng: 127.0,
      );

      // 좌하단 셀
      expect(cells[0].x1, 126.0);
      expect(cells[0].y1, 37.0);
      expect(cells[0].x2, 126.5);
      expect(cells[0].y2, 37.5);

      // 우하단 셀
      expect(cells[1].x1, 126.5);
      expect(cells[1].y1, 37.0);
      expect(cells[1].x2, 127.0);
      expect(cells[1].y2, 37.5);

      // 좌상단 셀
      expect(cells[2].x1, 126.0);
      expect(cells[2].y1, 37.5);
      expect(cells[2].x2, 126.5);
      expect(cells[2].y2, 38.0);

      // 우상단 셀
      expect(cells[3].x1, 126.5);
      expect(cells[3].y1, 37.5);
      expect(cells[3].x2, 127.0);
      expect(cells[3].y2, 38.0);
    });

    test('3×3 그리드는 9개 셀을 반환한다', () {
      final cells = GeoUtils.splitIntoGrid(
        minLat: 37.0,
        minLng: 126.0,
        maxLat: 38.0,
        maxLng: 127.0,
        rows: 3,
        cols: 3,
      );

      expect(cells.length, 9);
    });
  });
}
