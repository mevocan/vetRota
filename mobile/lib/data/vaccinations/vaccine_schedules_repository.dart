import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../auth/auth_storage.dart';
import '../db/app_database.dart';

// Asi plani + ilac kataloğu (drug) + hayvan join'li meta.
class VaccineScheduleWithMeta {
  VaccineScheduleWithMeta({
    required this.row,
    this.animalName,
    this.animalEarTag,
    this.animalSpecies,
    this.drugName,
  });
  final VaccineScheduleRow row;
  final String? animalName;
  final String? animalEarTag;
  final String? animalSpecies;
  final String? drugName;

  String get animalLabel {
    if (animalName != null && animalName!.isNotEmpty) return animalName!;
    if (animalEarTag != null && animalEarTag!.isNotEmpty) {
      return 'Kupe $animalEarTag';
    }
    return animalSpecies ?? 'Hayvan';
  }

  // next_due_date saat kismi alakasiz — gunlerle hesaplanir.
  int get daysToNext {
    final today = DateTime.now();
    final t = DateTime(today.year, today.month, today.day);
    final d = DateTime(row.nextDueDate.year, row.nextDueDate.month,
        row.nextDueDate.day);
    return d.difference(t).inDays;
  }

  bool get isDueSoon => daysToNext >= 0 && daysToNext <= row.remindDaysBefore;
  bool get isOverdue => daysToNext < 0;
}

class VaccineSchedulesRepository {
  VaccineSchedulesRepository(this._db, this._storage);

  final AppDatabase _db;
  final AuthStorage _storage;
  static const _uuid = Uuid();

  Stream<List<VaccineScheduleWithMeta>> watchAllWithMeta(
      {bool onlyActive = true}) {
    var q = _db.select(_db.vaccineSchedules).join([
      leftOuterJoin(_db.animals,
          _db.animals.id.equalsExp(_db.vaccineSchedules.animalId)),
      leftOuterJoin(
          _db.drugs, _db.drugs.id.equalsExp(_db.vaccineSchedules.drugId)),
    ])
      ..where(_db.vaccineSchedules.deletedLocal.equals(false))
      ..orderBy([
        OrderingTerm(expression: _db.vaccineSchedules.nextDueDate),
      ]);
    if (onlyActive) {
      q = q
        ..where(_db.vaccineSchedules.isActive.equals(true));
    }
    return q.watch().map((rows) => rows.map((r) {
          final vs = r.readTable(_db.vaccineSchedules);
          final a = r.readTableOrNull(_db.animals);
          final d = r.readTableOrNull(_db.drugs);
          return VaccineScheduleWithMeta(
            row: vs,
            animalName: a?.name,
            animalEarTag: a?.earTag,
            animalSpecies: a?.species,
            drugName: d?.name,
          );
        }).toList());
  }

  Stream<List<VaccineScheduleWithMeta>> watchByAnimal(String animalId) {
    final q = _db.select(_db.vaccineSchedules).join([
      leftOuterJoin(_db.animals,
          _db.animals.id.equalsExp(_db.vaccineSchedules.animalId)),
      leftOuterJoin(
          _db.drugs, _db.drugs.id.equalsExp(_db.vaccineSchedules.drugId)),
    ])
      ..where(_db.vaccineSchedules.animalId.equals(animalId) &
          _db.vaccineSchedules.deletedLocal.equals(false))
      ..orderBy([
        OrderingTerm(expression: _db.vaccineSchedules.nextDueDate),
      ]);
    return q.watch().map((rows) => rows.map((r) {
          final vs = r.readTable(_db.vaccineSchedules);
          final a = r.readTableOrNull(_db.animals);
          final d = r.readTableOrNull(_db.drugs);
          return VaccineScheduleWithMeta(
            row: vs,
            animalName: a?.name,
            animalEarTag: a?.earTag,
            animalSpecies: a?.species,
            drugName: d?.name,
          );
        }).toList());
  }

