import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../auth/auth_storage.dart';
import '../db/app_database.dart';

// M7.3 + M9.7: Ciftci odemesi. Offline yazma: pending kayit, sync push.
// Ledger — silinmez. Yanlislik ters hareket (negatif amount) ile duzeltilir.

class PaymentWithMeta {
  PaymentWithMeta({required this.row, this.farmerName});
  final PaymentRow row;
  final String? farmerName;
}

class PaymentsRepository {
  PaymentsRepository(this._db, this._storage);

  final AppDatabase _db;
  final AuthStorage _storage;
  static const _uuid = Uuid();

  Stream<List<PaymentRow>> watchByFarmer(String farmerId) {
    return (_db.select(_db.payments)
          ..where((p) =>
              p.farmerId.equals(farmerId) & p.deletedLocal.equals(false))
          ..orderBy([
            (p) =>
                OrderingTerm(expression: p.paidAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Stream<List<PaymentWithMeta>> watchAllWithMeta() {
    final q = _db.select(_db.payments).join([
      leftOuterJoin(
          _db.farmers, _db.farmers.id.equalsExp(_db.payments.farmerId)),
    ])
      ..where(_db.payments.deletedLocal.equals(false))
      ..orderBy([
        OrderingTerm(
          expression: _db.payments.paidAt,
          mode: OrderingMode.desc,
        ),
      ]);
    return q.watch().map((rows) => rows.map((r) {
          final p = r.readTable(_db.payments);
          final f = r.readTableOrNull(_db.farmers);
          return PaymentWithMeta(
            row: p,
            farmerName: f == null
                ? null
                : '${f.firstName} ${f.lastName}'.trim(),
          );
        }).toList());
  }

  Future<PaymentRow> create({
    required String farmerId,
    required double amount,
    String method = 'cash',
    DateTime? paidAt,
    String? notes,
  }) async {
    final clinicId = await _storage.readClinicId();
    final deviceId = await _storage.ensureDeviceId();
    final id = _uuid.v4();
    final now = DateTime.now();

    final companion = PaymentsCompanion.insert(
      id: id,
      farmerId: farmerId,
      amount: amount,
      paidAt: paidAt ?? now,
      method: Value(method),
      notes: Value(notes),
      version: const Value(0),
      lastModifiedAt: Value(now),
      originDeviceId: Value(deviceId),
      clinicId: Value(clinicId),
      localSyncStatus: const Value(LocalSyncStatus.pending),
      localUpdatedAt: Value(now),
    );
    await _db.into(_db.payments).insert(companion);
    return (await (_db.select(_db.payments)..where((p) => p.id.equals(id)))
        .getSingle());
  }

  // Ters hareket: yanlis girilen odemeyi iptal etmek icin negatif tutarli
  // yeni satir ekler. Orijinal satir ledger'da kalir.
  Future<void> reverse({
    required PaymentRow original,
    String? notes,
  }) async {
    await create(
      farmerId: original.farmerId,
      amount: -original.amount,
      method: original.method,
      paidAt: DateTime.now(),
      notes: notes ?? 'Iptal: ${original.id.substring(0, 8)}',
    );
  }
}

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return PaymentsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(authStorageProvider),
  );
});

final paymentsByFarmerProvider =
    StreamProvider.family<List<PaymentRow>, String>((ref, farmerId) {
  return ref.watch(paymentsRepositoryProvider).watchByFarmer(farmerId);
});

final paymentsAllProvider = StreamProvider<List<PaymentWithMeta>>((ref) {
  return ref.watch(paymentsRepositoryProvider).watchAllWithMeta();
});
