import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';

// M9.9: Hastalik haritasi — koy bazli olgu yogunlugu. Online cekim,
// sync-disi. Backend M7.6.2.

class DiseaseVillage {
  DiseaseVillage({
    required this.villageId,
    required this.villageName,
    this.district,
    this.lat,
    this.lng,
    required this.caseCount,
    this.topKeywords = const [],
  });
  final String villageId;
  final String villageName;
  final String? district;
  final double? lat;
  final double? lng;
  final int caseCount;
  final List<String> topKeywords;

  bool get hasGeo => lat != null && lng != null;

  factory DiseaseVillage.fromJson(Map<String, dynamic> j) => DiseaseVillage(
        villageId: j['village_id'] as String,
        villageName: j['village_name'] as String,
        district: j['district'] as String?,
        lat: (j['lat'] as num?)?.toDouble(),
        lng: (j['lng'] as num?)?.toDouble(),
        caseCount: (j['case_count'] as num?)?.toInt() ?? 0,
        topKeywords: ((j['top_keywords'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
      );
}

class DiseaseMapResponse {
  DiseaseMapResponse({
    required this.from,
    required this.to,
    this.species,
    required this.totalCases,
    required this.villages,
  });
  final String from;
  final String to;
  final String? species;
  final int totalCases;
  final List<DiseaseVillage> villages;

  factory DiseaseMapResponse.fromJson(Map<String, dynamic> j) =>
      DiseaseMapResponse(
        from: j['from'] as String,
        to: j['to'] as String,
        species: j['species'] as String?,
        totalCases: (j['total_cases'] as num?)?.toInt() ?? 0,
        villages: ((j['villages'] as List?) ?? const [])
            .cast<Map<String, dynamic>>()
            .map(DiseaseVillage.fromJson)
            .toList(),
      );
}

class DiseaseMapQuery {
  const DiseaseMapQuery({this.from, this.to, this.species});
  final DateTime? from;
  final DateTime? to;
  final String? species;

  @override
  bool operator ==(Object other) =>
      other is DiseaseMapQuery &&
      other.from == from &&
      other.to == to &&
      other.species == species;

  @override
  int get hashCode => Object.hash(from, to, species);
}

class DiseaseMapRepository {
  DiseaseMapRepository(this._api);

  final ApiClient _api;

  Future<DiseaseMapResponse> fetch(DiseaseMapQuery q) async {
    final r = await _api.dio.get<Map<String, dynamic>>(
      '/analytics/disease-map',
      queryParameters: {
        if (q.from != null) 'from': _ymd(q.from!),
        if (q.to != null) 'to': _ymd(q.to!),
        if (q.species != null && q.species!.isNotEmpty)
          'species': q.species,
      },
    );
    return DiseaseMapResponse.fromJson(r.data!);
  }

  static String _ymd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

final diseaseMapRepositoryProvider =
    Provider<DiseaseMapRepository>((ref) {
  return DiseaseMapRepository(ref.watch(apiClientProvider));
});

final diseaseMapProvider =
    FutureProvider.family<DiseaseMapResponse, DiseaseMapQuery>((ref, q) {
  return ref.watch(diseaseMapRepositoryProvider).fetch(q);
});
