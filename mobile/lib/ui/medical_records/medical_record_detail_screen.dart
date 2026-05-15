import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/db/app_database.dart';
import '../../data/medical_records/medical_records_repository.dart';
import 'medical_record_edit_screen.dart';

const Color _green = Color(Env.primaryColorHex);

class MedicalRecordDetailScreen extends ConsumerWidget {
  const MedicalRecordDetailScreen({super.key, required this.recordId});

  final String recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mrAsync = ref.watch(medicalRecordByIdProvider(recordId));
    final drugsAsync = ref.watch(medicalRecordDrugsProvider(recordId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Muayene detayi'),
        actions: [
          mrAsync.maybeWhen(
            data: (r) => r == null
                ? const SizedBox.shrink()
                : Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Duzenle',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                MedicalRecordEditScreen(record: r),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Sil',
                        onPressed: () =>
                            _confirmDelete(context, ref, r.id),
                      ),
                    ],
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: mrAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (r) {
          if (r == null) {
            return const Center(child: Text('Muayene bulunamadi'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _HeaderCard(record: r),
              const SizedBox(height: 12),
              _NotesCard(record: r),
              const SizedBox(height: 12),
              _VitalsCard(record: r),
              const SizedBox(height: 12),
              drugsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (e, _) => Text('Hata: $e'),
                data: (drugs) => _DrugsCard(drugs: drugs),
              ),
              const SizedBox(height: 12),
              _FooterCard(record: r),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Muayeneyi sil'),
        content: const Text(
          'Bu muayene silinsin mi? Stok hareketleri ve ilac satirlari '
          'ledger\'da kalir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Iptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(medicalRecordsRepositoryProvider).softDelete(id);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silindi (sync bekliyor)')),
        );
      }
    }
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.record});
  final MedicalRecordRow record;

  @override
  Widget build(BuildContext context) {
    final dt = record.examinedAt;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.medical_services, color: _green, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${dt.day.toString().padLeft(2, '0')}.'
                    '${dt.month.toString().padLeft(2, '0')}.${dt.year} '
                    '${dt.hour.toString().padLeft(2, '0')}:'
                    '${dt.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(_visitTypeLabel(record.visitType)),
                ],
              ),
            ),
            if (record.serviceFee != null)
              Text(
                '${record.serviceFee!.toStringAsFixed(0)} TL',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: _green,
                      fontWeight: FontWeight.bold,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  static String _visitTypeLabel(String t) {
    switch (t) {
      case 'emergency':
        return 'Acil';
      case 'vaccination':
        return 'Asilama';
      case 'follow_up':
        return 'Kontrol';
      default:
        return 'Rutin';
    }
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.record});
  final MedicalRecordRow record;

  @override
  Widget build(BuildContext context) {
    final items = <(String, String)>[
      if ((record.chiefComplaint ?? '').isNotEmpty)
        ('Sikayet', record.chiefComplaint!),
      if ((record.symptoms ?? '').isNotEmpty)
        ('Belirtiler', record.symptoms!),
      if ((record.diagnosisNotes ?? '').isNotEmpty)
        ('Tani', record.diagnosisNotes!),
      if ((record.treatmentNotes ?? '').isNotEmpty)
        ('Tedavi', record.treatmentNotes!),
      if ((record.recommendations ?? '').isNotEmpty)
        ('Oneriler', record.recommendations!),
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (k, v) in items) ...[
              Text(k,
                  style: const TextStyle(
                      color: Colors.black54, fontSize: 12)),
              const SizedBox(height: 2),
              Text(v),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _VitalsCard extends StatelessWidget {
  const _VitalsCard({required this.record});
  final MedicalRecordRow record;

  @override
  Widget build(BuildContext context) {
    final hasVitals = record.temperatureCelsius != null ||
        record.weightKg != null ||
        record.heartRate != null ||
        record.respiratoryRate != null;
    if (!hasVitals) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            if (record.temperatureCelsius != null)
              _vital(Icons.thermostat, 'Sicaklik',
                  '${record.temperatureCelsius} °C'),
            if (record.weightKg != null)
              _vital(Icons.monitor_weight, 'Agirlik',
                  '${record.weightKg} kg'),
            if (record.heartRate != null)
              _vital(Icons.favorite, 'Nabiz', '${record.heartRate}'),
            if (record.respiratoryRate != null)
              _vital(Icons.air, 'Solunum', '${record.respiratoryRate}'),
          ],
        ),
      ),
    );
  }

  Widget _vital(IconData icon, String label, String value) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 4),
          Text('$label: '),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      );
}

class _DrugsCard extends StatelessWidget {
  const _DrugsCard({required this.drugs});
  final List<MedicalRecordDrugDetail> drugs;

  @override
  Widget build(BuildContext context) {
    if (drugs.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kullanilan ilaclar',
              style:
                  TextStyle(color: Colors.black54, fontSize: 12),
            ),
            const SizedBox(height: 8),
            for (final d in drugs)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.medication,
                        size: 18, color: _green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(d.drugName)),
                    Text('${d.mrd.quantity} ${d.unit}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FooterCard extends StatelessWidget {
  const _FooterCard({required this.record});
  final MedicalRecordRow record;

  @override
  Widget build(BuildContext context) {
    if (!record.followUpNeeded) return const SizedBox.shrink();
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.event_repeat, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                record.followUpDate == null
                    ? 'Takip gerekli'
                    : 'Takip: '
                        '${record.followUpDate!.day.toString().padLeft(2, '0')}.'
                        '${record.followUpDate!.month.toString().padLeft(2, '0')}.'
                        '${record.followUpDate!.year}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
