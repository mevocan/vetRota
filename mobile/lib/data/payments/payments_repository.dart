import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../auth/auth_storage.dart';
import '../db/app_database.dart';

// M7.3: Ciftci odemesi. Offline yazma: pending kayit, sync push gonderir.
// Ledger — silinmez. Yanlislik ters hareket (negatif amount) ile duzeltilir.
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