  Future<VaccineScheduleRow> create({
    required String animalId,
    required String drugId,
    required int intervalDays,
    required DateTime firstDueDate,
    int remindDaysBefore = 7,
    String? notes,
  }) async {
    final clinicId = await _storage.readClinicId();
    final deviceId = await _storage.ensureDeviceId();
    final id = _uuid.v4();
    final now = DateTime.now();

    await _db.into(_db.vaccineSchedules).insert(
          VaccineSchedulesCompanion.insert(
            id: id,
            animalId: animalId,
            drugId: drugId,
            intervalDays: intervalDays,
            firstDueDate: firstDueDate,
            nextDueDate: firstDueDate,
            remindDaysBefore: Value(remindDaysBefore),
            isActive: const Value(true),
            notes: Value(notes),
            version: const Value(0),
            lastModifiedAt: Value(now),
            originDeviceId: Value(deviceId),
            clinicId: Value(clinicId),
            localSyncStatus: const Value(LocalSyncStatus.pending),
            localUpdatedAt: Value(now),
          ),
        );
    return (_db.select(_db.vaccineSchedules)..where((v) => v.id.equals(id)))
        .getSingle();
  }

  // Asi yapildi: last_administered_at simdi, next_due_date += interval.
  Future<void> markAdministered(String id) async {
    final deviceId = await _storage.ensureDeviceId();
    final now = DateTime.now();
    final current = await (_db.select(_db.vaccineSchedules)
          ..where((v) => v.id.equals(id)))
        .getSingleOrNull();
    if (current == null) return;
    final next = current.nextDueDate.add(
      Duration(days: current.intervalDays),
    );
    await (_db.update(_db.vaccineSchedules)..where((v) => v.id.equals(id)))
        .write(VaccineSchedulesCompanion(
      lastAdministeredAt: Value(now),
      nextDueDate: Value(next),
      lastModifiedAt: Value(now),
      originDeviceId: Value(deviceId),
      localSyncStatus: const Value(LocalSyncStatus.pending),
      localUpdatedAt: Value(now),
    ));
  }

  Future<void> setActive(String id, bool active) async {
    final deviceId = await _storage.ensureDeviceId();
    final now = DateTime.now();
    await (_db.update(_db.vaccineSchedules)..where((v) => v.id.equals(id)))
        .write(VaccineSchedulesCompanion(
      isActive: Value(active),
      lastModifiedAt: Value(now),
      originDeviceId: Value(deviceId),
      localSyncStatus: const Value(LocalSyncStatus.pending),
      localUpdatedAt: Value(now),
    ));
  }

  Future<void> softDelete(String id) async {
    final deviceId = await _storage.ensureDeviceId();
    final now = DateTime.now();
    await (_db.update(_db.vaccineSchedules)..where((v) => v.id.equals(id)))
        .write(VaccineSchedulesCompanion(
      deletedLocal: const Value(true),
      lastModifiedAt: Value(now),
      originDeviceId: Value(deviceId),
      localSyncStatus: const Value(LocalSyncStatus.pending),
      localUpdatedAt: Value(now),
    ));
  }
}

final vaccineSchedulesRepositoryProvider =
    Provider<VaccineSchedulesRepository>((ref) {
  return VaccineSchedulesRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(authStorageProvider),
  );
});

final vaccineSchedulesAllProvider =
    StreamProvider<List<VaccineScheduleWithMeta>>((ref) {
  return ref
      .watch(vaccineSchedulesRepositoryProvider)
      .watchAllWithMeta(onlyActive: true);
});

final vaccineSchedulesByAnimalProvider =
    StreamProvider.family<List<VaccineScheduleWithMeta>, String>(
        (ref, animalId) {
  return ref
      .watch(vaccineSchedulesRepositoryProvider)
      .watchByAnimal(animalId);
});

// Sadece asi olan ilaclar (drug picker icin filtre).
final vaccineDrugsProvider = StreamProvider<List<DrugRow>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.drugs)
        ..where((d) => d.deletedLocal.equals(false) & d.isVaccine.equals(true))
        ..orderBy([(d) => OrderingTerm(expression: d.name)]))
      .watch();
});
