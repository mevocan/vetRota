import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../auth/auth_storage.dart';
import '../db/app_database.dart';

// Liste ekrani icin meta — animal + farmer.
class MedicalRecordWithMeta {
  MedicalRecordWithMeta({
    required this.row,
    this.animalName,
    this.animalEarTag,
    this.animalSpecies,
    this.farmerName,
  });
  final MedicalRecordRow row;
  final String? animalName;
  final String? animalEarTag;
  final String? animalSpecies;
  final String? farmerName;

  String get animalLabel {
    if (animalName != null && animalName!.isNotEmpty) return animalName!;
    if (animalEarTag != null && animalEarTag!.isNotEmpty) {
      return 'Kupe $animalEarTag';
    }
    return animalSpecies ?? 'Hayvan';
  }
}

// Detay ekraninda ilac listesi icin.
class MedicalRecordDrugDetail {
  MedicalRecordDrugDetail({
    required this.mrd,
    required this.drugName,
    required this.unit,
  });
  final MedicalRecordDrugRow mrd;
  final String drugName;
  final String unit;
}

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

  // Global muayene listesi — animal/farmer join'li, en yeniden eskiye.
  Stream<List<MedicalRecordWithMeta>> watchAllWithMeta() {
    final q = _db.select(_db.medicalRecords).join([
      leftOuterJoin(_db.animals,
          _db.animals.id.equalsExp(_db.medicalRecords.animalId)),
      leftOuterJoin(_db.farmers,
          _db.farmers.id.equalsExp(_db.animals.farmerId)),
    ])
      ..where(_db.medicalRecords.deletedLocal.equals(false))
      ..orderBy([
        OrderingTerm(
          expression: _db.medicalRecords.examinedAt,
          mode: OrderingMode.desc,
        ),
      ]);
    return q.watch().map((rows) => rows.map((r) {
          final mr = r.readTable(_db.medicalRecords);
          final animal = r.readTableOrNull(_db.animals);
          final farmer = r.readTableOrNull(_db.farmers);
          return MedicalRecordWithMeta(
            row: mr,
            animalName: animal?.name,
            animalEarTag: animal?.earTag,
            animalSpecies: animal?.species,
            farmerName: farmer == null
                ? null
                : '${farmer.firstName} ${farmer.lastName}'.trim(),
          );
        }).toList());
  }

  Stream<MedicalRecordRow?> watchById(String id) {
    return (_db.select(_db.medicalRecords)
          ..where((m) => m.id.equals(id)))
        .watchSingleOrNull();
  }

  // Bir muayenede kullanilan ilaclar (drug satirlari ile join).
  Stream<List<MedicalRecordDrugDetail>> watchDrugsForRecord(String mrId) {
    final q = _db.select(_db.medicalRecordDrugs).join([
      leftOuterJoin(_db.drugs,
          _db.drugs.id.equalsExp(_db.medicalRecordDrugs.drugId)),
    ])
      ..where(_db.medicalRecordDrugs.medicalRecordId.equals(mrId) &
          _db.medicalRecordDrugs.deletedLocal.equals(false));
    return q.watch().map((rows) => rows.map((r) {
          final mrd = r.readTable(_db.medicalRecordDrugs);
          final d = r.readTableOrNull(_db.drugs);
          return MedicalRecordDrugDetail(
            mrd: mrd,
            drugName: d?.name ?? 'Bilinmeyen ilac',
            unit: d?.unit ?? '',
          );
        }).toList());
  }

  // Muayene metin/vital alanlarini guncelle (ilac listesi degismez —
  // ilac duzenlemesi stok ledger karmasik, ileride).
  Future<void> updateBasic({
    required String id,
    DateTime? examinedAt,
    String? visitType,
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
    bool? followUpNeeded,
    DateTime? followUpDate,
  }) async {
    final deviceId = await _storage.ensureDeviceId();
    final now = DateTime.now();
    await (_db.update(_db.medicalRecords)..where((m) => m.id.equals(id)))
        .write(MedicalRecordsCompanion(
      examinedAt:
          examinedAt == null ? const Value.absent() : Value(examinedAt),
      visitType:
          visitType == null ? const Value.absent() : Value(visitType),
      chiefComplaint: chiefComplaint == null
          ? const Value.absent()
          : Value(chiefComplaint),
      symptoms: symptoms == null ? const Value.absent() : Value(symptoms),
      diagnosisNotes: diagnosisNotes == null
          ? const Value.absent()
          : Value(diagnosisNotes),
      treatmentNotes: treatmentNotes == null
          ? const Value.absent()
          : Value(treatmentNotes),
      recommendations: recommendations == null
          ? const Value.absent()
          : Value(recommendations),
      temperatureCelsius: temperatureCelsius == null
          ? const Value.absent()
          : Value(temperatureCelsius),
      weightKg: weightKg == null ? const Value.absent() : Value(weightKg),
      heartRate:
          heartRate == null ? const Value.absent() : Value(heartRate),
      respiratoryRate: respiratoryRate == null
          ? const Value.absent()
          : Value(respiratoryRate),
      serviceFee:
          serviceFee == null ? const Value.absent() : Value(serviceFee),
      followUpNeeded: followUpNeeded == null
          ? const Value.absent()
          : Value(followUpNeeded),
      followUpDate: followUpDate == null
          ? const Value.absent()
          : Value(followUpDate),
      lastModifiedAt: Value(now),
      originDeviceId: Value(deviceId),
      localSyncStatus: const Value(LocalSyncStatus.pending),
      localUpdatedAt: Value(now),
    ));
  }

  // Muayene sil — sadece muayene satirini soft-delete eder. Iliskili
  // medical_record_drugs ve stock_movements ledger'da kalir (additive).
  // Daha kapsamli temizlik (stok geri ekleme) sahada gerekirse
  // ayri bir "iptal" akisi olusturulur.
  Future<void> softDelete(String id) async {
    final deviceId = await _storage.ensureDeviceId();
    final now = DateTime.now();
    await (_db.update(_db.medicalRecords)..where((m) => m.id.equals(id)))
        .write(MedicalRecordsCompanion(
      deletedLocal: const Value(true),
      lastModifiedAt: Value(now),
      originDeviceId: Value(deviceId),
      localSyncStatus: const Value(LocalSyncStatus.pending),
      localUpdatedAt: Value(now),
    ));
  }

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

// Global muayene listesi — Muayeneler ekranı için.
final medicalRecordsAllProvider =
    StreamProvider<List<MedicalRecordWithMeta>>((ref) {
  return ref.watch(medicalRecordsRepositoryProvider).watchAllWithMeta();
});

final medicalRecordByIdProvider =
    StreamProvider.family<MedicalRecordRow?, String>((ref, id) {
  return ref.watch(medicalRecordsRepositoryProvider).watchById(id);
});

final medicalRecordDrugsProvider =
    StreamProvider.family<List<MedicalRecordDrugDetail>, String>((ref, id) {
  return ref.watch(medicalRecordsRepositoryProvider).watchDrugsForRecord(id);
});

// Ilac kataloğu — yerel Drift'ten. Sync ile pull edilen ilaclar burada.
final localDrugsProvider = StreamProvider<List<DrugRow>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.drugs)
        ..where((d) => d.deletedLocal.equals(false))
        ..orderBy([(d) => OrderingTerm(expression: d.name)]))
      .watch();
});
