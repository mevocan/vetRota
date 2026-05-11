import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';

import '../../config/env.dart';
import '../../data/db/app_database.dart';
import '../../data/medical_records/medical_records_repository.dart';
import '../../data/reports/reports_repository.dart';
import '../medical_records/medical_record_form_screen.dart';
import '../photos/photo_strip_for_animal.dart';
import 'pregnancy_card.dart';

const Color _green = Color(Env.primaryColorHex);

// Hayvan detayi: ust kisimda hayvan ozeti, asagisinda muayene gecmisi.
class AnimalDetailScreen extends ConsumerWidget {
  const AnimalDetailScreen({super.key, required this.animal});

  final AnimalRow animal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mrAsync = ref.watch(medicalRecordsByAnimalProvider(animal.id));
    final title = animal.name?.isNotEmpty == true
        ? animal.name!
        : (animal.earTag?.isNotEmpty == true
            ? 'Kupe ${animal.earTag}'
            : 'Isimsiz hayvan');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2),
            tooltip: 'QR etiket PDF',
            onPressed: () => _downloadQr(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.medical_services_outlined),
        label: const Text('Yeni muayene'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MedicalRecordFormScreen(animal: animal),
            ),
          );
        },
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _AnimalHeader(animal: animal),
          PregnancyCard(animalId: animal.id),
          const Divider(height: 1),
          PhotoStripForAnimal(animalId: animal.id),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Muayene gecmisi',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          mrAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Hata: $e'),
            ),
            data: (records) {
              if (records.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Henuz muayene kaydi yok.',
                    style: TextStyle(color: Colors.black54),
                  ),
                );
              }
              return Column(
                children: [
                  for (final r in records) _MedicalRecordTile(record: r),
                ],
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Future<void> _downloadQr(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('QR PDF indiriliyor...')),
    );
    try {
      final file = await ref.read(reportsRepositoryProvider).fetchAnimalQrPdf(
            animalId: animal.id,
            filenameHint: animal.earTag ?? animal.id,
          );
      await OpenFilex.open(file.path);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
            content: Text('QR indirilemedi: Internet baglantisi gerekli ($e)')),
      );
    }
  }
}

class _AnimalHeader extends StatelessWidget {
  const _AnimalHeader({required this.animal});
  final AnimalRow animal;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('Tur', animal.species),
      if (animal.breed?.isNotEmpty == true) ('Irk', animal.breed!),
      if (animal.gender != null) ('Cinsiyet', animal.gender!),
      if (animal.weightKg != null)
        ('Agirlik', '${animal.weightKg!.toStringAsFixed(0)} kg'),
      if (animal.earTag?.isNotEmpty == true) ('Kupe', animal.earTag!),
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      label,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                  Expanded(child: Text(value)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MedicalRecordTile extends StatelessWidget {
  const _MedicalRecordTile({required this.record});
  final MedicalRecordRow record;

  @override
  Widget build(BuildContext context) {
    final when = record.examinedAt.toLocal().toString().split('.').first;
    final summary = record.chiefComplaint?.isNotEmpty == true
        ? record.chiefComplaint!
        : (record.treatmentNotes ?? record.visitType);
    return ListTile(
      leading: const Icon(Icons.medical_services_outlined),
      title: Text(when),
      subtitle: Text(summary, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: _SyncDot(status: record.localSyncStatus),
    );
  }
}

class _SyncDot extends StatelessWidget {
  const _SyncDot({required this.status});
  final LocalSyncStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      LocalSyncStatus.synced => Colors.green,
      LocalSyncStatus.pending => Colors.orange,
      LocalSyncStatus.failed => Colors.red,
    };
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
