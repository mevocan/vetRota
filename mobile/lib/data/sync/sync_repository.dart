import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../api/api_client.dart';
import '../auth/auth_storage.dart';
import '../db/app_database.dart';
import '../photos/photos_repository.dart';
import 'sync_mappers.dart';
import 'ulid.dart';

// SyncRepository: push queue + pull queue.
//
// Sira:
//   1. push() — pending kayitlari toplar, /sync/push'a gonderir,
//      response'a gore localSyncStatus=synced/failed yapar, version'u
//      gunceller, conflict kayitlarini sync_conflicts'e yazar.
//   2. pull() — /sync/pull cursor loop ile cagirir, gelen kayitlari
//      Drift'e upsert eder, deleted_at varsa soft-delete isaretler.
//   3. last_synced_at sync_meta'ya yazilir.
//
// stock_movements ledger oldugundan delete asla gondermez.

class SyncResult {
  SyncResult({
    required this.pushedCount,
    required this.acceptedCount,
    required this.conflictCount,
    required this.rejectedCount,
    required this.pulledCount,
    this.photosUploaded = 0,
    this.photosFailed = 0,
  });

  final int pushedCount;
  final int acceptedCount;
  final int conflictCount;
  final int rejectedCount;
  final int pulledCount;
  final int photosUploaded;
  final int photosFailed;

  bool get hasIssues => rejectedCount > 0 || photosFailed > 0;

  @override
  String toString() =>
      'push=$pushedCount accepted=$acceptedCount conflicts=$conflictCount '
      'rejected=$rejectedCount pulled=$pulledCount '
      'photos_up=$photosUploaded photos_fail=$photosFailed';
}

class SyncRepository {
  SyncRepository(this._api, this._db, this._storage, this._photos);

  final ApiClient _api;
  final AppDatabase _db;
  final AuthStorage _storage;
  final PhotosRepository _photos;
  static const _uuid = Uuid();

  // ledger tablolari — delete operasyonu uretilmez.
  static const _ledgerTables = {'stock_movements', 'payments'};

  // Pull/push tablo sirasi: FK bagimliliklari (parent once).
  // medical_record_photos pull-only (binary /sync/photos icin push edilir).
  static const _tables = [
    'villages',
    'drugs',
    'farmers',
    'animals',
    'appointments',
    'medical_records',
    'medical_record_drugs',
    'medical_record_photos',
    'stocks',
    'stock_movements',
    'payments',
    'vaccine_schedules',
  ];

  Future<SyncResult> sync() async {
    final pushRes = await push();
    final photoRes = await uploadPendingPhotos();
    final pulledCount = await pull();
    return SyncResult(
      pushedCount: pushRes.pushedCount,
      acceptedCount: pushRes.acceptedCount,
      conflictCount: pushRes.conflictCount,
      rejectedCount: pushRes.rejectedCount,
      pulledCount: pulledCount,
      photosUploaded: photoRes.$1,
      photosFailed: photoRes.$2,
    );
  }

  // ============================================================ PHOTOS

  // /sync/photos endpoint'ine multipart yukleme. Her foto ayri istek —
  // tek transaction yok. Hata durumunda foto failed isaretlenir, sonraki
  // sync'te tekrar denenir.
  Future<(int uploaded, int failed)> uploadPendingPhotos() async {
    final pending = await _photos.pendingUploads();
    if (pending.isEmpty) return (0, 0);

    var uploaded = 0;
    var failed = 0;

    for (final photo in pending) {
      final localPath = photo.localPath;
      if (localPath == null) continue;
      final file = File(localPath);
      if (!file.existsSync()) {
        await _photos.markFailed(
          id: photo.id,
          reason: 'Lokal dosya bulunamadi: $localPath',
        );
        failed++;
        continue;
      }

      try {
        final form = FormData.fromMap({
          'id': photo.id,
          'medical_record_id': photo.medicalRecordId,
          'animal_id': photo.animalId,
          'taken_at': photo.takenAt.toUtc().toIso8601String(),
          if (photo.caption != null) 'caption': photo.caption,
          'photo': await MultipartFile.fromFile(
            file.path,
            filename: photo.originalFilename ?? '${photo.id}.jpg',
          ),
        });

        final response = await _api.dio.post<Map<String, dynamic>>(
          '/sync/photos',
          data: form,
          options: Options(contentType: 'multipart/form-data'),
        );

        final body = response.data ?? const {};
        await _photos.markUploaded(
          id: photo.id,
          serverStoragePath: (body['storage_path'] as String?) ?? '',
          newVersion: body['version'] as int?,
        );
        uploaded++;
      } catch (e) {
        await _photos.markFailed(id: photo.id, reason: e.toString());
        failed++;
      }
    }

    return (uploaded, failed);
  }

