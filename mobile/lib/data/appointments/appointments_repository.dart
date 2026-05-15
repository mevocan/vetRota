import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../auth/auth_storage.dart';
import '../db/app_database.dart';

// M5.5 + M9.4: Bugunun randevulari + tum randevu yonetimi.
// Offline-first: yazma islemleri Drift'e dusurulur, sync push gonderir.
// Drift sema su an minimal — backend'in appointment_type ve
// estimated_duration_minutes alanlari sync edilmiyor; UI'da gosterilmiyor.

class AppointmentWithMeta {
  AppointmentWithMeta({
    required this.row,
    this.animalName,
    this.animalEarTag,
    this.animalSpecies,
    this.farmerName,
    this.villageName,
    this.lat,
    this.lng,
  });

  final AppointmentRow row;
  final String? animalName;
  final String? animalEarTag;
  final String? animalSpecies;
  final String? farmerName;
  final String? villageName;
  final double? lat;
  final double? lng;

  bool get hasGeo => lat != null && lng != null;

  String get title {
    if (animalName != null && animalName!.isNotEmpty) return animalName!;
    if (animalEarTag != null && animalEarTag!.isNotEmpty) {
      return 'Kupe ${animalEarTag!}';
    }
    if (animalSpecies != null && animalSpecies!.isNotEmpty) {
      return animalSpecies!;
    }
    return 'Randevu';
  }

  String get subtitle {
    final parts = <String>[
      if (farmerName != null && farmerName!.isNotEmpty) farmerName!,
      if (villageName != null && villageName!.isNotEmpty) villageName!,
    ];
    return parts.join(' • ');
  }
}

class AppointmentsRepository {
  AppointmentsRepository(this._db, this._storage);

  final AppDatabase _db;
  final AuthStorage _storage;
  static const _uuid = Uuid();

  Stream<List<AppointmentWithMeta>> watchToday() {
    final start = _dayStart(DateTime.now());
    final end = start.add(const Duration(days: 1));
    return _watchRange(start, end);
  }

  // Yaklasan: bugun -> sonsuza kadar (gelecek + bugunki).
  Stream<List<AppointmentWithMeta>> watchUpcoming() {
    final start = _dayStart(DateTime.now());
    final end = start.add(const Duration(days: 365 * 5));
    return _watchRange(start, end);
  }

  // Gecmis: bugunden once.
  Stream<List<AppointmentWithMeta>> watchPast() {
    final end = _dayStart(DateTime.now());
    final start = end.subtract(const Duration(days: 365 * 5));
    return _watchRange(start, end, descending: true);
  }

  Stream<AppointmentWithMeta?> watchById(String id) {
    final query = _db.select(_db.appointments).join([
      leftOuterJoin(_db.animals,
          _db.animals.id.equalsExp(_db.appointments.animalId)),
      leftOuterJoin(_db.farmers,
          _db.farmers.id.equalsExp(_db.appointments.farmerId)),
      leftOuterJoin(_db.villages,
          _db.villages.id.equalsExp(_db.appointments.villageId)),
    ])
      ..where(_db.appointments.id.equals(id));

    return query.watchSingleOrNull().asyncMap((row) async {
      if (row == null) return null;
      final appt = row.readTable(_db.appointments);
      final animal = row.readTableOrNull(_db.animals);
      final farmer = row.readTableOrNull(_db.farmers);
      var village = row.readTableOrNull(_db.villages);
      if (village == null && animal?.villageId != null) {
        village = await (_db.select(_db.villages)
              ..where((v) => v.id.equals(animal!.villageId!)))
            .getSingleOrNull();
      }
      return AppointmentWithMeta(
        row: appt,
        animalName: animal?.name,
        animalEarTag: animal?.earTag,
        animalSpecies: animal?.species,
        farmerName: farmer == null
            ? null
            : '${farmer.firstName} ${farmer.lastName}'.trim(),
        villageName: village?.name,
        lat: village?.lat,
        lng: village?.lng,
      );
    });
  }

