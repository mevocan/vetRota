import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../auth/auth_storage.dart';
import '../db/app_database.dart';

// FarmersRepository: tek kaynak Drift. Yazma islemleri her zaman
// localSyncStatus=pending olarak kaydedilir; push queue gonderecek.
// CLAUDE.md §3: ID'ler client'ta UUID v4 uretilir.
class FarmersRepository {
  FarmersRepository(this._db, this._storage);

  final AppDatabase _db;
  final AuthStorage _storage;
  static const _uuid = Uuid();

  Stream<FarmerRow?> watchById(String id) {
    return (_db.select(_db.farmers)..where((f) => f.id.equals(id)))
        .watchSingleOrNull();
  }

  Stream<List<FarmerRow>> watchAll() {
    return (_db.select(_db.farmers)
          ..where((f) => f.deletedLocal.equals(false))
          ..orderBy([
            (f) => OrderingTerm(expression: f.firstName),
            (f) => OrderingTerm(expression: f.lastName),
          ]))
        .watch();
  }

  // Picker arama: ad/soyad/telefon icinde gecen.
  Stream<List<FarmerRow>> searchByQuery(String q) {
    final qq = q.trim().toLowerCase();
    if (qq.isEmpty) return watchAll();
    return (_db.select(_db.farmers)
          ..where((f) =>
              f.deletedLocal.equals(false) &
              (f.firstName.lower().like('%$qq%') |
                  f.lastName.lower().like('%$qq%') |
                  f.phone.lower().like('%$qq%')))
          ..orderBy([
            (f) => OrderingTerm(expression: f.firstName),
            (f) => OrderingTerm(expression: f.lastName),
          ]))
        .watch();
  }

  Future<FarmerRow> create({
    required String firstName,
    required String lastName,
    String? phone,
    String? email,
    String? addressDetail,
    String? villageId,
  }) async {
    final clinicId = await _storage.readClinicId();
    final deviceId = await _storage.ensureDeviceId();
    final id = _uuid.v4();
    final now = DateTime.now();

    final companion = FarmersCompanion.insert(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phone: Value(phone),
      email: Value(email),
      addressDetail: Value(addressDetail),
      villageId: Value(villageId),
      version: const Value(0),
      lastModifiedAt: Value(now),
      originDeviceId: Value(deviceId),
      clinicId: Value(clinicId),
      localSyncStatus: const Value(LocalSyncStatus.pending),
      localUpdatedAt: Value(now),
    );

    await _db.into(_db.farmers).insert(companion);
    return (_db.select(_db.farmers)..where((f) => f.id.equals(id)))
        .getSingle();
  }

  Future<void> update({
    required String id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? addressDetail,
    String? villageId,
  }) async {
    final deviceId = await _storage.ensureDeviceId();
    final now = DateTime.now();

    await (_db.update(_db.farmers)..where((f) => f.id.equals(id)))
        .write(FarmersCompanion(
      firstName: firstName == null ? const Value.absent() : Value(firstName),
      lastName: lastName == null ? const Value.absent() : Value(lastName),
      phone: phone == null ? const Value.absent() : Value(phone),
      email: email == null ? const Value.absent() : Value(email),
      addressDetail:
          addressDetail == null ? const Value.absent() : Value(addressDetail),
      villageId: villageId == null ? const Value.absent() : Value(villageId),
      lastModifiedAt: Value(now),
      originDeviceId: Value(deviceId),
      localSyncStatus: const Value(LocalSyncStatus.pending),
      localUpdatedAt: Value(now),
    ));
  }

  Future<void> softDelete(String id) async {
    final deviceId = await _storage.ensureDeviceId();
    final now = DateTime.now();
    await (_db.update(_db.farmers)..where((f) => f.id.equals(id)))
        .write(FarmersCompanion(
      deletedLocal: const Value(true),
      lastModifiedAt: Value(now),
      originDeviceId: Value(deviceId),
      localSyncStatus: const Value(LocalSyncStatus.pending),
      localUpdatedAt: Value(now),
    ));
  }
}

final farmersRepositoryProvider = Provider<FarmersRepository>((ref) {
  return FarmersRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(authStorageProvider),
  );
});

final farmerByIdProvider = StreamProvider.family<FarmerRow?, String>((ref, id) {
  return ref.watch(farmersRepositoryProvider).watchById(id);
});

final farmersListProvider = StreamProvider<List<FarmerRow>>((ref) {
  return ref.watch(farmersRepositoryProvider).watchAll();
});

final farmersSearchProvider =
    StreamProvider.family<List<FarmerRow>, String>((ref, query) {
  return ref.watch(farmersRepositoryProvider).searchByQuery(query);
});
