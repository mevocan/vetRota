import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/medical_records/medical_records_repository.dart';
import 'medical_record_detail_screen.dart';

const Color _green = Color(Env.primaryColorHex);

class MedicalRecordsListScreen extends ConsumerStatefulWidget {
  const MedicalRecordsListScreen({super.key});

  @override
  ConsumerState<MedicalRecordsListScreen> createState() =>
      _MedicalRecordsListScreenState();
}

class _MedicalRecordsListScreenState
    extends ConsumerState<MedicalRecordsListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(medicalRecordsAllProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Muayeneler')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Ara (hayvan, ciftci, sikayet)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: list.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Hata: $e')),
              data: (rows) {
                final filtered = _filter(rows);
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _query.isEmpty
                          ? 'Henuz muayene yok'
                          : 'Sonuc yok',
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final m = filtered[i];
                    final dt = m.row.examinedAt;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _green.withValues(alpha: 0.15),
                        child: const Icon(
                          Icons.medical_services,
                          color: _green,
                        ),
                      ),
                      title: Text(m.animalLabel),
                      subtitle: Text(
                        [
                          _fmtDate(dt),
                          if (m.farmerName != null &&
                              m.farmerName!.isNotEmpty)
                            m.farmerName!,
                          if (m.row.chiefComplaint != null &&
                              m.row.chiefComplaint!.isNotEmpty)
                            m.row.chiefComplaint!,
                        ].join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: m.row.serviceFee != null
                          ? Text(
                              '${m.row.serviceFee!.toStringAsFixed(0)} TL',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _green,
                              ),
                            )
                          : null,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MedicalRecordDetailScreen(
                            recordId: m.row.id,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<MedicalRecordWithMeta> _filter(List<MedicalRecordWithMeta> rows) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return rows;
    return rows.where((m) {
      final hay = (m.animalName ?? '').toLowerCase().contains(q) ||
          (m.animalEarTag ?? '').toLowerCase().contains(q) ||
          (m.animalSpecies ?? '').toLowerCase().contains(q);
      final fa = (m.farmerName ?? '').toLowerCase().contains(q);
      final co = (m.row.chiefComplaint ?? '').toLowerCase().contains(q) ||
          (m.row.symptoms ?? '').toLowerCase().contains(q);
      return hay || fa || co;
    }).toList();
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.${d.year} '
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';
}
