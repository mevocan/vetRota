import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../api/api_client.dart';

// M5.8: Bugunun raporu — backend'den binary PDF cek, app docs'a kaydet,
// dosya yolunu dondur. Offline ise DioException firlatir; UI yakalayip
// "Internet baglantisi gerekli" mesaji gosterir.
class ReportsRepository {
  ReportsRepository(this._api);

  final ApiClient _api;

  Future<File> fetchDailyPdf(DateTime day) async {
    final dateStr = _yyyyMmDd(day);
    final response = await _api.dio.get<List<int>>(
      '/reports/daily/$dateStr',
      queryParameters: {'format': 'pdf'},
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw const FormatException('PDF bos dondu');
    }
    final dir = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${dir.path}/reports');
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }
    final file = File('${reportsDir.path}/$dateStr.pdf');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  // M7.2: hayvan QR PDF — backend'den ceker, lokal'e indirir, dosyayi
  // dondurur. Internet zorunlu (DioException firlatir, UI yakalar).
  Future<File> fetchAnimalQrPdf({
    required String animalId,
    required String filenameHint,
  }) async {
    final response = await _api.dio.get<List<int>>(
      '/animals/$animalId/qr.pdf',
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw const FormatException('QR PDF bos dondu');
    }
    final dir = await getApplicationDocumentsDirectory();
    final qrDir = Directory('${dir.path}/qr');
    if (!await qrDir.exists()) {
      await qrDir.create(recursive: true);
    }
    final safe = filenameHint.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_');
    final file = File('${qrDir.path}/$safe.pdf');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  String _yyyyMmDd(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$y-$m-$dd';
  }
}

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository(ref.watch(apiClientProvider));
});
