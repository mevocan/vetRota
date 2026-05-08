import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_storage.dart';
import '../db/app_database.dart';

// M5.5: Bugunun randevulari + Liste/Harita ekrani icin DTO.
// Lat/lng siralamasi: appointment'in village > animal'in village > null.
// Null lat/lng olan randevular haritada gosterilmez ama listede vardir.
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
  // ignore: unused_field
  final AuthStorage _storage;

  Stream<List<AppointmentWithMeta>> watchToday() {
    final start = _dayStart(DateTime.now());
    final end = start.add(const Duration(days: 1));

    final query = _db.select(_db.appointments).join([
      leftOuterJoin(_db.animals,
          _db.animals.id.equalsExp(_db.appointments.animalId)),
      leftOuterJoin(_db.farmers,
          _db.farmers.id.equalsExp(_db.appointments.farmerId)),
      // Once appointment.villageId, yoksa animal.villageId — UI tarafinda
      // coalesce edecegiz.
      leftOuterJoin(_db.villages,
          _db.villages.id.equalsExp(_db.appointments.villageId)),
    ])
      ..where(_db.appointments.scheduledAt.isBetweenValues(start, end) &
          _db.appointments.deletedLocal.equals(false))
      ..orderBy([
        OrderingTerm(expression: _db.appointments.scheduledAt),
      ]);

    return query.watch().asyncMap((rows) async {
      // Animal'in village'ini ek bir lookup ile cek (appointment village'i
      // null oldugunda fallback).
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

  Future<void> markCompleted(String appointmentId) async {
    final deviceId = await _storage.ensureDeviceId();
    final now = DateTime.now();
    await (_db.update(_db.appointments)
          ..where((a) => a.id.equals(appointmentId)))
        .write(AppointmentsCompanion(
      status: const Value('completed'),
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
