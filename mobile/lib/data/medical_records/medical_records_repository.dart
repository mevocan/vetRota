import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../auth/auth_storage.dart';
import '../db/app_database.dart';

// Bir muayenede kullanilacak ilac satiri (form'dan gelir).
class DrugUsage {
  DrugUsage({
    required this.drugId,
    required this.quantity,
    this.dosageInstructions,
  });

  final String drugId;
  final double quantity;
  final String? dosageInstructions;
}

// MedicalRecordsRepository: muayene yazimi tek bir Drift transaction'i.
// Olusturulan kayitlar:
//   1. medical_records      (1 satir)
//   2. medical_record_drugs (N satir)
//   3. stock_movements      (N satir, type='usage', quantity=-x)
//
// Stock cache (current_quantity) sync-api §10 uyarinca client'ta da
// guncellenir; ama gercek dogrulayici server-side trigger'dir.
// Burada offline UI'in "mevcut stok" gostergesi tutarli kalsin diye
// stocks.current_quantity'yi de dususuyoruz (LWW; sync donusunde server
// degerine ezilir).
class MedicalRecordsRepository {
  MedicalRecordsRepository(this._db, this._storage);

  final AppDatabase _db;
  final AuthStorage _storage;
  static const _uuid = Uuid();

  Stream<List<MedicalRecordRow>> watchByAnimal(String animalId) {
    return (_db.select(_db.medicalRecords)
          ..where((m) =>
              m.animalId.equals(animalId) & m.deletedLocal.equals(false))
          ..orderBy([
            (m) => OrderingTerm(
                  expression: m.examinedAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  Future<MedicalRecordRow> create({
    required String animalId,
    required DateTime examinedAt,
    String visitType = 'routine',
    String? villageId,
    String? chiefComplaint,
    String? symptoms,
    String? diagnosisNotes,
    String? treatmentNotes,
    String? recommendations,
    double? temperatureCelsius,
    double? weightKg,
    int? heartRate,
    int? respiratoryRate,
    double? serviceFee,
    bool followUpNeeded = false,
    DateTime? followUpDate,
    List<DrugUsage> drugs = const [],
  }) async {
    final clinicId = await _storage.readClinicId();
    final deviceId = await _storage.ensureDeviceId();
    final now = DateTime.now();
    final mrId = _uuid.v4();

    return _db.transaction(() async {
      final mrCompanion = MedicalRecordsCompanion.insert(
        id: mrId,
        animalId: animalId,
        examinedAt: examinedAt,
        visitType: Value(visitType),
        villageId: Value(villageId),
        chiefComplaint: Value(chiefComplaint),
        symptoms: Value(symptoms),
        diagnosisNotes: Value(diagnosisNotes),
        treatmentNotes: Value(treatmentNotes),
        recommendations: Value(recommendations),
        temperatureCelsius: Value(temperatureCelsius),
        weightKg: Value(weightKg),
        heartRate: Value(heartRate),
        respiratoryRate: Value(respiratoryRate),
        serviceFee: Value(serviceFee),
        followUpNeeded: Value(followUpNeeded),
        followUpDate: Value(followUpDate),
        version: const Value(0),
        lastModifiedAt: Value(now),
        originDeviceId: Value(deviceId),
        clinicId: Value(clinicId),
        localSyncStatus: const Value(LocalSyncStatus.pending),
        localUpdatedAt: Value(now),
      );
      await _db.into(_db.medicalRecords).insert(mrCompanion);

      for (final usage in drugs) {
        // 1. medical_record_drugs satiri
        await _db.into(_db.medicalRecordDrugs).insert(
              MedicalRecordDrugsCompanion.insert(
                id: _uuid.v4(),
                medicalRecordId: mrId,
                drugId: usage.drugId,
                quantity: usage.quantity,
                dosageInstructions: Value(usage.dosageInstructions),
                version: const Value(0),
                lastModifiedAt: Value(now),
                originDeviceId: Value(deviceId),
                clinicId: Value(clinicId),
                localSyncStatus: const Value(LocalSyncStatus.pending),
                localUpdatedAt: Value(now),
              ),
            );

        // 2. stock_movements (additive ledger): usage = negatif quantity.
        // Once drug icin local stock satiri var mi bak; yoksa olustur.
        final stock = await _ensureStockForDrug(
          drugId: usage.drugId,
          deviceId: deviceId,
          clinicId: clinicId,
          now: now,
        );

        await _db.into(_db.stockMovements).insert(
              StockMovementsCompanion.insert(
                id: _uuid.v4(),
                stockId: stock.id,
                drugId: usage.drugId,
                movementType: 'usage',
                quantity: -usage.quantity,
                occurredAt: now,
                version: const Value(0),
                lastModifiedAt: Value(now),
                originDeviceId: Value(deviceId),
                clinicId: Value(clinicId),
                localSyncStatus: const Value(LocalSyncStatus.pending),
                localUpdatedAt: Value(now),
              ),
            );

        // 3. stocks.current_quantity'yi local'da dus (UI tutarli kalsin).
        await (_db.update(_db.stocks)..where((s) => s.id.equals(stock.id)))
            .write(
          StocksCompanion(
            currentQuantity: Value(stock.currentQuantity - usage.quantity),
            lastModifiedAt: Value(now),
            originDeviceId: Value(deviceId),
            localSyncStatus: const Value(LocalSyncStatus.pending),
            localUpdatedAt: Value(now),
          ),
        );
      }

      return (await (_db.select(_db.medicalRecords)
                ..where((m) => m.id.equals(mrId)))
              .getSingle());
    });
  }

  Future<StockRow> _ensureStockForDrug({
    required String drugId,
    required String deviceId,
    required String? clinicId,
    required DateTime now,
  }) async {
    final existing = await (_db.select(_db.stocks)
          ..where((s) => s.drugId.equals(drugId))
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) return existing;

    final stockId = _uuid.v4();
    await _db.into(_db.stocks).insert(
          StocksCompanion.insert(
            id: stockId,
            drugId: drugId,
            currentQuantity: const Value(0),
            version: const Value(0),
            lastModifiedAt: Value(now),
            originDeviceId: Value(deviceId),
            clinicId: Value(clinicId),
            localSyncStatus: const Value(LocalSyncStatus.pending),
            localUpdatedAt: Value(now),
          ),
        );
    return (await (_db.select(_db.stocks)
              ..where((s) => s.id.equals(stockId)))
            .getSingle());
  }
}

final medicalRecordsRepositoryProvider =
    Provider<MedicalRecordsRepository>((ref) {
  return MedicalRecordsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(authStorageProvider),
  );
});

final medicalRecordsByAnimalProvider =
    StreamProvider.family<List<MedicalRecordRow>, String>((ref, animalId) {
  return ref
      .watch(medicalRecordsRepositoryProvider)
      .watchByAnimal(animalId);
});

// Ilac kataloğu — yerel Drift'ten. Sync ile pull edilen ilaclar burada.
final localDrugsProvider = StreamProvider<List<DrugRow>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.drugs)
        ..where((d) => d.deletedLocal.equals(false))
        ..orderBy([(d) => OrderingTerm(expression: d.name)]))
      .watch();
});