  // ============================================================ PUSH

  Future<SyncResult> push() async {
    final batch = <String, List<Map<String, dynamic>>>{};
    var totalPending = 0;

    // Her tablo icin pending kayitlari topla.
    final villages = await _pendingVillages();
    if (villages.isNotEmpty) {
      batch['villages'] = villages.map((r) => _recordFor(
            id: r.id,
            version: r.version,
            data: villageToData(r),
            deleted: r.deletedLocal,
            tableName: 'villages',
            clientLastModifiedAt: r.lastModifiedAt,
          )).whereType<Map<String, dynamic>>().toList();
      totalPending += villages.length;
    }

    final drugs = await _pendingDrugs();
    if (drugs.isNotEmpty) {
      batch['drugs'] = drugs.map((r) => _recordFor(
            id: r.id,
            version: r.version,
            data: drugToData(r),
            deleted: r.deletedLocal,
            tableName: 'drugs',
            clientLastModifiedAt: r.lastModifiedAt,
          )).whereType<Map<String, dynamic>>().toList();
      totalPending += drugs.length;
    }

    final farmers = await _pendingFarmers();
    if (farmers.isNotEmpty) {
      batch['farmers'] = farmers.map((r) => _recordFor(
            id: r.id,
            version: r.version,
            data: farmerToData(r),
            deleted: r.deletedLocal,
            tableName: 'farmers',
            clientLastModifiedAt: r.lastModifiedAt,
          )).whereType<Map<String, dynamic>>().toList();
      totalPending += farmers.length;
    }

    final animals = await _pendingAnimals();
    if (animals.isNotEmpty) {
      batch['animals'] = animals.map((r) => _recordFor(
            id: r.id,
            version: r.version,
            data: animalToData(r),
            deleted: r.deletedLocal,
            tableName: 'animals',
            clientLastModifiedAt: r.lastModifiedAt,
          )).whereType<Map<String, dynamic>>().toList();
      totalPending += animals.length;
    }

    final appts = await _pendingAppointments();
    if (appts.isNotEmpty) {
      batch['appointments'] = appts.map((r) => _recordFor(
            id: r.id,
            version: r.version,
            data: appointmentToData(r),
            deleted: r.deletedLocal,
            tableName: 'appointments',
            clientLastModifiedAt: r.lastModifiedAt,
          )).whereType<Map<String, dynamic>>().toList();
      totalPending += appts.length;
    }

    final mrs = await _pendingMedicalRecords();
    if (mrs.isNotEmpty) {
      batch['medical_records'] = mrs.map((r) => _recordFor(
            id: r.id,
            version: r.version,
            data: medicalRecordToData(r),
            deleted: r.deletedLocal,
            tableName: 'medical_records',
            clientLastModifiedAt: r.lastModifiedAt,
          )).whereType<Map<String, dynamic>>().toList();
      totalPending += mrs.length;
    }

    final mrDrugs = await _pendingMrDrugs();
    if (mrDrugs.isNotEmpty) {
      batch['medical_record_drugs'] = mrDrugs.map((r) => _recordFor(
            id: r.id,
            version: r.version,
            data: mrDrugToData(r),
            deleted: r.deletedLocal,
            tableName: 'medical_record_drugs',
            clientLastModifiedAt: r.lastModifiedAt,
          )).whereType<Map<String, dynamic>>().toList();
      totalPending += mrDrugs.length;
    }

    final stocks = await _pendingStocks();
    if (stocks.isNotEmpty) {
      batch['stocks'] = stocks.map((r) => _recordFor(
            id: r.id,
            version: r.version,
            data: stockToData(r),
            deleted: r.deletedLocal,
            tableName: 'stocks',
            clientLastModifiedAt: r.lastModifiedAt,
          )).whereType<Map<String, dynamic>>().toList();
      totalPending += stocks.length;
    }

    final stockMoves = await _pendingStockMovements();
    if (stockMoves.isNotEmpty) {
      batch['stock_movements'] = stockMoves.map((r) => _recordFor(
            id: r.id,
            version: r.version,
            data: stockMovementToData(r),
            deleted: r.deletedLocal,
            tableName: 'stock_movements',
            clientLastModifiedAt: r.lastModifiedAt,
          )).whereType<Map<String, dynamic>>().toList();
      totalPending += stockMoves.length;
    }

    final payments = await _pendingPayments();
    if (payments.isNotEmpty) {
      batch['payments'] = payments.map((r) => _recordFor(
            id: r.id,
            version: r.version,
            data: paymentToData(r),
            deleted: r.deletedLocal,
            tableName: 'payments',
            clientLastModifiedAt: r.lastModifiedAt,
          )).whereType<Map<String, dynamic>>().toList();
      totalPending += payments.length;
    }

    final vaccineSchedules = await _pendingVaccineSchedules();
    if (vaccineSchedules.isNotEmpty) {
      batch['vaccine_schedules'] = vaccineSchedules.map((r) => _recordFor(
            id: r.id,
            version: r.version,
            data: vaccineScheduleToData(r),
            deleted: r.deletedLocal,
            tableName: 'vaccine_schedules',
            clientLastModifiedAt: r.lastModifiedAt,
          )).whereType<Map<String, dynamic>>().toList();
      totalPending += vaccineSchedules.length;
    }

    if (totalPending == 0) {
      return SyncResult(
        pushedCount: 0,
        acceptedCount: 0,
        conflictCount: 0,
        rejectedCount: 0,
        pulledCount: 0,
      );
    }

    final deviceId = await _storage.ensureDeviceId();
    final clientSyncId = generateUlid();
    final body = {
      'client_sync_id': clientSyncId,
      'device_id': deviceId,
      'client_time': DateTime.now().toUtc().toIso8601String(),
      'batch': batch,
    };

    final response = await _api.post<Map<String, dynamic>>(
      '/sync/push',
      data: body,
    );
    final results = (response.data?['results'] as Map<String, dynamic>?) ?? {};
    final accepted =
        (results['accepted'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final conflicts =
        (results['conflicts'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final rejected =
        (results['rejected'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    await _applyPushResults(
      accepted: accepted,
      conflicts: conflicts,
      rejected: rejected,
    );

    return SyncResult(
      pushedCount: totalPending,
      acceptedCount: accepted.length,
      conflictCount: conflicts.length,
      rejectedCount: rejected.length,
      pulledCount: 0,
    );
  }

  Map<String, dynamic>? _recordFor({
    required String id,
    required int version,
    required Map<String, dynamic> data,
    required bool deleted,
    required String tableName,
    required DateTime? clientLastModifiedAt,
  }) {
    if (deleted) {
      if (_ledgerTables.contains(tableName)) {
        // Ledger tablosunda delete operasyonu gondermeyiz; ters hareket
        // kayit eklenir. Bu MVP'de istemiyoruz, atla.
        return null;
      }
      return {
        'op': 'delete',
        'id': id,
        'expected_version': version,
        'client_last_modified_at':
            (clientLastModifiedAt ?? DateTime.now()).toUtc().toIso8601String(),
      };
    }
    return {
      'op': 'upsert',
      'id': id,
      'expected_version': version,
      'data': data,
      'client_last_modified_at':
          (clientLastModifiedAt ?? DateTime.now()).toUtc().toIso8601String(),
    };
  }

  Future<void> _applyPushResults({
    required List<Map<String, dynamic>> accepted,
    required List<Map<String, dynamic>> conflicts,
    required List<Map<String, dynamic>> rejected,
  }) async {
    await _db.transaction(() async {
      for (final a in accepted) {
        await _markRowSynced(
          table: a['table'] as String,
          id: a['id'] as String,
          newVersion: a['new_version'] as int?,
        );
      }
      // Conflict — server kazandi (server_won) veya client_won.
      // Her durumda local kaydi synced isaretle; gercek kayitlari pull
      // getirir. UI gostermek icin sync_conflicts'e yaz.
      for (final c in conflicts) {
        await _markRowSynced(
          table: c['table'] as String,
          id: c['id'] as String,
          newVersion: c['server_version'] as int?,
        );
        await _db.into(_db.syncConflicts).insert(
              SyncConflictsCompanion.insert(
                id: _uuid.v4(),
                targetTable: c['table'] as String,
                recordId: c['id'] as String,
                resolution: (c['resolution'] as String?) ?? 'unknown',
                serverVersion: Value(c['server_version'] as int?),
              ),
            );
      }
      for (final r in rejected) {
        await _markRowFailed(
          table: r['table'] as String,
          id: r['id'] as String,
          reason: '${r['reason']}: ${r['detail'] ?? ''}',
        );
      }
    });
  }

  Future<void> _markRowSynced({
    required String table,
    required String id,
    int? newVersion,
  }) async {
    Future<void> doUpdate<T extends Table, R>(
      TableInfo<T, R> tbl,
      Insertable<R> companion,
      Expression<bool> Function(T) where,
    ) async {
      await (_db.update(tbl)..where(where)).write(companion);
    }

    switch (table) {
      case 'villages':
        await doUpdate(
          _db.villages,
          VillagesCompanion(
            version: newVersion != null ? Value(newVersion) : const Value.absent(),
            localSyncStatus: const Value(LocalSyncStatus.synced),
            lastError: const Value(null),
          ),
          (t) => t.id.equals(id),
        );
        break;
      case 'drugs':
        await doUpdate(
          _db.drugs,
          DrugsCompanion(
            version: newVersion != null ? Value(newVersion) : const Value.absent(),
            localSyncStatus: const Value(LocalSyncStatus.synced),
            lastError: const Value(null),
          ),
          (t) => t.id.equals(id),
        );
        break;
      case 'farmers':
        await doUpdate(
          _db.farmers,
          FarmersCompanion(
            version: newVersion != null ? Value(newVersion) : const Value.absent(),
            localSyncStatus: const Value(LocalSyncStatus.synced),
            lastError: const Value(null),
          ),
          (t) => t.id.equals(id),
        );
        break;
      case 'animals':
        await doUpdate(
          _db.animals,
          AnimalsCompanion(
            version: newVersion != null ? Value(newVersion) : const Value.absent(),
            localSyncStatus: const Value(LocalSyncStatus.synced),
            lastError: const Value(null),
          ),
          (t) => t.id.equals(id),
        );
        break;
      case 'appointments':
        await doUpdate(
          _db.appointments,
          AppointmentsCompanion(
            version: newVersion != null ? Value(newVersion) : const Value.absent(),
            localSyncStatus: const Value(LocalSyncStatus.synced),
            lastError: const Value(null),
          ),
          (t) => t.id.equals(id),
        );
        break;
      case 'medical_records':
        await doUpdate(
          _db.medicalRecords,
          MedicalRecordsCompanion(
            version: newVersion != null ? Value(newVersion) : const Value.absent(),
            localSyncStatus: const Value(LocalSyncStatus.synced),
            lastError: const Value(null),
          ),
          (t) => t.id.equals(id),
        );
        break;
      case 'medical_record_drugs':
        await doUpdate(
          _db.medicalRecordDrugs,
          MedicalRecordDrugsCompanion(
            version: newVersion != null ? Value(newVersion) : const Value.absent(),
            localSyncStatus: const Value(LocalSyncStatus.synced),
            lastError: const Value(null),
          ),
          (t) => t.id.equals(id),
        );
        break;
      case 'stocks':
        await doUpdate(
          _db.stocks,
          StocksCompanion(
            version: newVersion != null ? Value(newVersion) : const Value.absent(),
            localSyncStatus: const Value(LocalSyncStatus.synced),
            lastError: const Value(null),
          ),
          (t) => t.id.equals(id),
        );
        break;
      case 'stock_movements':
        await doUpdate(
          _db.stockMovements,
          StockMovementsCompanion(
            version: newVersion != null ? Value(newVersion) : const Value.absent(),
            localSyncStatus: const Value(LocalSyncStatus.synced),
            lastError: const Value(null),
          ),
          (t) => t.id.equals(id),
        );
        break;
      case 'payments':
        await doUpdate(
          _db.payments,
          PaymentsCompanion(
            version: newVersion != null ? Value(newVersion) : const Value.absent(),
            localSyncStatus: const Value(LocalSyncStatus.synced),
            lastError: const Value(null),
          ),
          (t) => t.id.equals(id),
        );
        break;
      case 'vaccine_schedules':
        await doUpdate(
          _db.vaccineSchedules,
          VaccineSchedulesCompanion(
            version: newVersion != null ? Value(newVersion) : const Value.absent(),
            localSyncStatus: const Value(LocalSyncStatus.synced),
            lastError: const Value(null),
          ),
          (t) => t.id.equals(id),
        );
        break;
    }
  }

  Future<void> _markRowFailed({
    required String table,
    required String id,
    required String reason,
  }) async {
    Future<void> doUpdate<T extends Table, R>(
      TableInfo<T, R> tbl,
      Insertable<R> companion,
      Expression<bool> Function(T) where,
    ) async {
      await (_db.update(tbl)..where(where)).write(companion);
    }

    switch (table) {
      case 'villages':
        await doUpdate(
          _db.villages,
          VillagesCompanion(
            localSyncStatus: const Value(LocalSyncStatus.failed),
            lastError: Value(reason),
          ),
          (t) => t.id.equals(id),
        );
        break;
      case 'drugs':
        await doUpdate(
          _db.drugs,
          DrugsCompanion(
            localSyncStatus: const Value(LocalSyncStatus.failed),
            lastError: Value(reason),
          ),
          (t) => t.id.equals(id),
        );
        break;
      case 'farmers':
        await doUpdate(
          _db.farmers,
          FarmersCompanion(
            localSyncStatus: const Value(LocalSyncStatus.failed),
            lastError: Value(reason),
          ),
          (t) => t.id.equals(id),
        );
        break;
      case 'animals':
        await doUpdate(
          _db.animals,
          AnimalsCompanion(
            localSyncStatus: const Value(LocalSyncStatus.failed),
            lastError: Value(reason),
          ),
          (t) => t.id.equals(id),
        );
        break;
      case 'appointments':
        await doUpdate(
          _db.appointments,
          AppointmentsCompanion(
            localSyncStatus: const Value(LocalSyncStatus.failed),
            lastError: Value(reason),
          ),
          (t) => t.id.equals(id),
        );
        break;
      case 'medical_records':
        await doUpdate(
          _db.medicalRecords,
          MedicalRecordsCompanion(
            localSyncStatus: const Value(LocalSyncStatus.failed),
            lastError: Value(reason),
          ),
          (t) => t.id.equals(id),
        );
        break;
      case 'medical_record_drugs':
        await doUpdate(
          _db.medicalRecordDrugs,
          MedicalRecordDrugsCompanion(
            localSyncStatus: const Value(LocalSyncStatus.failed),
            lastError: Value(reason),
          ),
          (t) => t.id.equals(id),
        );
        break;
      case 'stocks':
        await doUpdate(
          _db.stocks,
          StocksCompanion(
            localSyncStatus: const Value(LocalSyncStatus.failed),
            lastError: Value(reason),
          ),
          (t) => t.id.equals(id),
        );
        break;
      case 'stock_movements':
        await doUpdate(
          _db.stockMovements,
          StockMovementsCompanion(
            localSyncStatus: const Value(LocalSyncStatus.failed),
            lastError: Value(reason),
          ),
          (t) => t.id.equals(id),
        );
        break;
      case 'payments':
        await doUpdate(
          _db.payments,
          PaymentsCompanion(
            localSyncStatus: const Value(LocalSyncStatus.failed),
            lastError: Value(reason),
          ),
          (t) => t.id.equals(id),
        );
        break;
      case 'vaccine_schedules':
        await doUpdate(
          _db.vaccineSchedules,
          VaccineSchedulesCompanion(
            localSyncStatus: const Value(LocalSyncStatus.failed),
            lastError: Value(reason),
          ),
          (t) => t.id.equals(id),
        );
        break;
    }
  }

  Future<List<VillageRow>> _pendingVillages() => (_db.select(_db.villages)
        ..where((t) => t.localSyncStatus
            .equalsValue(LocalSyncStatus.pending)))
      .get();
  Future<List<DrugRow>> _pendingDrugs() => (_db.select(_db.drugs)
        ..where((t) => t.localSyncStatus
            .equalsValue(LocalSyncStatus.pending)))
      .get();
  Future<List<FarmerRow>> _pendingFarmers() => (_db.select(_db.farmers)
        ..where((t) => t.localSyncStatus
            .equalsValue(LocalSyncStatus.pending)))
      .get();
  Future<List<AnimalRow>> _pendingAnimals() => (_db.select(_db.animals)
        ..where((t) => t.localSyncStatus
            .equalsValue(LocalSyncStatus.pending)))
      .get();
  Future<List<AppointmentRow>> _pendingAppointments() =>
      (_db.select(_db.appointments)
            ..where((t) => t.localSyncStatus
                .equalsValue(LocalSyncStatus.pending)))
          .get();
  Future<List<MedicalRecordRow>> _pendingMedicalRecords() =>
      (_db.select(_db.medicalRecords)
            ..where((t) => t.localSyncStatus
                .equalsValue(LocalSyncStatus.pending)))
          .get();
  Future<List<MedicalRecordDrugRow>> _pendingMrDrugs() =>
      (_db.select(_db.medicalRecordDrugs)
            ..where((t) => t.localSyncStatus
                .equalsValue(LocalSyncStatus.pending)))
          .get();
  Future<List<StockRow>> _pendingStocks() => (_db.select(_db.stocks)
        ..where((t) => t.localSyncStatus
            .equalsValue(LocalSyncStatus.pending)))
      .get();
  Future<List<PaymentRow>> _pendingPayments() =>
      (_db.select(_db.payments)
            ..where((p) => p.localSyncStatus
                .equalsValue(LocalSyncStatus.pending)))
          .get();

  Future<List<StockMovementRow>> _pendingStockMovements() =>
      (_db.select(_db.stockMovements)
            ..where((t) => t.localSyncStatus
                .equalsValue(LocalSyncStatus.pending)))
          .get();

  Future<List<VaccineScheduleRow>> _pendingVaccineSchedules() =>
      (_db.select(_db.vaccineSchedules)
            ..where((t) => t.localSyncStatus
                .equalsValue(LocalSyncStatus.pending)))
          .get();

  // ============================================================ PULL

  Future<int> pull() async {
    final since = await _readMeta('last_synced_at') ?? '1970-01-01T00:00:00Z';
    var nextCursor = await _readMeta('pull_cursor');
    var totalPulled = 0;
    String? newSince = since;
    var safetyLimit = 50; // max sayfa

    while (safetyLimit-- > 0) {
      final query = <String, dynamic>{
        'since': newSince,
        'tables': _tables.join(','),
        'limit': 500,
      };
      if (nextCursor != null) query['cursor'] = nextCursor;

      final response = await _api.get<Map<String, dynamic>>(
        '/sync/pull',
        query: query,
      );
      final body = response.data ?? const {};
      final data = (body['data'] as Map<String, dynamic>?) ?? {};
      totalPulled += await _applyPullPage(data);

      final hasMore = body['has_more'] as bool? ?? false;
      newSince = (body['next_since'] as String?) ?? newSince;
      nextCursor = body['next_cursor'] as String?;
      if (!hasMore) break;
    }

    // Tum sayfalar bittiginde cursor'u temizle, since'i ileri tasi.
    await _writeMeta('last_synced_at', newSince!);
    await _writeMeta('pull_cursor', null);
    await _writeMeta(
      'last_synced_local',
      DateTime.now().toUtc().toIso8601String(),
    );
    return totalPulled;
  }

  Future<int> _applyPullPage(Map<String, dynamic> data) async {
    var count = 0;
    await _db.transaction(() async {
      for (final table in _tables) {
        final rows = (data[table] as List?)?.cast<Map<String, dynamic>>();
        if (rows == null || rows.isEmpty) continue;
        for (final row in rows) {
          await _upsertPulledRow(table, row);
          count++;
        }
      }
    });
    return count;
  }

  Future<void> _upsertPulledRow(
    String table,
    Map<String, dynamic> j,
  ) async {
    switch (table) {
      case 'villages':
        await _db.into(_db.villages).insertOnConflictUpdate(
              villageFromServer(j),
            );
        break;
      case 'drugs':
        await _db.into(_db.drugs).insertOnConflictUpdate(drugFromServer(j));
        break;
      case 'farmers':
        await _db.into(_db.farmers).insertOnConflictUpdate(
              farmerFromServer(j),
            );
        break;
      case 'animals':
        await _db.into(_db.animals).insertOnConflictUpdate(
              animalFromServer(j),
            );
        break;
      case 'appointments':
        await _db.into(_db.appointments).insertOnConflictUpdate(
              appointmentFromServer(j),
            );
        break;
      case 'medical_records':
        await _db.into(_db.medicalRecords).insertOnConflictUpdate(
              medicalRecordFromServer(j),
            );
        break;
      case 'medical_record_drugs':
        await _db.into(_db.medicalRecordDrugs).insertOnConflictUpdate(
              mrDrugFromServer(j),
            );
        break;
      case 'medical_record_photos':
        await _db.into(_db.medicalRecordPhotos).insertOnConflictUpdate(
              mrPhotoFromServer(j),
            );
        break;
      case 'stocks':
        await _db
            .into(_db.stocks)
            .insertOnConflictUpdate(stockFromServer(j));
        break;
      case 'stock_movements':
        await _db.into(_db.stockMovements).insertOnConflictUpdate(
              stockMovementFromServer(j),
            );
        break;
      case 'payments':
        await _db.into(_db.payments).insertOnConflictUpdate(
              paymentFromServer(j),
            );
        break;
      case 'vaccine_schedules':
        await _db.into(_db.vaccineSchedules).insertOnConflictUpdate(
              vaccineScheduleFromServer(j),
            );
        break;
    }
  }

  // ============================================================ META

  Future<String?> _readMeta(String key) async {
    final r = await (_db.select(_db.syncMeta)
          ..where((m) => m.key.equals(key))
          ..limit(1))
        .getSingleOrNull();
    return r?.value;
  }

  Future<void> _writeMeta(String key, String? value) async {
    await _db.into(_db.syncMeta).insertOnConflictUpdate(
          SyncMetaCompanion.insert(key: key, value: Value(value)),
        );
  }

  Future<DateTime?> readLastSyncedLocal() async {
    final v = await _readMeta('last_synced_local');
    return v == null ? null : DateTime.parse(v).toLocal();
  }
}

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepository(
    ref.watch(apiClientProvider),
    ref.watch(appDatabaseProvider),
    ref.watch(authStorageProvider),
    ref.watch(photosRepositoryProvider),
  );
});

// Bekleyen kayit sayisi — UI badge.
final pendingCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  // Tum sync edilen tablolarda pending olanlari say.
  final query = db.customSelect(
    '''
    SELECT
      (SELECT COUNT(*) FROM villages WHERE local_sync_status = ?)
      + (SELECT COUNT(*) FROM drugs WHERE local_sync_status = ?)
      + (SELECT COUNT(*) FROM farmers WHERE local_sync_status = ?)
      + (SELECT COUNT(*) FROM animals WHERE local_sync_status = ?)
      + (SELECT COUNT(*) FROM appointments WHERE local_sync_status = ?)
      + (SELECT COUNT(*) FROM medical_records WHERE local_sync_status = ?)
      + (SELECT COUNT(*) FROM medical_record_drugs WHERE local_sync_status = ?)
      + (SELECT COUNT(*) FROM stocks WHERE local_sync_status = ?)
      + (SELECT COUNT(*) FROM stock_movements WHERE local_sync_status = ?)
      + (SELECT COUNT(*) FROM payments WHERE local_sync_status = ?)
      + (SELECT COUNT(*) FROM vaccine_schedules WHERE local_sync_status = ?)
      AS pending
    ''',
    variables: List.generate(
      11,
      (_) => Variable.withInt(LocalSyncStatus.pending.index),
    ),
    readsFrom: {
      db.villages,
      db.drugs,
      db.farmers,
      db.animals,
      db.appointments,
      db.medicalRecords,
      db.medicalRecordDrugs,
      db.stocks,
      db.stockMovements,
      db.payments,
      db.vaccineSchedules,
    },
  );
  return query.watchSingle().map((row) => row.read<int>('pending'));
});

// Conflict listesi — UI'da gosterim.
final syncConflictsProvider = StreamProvider<List<SyncConflictRow>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.syncConflicts)
        ..orderBy([
          (c) => OrderingTerm(
                expression: c.observedAt,
                mode: OrderingMode.desc,
              ),
        ]))
      .watch();
});
