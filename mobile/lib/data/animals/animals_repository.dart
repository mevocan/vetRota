import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../auth/auth_storage.dart';
import '../db/app_database.dart';
import 'pregnancy_helper.dart';

// AnimalsRepository: tek kaynak Drift. Yazma islemleri her zaman
// localSyncStatus = pending olarak kaydedilir; push queue (Adim 8)
// bunlari toplayip sync/push'a gonderir.
//
// CLAUDE.md §3: ID'ler client'ta UUID v4 uretilir. Loading spinner yok —
// ekranlar Drift stream'ine baglanir, sync arkada cigner.
class AnimalsRepository {
  AnimalsRepository(this._db, this._storage);

  final AppDatabase _db;
  final AuthStorage _storage;
  static const _uuid = Uuid();

  Stream<List<AnimalRow>> watchAll() {
    return (_db.select(_db.animals)
          ..where((a) => a.deletedLocal.equals(false))
          ..orderBy([
            (a) => OrderingTerm(
                  expression: a.localUpdatedAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  Future<AnimalRow> create({
    required String farmerId,
    required String species,
    String? name,
    String? earTag,
    String? breed,
    String? gender,
    double? weightKg,
    String? villageId,
    String? notes,
  }) async {
    final clinicId = await _storage.readClinicId();
    final deviceId = await _storage.ensureDeviceId();
    final id = _uuid.v4();
    final now = DateTime.now();

    final companion = AnimalsCompanion.insert(
      id: id,
      farmerId: farmerId,
      species: species,
      name: Value(name),
      earTag: Value(earTag),
      breed: Value(breed),
      gender: Value(gender),
      weightKg: Value(weightKg),
      villageId: Value(villageId),
      notes: Value(notes),
      // Sync kolonlari: yeni kayit version=0, push'tan sonra server 1'e
      // cevirir; localSyncStatus=pending => push queue toplayacak.
      version: const Value(0),
      lastModifiedAt: Value(now),
      originDeviceId: Value(deviceId),
      clinicId: Value(clinicId),
      localSyncStatus: const Value(LocalSyncStatus.pending),
      localUpdatedAt: Value(now),
    );

    await _db.into(_db.animals).insert(companion);
    return (await (_db.select(_db.animals)
              ..where((a) => a.id.equals(id)))
            .getSingle());
  }

  Stream<AnimalRow?> watchById(String id) {
    return (_db.select(_db.animals)..where((a) => a.id.equals(id)))
        .watchSingleOrNull();
  }

  // Bir ciftciye ait tum (silinmemis) hayvanlar — randevu/muayene
  // formlarinda animal picker icin.
  Stream<List<AnimalRow>> watchByFarmer(String farmerId) {
    return (_db.select(_db.animals)
          ..where((a) =>
              a.farmerId.equals(farmerId) & a.deletedLocal.equals(false))
          ..orderBy([
            (a) => OrderingTerm(expression: a.name),
            (a) => OrderingTerm(expression: a.earTag),
          ]))
        .watch();
  }

  // Yaklasan dogumlar: expected_birth_date bugun + [windowDays] icinde olan
  // gebe hayvanlar (status='alive').
  Stream<List<AnimalRow>> watchUpcomingBirths({int windowDays = 30}) {
    final until = DateTime.now().add(Duration(days: windowDays));
    return (_db.select(_db.animals)
          ..where((a) =>
              a.deletedLocal.equals(false) &
              a.isPregnant.equals(true) &
              a.expectedBirthDate.isNotNull() &
              a.expectedBirthDate.isSmallerOrEqualValue(until))
          ..orderBy([
            (a) => OrderingTerm(expression: a.expectedBirthDate),
          ]))
        .watch();
  }

  // Gebelik durumunu degistir. pending olarak isaretler — sync push edecek.
  // species verilmezse mevcut Drift kaydindan okur (expected_birth_date
  // hesaplamak icin gerekli).
  Future<void> setPregnancy({
    required String animalId,
    required bool isPregnant,
    DateTime? startedAt,
    String? notes,
  }) async {
    final deviceId = await _storage.ensureDeviceId();
    final now = DateTime.now();

    DateTime? expected;
    String? notesValue;
    DateTime? startedValue;

    if (isPregnant) {
      final row = await (_db.select(_db.animals)
            ..where((a) => a.id.equals(animalId)))
          .getSingleOrNull();
      if (row == null) return;
      startedValue = startedAt ?? DateTime.now();
      expected = PregnancyHelper.calculateBirthDate(row.species, startedValue);
      notesValue = notes;
    }

    await (_db.update(_db.animals)..where((a) => a.id.equals(animalId)))
        .write(AnimalsCompanion(
      isPregnant: Value(isPregnant),
      pregnancyStartedAt: Value(startedValue),
      expectedBirthDate: Value(expected),
      pregnancyNotes: Value(notesValue),
      lastModifiedAt: Value(now),
      originDeviceId: Value(deviceId),
      localSyncStatus: const Value(LocalSyncStatus.pending),
      localUpdatedAt: Value(now),
    ));
  }
}

final animalsRepositoryProvider = Provider<AnimalsRepository>((ref) {
  return AnimalsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(authStorageProvider),
  );
});

// Liste ekrani icin stream — Drift kayit degisikliklerinde otomatik tetiklenir.
final animalsListProvider = StreamProvider<List<AnimalRow>>((ref) {
  return ref.watch(animalsRepositoryProvider).watchAll();
});

// Yaklasan dogumlar (30 gun) — UI rozeti + alt liste icin.
final upcomingBirthsProvider = StreamProvider<List<AnimalRow>>((ref) {
  return ref.watch(animalsRepositoryProvider).watchUpcomingBirths();
});

// Tek hayvan stream — detay sayfasi gebelik degisikligini canli gormesi icin.
final animalByIdProvider = StreamProvider.family<AnimalRow?, String>((ref, id) {
  return ref.watch(animalsRepositoryProvider).watchById(id);
});

// Bir ciftciye ait hayvanlar — randevu/muayene picker'lari.
final animalsByFarmerProvider =
    StreamProvider.family<List<AnimalRow>, String>((ref, farmerId) {
  return ref.watch(animalsRepositoryProvider).watchByFarmer(farmerId);
});
