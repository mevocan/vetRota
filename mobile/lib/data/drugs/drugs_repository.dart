import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../auth/auth_storage.dart';
import '../db/app_database.dart';

// Drug + stok yonetimi. Offline-first: tum yazma islemleri Drift'e
// dusurulur, localSyncStatus=pending olarak isaretlenir.
// Stocks ve StockMovements server tarafindan birlikte yonetilir;
// mobilde stok hareketi eklemek StockMovementsCompanion yaratir, Stocks
// tablosu sync sonrasi server'dan tazelenir.
//
// drugType degerleri (backend ile uyumlu): antibiotic, vaccine,
// antiparasitic, antiinflammatory, analgesic, vitamin, hormone, other.
// unit degerleri: ml, tablet, doz, g, flakon, ampul.

class DrugWithStock {
  DrugWithStock({required this.drug, this.stock});
  final DrugRow drug;
  final StockRow? stock;

  bool get hasStock => stock != null;
  double get currentQuantity => stock?.currentQuantity ?? 0;
  bool get isLow {
    final s = stock;
    final t = s?.criticalThreshold;
    if (s == null || t == null) return false;
    return s.currentQuantity <= t;
  }
}

class DrugsRepository {
  DrugsRepository(this._db, this._storage);

  final AppDatabase _db;
  final AuthStorage _storage;
  static const _uuid = Uuid();

  Stream<List<DrugRow>> watchAll() {
    return (_db.select(_db.drugs)
          ..where((d) => d.deletedLocal.equals(false))
          ..orderBy([(d) => OrderingTerm(expression: d.name)]))
        .watch();
  }

  Stream<List<DrugRow>> searchByQuery(String q) {
    final qq = q.trim().toLowerCase();
    if (qq.isEmpty) return watchAll();
    return (_db.select(_db.drugs)
          ..where((d) =>
              d.deletedLocal.equals(false) &
              (d.name.lower().like('%$qq%') |
                  d.activeIngredient.lower().like('%$qq%') |
                  d.manufacturer.lower().like('%$qq%')))
          ..orderBy([(d) => OrderingTerm(expression: d.name)]))
        .watch();
  }

  Stream<DrugRow?> watchById(String id) {
    return (_db.select(_db.drugs)..where((d) => d.id.equals(id)))
        .watchSingleOrNull();
  }

  // Bir drug'a ait stok satiri (yoksa null) — detay ekrani icin.
  Stream<StockRow?> watchStockForDrug(String drugId) {
    return (_db.select(_db.stocks)
          ..where((s) =>
              s.drugId.equals(drugId) & s.deletedLocal.equals(false))
          ..limit(1))
        .watchSingleOrNull();
  }

  // Liste ekrani icin: tum drug'lar + her birinin stoku.
  Stream<List<DrugWithStock>> watchAllWithStock() async* {
    // Drug stream'i + her tetiklemede stock'lari yeniden cek.
    await for (final drugs in watchAll()) {
      final stocks = await (_db.select(_db.stocks)
            ..where((s) => s.deletedLocal.equals(false)))
          .get();
      final byDrugId = {for (final s in stocks) s.drugId: s};
      yield [
        for (final d in drugs)
          DrugWithStock(drug: d, stock: byDrugId[d.id]),
      ];
    }
  }

  Future<DrugRow> create({
    required String name,
    required String drugType,
    required String unit,
    String? activeIngredient,
    String? manufacturer,
    double? packageSize,
    bool isVaccine = false,
  }) async {
    final clinicId = await _storage.readClinicId();
    final deviceId = await _storage.ensureDeviceId();
    final id = _uuid.v4();
    final now = DateTime.now();

    final companion = DrugsCompanion.insert(
      id: id,
      name: name,
      drugType: drugType,
      unit: unit,
      activeIngredient: Value(activeIngredient),
      manufacturer: Value(manufacturer),
      packageSize: Value(packageSize),
      isVaccine: Value(isVaccine),
      version: const Value(0),
      lastModifiedAt: Value(now),
      originDeviceId: Value(deviceId),
      clinicId: Value(clinicId),
      localSyncStatus: const Value(LocalSyncStatus.pending),
      localUpdatedAt: Value(now),
    );

    await _db.into(_db.drugs).insert(companion);
    return (_db.select(_db.drugs)..where((d) => d.id.equals(id)))
        .getSingle();
  }

  Future<void> update({
    required String id,
    String? name,
    String? drugType,
    String? unit,
    String? activeIngredient,
    String? manufacturer,
    double? packageSize,
    bool? isVaccine,
  }) async {
    final deviceId = await _storage.ensureDeviceId();
    final now = DateTime.now();
    await (_db.update(_db.drugs)..where((d) => d.id.equals(id)))
        .write(DrugsCompanion(
      name: name == null ? const Value.absent() : Value(name),
      drugType: drugType == null ? const Value.absent() : Value(drugType),
      unit: unit == null ? const Value.absent() : Value(unit),
      activeIngredient: activeIngredient == null
          ? const Value.absent()
          : Value(activeIngredient),
      manufacturer:
          manufacturer == null ? const Value.absent() : Value(manufacturer),
      packageSize:
          packageSize == null ? const Value.absent() : Value(packageSize),
      isVaccine: isVaccine == null ? const Value.absent() : Value(isVaccine),
      lastModifiedAt: Value(now),
      originDeviceId: Value(deviceId),
      localSyncStatus: const Value(LocalSyncStatus.pending),
      localUpdatedAt: Value(now),
    ));
  }

