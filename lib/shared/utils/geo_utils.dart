import 'dart:math';

class GeoUtils {
  GeoUtils._();

  static const double _earthRadiusMeters = 6371000.0;

  /// Haversine 공식으로 두 좌표 간 거리를 미터 단위로 계산한다.
  static int haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return (_earthRadiusMeters * c).round();
  }

  /// 중심 좌표와 반경(미터)으로 바운딩 박스를 계산한다.
  /// 반환: (minLat, minLng, maxLat, maxLng)
  static ({double minLat, double minLng, double maxLat, double maxLng})
      boundingBox(double lat, double lng, int radiusMeters) {
    final latDelta = radiusMeters / _earthRadiusMeters * (180 / pi);
    final lngDelta =
        radiusMeters / (_earthRadiusMeters * cos(_toRadians(lat))) * (180 / pi);
    return (
      minLat: lat - latDelta,
      minLng: lng - lngDelta,
      maxLat: lat + latDelta,
      maxLng: lng + lngDelta,
    );
  }

  /// 바운딩 박스를 rows×cols 그리드로 분할한다.
  /// 각 셀은 카카오 API rect 파라미터 형식: (x1, y1, x2, y2) = (minLng, minLat, maxLng, maxLat)
  static List<({double x1, double y1, double x2, double y2})> splitIntoGrid({
    required double minLat,
    required double minLng,
    required double maxLat,
    required double maxLng,
    int rows = 2,
    int cols = 2,
  }) {
    final latStep = (maxLat - minLat) / rows;
    final lngStep = (maxLng - minLng) / cols;
    final cells = <({double x1, double y1, double x2, double y2})>[];

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        cells.add((
          x1: minLng + lngStep * c,
          y1: minLat + latStep * r,
          x2: minLng + lngStep * (c + 1),
          y2: minLat + latStep * (r + 1),
        ));
      }
    }

    return cells;
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
}
