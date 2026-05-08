import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

// M5.6: Nearest-neighbor (greedy) rota optimizasyonu.
// 10-15 koy icin O(N^2) yeter; TSP solver gereksiz.
// Mesafe: Haversine (kus ucusu km).

class OptimizedStop {
  const OptimizedStop({
    required this.original,
    required this.distanceFromPrevKm,
  });
  final LatLng original;
  final double distanceFromPrevKm;
}

class OptimizedRoute {
  const OptimizedRoute({
    required this.stops,
    required this.totalDistanceKm,
  });
  final List<OptimizedStop> stops;
  final double totalDistanceKm;
}

// Haversine: iki nokta arasi buyuk cember mesafesi (km).
double distanceKm(LatLng a, LatLng b) {
  const earthRadiusKm = 6371.0;
  final lat1 = _deg2rad(a.latitude);
  final lat2 = _deg2rad(b.latitude);
  final dLat = _deg2rad(b.latitude - a.latitude);
  final dLng = _deg2rad(b.longitude - a.longitude);
  final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) * math.cos(lat2) *
          math.sin(dLng / 2) * math.sin(dLng / 2);
  final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  return earthRadiusKm * c;
}

double _deg2rad(double d) => d * math.pi / 180;

// Nearest-neighbor: start'tan baslayip her adimda en yakin ziyaret edilmemis
// noktayi seclar. Girdideki sira korunmaz; cikistaki sira optimize edilmis
// sequence'tir.
OptimizedRoute nearestNeighbor({
  required LatLng start,
  required List<LatLng> points,
}) {
  if (points.isEmpty) {
    return const OptimizedRoute(stops: [], totalDistanceKm: 0);
  }

  final remaining = List<LatLng>.from(points);
  final stops = <OptimizedStop>[];
  var current = start;
  var total = 0.0;

  while (remaining.isNotEmpty) {
    var bestIdx = 0;
    var bestDist = distanceKm(current, remaining[0]);
    for (var i = 1; i < remaining.length; i++) {
      final d = distanceKm(current, remaining[i]);
      if (d < bestDist) {
        bestDist = d;
        bestIdx = i;
      }
    }
    final next = remaining.removeAt(bestIdx);
    stops.add(OptimizedStop(original: next, distanceFromPrevKm: bestDist));
    total += bestDist;
    current = next;
  }

  return OptimizedRoute(stops: stops, totalDistanceKm: total);
}
