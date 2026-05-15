import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/vaccinations/vaccine_schedules_repository.dart';
import 'vaccine_schedule_form_screen.dart';

const Color _green = Color(Env.primaryColorHex);

class VaccineSchedulesListScreen extends ConsumerWidget {
  const VaccineSchedulesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(vaccineSchedulesAllProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Asi planlari')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Yeni plan'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const VaccineScheduleFormScreen(),
          ),
        ),
      ),
      body: list.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (rows) {
          if (rows.isEmpty) {
            return const Center(child: Text('Henuz asi plani yok'));
          }
          return ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) => _ScheduleTile(item: rows[i]),
          );
        },
      ),
    );
  }
}

class _ScheduleTile extends ConsumerWidget {
  const _ScheduleTile({required this.item});
  final VaccineScheduleWithMeta item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dt = item.row.nextDueDate;
    final urgent = item.isOverdue || item.isDueSoon;
    final color = item.isOverdue
        ? Colors.red
        : (item.isDueSoon ? Colors.orange : _green);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(Icons.vaccines, color: color),
      ),
      title: Text(item.drugName ?? 'Bilinmeyen asi'),
      subtitle: Text(
        '${item.animalLabel} · '
        '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.${dt.year}'
        '${item.isOverdue ? " (gecmis)" : item.isDueSoon ? " (yaklasti)" : ""} · '
        'her ${item.row.intervalDays} gunde',
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (v) async {
          final repo = ref.read(vaccineSchedulesRepositoryProvider);
          switch (v) {
            case 'done':
              await repo.markAdministered(item.row.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Yapildi olarak isaretlendi')),
                );
              }
              break;
            case 'disable':
              await repo.setActive(item.row.id, false);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Devre disi birakildi')),
                );
              }
              break;
            case 'delete':
              await repo.softDelete(item.row.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Silindi')),
                );
              }
              break;
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(
              value: 'done', child: Text('Yapildi (siradakine geç)')),
          PopupMenuItem(value: 'disable', child: Text('Devre disi birak')),
          PopupMenuItem(value: 'delete', child: Text('Sil')),
        ],
      ),
      tileColor: urgent ? color.withValues(alpha: 0.05) : null,
    );
  }
}
