import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../api/api_client.dart';

// M9.8: Recete listeleme + PDF indirme. Recete tasarim geregi sync-disi
// (CLAUDE.md §3, prescription migration yorumu). Online iken cekilir,
// pending durumu yok.

class PrescriptionFarmer {
  PrescriptionFarmer({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phone,
  });
  final String id;
  final String firstName;
  final String lastName;
  final String? phone;

  String get fullName => '$firstName $lastName'.trim();

  factory PrescriptionFarmer.fromJson(Map<String, dynamic> j) =>
      PrescriptionFarmer(
        id: j['id'] as String,
        firstName: j['first_name'] as String,
        lastName: j['last_name'] as String,
        phone: j['phone'] as String?,
      );
}

class PrescriptionAnimal {
  PrescriptionAnimal({
    required this.id,
    this.name,
    this.earTag,
    this.species,
  });
  final String id;
  final String? name;
  final String? earTag;
  final String? species;

  String get label {
    if (name != null && name!.isNotEmpty) return name!;
    if (earTag != null && earTag!.isNotEmpty) return 'Kupe $earTag';
    return species ?? 'Hayvan';
  }

  factory PrescriptionAnimal.fromJson(Map<String, dynamic> j) =>
      PrescriptionAnimal(
        id: j['id'] as String,
        name: j['name'] as String?,
        earTag: j['ear_tag'] as String?,
        species: j['species'] as String?,
      );
}

class PrescriptionListItem {
  PrescriptionListItem({
    required this.id,
    this.prescriptionNumber,
    required this.medicalRecordId,
    this.farmer,
    this.animal,
    this.vetName,
    this.smsSentAt,
    this.createdAt,
    this.notes,
  });

  final String id;
  final String? prescriptionNumber;
  final String medicalRecordId;
  final PrescriptionFarmer? farmer;
  final PrescriptionAnimal? animal;
  final String? vetName;
  final DateTime? smsSentAt;
  final DateTime? createdAt;
  final String? notes;

  factory PrescriptionListItem.fromJson(Map<String, dynamic> j) =>
      PrescriptionListItem(
        id: j['id'] as String,
        prescriptionNumber: j['prescription_number'] as String?,
        medicalRecordId: j['medical_record_id'] as String,
        farmer: j['farmer'] == null
            ? null
            : PrescriptionFarmer.fromJson(
                (j['farmer'] as Map).cast<String, dynamic>()),
        animal: j['animal'] == null
            ? null
            : PrescriptionAnimal.fromJson(
                (j['animal'] as Map).cast<String, dynamic>()),
        vetName: j['vet_name'] as String?,
        smsSentAt: j['sms_sent_at'] == null
            ? null
            : DateTime.tryParse(j['sms_sent_at'] as String),
        createdAt: j['created_at'] == null
            ? null
            : DateTime.tryParse(j['created_at'] as String),
        notes: j['notes'] as String?,
      );
}

class PrescriptionsRepository {
  PrescriptionsRepository(this._api);

  final ApiClient _api;

  Future<List<PrescriptionListItem>> fetchAll({String? query}) async {
    final response = await _api.dio.get<Map<String, dynamic>>(
      '/prescriptions',
      queryParameters: {
        'per_page': 100,
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      },
    );
    final raw = (response.data?['data'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    return raw.map(PrescriptionListItem.fromJson).toList();
  }

  // Recete PDF'i indir — klinik token'i ile.
  Future<File> downloadPdf(String prescriptionId) async {
    final response = await _api.dio.get<List<int>>(
      '/prescriptions/$prescriptionId/pdf',
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw const FormatException('PDF bos dondu');
    }
    final dir = await getApplicationDocumentsDirectory();
    final outDir = Directory('${dir.path}/prescriptions');
    if (!await outDir.exists()) {
      await outDir.create(recursive: true);
    }
    final file = File('${outDir.path}/$prescriptionId.pdf');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}

final prescriptionsRepositoryProvider =
    Provider<PrescriptionsRepository>((ref) {
  return PrescriptionsRepository(ref.watch(apiClientProvider));
});

// Online tek seferlik cekim — UI ekrani manuel refresh ile cagirir.
final prescriptionsListProvider =
    FutureProvider.family<List<PrescriptionListItem>, String>(
        (ref, query) {
  return ref.watch(prescriptionsRepositoryProvider).fetchAll(query: query);
});
