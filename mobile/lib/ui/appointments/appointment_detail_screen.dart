import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/animals/animals_repository.dart';
import '../../data/appointments/appointments_repository.dart';
import '../medical_records/medical_record_form_screen.dart';
import 'appointment_form_screen.dart';

const Color _green = Color(Env.primaryColorHex);

class AppointmentDetailScreen extends ConsumerWidget {
  const AppointmentDetailScreen({super.key, required this.appointmentId});

  final String appointmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apptAsync = ref.watch(appointmentByIdProvider(appointmentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Randevu detayi'),
        actions: [
          apptAsync.maybeWhen(
            data: (a) => a == null
                ? const SizedBox.shrink()
                : Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Duzenle',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AppointmentFormScreen(
                              existing: a.row,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Sil',
                        onPressed: () => _confirmDelete(context, ref, a.row.id),
                      ),
                    ],
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: apptAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (a) {
          if (a == null) {
            return const Center(child: Text('Randevu bulunamadi'));
          }
          final dt = a.row.scheduledAt;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.event, color: _green),
                          const SizedBox(width: 8),
                          Text(
                            '${dt.day.toString().padLeft(2, '0')}.'
                            '${dt.month.toString().padLeft(2, '0')}.'
                            '${dt.year} '
                            '${dt.hour.toString().padLeft(2, '0')}:'
                            '${dt.minute.toString().padLeft(2, '0')}',
                            style:
                                Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          _StatusChip(status: a.row.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _kv('Hayvan', a.title),
                      if (a.farmerName != null && a.farmerName!.isNotEmpty)
                        _kv('Ciftci', a.farmerName!),
                      if (a.villageName != null && a.villageName!.isNotEmpty)
                        _kv('Koy', a.villageName!),
                      if (a.row.reason != null && a.row.reason!.isNotEmpty)
                        _kv('Sebep', a.row.reason!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _StatusActions(appointment: a.row),
              const SizedBox(height: 12),
              if (a.row.status != 'completed' && a.row.animalId != null)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.medical_services),
                  label: const Text('Muayene baslat'),
                  onPressed: () async {
                    final animal = await ref
                        .read(animalsRepositoryProvider)
                        .watchById(a.row.animalId!)
                        .first;
                    if (animal == null || !context.mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MedicalRecordFormScreen(
                          animal: animal,
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text(k, style: const TextStyle(color: Colors.black54)),
            ),
            Expanded(child: Text(v)),
          ],
        ),
      );

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Randevuyu sil'),
        content: const Text('Bu randevu silinsin mi?'),
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
      await ref.read(appointmentsRepositoryProvider).softDelete(id);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silindi (sync bekliyor)')),
        );
      }
    }
  }
}

class _StatusActions extends ConsumerWidget {
  const _StatusActions({required this.appointment});
  final dynamic appointment; // AppointmentRow

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> setStatus(String s) async {
      await ref
          .read(appointmentsRepositoryProvider)
          .setStatus(appointment.id, s);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Durum: $s (sync bekliyor)')),
        );
      }
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.check_circle, size: 18),
          label: const Text('Tamamlandi'),
          onPressed:
              appointment.status == 'completed' ? null : () => setStatus('completed'),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.play_arrow, size: 18),
          label: const Text('Basla'),
          onPressed: appointment.status == 'in_progress'
              ? null
              : () => setStatus('in_progress'),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.cancel, size: 18),
          label: const Text('Iptal et'),
          onPressed: appointment.status == 'cancelled'
              ? null
              : () => setStatus('cancelled'),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    String label;
    switch (status) {
      case 'completed':
        bg = Colors.green;
        label = 'Tamamlandi';
        break;
      case 'in_progress':
        bg = Colors.blue;
        label = 'Suruyor';
        break;
      case 'cancelled':
        bg = Colors.red;
        label = 'Iptal';
        break;
      case 'no_show':
        bg = Colors.grey;
        label = 'Gelmedi';
        break;
      case 'confirmed':
        bg = Colors.teal;
        label = 'Onayli';
        break;
      default:
        bg = Colors.orange;
        label = 'Planli';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bg.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(color: bg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
