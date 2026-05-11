import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_filex/open_filex.dart';

import '../../config/env.dart';
import '../../data/appointments/appointments_repository.dart';
import '../../data/db/app_database.dart';
import '../../data/reports/reports_repository.dart';
import '../../data/routes/routes_repository.dart';
import '../../util/route_optimizer.dart';
import '../medical_records/medical_record_form_screen.dart';

const Color _green = Color(Env.primaryColorHex);

// M5.5-5.8: Bugunun randevulari ekrani.
// - Liste / Harita toggle
// - "Rotayi optimize et" -> nearest-neighbor + Drift'e route + polyline
// - Randevu detayi -> Tamamla / Tamamla + muayene gir
// - "Bugunun raporu" -> backend'den PDF cek, ac
class AppointmentsTodayScreen extends ConsumerStatefulWidget {
  const AppointmentsTodayScreen({super.key});

  @override
  ConsumerState<AppointmentsTodayScreen> createState() =>
      _AppointmentsTodayScreenState();
}

enum _ViewMode { list, map }

class _AppointmentsTodayScreenState
    extends ConsumerState<AppointmentsTodayScreen> {
  _ViewMode _mode = _ViewMode.list;
  bool _busy = false;
  final _mapController = MapController();

  // Optimize'da baslangic noktasi: simdilik klinigin lat/lng'si yok,
  // MVP'de ilk randevunun konumunu start kabul ediyoruz (m5-progress.md'de
  // "klinik veya manuel pin" yaziyor — manuel pin sonra eklenir).
  LatLng? _startPoint(List<AppointmentWithMeta> withGeo) {
    if (withGeo.isEmpty) return null;
    return LatLng(withGeo.first.lat!, withGeo.first.lng!);
  }

  Future<void> _optimize(List<AppointmentWithMeta> appointments) async {
    final withGeo = appointments.where((a) => a.hasGeo).toList();
    if (withGeo.length < 2) {
      _toast('Optimize icin en az 2 lokasyonlu randevu gerekli.');
      return;
    }
    final start = _startPoint(withGeo);
    if (start == null) return;

    final points =
        withGeo.skip(1).map((a) => LatLng(a.lat!, a.lng!)).toList();
    final optimized = nearestNeighbor(start: start, points: points);

    // appointment_id eslestirmek icin LatLng'den indexe gerek var.
    final stops = <
        ({String? appointmentId, double lat, double lng, double distFromPrevKm})>[];
    // Ilk durak start'in kendisi (= ilk randevu).
    stops.add((
      appointmentId: withGeo.first.row.id,
      lat: start.latitude,
      lng: start.longitude,
      distFromPrevKm: 0,
    ));
    for (final s in optimized.stops) {
      final match = withGeo.firstWhere(
        (a) =>
            (a.lat! - s.original.latitude).abs() < 1e-6 &&
            (a.lng! - s.original.longitude).abs() < 1e-6,
      );
      stops.add((
        appointmentId: match.row.id,
        lat: s.original.latitude,
        lng: s.original.longitude,
        distFromPrevKm: s.distanceFromPrevKm,
      ));
    }

    setState(() => _busy = true);
    try {
      final vetId = withGeo.first.row.vetId;
      if (vetId == null) {
        _toast('Vet ID bulunamadi.');
        return;
      }
      await ref.read(routesRepositoryProvider).replaceTodayRoute(
            vetId: vetId,
            startLat: start.latitude,
            startLng: start.longitude,
            stops: stops,
            totalDistanceKm: optimized.totalDistanceKm,
          );
      if (!mounted) return;
      setState(() => _mode = _ViewMode.map);
      _toast(
          'Rota: ${stops.length} durak, ${optimized.totalDistanceKm.toStringAsFixed(1)} km');
    } catch (e) {
      _toast('Optimize hatasi: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _downloadReport() async {
    setState(() => _busy = true);
    try {
      final file = await ref
          .read(reportsRepositoryProvider)
          .fetchDailyPdf(DateTime.now());
      if (!mounted) return;
      _toast('Rapor indirildi: ${file.path.split('/').last}');
      await OpenFilex.open(file.path);
    } catch (e) {
      _toast('Rapor indirilemedi (internet gerekli): $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final asyncAppointments = ref.watch(todayAppointmentsProvider);
    final routeAsync = ref.watch(todayRouteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bugunun randevulari'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Bugunun raporu',
            onPressed: _busy ? null : _downloadReport,
          ),
        ],
      ),
      floatingActionButton: asyncAppointments.maybeWhen(
        data: (list) {
          if (list.where((a) => a.hasGeo).length < 2) {
            return null;
          }
          return FloatingActionButton.extended(
            backgroundColor: _green,
            foregroundColor: Colors.white,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.alt_route),
            label: const Text('Rotayi optimize et'),
            onPressed: _busy ? null : () => _optimize(list),
          );
        },
        orElse: () => null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SegmentedButton<_ViewMode>(
              segments: const [
                ButtonSegment(
                    value: _ViewMode.list,
                    icon: Icon(Icons.list),
                    label: Text('Liste')),
                ButtonSegment(
                    value: _ViewMode.map,
                    icon: Icon(Icons.map),
                    label: Text('Harita')),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() => _mode = s.first),
            ),
          ),
          Expanded(
            child: asyncAppointments.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Center(child: Text('Hata: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return const _EmptyState();
                }
                return _mode == _ViewMode.list
                    ? _AppointmentList(items: list, onTap: _openDetail)
                    : _AppointmentMap(
                        items: list,
                        controller: _mapController,
                        onTap: _openDetail,
                        routeStops: routeAsync.maybeWhen(
                          data: (r) => r,
                          orElse: () => null,
                        ),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(AppointmentWithMeta appt) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => _AppointmentDetailSheet(appt: appt),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_busy, size: 64, color: Colors.black26),
            const SizedBox(height: 16),
            const Text('Bugune randevu yok',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Sync yaptiktan sonra burada gorunur.',
                style: TextStyle(color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  const _AppointmentList({required this.items, required this.onTap});
  final List<AppointmentWithMeta> items;
  final void Function(AppointmentWithMeta) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final a = items[i];
        final completed = a.row.status == 'completed';
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: completed ? Colors.grey : _green,
            child: Text(
              '${a.row.scheduledAt.hour.toString().padLeft(2, '0')}:${a.row.scheduledAt.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
          title: Text(
            a.title,
            style: TextStyle(
              decoration:
                  completed ? TextDecoration.lineThrough : TextDecoration.none,
              color: completed ? Colors.grey : null,
            ),
          ),
          subtitle: Text(a.subtitle.isEmpty ? '—' : a.subtitle),
          trailing: a.hasGeo
              ? const Icon(Icons.place, size: 18, color: Colors.green)
              : const Tooltip(
                  message: 'Konum bilgisi yok',
                  child: Icon(Icons.location_off,
                      size: 18, color: Colors.orange)),
          onTap: () => onTap(a),
        );
      },
    );
  }
}

class _AppointmentMap extends StatelessWidget {
  const _AppointmentMap({
    required this.items,
    required this.controller,
    required this.onTap,
    this.routeStops,
  });
  final List<AppointmentWithMeta> items;
  final MapController controller;
  final void Function(AppointmentWithMeta) onTap;
  final RouteRow? routeStops;

  @override
  Widget build(BuildContext context) {
    final geoItems = items.where((a) => a.hasGeo).toList();
    if (geoItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
              'Hicbir randevuda konum bilgisi yok. Hayvan/koy kayitlarinda lat/lng eksik.'),
        ),
      );
    }

    final center = LatLng(geoItems.first.lat!, geoItems.first.lng!);

    return Consumer(builder: (context, ref, _) {
      // Rota varsa stop sirasi -> polyline + numarali pin.
      List<LatLng> polylinePoints = const [];
      Map<String, int> seqByApptId = const {};
      if (routeStops != null) {
        final stops =
            ref.watch(routeStopsProvider(routeStops!.id)).maybeWhen(
                  data: (s) => s,
                  orElse: () => <RouteStopRow>[],
                );
        polylinePoints = [
          if (routeStops!.startLat != null && routeStops!.startLng != null)
            LatLng(routeStops!.startLat!, routeStops!.startLng!),
          ...stops.map((s) => LatLng(s.lat, s.lng)),
        ];
        seqByApptId = {
          for (final s in stops)
            if (s.appointmentId != null) s.appointmentId!: s.sequence,
        };
      }

      return FlutterMap(
        mapController: controller,
        options: MapOptions(
          initialCenter: center,
          initialZoom: 11,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.vetrota.mobile',
          ),
          if (polylinePoints.length >= 2)
            PolylineLayer(polylines: [
              Polyline(
                points: polylinePoints,
                color: _green,
                strokeWidth: 4,
              ),
            ]),
          MarkerLayer(
            markers: [
              for (final a in geoItems)
                Marker(
                  point: LatLng(a.lat!, a.lng!),
                  width: 36,
                  height: 36,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(a),
                    child: _NumberedPin(
                      sequence: seqByApptId[a.row.id],
                      completed: a.row.status == 'completed',
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
    });
  }
}

class _NumberedPin extends StatelessWidget {
  const _NumberedPin({this.sequence, required this.completed});
  final int? sequence;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final color = completed ? Colors.grey : _green;
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        sequence?.toString() ?? '•',
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}

class _AppointmentDetailSheet extends ConsumerWidget {
  const _AppointmentDetailSheet({required this.appt});
  final AppointmentWithMeta appt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = appt.row.status == 'completed';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appt.title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(appt.subtitle, style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 12),
            Text(
                'Saat: ${appt.row.scheduledAt.hour.toString().padLeft(2, '0')}:${appt.row.scheduledAt.minute.toString().padLeft(2, '0')}'),
            if (appt.row.reason != null && appt.row.reason!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Sebep: ${appt.row.reason}'),
              ),
            const SizedBox(height: 16),
            if (completed)
              const Chip(
                avatar: Icon(Icons.check_circle, color: Colors.white, size: 18),
                label: Text('Tamamlandi',
                    style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.grey,
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Tamamla'),
                      onPressed: () async {
                        await ref
                            .read(appointmentsRepositoryProvider)
                            .markCompleted(appt.row.id);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (appt.row.animalId != null)
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: _green),
                        icon: const Icon(Icons.note_add),
                        label: const Text('Tamamla + muayene'),
                        onPressed: () async {
                          final db = ref.read(appDatabaseProvider);
                          final animal = await (db.select(db.animals)
                                ..where((a) =>
                                    a.id.equals(appt.row.animalId!)))
                              .getSingleOrNull();
                          await ref
                              .read(appointmentsRepositoryProvider)
                              .markCompleted(appt.row.id);
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                          if (animal == null) return;
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  MedicalRecordFormScreen(animal: animal),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
