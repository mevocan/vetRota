import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/db/app_database.dart';
import '../../data/medical_records/medical_records_repository.dart';

const Color _green = Color(Env.primaryColorHex);

// M7.5.3: Secili hayvanlara toplu asi/muayene uygula.
// Her hayvan icin ayri MR + drug usage + stock movement uretilir
// (offline-first: tek Drift transaction yerine sirayla — repo zaten
// her create'i kendi transaction'inda yapiyor). Progress gosterilir.
class BulkVaccinationSheet extends ConsumerStatefulWidget {
  const BulkVaccinationSheet({super.key, required this.animals});

  final List<AnimalRow> animals;

  @override
  ConsumerState<BulkVaccinationSheet> createState() =>
      _BulkVaccinationSheetState();
}

class _BulkVaccinationSheetState extends ConsumerState<BulkVaccinationSheet> {
  String? _selectedDrugId;
  final _quantityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  bool _running = false;
  int _doneCount = 0;
  int _failedCount = 0;

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final drugId = _selectedDrugId;
    if (drugId == null) {
      _snack('Once ilac secin.');
      return;
    }
    final qty = double.tryParse(
      _quantityController.text.trim().replaceAll(',', '.'),
    );
    if (qty == null || qty <= 0) {
      _snack('Miktar 0\'dan buyuk olmali.');
      return;
    }

    setState(() {
      _running = true;
      _doneCount = 0;
      _failedCount = 0;
    });

    final repo = ref.read(medicalRecordsRepositoryProvider);
    final now = DateTime.now();
    final notes = _notesController.text.trim();

    for (final a in widget.animals) {
      try {
        await repo.create(
          animalId: a.id,
          examinedAt: now,
          visitType: 'vaccination',
          villageId: a.villageId,
          treatmentNotes: notes.isEmpty ? null : notes,
          drugs: [DrugUsage(drugId: drugId, quantity: qty)],
        );
        setState(() => _doneCount++);
      } catch (_) {
        setState(() => _failedCount++);
      }
    }

    if (!mounted) return;
    Navigator.of(context).pop(_doneCount);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final drugsAsync = ref.watch(localDrugsProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.vaccines, color: _green),
                    const SizedBox(width: 8),
                    Text(
                      'Toplu asi · ${widget.animals.length} hayvan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                drugsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Ilac listesi alinmadi: $e'),
                  data: (drugs) => DropdownButtonFormField<String>(
                    initialValue: _selectedDrugId,
                    decoration: const InputDecoration(
                      labelText: 'Ilac / asi',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final d in drugs)
                        DropdownMenuItem(
                          value: d.id,
                          child: Text(
                            d.name + (d.isVaccine ? ' (asi)' : ''),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: _running
                        ? null
                        : (v) => setState(() => _selectedDrugId = v),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _quantityController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  enabled: !_running,
                  decoration: const InputDecoration(
                    labelText: 'Hayvan basina miktar',
                    helperText: 'Toplam stok düşümü: miktar × hayvan sayisi',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  maxLines: 2,
                  enabled: !_running,
                  decoration: const InputDecoration(
                    labelText: 'Not (opsiyonel)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                if (_running) ...[
                  LinearProgressIndicator(
                    value: widget.animals.isEmpty
                        ? null
                        : (_doneCount + _failedCount) /
                            widget.animals.length,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Islem: $_doneCount basarili'
                    '${_failedCount > 0 ? " · $_failedCount hata" : ""} / ${widget.animals.length}',
                    textAlign: TextAlign.center,
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, 0),
                          child: const Text('Iptal'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: _green,
                          ),
                          icon: const Icon(Icons.check),
                          label: const Text('Uygula'),
                          onPressed: _apply,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
