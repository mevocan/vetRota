import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';

// M7.3: Mobil farmer sorgulari (read-only — Drift'te zaten var, sync
// ile pull edilir). FarmerOwnerCard hayvan sahibini ve bakiyesini gosterir.
class FarmersRepository {
  FarmersRepository(this._db);

  final AppDatabase _db;

  Stream<FarmerRow?> watchById(String id) {
    return (_db.select(_db.farmers)..where((f) => f.id.equals(id)))
        .watchSingleOrNull();
  }
}

final farmersRepositoryProvider = Provider<FarmersRepository>((ref) {
  return FarmersRepository(ref.watch(appDatabaseProvider));
});

final farmerByIdProvider = StreamProvider.family<FarmerRow?, String>((ref, id) {
  return ref.watch(farmersRepositoryProvider).watchById(id);
});
