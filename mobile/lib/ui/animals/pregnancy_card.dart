import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/animals/animals_repository.dart';
import '../../data/animals/pregnancy_helper.dart';
import '../../data/db/app_database.dart';

// M7.1: Hayvan detayinda gebelik durumu karti. Live stream — gebe
// isaretlendigi anda baska yere navigate olmadan guncellenir.
class PregnancyCard extends ConsumerWidget {
  const PregnancyCard({super.key, required this.animalId});

  final String animalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAnimal = ref.watch(animalByIdProvider(animalId));
    return asyncAnimal.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (animal) {
        if (animal == null) return const SizedBox.shrink();
        // Sadece disi hayvanlarda goster (erkek hayvan gebelik kartina
        // ihtiyac duymaz).
        if (animal.gender != 'female') return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: _Card(animal: animal),
        );
      },
    );
  }
}

class _Card extends ConsumerWidget {
  const _Card({required this.animal});
  final AnimalRow animal;

  static const _green = Color(Env.primaryColorHex);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pregnant = animal.isPregnant;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: pregnant ? Colors.pink.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: pregnant ? Colors.pink.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            pregnant ? Icons.pregnant_woman : Icons.female,
            color: pregnant ? Colors.pink : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pregnant ? 'Gebe' : 'Gebe degil',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (pregnant && animal.expectedBirthDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Beklenen dogum: ${_fmtDate(animal.expectedBirthDate!)}',
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 12),
                    ),
                  ),
                if (pregnant && animal.pregnancyStartedAt != null)
                  Text(
                    'Tespit: ${_fmtDate(animal.pregnancyStartedAt!)}',
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                if (pregnant && (animal.pregnancyNotes?.isNotEmpty ?? false))
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      animal.pregnancyNotes!,
                      style: const TextStyle(
                          fontStyle: FontStyle.italic, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _openSheet(context, ref, animal),
            style: TextButton.styleFrom(
              foregroundColor: pregnant ? Colors.pink.shade700 : _green,
            ),
            child: Text(pregnant ? 'Guncelle' : 'Gebe isaretle'),
          ),
        ],
      ),
    );
  }

  void _openSheet(BuildContext context, WidgetRef ref, AnimalRow animal) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PregnancyEditSheet(animal: animal),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.'
      '${d.year}';
}

class _PregnancyEditSheet extends ConsumerStatefulWidget {
  const _PregnancyEditSheet({required this.animal});
  final AnimalRow animal;

  @override
  ConsumerState<_PregnancyEditSheet> createState() => _PregnancyEditSheetState();
}

class _PregnancyEditSheetState extends ConsumerState<_PregnancyEditSheet> {
  late DateTime _startedAt;
  late TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _startedAt = widget.animal.pregnancyStartedAt ?? DateTime.now();
    _notesCtrl = TextEditingController(text: widget.animal.pregnancyNotes ?? '');
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startedAt,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) setState(() => _startedAt = picked);
  }

  Future<void> _save({required bool pregnant}) async {
    final repo = ref.read(animalsRepositoryProvider);
    await repo.setPregnancy(
      animalId: widget.animal.id,
      isPregnant: pregnant,
      startedAt: pregnant ? _startedAt : null,
      notes: pregnant && _notesCtrl.text.trim().isNotEmpty
          ? _notesCtrl.text.trim()
          : null,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pregnant
            ? 'Gebe olarak isaretlendi (sync bekliyor)'
            : 'Gebelik kaldirildi (sync bekliyor)'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expected =
        PregnancyHelper.calculateBirthDate(widget.animal.species, _startedAt);
    final days = PregnancyHelper.gestationDaysFor(widget.animal.species);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Gebelik bilgisi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text('Tur: ${widget.animal.species}  •  Gebelik suresi: $days gun',
                style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tespit tarihi',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  '${_startedAt.day.toString().padLeft(2, '0')}.'
                  '${_startedAt.month.toString().padLeft(2, '0')}.'
                  '${_startedAt.year}',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Beklenen dogum: '
              '${expected.day.toString().padLeft(2, '0')}.'
              '${expected.month.toString().padLeft(2, '0')}.'
              '${expected.year}',
              style: TextStyle(
                  color: Colors.pink.shade700, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Not (opsiyonel)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (widget.animal.isPregnant)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _save(pregnant: false),
                      icon: const Icon(Icons.close),
                      label: const Text('Gebeligi kaldir'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red),
                    ),
                  ),
                if (widget.animal.isPregnant) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _save(pregnant: true),
                    icon: const Icon(Icons.check),
                    label:
                        Text(widget.animal.isPregnant ? 'Guncelle' : 'Kaydet'),
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
