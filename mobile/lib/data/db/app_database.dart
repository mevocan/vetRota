import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';

// Sync durumunu Drift kayitlarinda takip eden enum.
// - synced:   server ile aynidir
// - pending:  yerel olarak yazildi, push edilmesi gerekiyor
// - failed:   son push denemesi reddedildi (validation/conflict),
//             kullanici mudahalesi gerekiyor
enum LocalSyncStatus { synced, pending, failed }

// Mixin: tum sync edilen tablolar bu sutunlari paylasir.
// id'ler client'ta UUID v4 uretilir; auto-increment yok.
mixin SyncColumns on Table {
  TextColumn get id => text()();
  IntColumn get version => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastModifiedAt => dateTime().nullable()();
  TextColumn get originDeviceId => text().nullable()();
  TextColumn get clinicId => text().nullable()();

  IntColumn get localSyncStatus => intEnum<LocalSyncStatus>()
      .withDefault(Constant(LocalSyncStatus.synced.index))();
  DateTimeColumn get localUpdatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get lastError => text().nullable()();
  BoolColumn get deletedLocal =>
      boolean().withDefault(const Constant(false))();
}

@DataClassName('VillageRow')
class Villages extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get district => text().nullable()();
  TextColumn get city => text().nullable()();
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('FarmerRow')
class Farmers extends Table with SyncColumns {
  TextColumn get villageId => text().nullable()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get addressDetail => text().nullable()();
  RealColumn get balance => real().withDefault(const Constant(0))();
  BoolColumn get smsNotificationsEnabled =>
      boolean().withDefault(const Constant(true))();
  TextColumn get preferredSmsLanguage =>
      text().withDefault(const Constant('tr'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AnimalRow')
class Animals extends Table with SyncColumns {
  TextColumn get farmerId => text()();
  TextColumn get villageId => text().nullable()();
  TextColumn get earTag => text().nullable()();
  TextColumn get name => text().nullable()();
  TextColumn get species => text()();
  TextColumn get breed => text().nullable()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get gender => text().nullable()();
  RealColumn get weightKg => real().nullable()();
  TextColumn get color => text().nullable()();
  BoolColumn get isPregnant => boolean().withDefault(const Constant(false))();
  DateTimeColumn get pregnancyStartedAt => dateTime().nullable()();
  DateTimeColumn get expectedBirthDate => dateTime().nullable()();
  TextColumn get pregnancyNotes => text().nullable()();
  DateTimeColumn get lastVaccinationAt => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('alive'))();
  DateTimeColumn get statusChangedAt => dateTime().nullable()();
  TextColumn get statusNotes => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AppointmentRow')
class Appointments extends Table with SyncColumns {
  TextColumn get farmerId => text().nullable()();
  TextColumn get animalId => text().nullable()();
  TextColumn get villageId => text().nullable()();
  IntColumn get vetId => integer().nullable()();
  DateTimeColumn get scheduledAt => dateTime()();
  TextColumn get reason => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('scheduled'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MedicalRecordRow')
class MedicalRecords extends Table with SyncColumns {
  TextColumn get animalId => text()();
  IntColumn get vetId => integer().nullable()();
  TextColumn get villageId => text().nullable()();
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  TextColumn get visitType =>
      text().withDefault(const Constant('routine'))();
  TextColumn get chiefComplaint => text().nullable()();
  TextColumn get symptoms => text().nullable()();
  TextColumn get diagnosisNotes => text().nullable()();
  TextColumn get treatmentNotes => text().nullable()();
  TextColumn get recommendations => text().nullable()();
  RealColumn get temperatureCelsius => real().nullable()();
  RealColumn get weightKg => real().nullable()();
  IntColumn get heartRate => integer().nullable()();
  IntColumn get respiratoryRate => integer().nullable()();
  RealColumn get serviceFee => real().nullable()();
  DateTimeColumn get examinedAt => dateTime()();
  BoolColumn get followUpNeeded =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get followUpDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DrugRow')
class Drugs extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get activeIngredient => text().nullable()();
  TextColumn get manufacturer => text().nullable()();
  TextColumn get drugType => text()();
  TextColumn get unit => text()();
  RealColumn get packageSize => real().nullable()();
  BoolColumn get isVaccine => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('StockRow')
class Stocks extends Table with SyncColumns {
  TextColumn get drugId => text()();
  RealColumn get currentQuantity => real().withDefault(const Constant(0))();
  RealColumn get criticalThreshold => real().nullable()();
  RealColumn get reorderQuantity => real().nullable()();
  DateTimeColumn get lastPurchasedAt => dateTime().nullable()();
  DateTimeColumn get earliestExpiryAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('StockMovementRow')
class StockMovements extends Table with SyncColumns {
  TextColumn get stockId => text()();
  TextColumn get drugId => text()();
  TextColumn get movementType => text()();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real().nullable()();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  TextColumn get supplierName => text().nullable()();
  IntColumn get performedBy => integer().nullable()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MedicalRecordDrugRow')
class MedicalRecordDrugs extends Table with SyncColumns {
  TextColumn get medicalRecordId => text()();
  TextColumn get drugId => text()();
  RealColumn get quantity => real()();
  TextColumn get dosageInstructions => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// M4: muayene fotograflari. localPath cihazdaki dosya, serverStoragePath
// upload sonrasi backend yolu. uploadStatus pending iken push queue
// tarafindan multipart yuklenir.
enum LocalUploadStatus { pending, uploaded, failed }

@DataClassName('MedicalRecordPhotoRow')
class MedicalRecordPhotos extends Table with SyncColumns {
  TextColumn get medicalRecordId => text()();
  TextColumn get animalId => text()();
  TextColumn get localPath => text().nullable()();
  TextColumn get serverStoragePath => text().nullable()();
  TextColumn get originalFilename => text().nullable()();
  TextColumn get mimeType => text().nullable()();
  IntColumn get sizeBytes => integer().nullable()();
  IntColumn get widthPx => integer().nullable()();
  IntColumn get heightPx => integer().nullable()();
  DateTimeColumn get takenAt => dateTime()();
  TextColumn get caption => text().nullable()();
  IntColumn get uploadStatus => intEnum<LocalUploadStatus>()
      .withDefault(Constant(LocalUploadStatus.pending.index))();

  @override
  Set<Column> get primaryKey => {id};
}

// M5: optimize edilmis gunluk rota.
@DataClassName('RouteRow')
class Routes extends Table with SyncColumns {
  IntColumn get vetId => integer()();
  DateTimeColumn get date => dateTime()();
  RealColumn get totalDistanceKm => real().nullable()();
  IntColumn get totalDurationMin => integer().nullable()();
  RealColumn get startLat => real().nullable()();
  RealColumn get startLng => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RouteStopRow')
class RouteStops extends Table with SyncColumns {
  TextColumn get routeId => text()();
  TextColumn get appointmentId => text().nullable()();
  IntColumn get sequence => integer()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  RealColumn get distanceFromPrevKm => real().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get visitedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Sync metadata: cursor + last sync timestamp.
@DataClassName('SyncMetaRow')
class SyncMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

// Conflict gostergeleri (UI'da liste icin).
@DataClassName('SyncConflictRow')
class SyncConflicts extends Table {
  TextColumn get id => text()();
  TextColumn get targetTable => text().named('table_name')();
  TextColumn get recordId => text()();
  TextColumn get resolution => text()();
  IntColumn get serverVersion => integer().nullable()();
  DateTimeColumn get observedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Villages,
  Farmers,
  Animals,
  Appointments,
  MedicalRecords,
  Drugs,
  Stocks,
  StockMovements,
  MedicalRecordDrugs,
  MedicalRecordPhotos,
  Routes,
  RouteStops,
  SyncMeta,
  SyncConflicts,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  // schemaVersion: 1 baslangic, 2 = M4 photos, 3 = M5 routes/route_stops,
  // 4 = M7.1 animals pregnancy alanlari.
  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(medicalRecordPhotos);
          }
          if (from < 3) {
            await m.createTable(routes);
            await m.createTable(routeStops);
          }
          if (from < 4) {
            await m.addColumn(animals, animals.pregnancyStartedAt);
            await m.addColumn(animals, animals.expectedBirthDate);
            await m.addColumn(animals, animals.pregnancyNotes);
          }
        },
      );

  static QueryExecutor _open() {
    return driftDatabase(name: 'vetrota_local');
  }
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
