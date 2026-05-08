import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../auth/auth_storage.dart';
import '../db/app_database.dart';

// RoutesRepository: gunluk optimize rotanin lokal yazimi.
// Optimize butonu basildiginda mevcut tarihteki route silinir
// (soft-delete) ve yenisi yazilir. UNIQUE(vet_id, date) — bir gun
// tek route.
class RoutesRepository {
  RoutesRepository(this._db, this._storage);

  final AppDatabase _db;
  final AuthStorage _storage;
  static const _uuid = Uuid();

  Stream<RouteRow?> watchToday() {
    final today = _dayStart(DateTime.now());
    return (_db.select(_db.routes)
          ..where((r) =>
              r.date.equals(today) & r.deletedLocal.equals(false))
          ..limit(1))
        .watchSingleOrNull();
  }

  Stream<List<RouteStopRow>> watchStops(String routeId) {
    return (_db.select(_db.routeStops)
          ..where((s) =>
              s.routeId.equals(routeId) & s.deletedLocal.equals(false))
          ..orderBy([(s) => OrderingTerm(expression: s.sequence)]))
        .watch();
  }

  // Onceden bu gun icin route varsa soft-delete eder, yeni route ve
  // stop'lari yazar. Tum yazim tek transaction.
  Future<RouteRow> replaceTodayRoute({
    required int vetId,
    required double startLat,
    required double startLng,
    required List<({String? appointmentId, double lat, double lng, double distFromPrevKm})> stops,
    required double totalDistanceKm,
  }) async {
    final clinicId = await _storage.readClinicId();
    final deviceId = await _storage.ensureDeviceId();
    final today = _dayStart(DateTime.now());
    final now = DateTime.now();

    return _db.transaction(() async {
      // Eski route'u soft-delete et + stop'lari da.
      final old = await (_db.select(_db.routes)
            ..where((r) => r.vetId.equals(vetId) & r.date.equals(today)))
          .getSingleOrNull();
      if (old != null) {
        await (_db.update(_db.routes)..where((r) => r.id.equals(old.id)))
            .write(RoutesCompanion(
          deletedLocal: const Value(true),
          lastModifiedAt: Value(now),
          originDeviceId: Value(deviceId),
          localSyncStatus: const Value(LocalSyncStatus.pending),
          localUpdatedAt: Value(now),
        ));
        await (_db.update(_db.routeStops)
              ..where((s) => s.routeId.equals(old.id)))
            .write(RouteStopsCompanion(
          deletedLocal: const Value(true),
          lastModifiedAt: Value(now),
          originDeviceId: Value(deviceId),
          localSyncStatus: const Value(LocalSyncStatus.pending),
          localUpdatedAt: Value(now),
        ));
      }

      final routeId = _uuid.v4();
      await _db.into(_db.routes).insert(RoutesCompanion.insert(
            id: routeId,
            vetId: vetId,
            date: today,
            startLat: Value(startLat),
            startLng: Value(startLng),
            totalDistanceKm: Value(totalDistanceKm),
            version: const Value(0),
            lastModifiedAt: Value(now),
            originDeviceId: Value(deviceId),
            clinicId: Value(clinicId),
            localSyncStatus: const Value(LocalSyncStatus.pending),
            localUpdatedAt: Value(now),
          ));

      var seq = 1;
      for (final s in stops) {
        await _db.into(_db.routeStops).insert(RouteStopsCompanion.insert(
              id: _uuid.v4(),
              routeId: routeId,
              appointmentId: Value(s.appointmentId),
              sequence: seq++,
              lat: s.lat,
              lng: s.lng,
              distanceFromPrevKm: Value(s.distFromPrevKm),
              status: const Value('pending'),
              version: const Value(0),
              lastModifiedAt: Value(now),
              originDeviceId: Value(deviceId),
              clinicId: Value(clinicId),
              localSyncStatus: const Value(LocalSyncStatus.pending),
              localUpdatedAt: Value(now),
            ));
      }

      return (await (_db.select(_db.routes)
                ..where((r) => r.id.equals(routeId)))
              .getSingle());
    });
  }

  Future<void> markStopVisited(String stopId) async {
    final now = DateTime.now();
    final deviceId = await _storage.ensureDeviceId();
    await (_db.update(_db.routeStops)..where((s) => s.id.equals(stopId)))
        .write(RouteStopsCompanion(
      status: const Value('visited'),
      visitedAt: Value(now),
      lastModifiedAt: Value(now),
      originDeviceId: Value(deviceId),
      localSyncStatus: const Value(LocalSyncStatus.pending),
      localUpdatedAt: Value(now),
    ));
  }

  DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);
}

final routesRepositoryProvider = Provider<RoutesRepository>((ref) {
  return RoutesRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(authStorageProvider),
  );
});

final todayRouteProvider = StreamProvider<RouteRow?>((ref) {
  return ref.watch(routesRepositoryProvider).watchToday();
});

final routeStopsProvider =
    StreamProvider.family<List<RouteStopRow>, String>((ref, routeId) {
  return ref.watch(routesRepositoryProvider).watchStops(routeId);
});
