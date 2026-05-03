import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../auth/auth_storage.dart';
import '../db/app_database.dart';

// PhotosRepository: kameradan veya galeriden alinan fotograflari
// uygulamanin documents dizini altinda kalici saklar, Drift'e metadata
// satiri yazar (uploadStatus=pending). Push queue (M4.5) sonra bu
// satirlari /sync/photos'a gonderir.
class PhotosRepository {
  PhotosRepository(this._db, this._storage);

  final AppDatabase _db;
  final AuthStorage _storage;
  static const _uuid = Uuid();

  Stream<List<MedicalRecordPhotoRow>> watchByAnimal(String animalId) {
    return (_db.select(_db.medicalRecordPhotos)
          ..where((p) =>
              p.animalId.equals(animalId) & p.deletedLocal.equals(false))
          ..orderBy([
            (p) => OrderingTerm(
                  expression: p.takenAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  Stream<List<MedicalRecordPhotoRow>> watchByMedicalRecord(String mrId) {
    return (_db.select(_db.medicalRecordPhotos)
          ..where((p) =>
              p.medicalRecordId.equals(mrId) &
              p.deletedLocal.equals(false))
          ..orderBy([
            (p) => OrderingTerm(expression: p.takenAt),
          ]))
        .watch();
  }

  // image_picker'dan donen XFile'i kalici dizine kopyalar, Drift'e yazar.
  // sourceFile kullanici reseti veya cache temizligi ile silinebilir.
  Future<MedicalRecordPhotoRow> savePickedPhoto({
    required File sourceFile,
    required String medicalRecordId,
    required String animalId,
    required DateTime takenAt,
    String? caption,
  }) async {
    final clinicId = await _storage.readClinicId();
    final deviceId = await _storage.ensureDeviceId();
    final id = _uuid.v4();
    final now = DateTime.now();

    // Hedef yol: <docs>/photos/<animalId>/<id>.<ext>
    final docsDir = await getApplicationDocumentsDirectory();
    final ext = p.extension(sourceFile.path).isNotEmpty
        ? p.extension(sourceFile.path)
        : '.jpg';
    final targetDir = Directory(p.join(docsDir.path, 'photos', animalId));
    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }
    final targetPath = p.join(targetDir.path, '$id$ext');
    final saved = await sourceFile.copy(targetPath);
    final size = await saved.length();

    final companion = MedicalRecordPhotosCompanion.insert(
      id: id,
      medicalRecordId: medicalRecordId,
      animalId: animalId,
      takenAt: takenAt,
      localPath: Value(saved.path),
      mimeType: Value(_mimeFromExt(ext)),
      sizeBytes: Value(size),
      originalFilename: Value(p.basename(sourceFile.path)),
      caption: Value(caption),
      uploadStatus: const Value(LocalUploadStatus.pending),
      version: const Value(0),
      lastModifiedAt: Value(now),
      originDeviceId: Value(deviceId),
      clinicId: Value(clinicId),
      localSyncStatus: const Value(LocalSyncStatus.pending),
      localUpdatedAt: Value(now),
    );
    await _db.into(_db.medicalRecordPhotos).insert(companion);

    return (await (_db.select(_db.medicalRecordPhotos)
              ..where((p) => p.id.equals(id)))
            .getSingle());
  }

  Future<List<MedicalRecordPhotoRow>> pendingUploads() {
    return (_db.select(_db.medicalRecordPhotos)
          ..where((p) =>
              p.uploadStatus.equalsValue(LocalUploadStatus.pending) &
              p.localPath.isNotNull()))
        .get();
  }

  Future<void> markUploaded({
    required String id,
    required String serverStoragePath,
    int? newVersion,
  }) async {
    await (_db.update(_db.medicalRecordPhotos)
          ..where((p) => p.id.equals(id)))
        .write(
      MedicalRecordPhotosCompanion(
        serverStoragePath: Value(serverStoragePath),
        uploadStatus: const Value(LocalUploadStatus.uploaded),
        localSyncStatus: const Value(LocalSyncStatus.synced),
        version:
            newVersion != null ? Value(newVersion) : const Value.absent(),
        lastError: const Value(null),
      ),
    );
  }

  Future<void> markFailed({
    required String id,
    required String reason,
  }) async {
    await (_db.update(_db.medicalRecordPhotos)
          ..where((p) => p.id.equals(id)))
        .write(
      MedicalRecordPhotosCompanion(
        uploadStatus: const Value(LocalUploadStatus.failed),
        localSyncStatus: const Value(LocalSyncStatus.failed),
        lastError: Value(reason),
      ),
    );
  }

  String _mimeFromExt(String ext) {
    switch (ext.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}

final photosRepositoryProvider = Provider<PhotosRepository>((ref) {
  return PhotosRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(authStorageProvider),
  );
});

final photosByAnimalProvider =
    StreamProvider.family<List<MedicalRecordPhotoRow>, String>((ref, animalId) {
  return ref.watch(photosRepositoryProvider).watchByAnimal(animalId);
});

final photosByMedicalRecordProvider =
    StreamProvider.family<List<MedicalRecordPhotoRow>, String>((ref, mrId) {
  return ref.watch(photosRepositoryProvider).watchByMedicalRecord(mrId);
});
