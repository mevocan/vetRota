import 'package:drift/drift.dart';

import '../db/app_database.dart';

// Drift satirlarini server JSON'una cevirir + tersine.
// Her tablo icin "data" alani (server'in beklediği kolonlar) ve pull'da
// gelen JSON'u Companion'a cevirme mantiği burada.
//
// Tarih alanlari ISO 8601 UTC string olarak gönderilir/okunur.

String? _iso(DateTime? d) => d?.toUtc().toIso8601String();
DateTime? _parseIso(Object? v) {
  if (v == null) return null;
  return DateTime.parse(v as String).toLocal();
}

// Laravel'in `decimal` cast'i veya PostgreSQL `numeric` tipi JSON'da
// string ("40.1660000") doner; raw query builder (`DB::table`) Eloquent
// cast'lerini uygulamaz. Bu yuzden hem num hem String kabul eden
// tolerant donusturucu kullaniyoruz.
double? _num(Object? v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

int? _int(Object? v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

// ========== ANIMALS ==========

Map<String, dynamic> animalToData(AnimalRow r) => {
      'farmer_id': r.farmerId,
      'village_id': r.villageId,
      'ear_tag': r.earTag,
      'name': r.name,
      'species': r.species,
      'breed': r.breed,
      'birth_date': _iso(r.birthDate),
      'gender': r.gender,
      'weight_kg': r.weightKg,
      'color': r.color,
      'is_pregnant': r.isPregnant,
      'last_vaccination_at': _iso(r.lastVaccinationAt),
      'status': r.status,
      'status_changed_at': _iso(r.statusChangedAt),
      'status_notes': r.statusNotes,
      'notes': r.notes,
    };

AnimalsCompanion animalFromServer(Map<String, dynamic> j) {
  return AnimalsCompanion(
    id: Value(j['id'] as String),
    farmerId: Value(j['farmer_id'] as String),
    villageId: Value(j['village_id'] as String?),
    earTag: Value(j['ear_tag'] as String?),
    name: Value(j['name'] as String?),
    species: Value(j['species'] as String),
    breed: Value(j['breed'] as String?),
    birthDate: Value(_parseIso(j['birth_date'])),
    gender: Value(j['gender'] as String?),
    weightKg: Value(_num(j['weight_kg'])),
    color: Value(j['color'] as String?),
    isPregnant: Value(j['is_pregnant'] as bool? ?? false),
    lastVaccinationAt: Value(_parseIso(j['last_vaccination_at'])),
    status: Value(j['status'] as String? ?? 'alive'),
    statusChangedAt: Value(_parseIso(j['status_changed_at'])),
    statusNotes: Value(j['status_notes'] as String?),
    notes: Value(j['notes'] as String?),
    version: Value(_int(j['version']) ?? 0),
    lastModifiedAt: Value(_parseIso(j['last_modified_at'])),
    originDeviceId: Value(j['origin_device_id'] as String?),
    clinicId: Value(j['clinic_id'] as String?),
    deletedLocal: Value(j['deleted_at'] != null),
    localSyncStatus: const Value(LocalSyncStatus.synced),
    localUpdatedAt: Value(DateTime.now()),
  );
}

// ========== VILLAGES ==========

Map<String, dynamic> villageToData(VillageRow r) => {
      'name': r.name,
      'district': r.district,
      'city': r.city,
      'lat': r.lat,
      'lng': r.lng,
    };

VillagesCompanion villageFromServer(Map<String, dynamic> j) {
  return VillagesCompanion(
    id: Value(j['id'] as String),
    name: Value(j['name'] as String),
    district: Value(j['district'] as String?),
    city: Value(j['city'] as String?),
    lat: Value(_num(j['lat'])),
    lng: Value(_num(j['lng'])),
    version: Value(_int(j['version']) ?? 0),
    lastModifiedAt: Value(_parseIso(j['last_modified_at'])),
    originDeviceId: Value(j['origin_device_id'] as String?),
    clinicId: Value(j['clinic_id'] as String?),
    deletedLocal: Value(j['deleted_at'] != null),
    localSyncStatus: const Value(LocalSyncStatus.synced),
    localUpdatedAt: Value(DateTime.now()),
  );
}

// ========== FARMERS ==========

Map<String, dynamic> farmerToData(FarmerRow r) => {
      'village_id': r.villageId,
      'first_name': r.firstName,
      'last_name': r.lastName,
      'phone': r.phone,
      'email': r.email,
      'address_detail': r.addressDetail,
      'balance': r.balance,
      'sms_notifications_enabled': r.smsNotificationsEnabled,
      'preferred_sms_language': r.preferredSmsLanguage,
    };

FarmersCompanion farmerFromServer(Map<String, dynamic> j) {
  return FarmersCompanion(
    id: Value(j['id'] as String),
    villageId: Value(j['village_id'] as String?),
    firstName: Value(j['first_name'] as String),
    lastName: Value(j['last_name'] as String),
    phone: Value(j['phone'] as String?),
    email: Value(j['email'] as String?),
    addressDetail: Value(j['address_detail'] as String?),
    balance: Value(_num(j['balance']) ?? 0),
    smsNotificationsEnabled:
        Value(j['sms_notifications_enabled'] as bool? ?? true),
    preferredSmsLanguage:
        Value(j['preferred_sms_language'] as String? ?? 'tr'),
    version: Value(_int(j['version']) ?? 0),
    lastModifiedAt: Value(_parseIso(j['last_modified_at'])),
    originDeviceId: Value(j['origin_device_id'] as String?),
    clinicId: Value(j['clinic_id'] as String?),
    deletedLocal: Value(j['deleted_at'] != null),
    localSyncStatus: const Value(LocalSyncStatus.synced),
    localUpdatedAt: Value(DateTime.now()),
  );
}

// ========== APPOINTMENTS ==========

Map<String, dynamic> appointmentToData(AppointmentRow r) => {
      'farmer_id': r.farmerId,
      'animal_id': r.animalId,
      'village_id': r.villageId,
      'vet_id': r.vetId,
      'scheduled_at': _iso(r.scheduledAt),
      'reason': r.reason,
      'status': r.status,
    };

AppointmentsCompanion appointmentFromServer(Map<String, dynamic> j) {
  return AppointmentsCompanion(
    id: Value(j['id'] as String),
    farmerId: Value(j['farmer_id'] as String?),
    animalId: Value(j['animal_id'] as String?),
    villageId: Value(j['village_id'] as String?),
    vetId: Value(_int(j['vet_id'])),
    scheduledAt: Value(_parseIso(j['scheduled_at'])!),
    reason: Value(j['reason'] as String?),
    status: Value(j['status'] as String? ?? 'scheduled'),
    version: Value(_int(j['version']) ?? 0),
    lastModifiedAt: Value(_parseIso(j['last_modified_at'])),
    originDeviceId: Value(j['origin_device_id'] as String?),
    clinicId: Value(j['clinic_id'] as String?),
    deletedLocal: Value(j['deleted_at'] != null),
    localSyncStatus: const Value(LocalSyncStatus.synced),
    localUpdatedAt: Value(DateTime.now()),
  );
}

// ========== MEDICAL RECORDS ==========

Map<String, dynamic> medicalRecordToData(MedicalRecordRow r) => {
      'animal_id': r.animalId,
      'vet_id': r.vetId,
      'village_id': r.villageId,
      'lat': r.lat,
      'lng': r.lng,
      'visit_type': r.visitType,
      'chief_complaint': r.chiefComplaint,
      'symptoms': r.symptoms,
      'diagnosis_notes': r.diagnosisNotes,
      'treatment_notes': r.treatmentNotes,
      'recommendations': r.recommendations,
      'temperature_celsius': r.temperatureCelsius,
      'weight_kg': r.weightKg,
      'heart_rate': r.heartRate,
      'respiratory_rate': r.respiratoryRate,
      'service_fee': r.serviceFee,
      'examined_at': _iso(r.examinedAt),
      'follow_up_needed': r.followUpNeeded,
      'follow_up_date': _iso(r.followUpDate),
    };

MedicalRecordsCompanion medicalRecordFromServer(Map<String, dynamic> j) {
  return MedicalRecordsCompanion(
    id: Value(j['id'] as String),
    animalId: Value(j['animal_id'] as String),
    vetId: Value(_int(j['vet_id'])),
    villageId: Value(j['village_id'] as String?),
    lat: Value(_num(j['lat'])),
    lng: Value(_num(j['lng'])),
    visitType: Value(j['visit_type'] as String? ?? 'routine'),
    chiefComplaint: Value(j['chief_complaint'] as String?),
    symptoms: Value(j['symptoms'] as String?),
    diagnosisNotes: Value(j['diagnosis_notes'] as String?),
    treatmentNotes: Value(j['treatment_notes'] as String?),
    recommendations: Value(j['recommendations'] as String?),
    temperatureCelsius: Value(_num(j['temperature_celsius'])),
    weightKg: Value(_num(j['weight_kg'])),
    heartRate: Value(_int(j['heart_rate'])),
    respiratoryRate: Value(_int(j['respiratory_rate'])),
    serviceFee: Value(_num(j['service_fee'])),
    examinedAt: Value(_parseIso(j['examined_at'])!),
    followUpNeeded: Value(j['follow_up_needed'] as bool? ?? false),
    followUpDate: Value(_parseIso(j['follow_up_date'])),
    version: Value(_int(j['version']) ?? 0),
    lastModifiedAt: Value(_parseIso(j['last_modified_at'])),
    originDeviceId: Value(j['origin_device_id'] as String?),
    clinicId: Value(j['clinic_id'] as String?),
    deletedLocal: Value(j['deleted_at'] != null),
    localSyncStatus: const Value(LocalSyncStatus.synced),
    localUpdatedAt: Value(DateTime.now()),
  );
}

// ========== MEDICAL RECORD DRUGS ==========

Map<String, dynamic> mrDrugToData(MedicalRecordDrugRow r) => {
      'medical_record_id': r.medicalRecordId,
      'drug_id': r.drugId,
      'quantity': r.quantity,
      'dosage_instructions': r.dosageInstructions,
    };

MedicalRecordDrugsCompanion mrDrugFromServer(Map<String, dynamic> j) {
  return MedicalRecordDrugsCompanion(
    id: Value(j['id'] as String),
    medicalRecordId: Value(j['medical_record_id'] as String),
    drugId: Value(j['drug_id'] as String),
    quantity: Value(_num(j['quantity']) ?? 0),
    dosageInstructions: Value(j['dosage_instructions'] as String?),
    version: Value(_int(j['version']) ?? 0),
    lastModifiedAt: Value(_parseIso(j['last_modified_at'])),
    originDeviceId: Value(j['origin_device_id'] as String?),
    clinicId: Value(j['clinic_id'] as String?),
    deletedLocal: Value(j['deleted_at'] != null),
    localSyncStatus: const Value(LocalSyncStatus.synced),
    localUpdatedAt: Value(DateTime.now()),
  );
}

// ========== MEDICAL RECORD PHOTOS ==========
//
// Push gondermeyiz (binary /sync/photos kanalindan); sadece pull mapper'i.

MedicalRecordPhotosCompanion mrPhotoFromServer(Map<String, dynamic> j) {
  return MedicalRecordPhotosCompanion(
    id: Value(j['id'] as String),
    medicalRecordId: Value(j['medical_record_id'] as String),
    animalId: Value(j['animal_id'] as String),
    serverStoragePath: Value(j['storage_path'] as String?),
    originalFilename: Value(j['original_filename'] as String?),
    mimeType: Value(j['mime_type'] as String?),
    sizeBytes: Value(_int(j['size_bytes'])),
    widthPx: Value(_int(j['width'])),
    heightPx: Value(_int(j['height'])),
    takenAt: Value(_parseIso(j['taken_at'])!),
    caption: Value(j['caption'] as String?),
    uploadStatus: const Value(LocalUploadStatus.uploaded),
    version: Value(_int(j['version']) ?? 0),
    lastModifiedAt: Value(_parseIso(j['last_modified_at'])),
    originDeviceId: Value(j['origin_device_id'] as String?),
    clinicId: Value(j['clinic_id'] as String?),
    deletedLocal: Value(j['deleted_at'] != null),
    localSyncStatus: const Value(LocalSyncStatus.synced),
    localUpdatedAt: Value(DateTime.now()),
  );
}

// ========== DRUGS ==========

Map<String, dynamic> drugToData(DrugRow r) => {
      'name': r.name,
      'active_ingredient': r.activeIngredient,
      'manufacturer': r.manufacturer,
      'drug_type': r.drugType,
      'unit': r.unit,
      'package_size': r.packageSize,
      'is_vaccine': r.isVaccine,
    };

DrugsCompanion drugFromServer(Map<String, dynamic> j) {
  return DrugsCompanion(
    id: Value(j['id'] as String),
    name: Value(j['name'] as String),
    activeIngredient: Value(j['active_ingredient'] as String?),
    manufacturer: Value(j['manufacturer'] as String?),
    drugType: Value(j['drug_type'] as String),
    unit: Value(j['unit'] as String),
    packageSize: Value(_num(j['package_size'])),
    isVaccine: Value(j['is_vaccine'] as bool? ?? false),
    version: Value(_int(j['version']) ?? 0),
    lastModifiedAt: Value(_parseIso(j['last_modified_at'])),
    originDeviceId: Value(j['origin_device_id'] as String?),
    clinicId: Value(j['clinic_id'] as String?),
    deletedLocal: Value(j['deleted_at'] != null),
    localSyncStatus: const Value(LocalSyncStatus.synced),
    localUpdatedAt: Value(DateTime.now()),
  );
}

// ========== STOCKS ==========

Map<String, dynamic> stockToData(StockRow r) => {
      'drug_id': r.drugId,
      'current_quantity': r.currentQuantity,
      'critical_threshold': r.criticalThreshold,
      'reorder_quantity': r.reorderQuantity,
      'last_purchased_at': _iso(r.lastPurchasedAt),
      'earliest_expiry_at': _iso(r.earliestExpiryAt),
    };

StocksCompanion stockFromServer(Map<String, dynamic> j) {
  return StocksCompanion(
    id: Value(j['id'] as String),
    drugId: Value(j['drug_id'] as String),
    currentQuantity: Value(_num(j['current_quantity']) ?? 0),
    criticalThreshold: Value(_num(j['critical_threshold'])),
    reorderQuantity: Value(_num(j['reorder_quantity'])),
    lastPurchasedAt: Value(_parseIso(j['last_purchased_at'])),
    earliestExpiryAt: Value(_parseIso(j['earliest_expiry_at'])),
    version: Value(_int(j['version']) ?? 0),
    lastModifiedAt: Value(_parseIso(j['last_modified_at'])),
    originDeviceId: Value(j['origin_device_id'] as String?),
    clinicId: Value(j['clinic_id'] as String?),
    deletedLocal: Value(j['deleted_at'] != null),
    localSyncStatus: const Value(LocalSyncStatus.synced),
    localUpdatedAt: Value(DateTime.now()),
  );
}

// ========== STOCK MOVEMENTS (LEDGER, append-only) ==========

Map<String, dynamic> stockMovementToData(StockMovementRow r) => {
      'stock_id': r.stockId,
      'drug_id': r.drugId,
      'movement_type': r.movementType,
      'quantity': r.quantity,
      'unit_price': r.unitPrice,
      'expiry_date': _iso(r.expiryDate),
      'supplier_name': r.supplierName,
      'performed_by': r.performedBy,
      'occurred_at': _iso(r.occurredAt),
      'notes': r.notes,
    };

StockMovementsCompanion stockMovementFromServer(Map<String, dynamic> j) {
  return StockMovementsCompanion(
    id: Value(j['id'] as String),
    stockId: Value(j['stock_id'] as String),
    drugId: Value(j['drug_id'] as String),
    movementType: Value(j['movement_type'] as String),
    quantity: Value(_num(j['quantity']) ?? 0),
    unitPrice: Value(_num(j['unit_price'])),
    expiryDate: Value(_parseIso(j['expiry_date'])),
    supplierName: Value(j['supplier_name'] as String?),
    performedBy: Value(_int(j['performed_by'])),
    occurredAt: Value(_parseIso(j['occurred_at'])!),
    notes: Value(j['notes'] as String?),
    version: Value(_int(j['version']) ?? 0),
    lastModifiedAt: Value(_parseIso(j['last_modified_at'])),
    originDeviceId: Value(j['origin_device_id'] as String?),
    clinicId: Value(j['clinic_id'] as String?),
    deletedLocal: Value(j['deleted_at'] != null),
    localSyncStatus: const Value(LocalSyncStatus.synced),
    localUpdatedAt: Value(DateTime.now()),
  );
}
