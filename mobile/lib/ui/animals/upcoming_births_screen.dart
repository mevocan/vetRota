import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/animals/animals_repository.dart';
import '../../data/db/app_database.dart';
import 'animal_detail_screen.dart';

// M7.1: Yaklasan dogumlar (30 gun) — appbar'dan acilir, tarih sirali.
class UpcomingBirthsScreen extends ConsumerWidget {
  const UpcomingBirthsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(upcomingBirthsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Yaklasan dogumlar (30 gun)')),
      body: asyncList.when(
        loading: () => const SizedBox.shrink(),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (rows) {
          if (rows.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  '30 gun icinde dogum beklenen hayvan yok.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) => _BirthTile(animal: rows[i]),
          );
        },
      ),
    );
  }
}

class _BirthTile extends StatelessWidget {
  const _BirthTile({required this.animal});
  final AnimalRow animal;

  @override
  Widget build(BuildContext context) {
    final due = animal.expectedBirthDate;
    final daysLeft =
        due == null ? null : due.difference(DateTime.now()).inDays;
    final title = animal.name?.isNotEmpty == true
        ? animal.name!
        : (animal.earTag?.isNotEmpty == true
            ? 'Kupe ${animal.earTag}'
            : 'Isimsiz hayvan');
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.pink,
        child: Icon(Icons.pregnant_woman, color: Colors.white),
      ),
      title: Text(title),
      subtitle: Text(
        due == null
            ? animal.species
            : '${animal.species} • ${_fmt(due)}'
                '${daysLeft != null ? ' (${daysLeft >= 0 ? '$daysLeft gun kaldi' : 'gecmis'})' : ''}',
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AnimalDetailScreen(animal: animal),
          ),
        );
      },
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.'
      '${d.year}';
}