  Future<void> softDelete(String id) async {
    final deviceId = await _storage.ensureDeviceId();
    final now = DateTime.now();
    await (_db.update(_db.drugs)..where((d) => d.id.equals(id)))
        .write(DrugsCompanion(
      deletedLocal: const Value(true),
      lastModifiedAt: Value(now),
      originDeviceId: Value(deviceId),
      localSyncStatus: const Value(LocalSyncStatus.pending),
      localUpdatedAt: Value(now),
    ));
  }

  // Stok hareketi ekle — additive ledger (CLAUDE.md §3: silinmez).
  // movementType: 'purchase' (giris) | 'usage' (cikis) | 'adjustment'
  // (manuel) | 'waste' (zayi). quantity her zaman pozitif; isareti
  // movement_type tasir. Stocks.current_quantity sync sonrasi server
  // tarafindan guncellenir; offline iken yerelde de tutariligi
  // korumak istersek StockMovement insertinin yaninda manuel update.
  Future<void> addStockMovement({
    required String drugId,
    required String movementType,
    required double quantity,
    double? unitPrice,
    DateTime? expiryDate,
    String? supplierName,
    String? notes,
  }) async {
    final clinicId = await _storage.readClinicId();
    final deviceId = await _storage.ensureDeviceId();
    final id = _uuid.v4();
    final now = DateTime.now();

    // Drug'a baglı stock satirini bul; yoksa olustur.
    var stock = await (_db.select(_db.stocks)
          ..where((s) =>
              s.drugId.equals(drugId) & s.deletedLocal.equals(false))
          ..limit(1))
        .getSingleOrNull();

    if (stock == null) {
      final stockId = _uuid.v4();
      await _db.into(_db.stocks).insert(StocksCompanion.insert(
            id: stockId,
            drugId: drugId,
            currentQuantity: const Value(0),
            version: const Value(0),
            lastModifiedAt: Value(now),
            originDeviceId: Value(deviceId),
            clinicId: Value(clinicId),
            localSyncStatus: const Value(LocalSyncStatus.pending),
            localUpdatedAt: Value(now),
          ));
      stock = await (_db.select(_db.stocks)
            ..where((s) => s.id.equals(stockId)))
          .getSingle();
    }

    // Yerel istemci de tutarli kalsin diye current_quantity'i guncelle.
    // Sync sonrasi server kanon olur.
    final delta = (movementType == 'purchase' || movementType == 'adjustment')
        ? quantity
        : -quantity;
    final newQty = (stock.currentQuantity + delta).clamp(0, double.infinity);

    await (_db.update(_db.stocks)..where((s) => s.id.equals(stock!.id)))
        .write(StocksCompanion(
      currentQuantity: Value(newQty.toDouble()),
      lastPurchasedAt: movementType == 'purchase'
          ? Value(now)
          : const Value.absent(),
      lastModifiedAt: Value(now),
      originDeviceId: Value(deviceId),
      localSyncStatus: const Value(LocalSyncStatus.pending),
      localUpdatedAt: Value(now),
    ));

    await _db.into(_db.stockMovements).insert(StockMovementsCompanion.insert(
          id: id,
          stockId: stock.id,
          drugId: drugId,
          movementType: movementType,
          quantity: quantity,
          unitPrice: Value(unitPrice),
          expiryDate: Value(expiryDate),
          supplierName: Value(supplierName),
          occurredAt: now,
          notes: Value(notes),
          version: const Value(0),
          lastModifiedAt: Value(now),
          originDeviceId: Value(deviceId),
          clinicId: Value(clinicId),
          localSyncStatus: const Value(LocalSyncStatus.pending),
          localUpdatedAt: Value(now),
        ));
  }

  // Bir drug'in tum stok hareketleri (yeni->eski).
  Stream<List<StockMovementRow>> watchMovements(String drugId) {
    return (_db.select(_db.stockMovements)
          ..where((m) =>
              m.drugId.equals(drugId) & m.deletedLocal.equals(false))
          ..orderBy([
            (m) => OrderingTerm(
                  expression: m.occurredAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }
}

final drugsRepositoryProvider = Provider<DrugsRepository>((ref) {
  return DrugsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(authStorageProvider),
  );
});

final drugsListProvider = StreamProvider<List<DrugWithStock>>((ref) {
  return ref.watch(drugsRepositoryProvider).watchAllWithStock();
});

final drugSearchProvider =
    StreamProvider.family<List<DrugRow>, String>((ref, q) {
  return ref.watch(drugsRepositoryProvider).searchByQuery(q);
});

final drugByIdProvider =
    StreamProvider.family<DrugRow?, String>((ref, id) {
  return ref.watch(drugsRepositoryProvider).watchById(id);
});

final drugMovementsProvider =
    StreamProvider.family<List<StockMovementRow>, String>((ref, drugId) {
  return ref.watch(drugsRepositoryProvider).watchMovements(drugId);
});

final drugStockProvider =
    StreamProvider.family<StockRow?, String>((ref, drugId) {
  return ref.watch(drugsRepositoryProvider).watchStockForDrug(drugId);
});
