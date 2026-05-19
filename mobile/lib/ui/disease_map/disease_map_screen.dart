import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../config/env.dart';
import '../../data/disease_map/disease_map_repository.dart';

const Color _green = Color(Env.primaryColorHex);

class DiseaseMapScreen extends ConsumerStatefulWidget {
  const DiseaseMapScreen({super.key});

  @override
  ConsumerState<DiseaseMapScreen> createState() => _DiseaseMapScreenState();
}

class _DiseaseMapScreenState extends ConsumerState<DiseaseMapScreen> {
  late DateTime _from;
  late DateTime _to;
  bool _mapView = true; // false = liste

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _to = DateTime(now.year, now.month, now.day);
    _from = _to.subtract(const Duration(days: 30));
  }

  Future<void> _pickFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _from,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      lastDate: _to,
    );
    if (picked != null) setState(() => _from = picked);
  }

  Future<void> _pickTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _to,
      firstDate: _from,
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _to = picked);
  }

  @override
  Widget build(BuildContext context) {
    final query = DiseaseMapQuery(from: _from, to: _to);
    final result = ref.watch(diseaseMapProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hastalik haritasi'),
        actions: [
          IconButton(
            icon: Icon(_mapView ? Icons.list : Icons.map),
            tooltip: _mapView ? 'Liste' : 'Harita',
            onPressed: () => setState(() => _mapView = !_mapView),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(diseaseMapProvider(query)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.event, size: 16),
                    onPressed: _pickFrom,
                    label: Text(_fmt(_from)),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text('—'),
                ),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.event, size: 16),
                    onPressed: _pickTo,
                    label: Text(_fmt(_to)),
                  ),
                ),
              ],
            ),
          ),
          result.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (d) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Card(
                color: _green.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.coronavirus, color: _green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Toplam ${d.totalCases} olgu · '
                          '${d.villages.length} koy',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: result.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text('Veri alinamadi: $e'),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () =>
                            ref.invalidate(diseaseMapProvider(query)),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tekrar dene'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (d) {
                if (d.villages.isEmpty) {
                  return const Center(
                      child: Text('Bu aralikta olgu yok'));
                }
                return _mapView
                    ? _DiseaseMap(villages: d.villages)
                    : _DiseaseList(villages: d.villages);
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.${d.year}';
}

class _DiseaseMap extends StatelessWidget {
  const _DiseaseMap({required this.villages});
  final List<DiseaseVillage> villages;

  @override
  Widget build(BuildContext context) {
    final geo = villages.where((v) => v.hasGeo).toList();
    if (geo.isEmpty) {
      return const Center(
        child: Text('Koy konumlari (lat/lng) eksik — listede gosteriliyor'),
      );
    }
    final maxCases = geo.map((v) => v.caseCount).reduce((a, b) => a > b ? a : b);
    final center = LatLng(
      geo.map((v) => v.lat!).reduce((a, b) => a + b) / geo.length,
      geo.map((v) => v.lng!).reduce((a, b) => a + b) / geo.length,
    );

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 9,
        minZoom: 5,
        maxZoom: 16,
      ),
      children: [
        // Esri uydu (hybrid) - Google Maps Satellite es degerinde, ucretsiz.
        TileLayer(
          urlTemplate:
              'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
          userAgentPackageName: 'tr.com.vetrota.mobile',
          maxNativeZoom: 19,
        ),
        // Yol + yer adi overlay (transparan).
        TileLayer(
          urlTemplate:
              'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}',
          userAgentPackageName: 'tr.com.vetrota.mobile',
          maxNativeZoom: 19,
        ),
        CircleLayer(
          circles: [
            for (final v in geo)
              CircleMarker(
                point: LatLng(v.lat!, v.lng!),
                radius: _radiusFor(v.caseCount, maxCases),
                color: _colorFor(v.caseCount, maxCases)
                    .withValues(alpha: 0.4),
                borderColor: _colorFor(v.caseCount, maxCases),
                borderStrokeWidth: 2,
                useRadiusInMeter: false,
              ),
          ],
        ),
        const RichAttributionWidget(
          alignment: AttributionAlignment.bottomLeft,
          attributions: [
            TextSourceAttribution('Tiles © Esri'),
          ],
        ),
        MarkerLayer(
          markers: [
            for (final v in geo)
              Marker(
                point: LatLng(v.lat!, v.lng!),
                width: 80,
                height: 30,
                child: Container(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${v.villageName} (${v.caseCount})',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  static double _radiusFor(int cases, int max) {
    final scale = max == 0 ? 0.0 : cases / max;
    return 8 + scale * 24; // 8-32 px
  }

  static Color _colorFor(int cases, int max) {
    final scale = max == 0 ? 0.0 : cases / max;
    if (scale > 0.66) return Colors.red;
    if (scale > 0.33) return Colors.orange;
    return Colors.yellow.shade700;
  }
}

class _DiseaseList extends StatelessWidget {
  const _DiseaseList({required this.villages});
  final List<DiseaseVillage> villages;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: villages.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final v = villages[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.red.withValues(alpha: 0.12),
            child: Text(
              '${v.caseCount}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          title: Text(v.villageName),
          subtitle: Text(
            [
              if (v.district != null) v.district!,
              if (v.topKeywords.isNotEmpty) v.topKeywords.join(', '),
            ].join(' · '),
          ),
        );
      },
    );
  }
}