  Stream<List<AppointmentWithMeta>> _watchRange(
    DateTime start,
    DateTime end, {
    bool descending = false,
  }) {
    final query = _db.select(_db.appointments).join([
      leftOuterJoin(_db.animals,
          _db.animals.id.equalsExp(_db.appointments.animalId)),
      leftOuterJoin(_db.farmers,
          _db.farmers.id.equalsExp(_db.appointments.farmerId)),
      leftOuterJoin(_db.villages,
          _db.villages.id.equalsExp(_db.appointments.villageId)),
    ])
      ..where(_db.appointments.scheduledAt.isBetweenValues(start, end) &
          _db.appointments.deletedLocal.equals(false))
      ..orderBy([
        OrderingTerm(
          expression: _db.appointments.scheduledAt,
          mode: descending ? OrderingMode.desc : OrderingMode.asc,
        ),
      ]);

    return query.watch().asyncMap((rows) async {
      final missingVillageAnimalIds = <String>{};
      for (final r in rows) {
        final apptVillage = r.readTableOrNull(_db.villages);
        final animal = r.readTableOrNull(_db.animals);
        if (apptVillage == null && animal?.villageId != null) {
          missingVillageAnimalIds.add(animal!.villageId!);
        }
      }
      Map<String, VillageRow> villageById = const {};
      if (missingVillageAnimalIds.isNotEmpty) {
        final villages = await (_db.select(_db.villages)
              ..where((v) => v.id.isIn(missingVillageAnimalIds)))
            .get();
        villageById = {for (final v in villages) v.id: v};
      }

      return rows.map((r) {
        final appt = r.readTable(_db.appointments);
        final animal = r.readTableOrNull(_db.animals);
        final farmer = r.readTableOrNull(_db.farmers);
        var village = r.readTableOrNull(_db.villages);
        if (village == null && animal?.villageId != null) {
          village = villageById[animal!.villageId!];
        }
        return AppointmentWithMeta(
          row: appt,
          animalName: animal?.name,
          animalEarTag: animal?.earTag,
          animalSpecies: animal?.species,
          farmerName: farmer == null
              ? null
              : '${farmer.firstName} ${farmer.lastName}'.trim(),
          villageName: village?.name,
          lat: village?.lat,
          lng: village?.lng,
        );
      }).toList();
    });
  }

  Future<AppointmentRow> create({
    required String farmerId,
    String? animalId,
    String? villageId,
    required DateTime scheduledAt,
    String? reason,
    String status = 'scheduled',
  }) async {
    final clinicId = await _storage.readClinicId();
    final deviceId = await _storage.ensureDeviceId();
    final id = _uuid.v4();
    final now = DateTime.now();

    await _db.into(_db.appointments).insert(AppointmentsCompanion.insert(
          id: id,
          farmerId: Value(farmerId),
          animalId: Value(animalId),
          villageId: Value(villageId),
          scheduledAt: scheduledAt,
          reason: Value(reason),
          status: Value(status),
          version: const Value(0),
          lastModifiedAt: Value(now),
          originDeviceId: Value(deviceId),
          clinicId: Value(clinicId),
          localSyncStatus: const Value(LocalSyncStatus.pending),
          localUpdatedAt: Value(now),
        ));
    return (_db.select(_db.appointments)..where((a) => a.id.equals(id)))
        .getSingle();
  }

  Future<void> update({
    required String id,
    String? farmerId,
    String? animalId,
    String? villageId,
    DateTime? scheduledAt,
    String? reason,
    String? status,
  }) async {
    final deviceId = await _storage.ensureDeviceId();
    final now = DateTime.now();
    await (_db.update(_db.appointments)..where((a) => a.id.equals(id)))
        .write(AppointmentsCompanion(
      farmerId: farmerId == null ? const Value.absent() : Value(farmerId),
      animalId: animalId == null ? const Value.absent() : Value(animalId),
      villageId: villageId == null ? const Value.absent() : Value(villageId),
      scheduledAt:
          scheduledAt == null ? const Value.absent() : Value(scheduledAt),
      reason: reason == null ? const Value.absent() : Value(reason),
      status: status == null ? const Value.absent() : Value(status),
      lastModifiedAt: Value(now),
      originDeviceId: Value(deviceId),
      localSyncStatus: const Value(LocalSyncStatus.pending),
      localUpdatedAt: Value(now),
    ));
  }

  Future<void> setStatus(String appointmentId, String status) async {
    await update(id: appointmentId, status: status);
  }

  Future<void> markCompleted(String appointmentId) async {
    await setStatus(appointmentId, 'completed');
  }

  Future<void> softDelete(String id) async {
    final deviceId = await _storage.ensureDeviceId();
    final now = DateTime.now();
    await (_db.update(_db.appointments)..where((a) => a.id.equals(id)))
        .write(AppointmentsCompanion(
      deletedLocal: const Value(true),
      lastModifiedAt: Value(now),
      originDeviceId: Value(deviceId),
      localSyncStatus: const Value(LocalSyncStatus.pending),
      localUpdatedAt: Value(now),
    ));
  }

  DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);
}

final appointmentsRepositoryProvider =
    Provider<AppointmentsRepository>((ref) {
  return AppointmentsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(authStorageProvider),
  );
});

final todayAppointmentsProvider =
    StreamProvider<List<AppointmentWithMeta>>((ref) {
  return ref.watch(appointmentsRepositoryProvider).watchToday();
});

final upcomingAppointmentsProvider =
    StreamProvider<List<AppointmentWithMeta>>((ref) {
  return ref.watch(appointmentsRepositoryProvider).watchUpcoming();
});

final pastAppointmentsProvider =
    StreamProvider<List<AppointmentWithMeta>>((ref) {
  return ref.watch(appointmentsRepositoryProvider).watchPast();
});

final appointmentByIdProvider =
    StreamProvider.family<AppointmentWithMeta?, String>((ref, id) {
  return ref.watch(appointmentsRepositoryProvider).watchById(id);
});
