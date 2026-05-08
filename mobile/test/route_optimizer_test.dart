import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:vetrota_mobile/util/route_optimizer.dart';

void main() {
  group('distanceKm (Haversine)', () {
    test('ayni nokta -> 0 km', () {
      final a = const LatLng(40.0, 30.0);
      expect(distanceKm(a, a), closeTo(0, 0.0001));
    });

    test('Ankara - Istanbul kabaca 350-400 km arasi', () {
      final ankara = const LatLng(39.9334, 32.8597);
      final istanbul = const LatLng(41.0082, 28.9784);
      final d = distanceKm(ankara, istanbul);
      expect(d, greaterThan(300));
      expect(d, lessThan(450));
    });
  });

  group('nearestNeighbor', () {
    test('bos liste -> bos route', () {
      final r = nearestNeighbor(start: const LatLng(0, 0), points: []);
      expect(r.stops, isEmpty);
      expect(r.totalDistanceKm, 0);
    });

    test('grid uzerinde sirayi optimize eder', () {
      // start (0,0), noktalar (0,1) (0,3) (0,2). Greedy sira: 1 -> 2 -> 3.
      final r = nearestNeighbor(
        start: const LatLng(0, 0),
        points: [
          const LatLng(0, 3),
          const LatLng(0, 1),
          const LatLng(0, 2),
        ],
      );
      expect(r.stops.length, 3);
      expect(r.stops[0].original.longitude, 1);
      expect(r.stops[1].original.longitude, 2);
      expect(r.stops[2].original.longitude, 3);
      expect(r.totalDistanceKm, greaterThan(0));
    });
  });
}
